LOAD DATA
INFILE '/opt/dba_deployment/data/stocks_data_demo.csv'
INTO TABLE stock_user.stocks
INSERT
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
  dummy_id FILLER,                 -- ignore the first CSV column
  symbol,
  trade_date "TO_TIMESTAMP(:trade_date,'YYYY-MM-DD HH24:MI:SS')",
  open,
  low,
  high,
  close,
  volume
)
