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