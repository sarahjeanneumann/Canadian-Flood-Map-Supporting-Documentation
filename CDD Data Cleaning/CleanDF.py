import pandas as pd
import numpy as np

def clean_csv_file(file_path, columns_to_keep, new_columns, column_order, rows_to_delete=None):
    try:
        df = pd.read_csv(file_path)
        
        # Delete rows that are empty or contain only zeros
        if rows_to_delete:
            df.drop(rows_to_delete, inplace=True)
        cleaned_df = df.dropna(how='all')
        cleaned_df = cleaned_df.loc[~(cleaned_df == 0).all(axis=1)]
        
        # keep, delete, and add new columns
        cleaned_df = cleaned_df[columns_to_keep]

        for column in new_columns:
            cleaned_df[column] = None
        
        cleaned_df = cleaned_df[column_order] #Reorder columns

        return cleaned_df
    except Exception as e:
        print(f"Error reading Excel file: {e}")
        return None

# File Cleaning
file_path = '/Users/sarahneumann/Library/CloudStorage/OneDrive-UniversityofCalgary/uc-hal/summer 2023/Coding/CDD_Flood_2010.csv'

# Keep relevant columns
columns_to_keep = ['PLACE', 'EVENT START DATE', 'FATALITIES', 'EVACUATED', 'ESTIMATED TOTAL COST']  # Modify with the column names you want to keep

# Add columns for dataset completion 
new_columns = ['POPULATION', 'IMPACTED REGIONS', 'FLOW MAGNITUDE', 'LEVEL MAGNITUDE', 'MAGNITUDE SOURCE', 'STATIONS', 'COST SOURCE', 
               'NORMALIZED COST', 'NORMALIZED FATALITIES', 'FATALITIES SOURCE', 'NORMALIZED EVACUATED', 'EVACUATED SOURCE']

# Order columns for import into PostgreSQL database
column_order = ['PLACE', 'EVENT START DATE', 'POPULATION', 'IMPACTED REGIONS', 'FLOW MAGNITUDE', 'LEVEL MAGNITUDE', 
                'STATIONS', 'MAGNITUDE SOURCE', 'ESTIMATED TOTAL COST', 'NORMALIZED COST', 'COST SOURCE', 'FATALITIES', 
                'NORMALIZED FATALITIES', 'FATALITIES SOURCE', 'EVACUATED', 'NORMALIZED EVACUATED', 'EVACUATED SOURCE']

cleaned_df = clean_csv_file(file_path, columns_to_keep, new_columns, column_order)

if cleaned_df is not None:
    rows_to_delete = cleaned_df.index[(cleaned_df.isnull() | (cleaned_df == 0)).all(axis=1)].tolist()
    cleaned_df = clean_csv_file(file_path, columns_to_keep, new_columns, column_order, rows_to_delete)
    print(cleaned_df)

    # Write DataFrame to CSV file
    cleaned_df.to_csv('/Users/sarahneumann/Library/CloudStorage/OneDrive-UniversityofCalgary/uc-hal/summer 2023/Coding/Tidy_CDD_Flood_2010.csv', index=False)