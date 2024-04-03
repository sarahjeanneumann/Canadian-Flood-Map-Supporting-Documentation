-- normalized_total_cost = estimated_total_cost * (0.3 * (EXTRACT(YEAR FROM date) - 1900));

-- normalized_evacuated = es.evacuated::NUMERIC / pop.population
-- FROM population AS pop
-- WHERE EXTRACT(YEAR FROM es.date) = pop.year;

-- normalized_fatalities = es.fatalities::NUMERIC / pop.population
-- FROM population AS pop
-- WHERE EXTRACT(YEAR FROM es.date) = pop.year;

-- impact score calcualtion (rank each attribute, then impact score = sum of ranks)
SELECT
    event_id,
    RANK() OVER (ORDER BY normalized_total_cost) AS total_cost_rank,
    RANK() OVER (ORDER BY normalized_fatalities) AS fatalities_rank,
    RANK() OVER (ORDER BY normalized_evacuated) AS evacuated_rank,
    RANK() OVER (ORDER BY magnitude) AS magnitude_rank
FROM events_summary;

SELECT
    event_id,
    total_cost_rank,
    fatalities_rank,
    evacuated_rank,
    magnitude_rank,
    total_cost_rank + fatalities_rank + evacuated_rank + magnitude_rank AS impact_score
FROM (
    SELECT
        event_id,
        RANK() OVER (ORDER BY normalized_total_cost) AS total_cost_rank,
        RANK() OVER (ORDER BY normalized_fatalities) AS fatalities_rank,
        RANK() OVER (ORDER BY normalized_evacuated) AS evacuated_rank,
        RANK() OVER (ORDER BY magnitude) AS magnitude_rank
    FROM events_summary
) ranked_events;

ALTER TABLE events_summary
ADD COLUMN impact_score INTEGER;


UPDATE events_summary AS es
SET impact_score = re.total_cost_rank + re.fatalities_rank + re.evacuated_rank + re.magnitude_rank
FROM (
    SELECT
        event_id,
        RANK() OVER (ORDER BY normalized_total_cost) AS total_cost_rank,
        RANK() OVER (ORDER BY normalized_fatalities) AS fatalities_rank,
        RANK() OVER (ORDER BY normalized_evacuated) AS evacuated_rank,
        RANK() OVER (ORDER BY magnitude) AS magnitude_rank
    FROM events_summary
) AS re
WHERE es.event_id = re.event_id;


UPDATE events_summary AS es
SET impact_score = subquery.total_rank
FROM (
    SELECT
        event_id,
        COALESCE(RANK() OVER (ORDER BY normalized_total_cost), 0)
        + COALESCE(RANK() OVER (ORDER BY normalized_fatalities), 0)
        + COALESCE(RANK() OVER (ORDER BY normalized_evacuated), 0)
        + COALESCE(RANK() OVER (ORDER BY magnitude), 0) AS total_rank
    FROM events_summary
    WHERE normalized_total_cost IS NOT NULL
        AND normalized_fatalities IS NOT NULL
        AND normalized_evacuated IS NOT NULL
        AND magnitude IS NOT NULL
) AS subquery
WHERE es.event_id = subquery.event_id;

UPDATE events_summary AS es
SET impact_score = subquery.impact_score
FROM (
    SELECT
        event_id,
        CASE
            WHEN normalized_total_cost IS NOT NULL
                AND normalized_fatalities IS NOT NULL
                AND normalized_evacuated IS NOT NULL
                AND magnitude IS NOT NULL THEN
                RANK() OVER (ORDER BY normalized_total_cost)
                + RANK() OVER (ORDER BY normalized_fatalities)
                + RANK() OVER (ORDER BY normalized_evacuated)
                + RANK() OVER (ORDER BY magnitude)
            ELSE NULL
        END AS impact_score
    FROM events_summary
) AS subquery
WHERE es.event_id = subquery.event_id;
