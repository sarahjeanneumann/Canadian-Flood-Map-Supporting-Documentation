--normalized total cost calculations
CREATE OR REPLACE FUNCTION calculate_and_update_normalized_cost()
RETURNS TRIGGER AS $$
BEGIN
  -- Calculate the normalized total cost using the formula
  NEW.normalized_total_cost := NEW.estimated_total_cost * (0.3 * (EXTRACT(YEAR FROM NEW.date) - 1900));
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_normalized_cost_trigger
BEFORE INSERT OR UPDATE ON events_summary
FOR EACH ROW
EXECUTE FUNCTION calculate_and_update_normalized_cost();

--normalized fatalities calculations
CREATE OR REPLACE FUNCTION calculate_and_update_normalized_fatalities()
RETURNS TRIGGER AS $$
DECLARE
  event_year INT;
BEGIN
  -- Get the year from the event_date
  event_year := EXTRACT(YEAR FROM NEW.date);
  
  -- Calculate normalized_fatalities as fatalities/population for the corresponding year
  NEW.normalized_fatalities := NEW.fatalities / (
    SELECT population 
    FROM population 
    WHERE year = event_year
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_normalized_fatalities_trigger
BEFORE INSERT OR UPDATE ON events_summary
FOR EACH ROW
EXECUTE FUNCTION calculate_and_update_normalized_fatalities();

--normlaized evacuated calculations
CREATE OR REPLACE FUNCTION calculate_and_update_normalized_evacuated()
RETURNS TRIGGER AS $$
DECLARE event_year INT;
BEGIN
	--Get the year from the event_date
	event_year := EXTRACT(YEAR FROM NEW.date);
	
	--Calculate normalized evacuated as evacuated/population for the corresponding year
	NEW.normalized_evacuated := New.evacuated / (
		SELECT population
		FROM population
		WHERE year = event_year
	);
	RETURN NEW;
END;
$$ LANGUAGE plpgsql

CREATE TRIGGER update_normalized_evacuated_trigger
BEFORE INSERT OR UPDATE ON events_summary
FOR EACH ROW
EXECUTE FUNCTION calculate_and_update_normalized_fatalities();

-- Calculate impact score
CREATE OR REPLACE FUNCTION calculate_and_update_impact_score()
RETURNS TRIGGER AS $$
DECLARE
  rank_magnitude INT;
  rank_fatalities INT;
  rank_evacuated INT;
  rank_total_cost INT;
BEGIN
  -- Check if any of the specified columns are NULL
  IF NEW.magnitude IS NULL OR NEW.normalized_fatalities IS NULL OR NEW.normalized_evacuated IS NULL OR NEW.normalized_total_cost IS NULL THEN
    -- If any column is NULL, set the impact_score to NULL
    NEW.impact_score := NULL;
  ELSE
    -- Calculate ranks for each column
    rank_magnitude := (
      SELECT COUNT(*) + 1
      FROM events_summary
      WHERE magnitude IS NOT NULL AND event_id < NEW.event_id
    );
    
    rank_fatalities := (
      SELECT COUNT(*) + 1
      FROM events_summary
      WHERE normalized_fatalities IS NOT NULL AND event_id < NEW.event_id
    );

    rank_evacuated := (
      SELECT COUNT(*) + 1
      FROM events_summary
      WHERE normalized_evacuated IS NOT NULL AND event_id < NEW.event_id
    );

    rank_total_cost := (
      SELECT COUNT(*) + 1
      FROM events_summary
      WHERE normalized_total_cost IS NOT NULL AND event_id < NEW.event_id
    );

    -- Calculate the impact score as the sum of ranks
    NEW.impact_score := rank_magnitude + rank_fatalities + rank_evacuated + rank_total_cost;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_impact_score_trigger
BEFORE INSERT OR UPDATE ON events_summary
FOR EACH ROW
EXECUTE FUNCTION calculate_and_update_impact_score();


