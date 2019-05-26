#!/usr/bin/env python

"""Script to extract instrument stems from medleydb"""

import logging
logging.basicConfig(format='%(levelname)s: %(message)s', level=logging.INFO)
import os
import shutil
import argparse
from collections import defaultdict
import subprocess

import medleydb as mdb


def get_valid_instruments(min_sources):
    """Get set of instruments with at least min_sources different sources"""
    logging.info('Determining valid instruments...\n')
    multitrack_list = mdb.load_all_multitracks()

    instrument_counts = defaultdict(lambda: 0)
    for track in multitrack_list:
        if not track.has_bleed:
            instruments = set()
            for stem in track.stems:
                instruments.add(stem.instrument)
            for instrument in instruments:
                instrument_counts[instrument] += 1
    logging.debug(str(instrument_counts))
    return {i for i in instrument_counts if instrument_counts[i] >= min_sources}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description="Extract instrument stems from medleydb")
    parser.add_argument('-d', '--destination', type=str, default='./data/train',
                        help='Destination to place instrument files')
    parser.add_argument('-s', '--min_sources', type=int, default=10,
                        help='Minimum number of seperate sources in medleyDB '
                             'for an instrument to be valid')
    parser.add_argument('-i', '--instruments', nargs='*', default=None,
                        help='List of instruments to extract')
    parser.add_argument('-k', '--keep_silence', action='store_true',
                        help="Don't remove silence from audio files")
    args = parser.parse_args()

    if args.instruments:
        valid_instruments = args.instruments
    else:
        valid_instruments = get_valid_instruments(args.min_sources)
    logging.info('Valid instruments: ' + str(valid_instruments) + '\n')

    multitrack_list = mdb.load_all_multitracks()

    for track in multitrack_list:
        if not track.has_bleed:
            for stem in track.stems:
                if stem.instrument in valid_instruments:
                    filename = os.path.basename(stem.file_path)
                    dest = os.path.join(args.destination,
                                        stem.instrument,
                                        filename)

                    # Create directory if necessary
                    try:
                        os.makedirs(os.path.dirname(dest))
                    except OSError:
                        pass
                    if args.keep_silence:
                        logging.info('Copying: ' + str(stem.file_path) + 'n')
                        shutil.copyfile(stem.file_path, dest)
                    else:
                        logging.info('Removing silence from: ' + str(stem.file_path) + '\n')
                        #mdb.sox.rm_silence(stem.file_path, dest, 0.1, 0.1)
                        # Also merge down to 1 channel with -c 1
                        sox_args = ['sox', stem.file_path, '-c', '1', dest, 'silence', '1', '0.1', '0.1%', '-1', '0.1', '0.1%']
                        process_handle = subprocess.Popen(sox_args, stderr=subprocess.PIPE)
