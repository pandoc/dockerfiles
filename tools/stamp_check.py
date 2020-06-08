#!/usr/bin/env python3

import argparse
import difflib
from difflib import unified_diff
from pathlib import Path
from textwrap import dedent
import sys

from pygments import lexers, formatters, highlight

core_crossref_template = dedent(r'''
    # Base #########################################################################
    FROM {base_image} AS {stack}-builder-base
    WORKDIR /app

    # begin(expected-local)
    # TODO: install build deps, gcc, ghc, cabal 3.0+, lua.
    # close(expected-local)

    COPY cabal.root.config /root/.cabal/config
    RUN cabal --version \
      && ghc --version \
      && cabal new-update

    # Builder ######################################################################
    FROM {stack}-builder-base as {stack}-builder
    ARG pandoc_commit=master
    RUN git clone --branch=$pandoc_commit --depth=1 --quiet \
      https://github.com/jgm/pandoc /usr/src/pandoc

    COPY ./{stack}/freeze/pandoc-$pandoc_commit.project.freeze \
      /usr/src/pandoc/cabal.project.freeze

    # Install Haskell dependencies
    WORKDIR /usr/src/pandoc
    # Add pandoc-crossref to project
    ARG without_crossref=
    RUN test -n "$without_crossref" || \
      printf "extra-packages: pandoc-crossref\n" > cabal.project.local;
    RUN cabal new-update \
      && cabal new-build \
        --disable-tests \
        --jobs \
        . pandoc-citeproc \
        $(test -n "$without_crossref" || printf pandoc-crossref)

    RUN find dist-newstyle \
      -name 'pandoc*' -type f -perm -u+x \
      -exec cp '{{}}' /usr/local/bin/ ';'

    # Cabal's exec stripping doesn't seem to work reliably, let's do it here.
    RUN strip /usr/local/bin/pandoc*

    # Core #########################################################################
    FROM {base_image} AS {stack}-core
    ARG pandoc_version=edge
    LABEL maintainer='Albert Krewinkel <albert+pandoc@zeitkraut.de>'
    LABEL org.pandoc.maintainer='Albert Krewinkel <albert+pandoc@zeitkraut.de>'
    LABEL org.pandoc.author "John MacFarlane"
    LABEL org.pandoc.version "$pandoc_version"

    WORKDIR /data
    ENTRYPOINT ["/usr/local/bin/pandoc"]

    COPY --from={stack}-builder \
      /usr/local/bin/pandoc \
      /usr/local/bin/pandoc-citeproc \
      /usr/local/bin/

    # begin(expected-local)
    # TODO: install any runtime dependencies (lua, yaml).
    # close(expected-local)

    # Crossref #####################################################################
    FROM {stack}-core AS {stack}-crossref
    COPY --from={stack}-builder \
      /usr/local/bin/pandoc-crossref \
      /usr/local/bin/
    ''').lstrip()

def code(code: str, lexer_class: str="docker", fmt: str="console"):
    return highlight(
        code,
        lexers.find_lexer_class_by_name(lexer_class)(),
        formatters.get_formatter_by_name(fmt))

def colorize(s: str, ansi_color: str, ansi_fmt: str=None):
    if ansi_fmt:
        prefix = f"{ansi_color};{ansi_fmt}m"
    else:
        prefix = ansi_color
    return f"\033[{prefix}{s}\033[0m"

def exclaim(msg: str):
    return f"{colorize('(!)', '31', '1')} {msg}"

def marker(title):
    return f"# {title} {'#' * (80 - (len(title) + 3))}"

class Section:
    def __init__(self, title):
        self.title = title
        self.marker = marker(title)
        self.lines = []
        self.active = False

        self.pruned_lines = []
        self.prune_idx = 0
        self.prune_map = {}

        self.lineno = 0

        # TODO: poaram this
        self.stack = "ubuntu"
        self.begin_local = f"# begin({self.stack}-local)"
        self.begin_templ = f"# begin(expected-local)"
        self.close_local = f"# close({self.stack}-local)"
        self.close_templ = f"# close(expected-local)"
        self.in_local = False

    def is_marker(self, line):
        return line == self.marker

    def add(self, line: str):
        self.lines.append(line)

        # Skip empty lines for pruned storage.
        if not line:
            pass
        elif line.startswith(self.begin_local) or line.startswith(self.begin_templ):
            self.in_local = True
            self.pruned_lines.append("# [[[ local ]]]")
            self.prune_map[self.prune_idx] = (self.lineno, -1)  # -1 is placeholder
        elif not self.in_local:
            self.pruned_lines.append(line)
        elif line.startswith(self.close_local) or line.startswith(self.close_templ):
            self.in_local = False
            start, _ = self.prune_map[self.prune_idx]
            self.prune_map[self.prune_idx] = (start, self.lineno)
            self.prune_idx += 1

        self.lineno += 1

    def add_line(self, line):
        self.lines.append(line)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Validate template patterns for an image stack.")
    parser.add_argument("cmd",
        help="Command to run.  Options: {%(choices)s}",
        metavar="cmd",
        choices=sorted({"docker", "yaml"}))
    parser.add_argument("stack",
        help="Image stack to validate.  Options: {%(choices)s}",
        metavar="stack",
        choices=sorted({"alpine", "ubuntu"}))
    parser.add_argument("--image",
        help=(
            "Dockerfile to check (only meaningful when cmd=docker).  Default: "
            "'all' checks all associated Dockerfiles.  Options: {%(choices)s}"),
        default="all",
        required=False,
        choices=sorted({"core-crossref", "latex", "all"}))


    args = parser.parse_args()

    repo_root = (Path(__file__).parent / "..").resolve()
    stack_root = repo_root / args.stack
    core_crossref_path = stack_root / "Dockerfile"
    latex_path = stack_root / "latex" / "Dockerfile"

    try:
        # Validate core-crossref image.
        with open(core_crossref_path, "r") as f:
            core_crossref_src = f.read()
    except Exception as e:
        sys.stderr.write(exclaim(
            f"Internal error.  Unable to read {core_crossref_path}: {e}\n"))
        sys.exit(1)

    class CoreCrossrefProto:
        def __init__(self, stack):
            self.stack = stack
            self.base = Section("Base")
            self.builder = Section("Builder")
            self.core = Section("Core")
            self.crossref = Section("Crossref")
            self.sections = [self.base, self.builder, self.core, self.crossref]

            self.active_section = None

        def select(self, section: Section):
            if self.active_section:
                self.active_section.active = False
            self.active_section = section
            if self.active_section:
                self.active_section.active = True

        def build(self, contents):
            skip = False
            for line in contents.splitlines():
                # See if this marker starts a new section.
                for s in self.sections:
                    if s.is_marker(line):
                        self.select(s)
                        continue

                # Skip empty lines (makes comparison easier).
                # if line:
                self.active_section.add_line(line)

            # Prune out any stack specific instructions e.g. apt-get vs apk.
            for s in self.sections:
                pruned_lines = []
                skip = False
                for line in s.lines:
                    if line.startswith(f"# begin({self.stack}-local)"):
                        skip = True
                        pruned_lines.append("# [[[ expected-local ]]]")
                        continue
                    if line.startswith(f"# end({self.stack}-local)"):
                        skip = False
                        continue
                    if not skip:
                        pruned_lines.append(line)

                s.lines = pruned_lines

    def base_image_for_stack(stack: str):
        if stack == "alpine":
            return "asdf"
        elif stack == "ubuntu":
            return "ubuntu:focal"
        raise ValueError(f"base_image_for_stack: '{stack}' not implemented.")

    from typing import Iterable, Optional
    class DockerfileRepr:
        def __init__(self, stack: str, section_labels: Iterable[str], contents: str):
            if len(set(section_labels)) != len(section_labels):
                raise ValueError("section_labels must be unique!")

            if len(section_labels) < 1:
                raise ValueError("At least one section_label required!")

            self.stack = stack
            self.sections = []
            for sl in section_labels:
                self.sections.append(Section(sl))

            self.active_section = None
            self._build(contents)

        def _build(self, contents: str):
            # For convenience, all dockerfiles must start with a marker.
            if not contents.startswith(self.sections[0].marker):
                raise ValueError("`contents` must start with first section:\n"
                                 f"{self.sections[0].marker}")

            # Split out the lines into different sections.
            for line in contents.splitlines():
                # See if this marker starts a new section.
                for s in self.sections:
                    if s.is_marker(line):
                        self.active_section = s
                        break

                self.active_section.add(line)

    class DockerfileComparator:
        def __init__(self, stack: str, section_labels: Iterable[str], template_contents: str, actual_path: Path):
            self.stack = stack
            self.template = DockerfileRepr(stack, section_labels, template_contents)
            self.actual_path = actual_path
            actual_contents = actual_path.read_text()
            self.actual = DockerfileRepr(stack, section_labels, actual_contents)

        def propose_diff(self):
            # Try and inject # begin({stack}-local)...# end({stack}-local) from
            # the `actual` into the `template` and do a full diff.
            any_mismatch = False
            for t_s, a_s in zip(self.template.sections, self.actual.sections):
                if len(t_s.prune_map) != len(a_s.prune_map):
                    any_mismatch = True
                    break

            template_lines = []
            actual_lines = []
            attr = "pruned_lines" if any_mismatch else "lines"
            for t_s, a_s in zip(self.template.sections, self.actual.sections):
                t_lines = [f"{l}\n" for l in getattr(t_s, attr)]
                a_lines = [f"{l}\n" for l in getattr(a_s, attr)]

                for idx, (t_start, t_end) in t_s.prune_map.items():
                    a_start, a_end = a_s.prune_map[idx]
                    t_lines[t_start:t_end+1] = a_lines[a_start:a_end+1]

                template_lines.extend(t_lines)
                actual_lines.extend(a_lines)

                # else:
                #     swap_num = 0
                #     for idx, elem in enumerate(t_s.lines):
                #         if swap_num in t_s.prune_map:
                #             start, end = t_s.prune_map[swap_num]
                #             if idx < start and idx >= end:
                #                 template_lines.append(f"{elem}\n")
                #             else:
                #                 a_start, a_end = a_s.prune_map[swap_num]
                #                 swap_num += 1
                #                 template_lines.extend([f"{l}\n" for l in a_s.lines[a_start:a_end+1]])
                #         else:
                #             template_lines.append(f"{elem}\n")

                #     actual_lines.extend([f"{l}\n" for l in a_s.lines])

            if any_mismatch:
                diff_args = [template_lines, actual_lines, "expected", "actual"]
                sys.stderr.write(exclaim(
                    "Cannot smart-diff: template and actual dockerfile have "
                    "different number of `# begin(distro-local)...# end(distro-local)` "
                    "comment blocks.  Reverting to section-based diffing, the line "
                    "numbers shown will not be valid.\n\n"))
            else:
                rel = self.actual_path.relative_to(repo_root)
                diff_args = [
                    actual_lines,
                    template_lines,
                    # `git apply` needs a/ and b/ in the names
                    str("a" / rel),
                    str("b" / rel)
                ]

            diff = difflib.unified_diff(*diff_args)
            diff_text = "".join(diff)
            if sys.stderr.isatty():
                diff_text = code(diff_text, "diff")
            sys.stderr.write(diff_text)

        def validate(self) -> bool:
            close = []
            for idx in range(len(self.template.sections)):
                close.append(self._close_enough(self.template.sections[idx], self.actual.sections[idx]))

            return all(close)

        def _close_enough(self, expected: Section, actual: Section):
            # difflib needs the newlines back
            # expected_lines = [f"{l}\n" for l in expected.pruned_lines]
            # actual_lines = [f"{l}\n" for l in actual.pruned_lines]
            expected_lines = "\n".join(expected.pruned_lines)
            actual_lines = "\n".join(actual.pruned_lines)
            return next(difflib.unified_diff(expected_lines, actual_lines), None) is None

    class CoreCrossrefRedux(DockerfileComparator):
        def __init__(self, stack: str):
            template = core_crossref_template.format(
                base_image=base_image_for_stack(stack), stack=stack)
            actual_path = (repo_root / stack / "Dockerfile").resolve()
            super().__init__(stack, ["Base", "Builder", "Core", "Crossref"], template, actual_path)

    ccr = CoreCrossrefRedux("ubuntu")
    # import pdb
    # pdb.set_trace()
    if not ccr.validate():
        ccr.propose_diff()
        sys.exit(1)
    sys.exit(0)
    # import pdb
    # pdb.set_trace()

    class CoreCrossref:
        def __init__(self, stack: str):
            self.stack = stack
            self.base_image = base_image_for_stack(self.stack)
            self.template = CoreCrossrefProto(self.stack)
            self.template.build(core_crossref_template.format(
                base_image=self.base_image, stack=self.stack))

            self.src_path = repo_root / self.stack / "Dockerfile"
            with open(self.src_path, "r") as f:
                self.src_contents = f.read()
            self.actual = CoreCrossrefProto(self.stack)
            self.actual.build(self.src_contents)

        def evaluate(self) -> bool:
            # Non-shortcircuiting `all` (we want all checks )
            return all([
                self._starts_with_base_marker(),
                self._all_markers_present(),
                self._close_enough(self.template.base, self.actual.base),
                self._close_enough(self.template.builder, self.actual.builder),
                self._close_enough(self.template.core, self.actual.core),
                self._close_enough(self.template.crossref, self.actual.crossref)
            ])

        def _close_enough(self, expected: Section, actual: Section):
            expected_lines = [f"{l}\n" for l in expected.lines]
            actual_lines = [f"{l}\n" for l in actual.lines]
            dockerfile = str(self.src_path.relative_to(repo_root))
            diff = list(unified_diff(
                expected_lines,
                actual_lines,
                dockerfile + " - expected",
                dockerfile + " - actual"))
            if diff:
                bold = (exclaim("") * 22) + "\n"
                sys.stderr.write(
                    bold +
                    exclaim(f"{expected.title} section unexpected changes:\n") +
                    bold +
                    code("".join(diff), "diff")
                )
                return False

            return True

        def _starts_with_base_marker(self) -> bool:
            if not self.src_contents.startswith(self.template.base.marker):
                sys.stderr.write(exclaim(
                    f"Expected {self.src_path} to start with the line:\n"
                    f"{code(self.base.marker)}"))
                return False

            return True

        def _all_markers_present(self) -> bool:
            for s in self.template.sections:
                if s.marker not in self.src_contents:
                    sys.stderr.write(exclaim(
                        f"{s.title} marker not found.  Expected {core_crossref_path} to "
                        f"contain:\n{code(s.marker)}"))
                    return False

            return True





    doc = CoreCrossref(args.stack)
    if not doc.evaluate():
        sys.exit(1)
