# texlive.profile written on Tue Feb  5 09:43:07 2019 UTC
# It will NOT be updated and reflects only the
# installation profile at installation time.
#
# NOTE: see also alpine/latex.Dockerfile which appends
# `binary_x86_64-linuxmusl 1` to this file, use for non-glibc distributions.
selected_scheme scheme-basic
TEXDIR         /opt/texlive/texdir
TEXMFLOCAL     /opt/texlive/texmf-local
TEXMFSYSVAR    /opt/texlive/texdir/texmf-var
TEXMFSYSCONFIG /opt/texlive/texdir/texmf-config
TEXMFVAR       ~/.texlive/texmf-var
TEXMFCONFIG    ~/.texlive/texmf-config
TEXMFHOME      ~/texmf
instopt_adjustpath 0
instopt_adjustrepo 1
instopt_letter 0
instopt_portable 0
instopt_write18_restricted 1
tlpdbopt_autobackup 1
tlpdbopt_backupdir tlpkg/backups
tlpdbopt_create_formats 1
tlpdbopt_desktop_integration 1
tlpdbopt_file_assocs 1
tlpdbopt_generate_updmap 0
tlpdbopt_install_docfiles 0
tlpdbopt_install_srcfiles 0
tlpdbopt_post_code 1
tlpdbopt_sys_bin /usr/local/bin
tlpdbopt_sys_info /usr/local/share/info
tlpdbopt_sys_man /usr/local/share/man
tlpdbopt_w32_multi_user 1
