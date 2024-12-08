'''
This code is modified from Single_OutPut_Predictor.ipynb (Mónica Ágreda-López et al., 2024 C & G)
Downloaded from https://github.com/magredal/Enhancing-ML-Thermobarometry-for-Clinopyroxene-Bearing-Magmas/ in November 2024
This code can only be used in the purpose of this study. For any other utilization,
please download the original code from the website above.
'''

import numpy as np
import pandas as pd
import json
import onnxruntime as rt
import scipy.stats as st
from sklearn.metrics import r2_score
import matplotlib.pyplot as plt
from sklearn.metrics import mean_squared_error as RMSE
import Thermobar as pt
from ML_PT_Pyworkflow_r import *

import warnings
import os
warnings.filterwarnings('ignore')

pd.options.display.max_columns = None

def Agreda_Lopez_cpx_only_calculator(df):
    model = 'cpx_only'  # 'cpx_only' or 'cpx_liquid'
    output = 'Temperature'  # 'Temperature' or 'Pressure'
    Elements_Cpx = ['SiO2_Cpx', 'TiO2_Cpx', 'Al2O3_Cpx', 'FeOt_Cpx', 'MgO_Cpx', 'MnO_Cpx', 'CaO_Cpx', 'Na2O_Cpx',
                'Cr2O3_Cpx']
    for element in Elements_Cpx:
        df_m = replace_zeros(df, element)

    Xd = df[Elements_Cpx]
    X = np.array(Xd)

    pred_max_bound = np.ones(len(X)) * 1700.000000
    pred_min_bound = np.ones(len(X)) * 700.000000
    pred_max_bound = pred_max_bound.reshape(-1, 1)
    pred_min_bound = pred_min_bound.reshape(-1, 1)

    warning = df.apply(lambda x: '' if 0.760000<=x['MgO_Cpx']<=31.300000
                                and 0.400000<=x['CaO_Cpx']<=24.820000
                                and 0.290000<=x['Al2O3_Cpx']<=19.010000
                                and 1.700000<=x['FeOt_Cpx']<=34.200000
                                and 0.000179<=x['MnO_Cpx']<=2.980000
                                else 'Input out of bound', axis=1)

    # Model prediction
    scaler, predictor, bias_json = P_T_predictors(output, model)
    X_s = scaler.transform(X)

    bias_popt_left = np.array(bias_json['slope']['left'])
    bias_popt_right = np.array(bias_json['slope']['right'])
    ang_left = bias_json['angle']['left']
    ang_right = bias_json['angle']['right']

    input_name = predictor.get_inputs()[0].name
    label_name = predictor.get_outputs()[0].name
    y_pred = predictor.run([label_name],{input_name: X_s.astype(np.float32)})[0]

    unit = 'C'

    bias_temp = bias_f(y_pred,
                    ang_left, bias_popt_left,
                    ang_right, bias_popt_right)

    unique_y_pred_temp = y_pred - bias_temp

    # Bound of the training set
    y_pred = np.minimum(pred_max_bound, np.maximum(pred_min_bound, unique_y_pred_temp))

    predictions = pd.DataFrame(data=np.array(y_pred),
                           columns=[output + '_' + unit])
    predictions['warning'] = warning

    return predictions

# Define file paths
current_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.abspath(os.path.join(current_dir, '..'))
main_workbook = os.path.join(parent_dir, 'Nak_pyroxene.xlsx')
excel_file = pd.ExcelFile(main_workbook, engine='openpyxl')
sheet_names = excel_file.sheet_names

for sheet in sheet_names:
    output_filename = f"Output_EPMA2_{sheet}.xlsx"
    try:
        df_init = pd.read_excel(output_filename)
    except FileNotFoundError:
        print(f"No such a file '{output_filename}' in the specified directory.")
        continue
    except Exception as e:
        print(f"An error occurred while importing '{output_filename}': {e}")
        continue

    df = data_imputation(df_init)

    # Use Ágreda-López et al. (2024) method for temperature calculations.
    predictions = Agreda_Lopez_cpx_only_calculator(df)
    writer = pd.ExcelWriter(f"Output_T_Rim_{sheet}.xlsx", engine='openpyxl')
    predictions.to_excel(writer, sheet_name="A24")
    writer.close()
    print(f"Successfully calculated {sheet} using A24 method and saved the results.")

    # Use Wang et al. (2021) method for temperature calculations.
    # This calculation is implemented in Thermobar (Wieser et al. 2022)
    out = pt.import_excel(output_filename, sheet_name="Sheet1")
    Cpxs = out['Cpxs']
    Calc_PT = pt.calculate_cpx_only_temp(cpx_comps=Cpxs,equationT="T_Wang2021_eq2",P=0)
    # Append the second DataFrame to the same file in a new sheet
    with pd.ExcelWriter(f"Output_T_Rim_{sheet}.xlsx", engine='openpyxl', mode='a') as writer:
        Calc_PT.to_excel(writer, sheet_name="W21", index=True)
    print(f"Successfully calculated {sheet} using W21 method and saved the results.")
