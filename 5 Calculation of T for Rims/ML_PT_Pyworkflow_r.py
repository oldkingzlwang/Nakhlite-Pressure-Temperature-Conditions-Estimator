'''
This code is modified from ML_PT_Pyworkflow.py (Mónica Ágreda-López et al., 2024 C & G)
Downloaded from https://bit.ly/ml-pt-py in November 2024
This code can only be used in the purpose of this study. For any other utilization,
please download the original code from https://bit.ly/ml-pt-py.
'''

import numpy as np
import pandas as pd  
import scipy.stats as st
import json
import joblib
from sklearn.model_selection import StratifiedGroupKFold
from sklearn.model_selection import StratifiedKFold
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.ensemble import ExtraTreesRegressor
import matplotlib.pyplot as plt
from skl2onnx.common.data_types import FloatTensorType
from scipy.optimize import curve_fit
import onnxruntime as rt

# STANDARD PARAMETERS

class Parameters:
    
    # Errors typically associated with each oxide measurement in the EPMA.

    ''' 
    # Relative errors (percentage. 3% for measurm. >1wt% and 8% for measurm. <1wt.%)
    'SiO2'   : 0.03,  
    'TiO2'   : 0.08,
    'Al2O3'  : 0.03,
    'FeO'    : 0.03,
    'MgO'    : 0.03,
    'MnO'    : 0.08,
    'CaO'    : 0.03,
    'Na2O'   : 0.08,
    'Cr2O3'  : 0.08,
    'k2O_Liq': 0.08
    '''
        
    oxide_rel_err = np.array([0.03,0.08,0.03,0.03,0.03,0.08,0.03,0.08,0.08])
    K_rel_err = np.array([0.08])


    temperature_bins = [600,1050,1140,1250,1800]
    pressure_bins    = [0,5,10,15,20,25,30]
    
    

# PREPROCESSING

def data_imputation(dataFrame):
    """
    Fill Nan values with 0.

    Args:
        dataFrame (pandas.DataFrame): dataset  to modify.

    Returns:
        pandas.DataFrame
    """
    dataFrame = dataFrame.fillna(0) 
    return dataFrame 

def replace_zeros(dataFrame, column_name):
    """
    Replace 0 values in a series with a random value from 0 to min of a series.

    Args:
       dataFrame (pandas.DataFrame): dataset to modify.
       column_name (string): column name of the dataset to modify.

    Returns:
        pandas.DataFrame 
    """
    min_non_zero = dataFrame[dataFrame[column_name] > 0][column_name].min()
    epsilon = np.nextafter(0.0, 1.0)
    dataFrame.loc[dataFrame[column_name] == 0, column_name] = dataFrame[column_name].apply(
        lambda x: np.random.uniform(epsilon, min_non_zero) if x == 0 else x
    )
    return dataFrame 

def pwlt_transformation(X):
    """
    Pairwise Log-ratio transformation.

    Args:
        X (np.array 2D): Dataset to transform.

    Returns:
        np.array (2D) 
    """
    
    X[X==0] = 0.001
    nr = len(X)  
    ni = len(X[0])
    nf = int(ni*(ni-1)/2)
    N = np.zeros((nr,nf))
    D = np.zeros((nr,nf))
    c_in = 0
    c_out = ni-1
    for i in range(0,ni-1):
        l = c_out-c_in
        N[:,c_in:c_out] = np.reshape(np.repeat(X[:,i], [l], axis=0),(-1,l))
        D[:,c_in:c_out] = X[:,i+1:]
        c_in = c_out
        c_out = c_out+(ni-i-2)
    return np.log(np.divide(N,D))


# DATA AUGMENTATION

def perturbation(X, y, std_dev_perc, n_perturbations=15):
    """
    Data augmentation picking new elements from a Gaussian distribution with mean
    'value of each original sample' and standard deviation 'std_dev_perc'. Useful
    for the training and testing phases because we are managing the output.

    Args:
        X (numpy.array 2D): Input dataset.
        y (np.array 1D): Output dataset.
        std_dev_perc (np.array 1D, or np.array 2D): standard deviation percentage.
        If you upload a 1D-array, all new samples are based on the same standard
        deviation, if you upload a 2D-array, new samples come from different
        standard deviations.
        n_perturbations (int): numbers of elements to create from each row of X.

    Returns:
        X_perturb (np.array 2D): Input dataset augmented
        y_rep (np.array 1D): Output dataset augmented
        groups (np.array 1D): index of samples with the same origin
    """
    X_rep = np.repeat(X, repeats=n_perturbations, axis=0)
    y_rep = np.repeat(y, repeats=n_perturbations, axis=0)
    
    if len(std_dev_perc.shape) == 1:
        std_dev_rep = np.repeat([std_dev_perc], repeats=len(X_rep), axis=0)*X_rep
    elif len(std_dev_perc.shape) == 2:
        std_dev_rep = np.repeat(std_dev_perc, repeats=n_perturbations, axis=0)*X_rep
    else:
        print('The dimension of standards deviation for data augmentation is not coherent')
    
    std_dev_rep = np.repeat([std_dev_perc], repeats=len(X_rep), axis=0)*X_rep
    np.random.seed(10)
    X_perturb = np.random.normal(X_rep, std_dev_rep)
    groups = np.repeat(np.arange(len(X)), repeats=n_perturbations, axis=0)
    return X_perturb, y_rep, groups

def input_perturbation(X, std_dev_perc, n_perturbations=15):
    """
    Data augmentation picking new elements from a Gaussian distribution with mean
    'value of each original sample' and standard deviation 'std_dev_perc'. Useful
    for the prediction phase because we are not managing the output.

    Args:
        X (numpy.array 2D): Input dataset.
        std_dev_perc (np.array 1D, or np.array 2D): standard deviation percentage.
        If you upload a 1D-array, all new samples are based on the same standard
        deviation, samples comes from different standard deviations.
        n_perturbations (int): numbers of elements to create from each row of X.

    Returns:
        X_perturb (np.array 2D): Input dataset augmented
        groups (np.array 1D): index of samples with the same origin
    """
    X_rep = np.repeat(X, repeats=n_perturbations, axis=0)
    
    if len(std_dev_perc.shape) == 1:
        std_dev_rep = np.repeat([std_dev_perc], repeats=len(X_rep), axis=0)*X_rep
    elif len(std_dev_perc.shape) == 2:
        std_dev_rep = np.repeat(std_dev_perc, repeats=n_perturbations, axis=0)*X_rep
    else:
        print('The dimension of standard deviation for data augmentation is not coherent')
        
    np.random.seed(10)
    X_perturb = np.random.normal(X_rep, std_dev_rep)
    groups = np.repeat(np.arange(len(X)), repeats=n_perturbations, axis=0)
    return X_perturb, groups


# TRAIN-TEST SPLIT

# Split to manage unbalanced output
def balanced_train_test(X,y,bins,test_size,sample_names):
    """
    Train-test split to manage unbalanced output and dependent samples. 
    
    Args:
        X (numpy.array 2D): Input dataset.
        y (np.array 1D): Output dataset.
        bins (np.array 1D): index of dependent samples
        test_size (int)
        sample_names (list 1D)

    Returns: 
        X_train (numpy.array 2D): Input dataset for training.
        X_test (np.array 2D): Input dataset for test.
        y_train (numpy.array 1D): Output dataset for training.
        y_test (np.array 1D): Output dataset for test.
        train_index (np.array 1D): Index for training.
        test_index (np.array 1D): Index for test.
    """
    
    out = np.digitize(y, bins, right = 1) 
    
    X_temp = np.concatenate((np.reshape(sample_names,(len(sample_names),1)),X),axis=1)
    X_train_temp, X_test_temp, y_train, y_test = train_test_split(X_temp ,y                                                                                                                         ,test_size=test_size 
                                                                  ,random_state=42
                                                                  , stratify=out)
    X_train = X_train_temp[:,1:]
    X_test = X_test_temp[:,1:]
    train_index = X_train_temp[:,0].astype(int)
    test_index = X_test_temp[:,0].astype(int)
    return(X_train, X_test, y_train, y_test, train_index, test_index)


# HYPERPARAMETERS FINE-TUNING

def ET_train_validation_balanced_perturbation(X_train
                                              ,y_train
                                              ,std_dev_perc
                                              ,bins
                                              ,k_fold=10
                                              ,n_estimators=200
                                              ,max_depth=15
                                              ,n_perturbations=15
                                              ,pwlt=False):
    """
    Cross validation process for Extra-Trees. It can manage unbalanced data as
    output and dependencies between the input samples generated via data augmentation

    Args:
        X_train (numpy.array 2D): Input dataset.
        y_train (np.array 1D): Output dataset.
        bins (np.array 1D): index of dependent samples
        std_dev_perc (np.array 1D, or np.array 2D): standard deviation percentage.
        If you upload a 1D-array, all new samples are based on the same standard
        deviation, if you upload a 2D-array, new samples comes from different
        standard deviations.

    Returns:
        model: model trained
        total_score_avg (np.float): score from cross-validation
    """
    X_train_perturb, y_train_perturb, groups = perturbation(X_train
                                                            ,y_train
                                                            ,std_dev_perc
                                                            ,n_perturbations)
    scaler = StandardScaler().fit(X_train_perturb)
    
    if pwlt:
        X_train_perturb = pwlt_transformation(X_train_perturb)
    else:
        X_train_perturb = scaler.transform(X_train_perturb)
        
    out = np.digitize(y_train_perturb, bins, right = 1)
    skf = StratifiedGroupKFold(n_splits=k_fold)
    skf.get_n_splits(X_train_perturb, out, groups)
    
    total_score = 0
    for i, (train_index, validation_index) in enumerate(skf.split(X_train_perturb, out, groups)):
        model = ExtraTreesRegressor(n_estimators=n_estimators, max_depth=max_depth)
        model_fit = model.fit(X_train_perturb[train_index],y_train_perturb[train_index])
        k_score = model.score(X_train_perturb[validation_index],y_train_perturb[validation_index])
        total_score += k_score
        total_score_avg = total_score/k_fold
    return model,total_score_avg

# Extra-Trees: can manage unbalanced data as output
def ET_train_validation_balanced(X_train
                                 ,y_train
                                 ,bins
                                 ,k_fold=10
                                 ,n_estimators=200
                                 ,max_depth=15
                                 ,pwlt=False):
    """
    Cross-validation process for Extra-Trees. It can manage unbalanced data as output
    
    Args:
        X_train (numpy.array 2D): Input dataset.
        y_train (np.array 1D): Output dataset.
        bins (np.array 1D): index of dependent samples
        
    Returns:
        model: model trained
        total_score_avg (np.float): score from cross-validation
    """
    
    scaler = StandardScaler().fit(X_train)
    
    if pwlt:
        X_train = pwlt_transformation(X_train)
    else:
        X_train = scaler.transform(X_train)
    
    out = np.digitize(y_train, bins, right = 1)
    skf = StratifiedKFold(n_splits=k_fold)
    skf.get_n_splits(X_train, out)
    
    total_score = 0
    for i, (train_index, validation_index) in enumerate(skf.split(X_train, out)):
        model = ExtraTreesRegressor(n_estimators=n_estimators,max_depth=max_depth)
        model_fit = model.fit(X_train[train_index],y_train[train_index])
        k_score = model.score(X_train[validation_index],y_train[validation_index])
        total_score += k_score
        total_score_avg = total_score/k_fold
    return model,total_score_avg


# MODELS

# Bias correction function (Linear piecewise function)
def bias_f_line(x,a):
    """
    half-line function
    """
    return a*(x-x0)

def bias_f_temp(x,
                ang_left,popt_left,
                ang_right,popt_right):
    """
    Piece-wise function
    """
    global x0
    if x<ang_left:
        x0 = ang_left
        return bias_f_line(x,popt_left)
    elif x>ang_right:
        x0 = ang_right
        return bias_f_line(x,popt_right)
    return 0.0    

bias_f = np.vectorize(bias_f_temp)

def piecewise_line(bias_split,X_train,y_train,model):
    """
    Piece-wise function fit on training dataset. It can manage model bias. 
    """
    ang_left = (max(y_train)+(bias_split-1)*min(y_train))/bias_split
    ang_right = ((bias_split-1)*max(y_train)+min(y_train))/bias_split

    pred = model.predict(X_train)
    bias_pred = pred - y_train
     
    ind = np.arange(0,len(y_train),1)
    ind_I = ind[y_train<ang_left]
    ind_II = ind[y_train>ang_right]
    
    y_train_I = y_train[ind_I]
    bias_pred_I = bias_pred[ind_I]
    y_train_II = y_train[ind_II]
    bias_pred_II = bias_pred[ind_II]
    
    global x0
    x0 = ang_left
    popt_bias_I, pcov_bias_I = curve_fit(bias_f_line, y_train_I, bias_pred_I)
    x0 = ang_right
    popt_bias_II, pcov_bias_II = curve_fit(bias_f_line, y_train_II, bias_pred_II)
    
    return(popt_bias_I,popt_bias_II,ang_left,ang_right)

    
def P_T_predictors(output, model):
    """
    Upload model for the entire pipeline: scaler, main model and bias function.

    Args:
        output (string): 'Pressure' or 'Temperature'.
        model (string): 'cpx_only' or 'cpx_liquid'.

    Returns:
        scaler (.joblib): scaler
        predictor (.onnx): main model
        bias_json (.json): parameters for the bias model.
    """

    if output == 'Pressure' and model == 'cpx_only':
        scaler=joblib.load("models/"+"Model_cpx_only_P_bias.joblib")
        predictor = rt.InferenceSession('models/'+'Model_cpx_only_P_bias'+'.onnx')
        with open("models/"+'Model_cpx_only_P_bias'+'.json') as json_file:
            bias_json = eval(json.load(json_file))
    
    elif output == 'Temperature' and model == 'cpx_only':
        scaler=joblib.load("models/"+"Model_cpx_only_T_bias.joblib")
        predictor = rt.InferenceSession("models/"+'Model_cpx_only_T_bias'+'.onnx')
        with open("models/"+'Model_cpx_only_T_bias'+'.json') as json_file:
            bias_json = eval(json.load(json_file))
    
    
    elif output == 'Pressure' and model == 'cpx_liquid':
        scaler=joblib.load("models/"+"Model_cpx_liquid_P_bias.joblib")
        predictor = rt.InferenceSession("models/"+'Model_cpx_liquid_P_bias'+'.onnx')
        with open("models/"+'Model_cpx_liquid_P_bias'+'.json') as json_file:
            bias_json = eval(json.load(json_file))
        
    elif output == 'Temperature' and model == 'cpx_liquid':
        scaler=joblib.load("models/"+"Model_cpx_liquid_T_bias.joblib")
        predictor = rt.InferenceSession("models/"+'Model_cpx_liquid_T_bias'+'.onnx')
        with open("models/"+'Model_cpx_liquid_T_bias'+'.json') as json_file:
            bias_json = eval(json.load(json_file))
            
    return(scaler, predictor, bias_json)
    
    

# EVALUATION

def max_perc(x):
    """
    84-th percentile.

    Args:
        x (np.array): Array to define 84-th percentile.

    Returns:
        np.array (1D) 
    """
    return(np.percentile(x,84))

def min_perc(x):
    """
    16-th percentile.

    Args:
        x (np.array): Array to define 16-th percentile.

    Returns:
        np.array (1D) 
    """
    return(np.percentile(x,16))