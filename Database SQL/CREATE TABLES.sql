-- create events summary table 
CREATE TABLE events_summary (
    event_id SERIAL PRIMARY KEY,
    date DATE,
    name VARCHAR(255),
    estimated_total_cost NUMERIC,
    fatalities INTEGER,
    evacuated INTEGER,
    magnitude FLOAT,
    normalized_total_cost NUMERIC,
    normalized_fatalities NUMERIC,
	normalized_evacuated NUMERIC,
    magnitude_source TEXT,
    estimated_cost_source TEXT,
    fatalities_source TEXT,
    evacuated_source TEXT,
	impact_score NUMERIC
);


-- create impacted regions table (connect event_id to events_summary table)
CREATE TABLE impacted_regions (
    event_id INTEGER,
    region_id TEXT
);

-- create population table (for normalization calculations)
CREATE TABLE population (
    year INTEGER PRIMARY KEY,
    population INTEGER
);

COPY population(year, population)
FROM '/Users/sarahneumann/OneDrive - University of Calgary/uc-hal/summer 2023/Coding/Database/canadianPopulation.csv'
DELIMITER ',' CSV HEADER;