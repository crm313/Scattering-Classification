#!/usr/bin/env python

"""Script to move files from train set to test set"""

import logging
logging.basicConfig(format='%(levelname)s: %(message)s', level=logging.INFO)
import os
import shutil
import glob
import argparse
import random


def copy_files(source_dir, dest_dir, location, num):
    """
    Copy one file form each subdirectory in source_dir to corresponding
    subirectories in dest_dir
    """
    subdirs = [name for name in os.listdir(source_dir)
               if os.path.isdir(os.path.join(source_dir, name))]
    for subdir in subdirs:
        files = glob.glob(os.path.join(source_dir, subdir, '*.wav'))
        selected_files = None
        if location == 'random':
            selected_files = random.sample(files, num)
        if location == 'first':
            selected_files = files[:num]
        if location == 'last':
            selected_files = files[-num:]

        for f in selected_files:
            dest = os.path.abspath(os.path.join(dest_dir,
                                   subdir,
                                   os.path.basename(f)))
            # Create directory if necessary
            try:
                os.makedirs(os.path.dirname(dest))
            except OSError:
                pass
            shutil.move(f, dest)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description="Extract instrument stems from medleydb")
    parser.add_argument('-l', '--location', type=str, default='last',
                        help='Location of file to copy (first/last/random)')
    parser.add_argument('-s', '--source_dir', type=str, default='./data/train',
                        help='Directory to copy files from')
    parser.add_argument('-d', '--dest_dir', type=str, default='./data/test',
                        help='Destination to copy files to')
    parser.add_argument('-n', '--num_items', type=int, default=1,
                        help='Number of files to move for each subdirectory')
    args = parser.parse_args()

    copy_files(args.source_dir, args.dest_dir, args.location, args.num_items)
