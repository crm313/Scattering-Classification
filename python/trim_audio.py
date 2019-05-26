#!/usr/bin/env python

"""Script to trime all audio files in a directory to a speficied total length"""

import logging
logging.basicConfig(format='%(levelname)s: %(message)s', level=logging.INFO)
import os
import glob
import argparse
import subprocess


def trim_to_total(source_dir, total_length):
    """
    Copy one file form each subdirectory in source_dir to corresponding
    subirectories in dest_dir
    """
    files = glob.glob(os.path.join(source_dir, '*.wav'))
    file_dur = total_length/len(files)

    for file_path in files:
        name, ext = os.path.splitext(file_path)
        dest_path = '{path}_{dur}s{ext}'.format(
            path=name,
            dur=file_dur,
            ext=ext,
        )
        # Trim file down to file_dur seconds
        sox_args = ['sox', file_path, dest_path, 'trim', '0', str(file_dur)]
        subprocess.call(sox_args, stderr=subprocess.PIPE)
        os.remove(file_path)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description="Extract instrument stems from medleydb")
    parser.add_argument('-s', '--source_dir', type=str, default='./data/train',
                        help='Directory to copy files from')
    parser.add_argument('-l', '--total_length', type=int, default=1,
                        help='Total audio duration (in seconds) to trim files down to')
    args = parser.parse_args()

    subdirs = [name for name in os.listdir(args.source_dir)
               if os.path.isdir(os.path.join(args.source_dir, name))]
    for subdir in subdirs:
        trim_to_total(os.path.join(args.source_dir, subdir), args.total_length)
