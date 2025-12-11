"""
===================================================================================
Filename: clean_synthetic_data.py

Copyright (c) 2025 Keona Gagnier
This software is licensed under the MIT License, located in the root directory
of this project (LICENSE file).
-----------------------------------------------------------------------------------
Author(s): Keona Gagnier
Date Created: Dec 4 2025
Last Modified: December 12 2025

Use of AI: 
Gemini AI was used to help debug and improve the script. 
All AI-generated suggestions were reviewed, verified, and modified by the author 
before inclusion.

Description:
This script is used to ensure the synthetic data produced by the synthesize_data.py
will not violate the constraints and data types of the stocks table in the database.
=====================================================================================
"""

import pandas as pd
import numpy as np

# --- Configuration ---
CSV_FILE = 'stocks_data_demo.csv'
CLEAN_FILE = 'final_stocks_data.csv'
TARGET_ROW_COUNT = 10001

# Define column names based on your database structure and input file
COLUMNS = [
    'DUMMY_ID', 'SYMBOL', 'TRADE_DATE', 'OPEN', 'LOW', 'HIGH', 'CLOSE', 'VOLUME'
]

PRICE_COLUMNS = ['OPEN', 'LOW', 'HIGH', 'CLOSE']
UNIQUE_KEY_COLUMNS = ['SYMBOL', 'TRADE_DATE']

# --- Step 1: Load and Clean Data ---
try:
    df = pd.read_csv(CSV_FILE, header=None, names=COLUMNS)
except FileNotFoundError:
    print(f"Error: The file '{CSV_FILE}' was not found.")
    exit()

print(f"Original Row Count: {len(df)}")

# --- A. Clean and Convert Data Types ---
for col in PRICE_COLUMNS:
    # Remove trailing non-numeric suffixes (e.g., .1, .2)
    df[col] = df[col].astype(str).str.replace(r'\.[0-9]+$', '', regex=True)
    # Convert to numeric, coercing errors to NaN
    df[col] = pd.to_numeric(df[col], errors='coerce').round(4)

# Volume (NUMBER(19)) cleaning
col = 'VOLUME'
df[col] = df[col].astype(str).str.replace(r'\.[0-9]+$', '', regex=True)
df[col] = pd.to_numeric(df[col], errors='coerce')


# --- B. Drop Duplicates ---
df_clean = df.drop_duplicates(subset=UNIQUE_KEY_COLUMNS, keep='first')
current_row_count = len(df_clean)
print(f"Row Count After Cleaning/Deduplication: {current_row_count}")

# ----------------------------------------------------
# 2. PAD: Generate New 'AAPL' Rows to Hit Target
# ----------------------------------------------------

# Calculate the number of rows needed
rows_to_generate = TARGET_ROW_COUNT - current_row_count

if rows_to_generate > 0:
    print(f"Generating {rows_to_generate} new rows for AAPL...")

    # Define the starting timestamp
    start_time = pd.to_datetime('2023-07-03 13:00:00')

    # Generate the timestamps in 5-minute intervals
    timestamps = pd.date_range(
        start=start_time,
        periods=rows_to_generate,
        freq='5min'
    ).strftime('%Y-%m-%d %H:%M:%S')

    # Create the new DataFrame
    data = {
        'DUMMY_ID': range(90000000, 90000000 + rows_to_generate),  # New unique IDs
        'SYMBOL': 'AAPL',
        'TRADE_DATE': timestamps,
        'OPEN': 180.00,  # Synthetic static values
        'LOW': 179.50,
        'HIGH': 180.50,
        'CLOSE': 180.00,
        'VOLUME': 1000
    }
    df_padding = pd.DataFrame(data)

    # Append the new padding data to the cleaned data
    df_final = pd.concat([df_clean, df_padding], ignore_index=True)

    print(f"Final Row Count: {len(df_final)}")
else:
    print("Target row count already met or exceeded. No padding needed.")
    df_final = df_clean


# --- Step 3: Save the Final Data ---
# Export the final data back to a CSV, ensuring no header and no index
df_final.to_csv(CLEAN_FILE, index=False, header=False)

print(f"\nSuccessfully created final data file with {len(df_final)} records in '{CLEAN_FILE}'.")