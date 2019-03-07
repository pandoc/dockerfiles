#!/bin/sh
set -e

cd output
xelatex $1
biber $1
xelatex $1
xelatex $1
