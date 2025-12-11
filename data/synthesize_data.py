"""
===================================================================================
Filename: synthesize_data.py

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
This script is used to synthesize our stock data from Financial Modeling Prep to 
ensure we do not violate their copyright in this
=====================================================================================
"""

import pandas as pd
from sdv.single_table import GaussianCopulaSynthesizer
from sdv.metadata import SingleTableMetadata

real_data = pd.read_csv('stocks_data_demo.csv')

metadata = SingleTableMetadata();
metadata.detect_from_dataframe(data=real_data)

synthesizer = GaussianCopulaSynthesizer(metadata)

synthesizer.fit(real_data)

synthetic_data = synthesizer.sample(num_rows=10000)

synthetic_data.to_csv('synthetic_stocks_data.csv', index=False);