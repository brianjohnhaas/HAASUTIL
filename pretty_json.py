#!/usr/bin/env python3

import sys, os, re
import json


if len(sys.argv) < 2:
    exit("\n\n\tusage: {} input.file.json > pretty.json\n\n".format(sys.argv[0]))

input_file = sys.argv[1]

with open(input_file) as fh:
    input_json = fh.read()

print(json.dumps(json.loads(input_json), indent=4))

sys.exit(0)

