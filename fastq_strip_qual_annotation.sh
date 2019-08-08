#!/bin/sh

perl -lane '$x++; if ($x % 4 == 3) { print "+"; } else { print;}'
