-- Initialize TimescaleDB for financial time series data
-- This script creates tables optimized for financial data analysis

-- Create extension if not exists
CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;

-- Create a schema for financial data
CREATE SCHEMA IF NOT EXISTS financial;

-- Create a table for price data
CREATE TABLE IF NOT EXISTS financial.price_data (
    time TIMESTAMPTZ NOT NULL,
    symbol VARCHAR(20) NOT NULL,
    open DOUBLE PRECISION NULL,
    high DOUBLE PRECISION NULL,
    low DOUBLE PRECISION NULL,
    close DOUBLE PRECISION NULL,
    volume DOUBLE PRECISION NULL,
    source VARCHAR(50) NOT NULL
);

-- Convert to hypertable
SELECT create_hypertable('financial.price_data', 'time', if_not_exists => TRUE);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_price_data_symbol ON financial.price_data (symbol, time DESC);
CREATE INDEX IF NOT EXISTS idx_price_data_source ON financial.price_data (source, time DESC);

-- Create a table for derived indicators
CREATE TABLE IF NOT EXISTS financial.indicators (
    time TIMESTAMPTZ NOT NULL,
    symbol VARCHAR(20) NOT NULL,
    indicator_name VARCHAR(50) NOT NULL,
    value DOUBLE PRECISION NULL,
    parameters JSONB NULL
);

-- Convert to hypertable
SELECT create_hypertable('financial.indicators', 'time', if_not_exists => TRUE);

-- Create indexes for indicators
CREATE INDEX IF NOT EXISTS idx_indicators_symbol_name ON financial.indicators (symbol, indicator_name, time DESC);

-- Create a table for economic data
CREATE TABLE IF NOT EXISTS financial.economic_data (
    time TIMESTAMPTZ NOT NULL,
    indicator VARCHAR(100) NOT NULL,
    value DOUBLE PRECISION NULL,
    region VARCHAR(50) NOT NULL
);

-- Convert to hypertable
SELECT create_hypertable('financial.economic_data', 'time', if_not_exists => TRUE);

-- Create a table for portfolio tracking
CREATE TABLE IF NOT EXISTS financial.portfolio (
    id SERIAL PRIMARY KEY,
    portfolio_name VARCHAR(100) NOT NULL,
    creation_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    description TEXT,
    metadata JSONB
);

-- Create a table for portfolio positions
CREATE TABLE IF NOT EXISTS financial.positions (
    id SERIAL PRIMARY KEY,
    portfolio_id INT REFERENCES financial.portfolio(id),
    symbol VARCHAR(20) NOT NULL,
    quantity DOUBLE PRECISION NOT NULL,
    entry_price DOUBLE PRECISION NOT NULL,
    entry_date TIMESTAMPTZ NOT NULL,
    exit_price DOUBLE PRECISION,
    exit_date TIMESTAMPTZ,
    status VARCHAR(20) NOT NULL DEFAULT 'open',
    metadata JSONB
);

-- Create a table for saved queries/analysis
CREATE TABLE IF NOT EXISTS financial.saved_analysis (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    query TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_run TIMESTAMPTZ,
    parameters JSONB,
    user_id VARCHAR(50)
);

-- Grant privileges to the default user
GRANT ALL PRIVILEGES ON SCHEMA financial TO postgres;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA financial TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA financial TO postgres;

-- Create a simple view for latest prices
CREATE OR REPLACE VIEW financial.latest_prices AS
SELECT DISTINCT ON (symbol) 
    symbol, 
    time, 
    close,
    source
FROM financial.price_data
ORDER BY symbol, time DESC;

-- Add comments for better documentation
COMMENT ON TABLE financial.price_data IS 'Financial market price data with OHLCV values';
COMMENT ON TABLE financial.indicators IS 'Derived technical indicators calculated from price data';
COMMENT ON TABLE financial.economic_data IS 'Economic indicators and statistics by region';
COMMENT ON TABLE financial.portfolio IS 'Portfolio definitions for tracking investments';
COMMENT ON TABLE financial.positions IS 'Individual positions within portfolios';
COMMENT ON TABLE financial.saved_analysis IS 'Saved analysis queries and parameters';

-- Example of creating a continuous aggregate for performance
-- Uncomment to use
/*
CREATE MATERIALIZED VIEW financial.daily_ohlcv
WITH (timescaledb.continuous) AS
SELECT
    time_bucket('1 day', time) AS bucket,
    symbol,
    first(open, time) AS open,
    max(high) AS high,
    min(low) AS low,
    last(close, time) AS close,
    sum(volume) AS volume
FROM financial.price_data
GROUP BY bucket, symbol;

-- Add refresh policy to update every day
SELECT add_continuous_aggregate_policy('financial.daily_ohlcv',
    start_offset => INTERVAL '3 days',
    end_offset => INTERVAL '1 hour',
    schedule_interval => INTERVAL '1 day');
*/