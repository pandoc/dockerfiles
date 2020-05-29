#!/usr/bin/env python3
"""
Convert a dot graph file to link text with uncoded url for Gravizo.

Whitespace is stripped and lines are folded using `;` to reduce lenghth of url
being encoded (speed, and 2000 char max).  Output is printed to `stdout`.
Advise piping to `xclip -selection clipboard`.
"""

import argparse
import sys
from pathlib import Path
from textwrap import dedent
from urllib.parse import quote


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)

    group = parser.add_mutually_exclusive_group()
    group.add_argument("--html", action="store_true", default=True)
    group.add_argument("--markdown", action="store_true", default=False)

    parser.add_argument(
        "graph_file", type=argparse.FileType("r"), help="Input DOT graph file.")

    args = parser.parse_args()

    url_head = "https://g.gravizo.com/svg?"

    contents = []
    for line in args.graph_file:
        contents.append(line.strip())
    contents = ";".join(contents)

    graph = quote(contents)
    url = f"{url_head}{graph}"

    if args.markdown:
        print(f"![repo structure]({url})")
    else:  # args.html
        print(f'<center><img src="{url}" alt="repo structure" /></center>')
