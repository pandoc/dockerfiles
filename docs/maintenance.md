# Maintenance

Overview:

- [Repository Tracking](#repository-tracking)

## Repository Tracking

Goal for repository structure:

<center><img src="https://g.gravizo.com/svg?digraph%20G%20%7B%3Branksep%3D0.75%3Bnode%20%5B%3Bstyle%3D%22rounded%2Cdotted%2Cfilled%22%3Bfontname%3D%22monospace%22%3Bshape%3Drect%3Bwidth%3D3.25%3Bheight%3D2.5%3B%5D%3Bedge%20%5B%3Bdir%3Dnone%3Bstyle%3Dfill%3B%5D%3B%3Blatex%20-%3E%20crossref%20%5Bdir%3Dback%5D%3Btectonic%20-%3E%20crossref%20%5Bdir%3Dback%5D%3Bcrossref%20-%3E%20core%20%5Bdir%3Dback%5D%3B%3Bsubgraph%20cluster_uber%20%7B%3Bstyle%3Drounded%3Bcolor%3Dnone%3Bbgcolor%3Dnone%3B%3Bsubgraph%20cluster_core%20%7B%3Bcore%20%5B%3Blabel%3D%22Core%5Cn%5Cn%22%20%2B%3B%22-%20pandoc%5Cl%22%20%2B%3B%22-%20pandoc-citeproc%5Cl%22%3Bshape%3Dcircle%3Bstyle%3D%22rounded%2Cfilled%22%3Bfillcolor%3Dthistle2%3B%5D%3Bcore_repos%20%5B%3Blabel%3D%22Alpine%3A%5Cl%22%20%2B%3B%22%20%20-%20pandoc/alpine%5Cl%22%20%2B%3B%22%20%20-%20pandoc/core%5Cl%5Cn%22%20%2B%3B%22Azure%20Pipelines%3A%5Cl%22%20%2B%3B%22%20%20-%20pandoc/azp%5Cl%5Cn%22%20%2B%3B%22Ubuntu%3A%5Cl%22%20%2B%3B%22%20%20-%20pandoc/ubuntu%5Cl%22%3Bfillcolor%3Dghostwhite%3B%5D%3B%3Bcore_repos%20-%3E%20core%20%5Bstyle%3Ddotted%5D%3B%7Brank%3Dsame%3B%20core%3B%20core_repos%7D%3B%7D%3B%3Bsubgraph%20cluster_crossref%20%7B%3Bcrossref%20%5B%3Blabel%3D%22Crossref%5Cn%5Cn%22%20%2B%3B%22-%20pandoc%5Cl%22%20%2B%3B%22-%20pandoc-citeproc%5Cl%22%20%2B%3B%22-%20pandoc-crossref%5Cl%22%3Bshape%3Dcircle%3Bstyle%3D%22rounded%2Cfilled%22%3Bfillcolor%3Ddarkseagreen2%3B%5D%3B%3Bcrossref_repos%20%5B%3Blabel%3D%22Alpine%3A%5Cl%22%20%2B%3B%22%20%20-%20pandoc/alpine-crossref%5Cl%22%20%2B%3B%22%20%20-%20pandoc/crossref%5Cl%5Cn%22%20%2B%3B%22Azure%20Pipelines%3A%5Cl%22%20%2B%3B%22%20%20-%20pandoc/azp-crossref%5Cl%5Cn%22%20%2B%3B%22Ubuntu%3A%5Cl%22%20%2B%3B%22%20%20-%20pandoc/ubuntu-crossref%5Cl%22%3Bfillcolor%3Dghostwhite%3B%5D%3B%3Bcrossref_repos%20-%3E%20crossref%20%5Bstyle%3Ddotted%5D%3B%7Brank%3Dsame%3B%20crossref%3B%20crossref_repos%7D%3B%7D%3Bsubgraph%20cluster_xref_children%20%7B%3Bsubgraph%20cluster_latex%20%7B%3Blatex%20%5B%3Blabel%3D%22LaTeX%5Cn%5Cn%22%20%2B%3B%22-%20pandoc%5Cl%22%20%2B%3B%22-%20pandoc-citeproc%5Cl%22%20%2B%3B%22-%20pandoc-crossref%5Cl%22%20%2B%3B%22-%20Minimal%20LaTeX%5Cl%22%3Bshape%3Dcircle%3Bstyle%3D%22rounded%2Cfilled%22%3Bfillcolor%3Dbisque%3B%5D%3Blatex_repos%20%5B%3Blabel%3D%22Alpine%3A%5Cl%22%20%2B%3B%22%20%20-%20pandoc/alpine-latex%5Cl%22%20%2B%3B%22%20%20-%20pandoc/latex%5Cl%5Cn%22%20%2B%3B%22Azure%20Pipelines%3A%5Cl%22%20%2B%3B%22%20%20-%20pandoc/azp-latex%5Cl%5Cn%22%20%2B%3B%22Ubuntu%3A%5Cl%22%20%2B%3B%22%20%20-%20pandoc/ubuntu-latex%5Cl%22%3Bfillcolor%3Dghostwhite%3B%5D%3B%3Blatex_repos%20-%3E%20latex%20%5Bstyle%3Ddotted%5D%3B%7Brank%3Dsame%3B%20latex%3B%20latex_repos%7D%3B%7D%3Bsubgraph%20cluster_tectonic%20%7B%3Btectonic%20%5B%3Blabel%3D%22Tectonic%5Cn%5Cn%22%20%2B%3B%22-%20pandoc%5Cl%22%20%2B%3B%22-%20pandoc-citeproc%5Cl%22%20%2B%3B%22-%20pandoc-crossref%5Cl%22%20%2B%3B%22-%20tectonic%5Cl%22%3Bshape%3Dcircle%3Bstyle%3D%22rounded%2Cfilled%22%3Bfillcolor%3Dazure2%3B%5D%3Btectonic_repos%20%5B%3Blabel%3D%22Alpine%3A%5Cl%22%20%2B%3B%22%20%20-%20pandoc/alpine-tectonic%5Cl%22%20%2B%3B%22%20%20-%20pandoc/tectonic%5Cl%5Cn%22%20%2B%3B%22Azure%20Pipelines%3A%5Cl%22%20%2B%3B%22%20%20-%20pandoc/azp-tectonic%5Cl%5Cn%22%20%2B%3B%22Ubuntu%3A%5Cl%22%20%2B%3B%22%20%20-%20pandoc/ubuntu-tectonic%5Cl%22%3Bfillcolor%3Dghostwhite%3B%5D%3B%3Btectonic_repos%20-%3E%20tectonic%20%5Bstyle%3Ddotted%5D%3B%7Brank%3Dsame%3B%20tectonic%3B%20tectonic_repos%7D%3B%7D%3B%7D%3B%7D%3B%7D" alt="repo structure" /></center>

Complete:

- [ ] Core:
    - [ ] Alpine:
        - [ ] `pandoc/alpine`
        - [x] `pandoc/core`
    - [ ] Azure Pipelines: `pandoc/azp`
    - [ ] Ubuntu: `pandoc/ubuntu`
- [ ] Crossref:
    - [ ] Alpine:
        - [ ] `pandoc/alpine-crossref`
        - [ ] `pandoc/crossref`
    - [ ] Azure Pipelines: `pandoc/azp-crossref`
    - [ ] Ubuntu: `pandoc/ubuntu-crossref`
- [ ] LaTeX:
    - [ ] Alpine:
        - [ ] `pandoc/alpine-latex`
        - [x] `pandoc/latex`
    - [ ] Azure Pipelines: `pandoc/azp-latex`
    - [ ] Ubuntu: `pandoc/ubuntu-latex`
- [ ] Tectonic:
    - [ ] Alpine:
        - [ ] `pandoc/alpine-tectonic`
        - [x] `pandoc/tectonic`
    - [ ] Azure Pipelines: `pandoc/azp-tectonic`
    - [ ] Ubuntu: `pandoc/ubuntu-tectonic`
