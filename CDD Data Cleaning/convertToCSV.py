import pandas as pd

def convert_txt_to_csv(input_file, output_file):
    data = pd.read_csv(input_file, delimiter='\t')  # Read the .txt file using pandas
    data.to_csv(output_file, index=False)  # Convert and save as .csv

# Example usage:
input_file = '/Users/sarahneumann/Library/CloudStorage/OneDrive-UniversityofCalgary/uc-hal/summer 2023/Coding/CDD_Flood_2010.txt'
output_file = '/Users/sarahneumann/Library/CloudStorage/OneDrive-UniversityofCalgary/uc-hal/summer 2023/Coding/CDD_Flood_2010.csv'
convert_txt_to_csv(input_file, output_file)
