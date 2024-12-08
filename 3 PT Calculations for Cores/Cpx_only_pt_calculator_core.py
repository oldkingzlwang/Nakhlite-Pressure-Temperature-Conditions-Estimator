'''
This program is adapted from the documentation of Thermobar (version: 1.0.44)
Please see https://thermobar.readthedocs.io/
Originally created by Penny Wieser and published in volcanica: https://doi.org/10.30909/vol.05.02.349384
'''

import pandas as pd
import Thermobar as pt
import os
pd.options.display.max_columns = None

# Define file paths
current_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.abspath(os.path.join(current_dir, '..'))
main_workbook = os.path.join(parent_dir, 'Nak_pyroxene.xlsx')
input_folder = os.path.join(parent_dir, "2 MC Modeling for Core Compositions")

# Load the main workbook
try:
    excel_file = pd.ExcelFile(main_workbook, engine='openpyxl')
except FileNotFoundError:
    print(f"Error: The file '{main_workbook}' was not found.")
    exit(1)
except Exception as e:
    print(f"An error occurred while reading '{main_workbook}': {e}")
    exit(1)

# Get sheet names
sheet_names = excel_file.sheet_names
print(sheet_names)

# Begin P-T calculations using Thermobar
for sheet in sheet_names:
    output_filename = os.path.join(input_folder, f"Output_EPMA_{sheet}.xlsx")
    try:
        out = pt.import_excel(output_filename, sheet_name="Sheet1")
    except FileNotFoundError:
        print(f"No such a file '{output_filename}' in the specified directory.")
        continue
    except Exception as e:
        print(f"An error occurred while importing '{output_filename}': {e}")
        continue

    Cpxs = out['Cpxs']

    Calc_PT = pt.calculate_cpx_only_press_all_eqs(cpx_comps=Cpxs)

    # Save the results
    writer = pd.ExcelWriter(f"Output_PT_{sheet}.xlsx", engine='openpyxl')
    Calc_PT.to_excel(writer, sheet_name="result")
    writer.close()
    print(f"Successfully calculated P-Ts of {sheet} and saved the results.")
