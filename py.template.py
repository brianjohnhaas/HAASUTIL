#!/usr/bin/env python
# encoding: utf-8

from __future__ import (absolute_import, division,
                        print_function, unicode_literals)
import os, sys, re
import logging
import argparse

FORMAT = "%(asctime)-15s: %(message)s"
logging.basicConfig(stream=sys.stderr, format=FORMAT, level=logging.INFO)
logger = logging.getLogger(__name__)



def main():

    parser = argparse.ArgumentParser(description="__add_descr__", formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    
    parser.add_argument("--my_opt", dest="__opt_name__", type=str, default="", required=True, help="__opt_help__")

    parser.add_argument("--my_TorF", dest="__opt_name2__", required=False, action="store_true", default=False, help="__opt_help__")

    parser.add_argument("--debug", required=False, action="store_true", default=False, help="debug mode")

    args = parser.parse_args()

    if args.debug:
        logger.setLevel(logging.DEBUG)      
    

 
####################
 
if __name__ == "__main__":
    main()
