#!/usr/bin/env python3
"""
tracker.py

Reads a YREC `.track` file into a pandas DataFrame.

This function scans for the last `#Version` line in the file 
and skips all preceding lines before reading the actual data table.
"""

import pandas as pd


def tracker(filepath):
    """
    Reads a YREC .track file into a pandas DataFrame.

    Parameters
    ----------
    filepath : str
        Full path to the .track file.

    Returns
    -------
    pd.DataFrame
        The track data read from the file.
    """

    # Step 1: Create a list to store the line numbers where '#Version' appears.
    start = []

    # Step 2: Open the file for reading.
    with open(filepath, 'r') as fp:
        # Step 3: Read all lines into memory.
        lines = fp.readlines()

        # Step 4: Loop over each line with its index.
        for idx, row in enumerate(lines):
            # Step 5: If '#Version' is found in the line, store its index.
            if '#Version' in row:
                start.append(idx)

    # Step 6: If no '#Version' line is found, raise an error.
    if not start:
        raise ValueError(f"No '#Version' line found in file: {filepath}")

    # Step 7: The data table starts right after the last '#Version' line.
    skiprows = start[-1] + 1

    # Step 8: Use pandas to read the file into a DataFrame, skipping metadata lines.
    track = pd.read_csv(
        filepath,
        header='infer',            # Automatically detect header from first data row
        skiprows=skiprows,          # Skip lines before data starts
        sep=r'\s+',                 # Split on any whitespace
        float_precision='legacy'    # Maintain original float precision
    )

    # Step 9: Return the resulting DataFrame.
    return track


# Example usage (uncomment for testing):
# df = tracker("/path/to/file.track")
# print(df.head())
