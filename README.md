# Nakhlite-Pressure-Temperature-Conditions-Estimator
A useful tool to constrain the formation pressures and temperatures of Martian nakhlite meteorites using clinopyroxene-only thermobarometers.



## Introduction to the Program

This program focuses on estimating the exact formation pressure and temperature conditions (P-Ts) of nakhlites using clinopyroxene-only thermobarometers. Detailed background information and rationale can be found in **Wang Z. L., and Tian W. 2025. Assessing the accuracy of clinopyroxene themobarometers in the Martian nakhlite system. *Abstract for 56th Lunar and Planetary Science Conference.* No. 1016.**

The program workflow involves the following steps:

1. Compilation of nakhlite clinopyroxene EPMA data from various literature sources.
2. Dimensionality reduction and clustering of clinopyroxene compositions to distinguish between core, mantle, and rim regions.
3. Calculation of P-T estimates for core and rim compositions using thermobarometers and Monte Carlo error propagation modeling.
4. Summarization of P-T results and generation of relevant figures for visualization.



## Detailed Implementation of the Program

### Nakhlite Clinopyroxene Database Compilation

The compiled EPMA data are stored in the `Nak_pyroxene.xlsx` file. This file contains 14 worksheets, each representing a distinct nakhlite meteorite or paired group. The relevant columns and their meanings are as follows:

- Column A and P: Labels for clinopyroxene data. Column A contains automatically generated cluster labels (1/2/3) using the `DR_Clustering.m` file, and Column P contains refined cluster labels  (Core/Mantle/Rim) manually adjusted based on Column A's content.

- Column B-N: EPMA compositional data collected from literature sources.

- Column O: Meteorite names.

- Column Q: References to literature sources for the data. The meaning of abbreviations is provided as follows:

  | No.  | Abbreviations in Column Q | Corresponding References         |
  | ---- | ------------------------- | -------------------------------- |
  | 1    | Baker2023                 | Baker et al. (2023) GCA          |
  | 2    | Balta2017                 | Balta et al. (2017) MaPS         |
  | 3    | Cao2022                   | Cao et al. (2022) JRS            |
  | 4    | McCubbin2013              | McCubbin et al. (2013) MaPS      |
  | 5    | Ostwald2024               | Ostwald et al. (2024) MaPS       |
  | 6    | Ramsey2023                | Ramery et al. (2024) MaPS        |
  | 7    | Ruggiu2020                | Krämer Ruggiu et al. (2020) MaPS |
  | 8    | Udry&Day2018              | Udry and Day (2018) GCA          |
  | 9    | This study                | Measured by the author           |

- Column R-AJ: Mole fractions of each element and calculated end-member compositions.

- Column AL-AW: P-T estimates generated using the `calculate_cpx_only_press_all_eqs` function from **Thermobar** (Wieser et al., 2022).

For the purpose of the dataset pretreatment, EPMA data outside the acceptable range (98–102% totals) and those with abnormally high contents of incompatible elements (e.g., Ti, Al, Cr, Na) are removed. Then, Data tables are sorted in descending order of clinopyroxene Mg# (molar Mg/(Mg+Fe) × 100) for better organization.



### First Step: Dimensionality Reduction and Clustering

#### **Running the Clustering Process**

1. Open the folder `1 Dimensionality Reduction and Clustering` and launch the `DR_Clustering.m` file.
2. The program will traverse all worksheets in `Nak_pyroxene.xlsx` and apply dimensionality reduction and clustering using the `pca_kmeans_calculator` function.

#### **Clustering Workflow**

The `pca_kmeans_calculator` function performs the following operations:

1. **K-Means Clustering (Elbow Method)**:
   - K-Means clustering is conducted for values of `k` ranging from 1 to 10.
   - The optimal number of clusters (`k`) is determined by identifying the "elbow" point, where the rate of decrease in the within-cluster sum of squares (WCSS) slows significantly.
   - Predefined values (`k_matrix = [3,2,3,3,2,3,3,3,3,2,2,2,3,2]`) ensure the optimal cluster number for each meteorite. For nakhlites, `k = 2` or `k = 3` is common, reflecting variations from cores to rims (k = 2) or cores to mantles to rims (k = 3).
2. **Silhouette Analysis**:
   - Silhouette diagrams are generated to evaluate clustering quality. Positive silhouette scores close to 1 indicate well-separated clusters.
3. **PCA Analysis**:
   - Principal Component Analysis (PCA) reduces dimensionality and plots the first two principal components for visualizing core, mantle, and rim clusters.

#### **Output**

- The program generates 14 PDF files named `ClusterResult_xxx.pdf` (where `xxx` corresponds to the worksheet name).
- These files visually display the clustering results and the separation of clinopyroxene core/rim/mantle regions.

#### **Manual Adjustments**

To modify clustering results:

1. Change the `i` variable in the `pca_kmeans_calculator` function to the desired worksheet index.

2. Copy the updated `idx` variable to Column A of the respective worksheet in `Nak_pyroxene.xlsx`.

3. Update the formula in Column P to reflect the new cluster assignments. For example, if idx = 3 corresponds to "Core" and idx = 1 to "Rim," modify the formula in cell P2 as follows:

   ```Excel
   `=IFS(A2=3,"Core",A2=1,"Rim",TRUE,"Mantle")`
   ```

4. Drag the formula down to ensure all entries in Column P are updated.



### Second Step: Monte Carlo Modeling for Core Compositions

This step involves modeling compositional variations in clinopyroxene cores of Martian nakhlites due to factors such as EPMA analysis errors, sampling bias, and sectoral zonation effects observed in some meteorites. The purpose is to better estimate the error propagation in pressure-temperature (P-T) calculations by generating a range of plausible EPMA compositions for clinopyroxene cores. For a detailed description to the method used in this step, please refer to the [Lunar-Mineral-EPMA-data-Generator](https://github.com/oldkingzlwang/Lunar-Mineral-EPMA-data-Generator) project page.

#### **How to Run the Program**

1. **Navigate to the Folder**:
   Open the folder `2 MC Modeling for Core Compositions` and launch the `EPMA_Composition_MC_Modeling.m` file in MATLAB.
2. **Input Data**:
   The program automatically reads data of clinopyroxene cores from all worksheets in `Nak_pyroxene.xlsx`, which contains the EPMA compositions of clinopyroxene for different nakhlites.
3. **Set the Number of Samples**:
   Modify the variable `numValidSamples` to specify the desired number of modeled EPMA compositions. The default value is 1000, but you can set this to any other number depending on your requirements.
4. **Run the Program**:
   After setting `numValidSamples`, simply click **Run** in MATLAB.

#### **Output Files**

The program generates the following outputs for each worksheet in `Nak_pyroxene.xlsx`:

1. **PDF Files**:
   - **Filename Format**: `Output_EPMA_xxx.pdf` (where `xxx` corresponds to the worksheet name).
   - **Content**: Element-to-element diagrams comparing the modeled EPMA compositions (red points) against the measured compositions (blue points). These diagrams visually assess the consistency between the generated and real data.
2. **Excel Files**:
   - **Filename Format**: `Output_EPMA_xxx.xlsx`.
   - **Content**: Contains the generated EPMA compositions for clinopyroxene cores. The data can be used for subsequent calculations or further analyses.

#### **Notes**

- The generated diagrams in the PDF files provide a quick visual check to ensure that the modeled data reasonably represent the actual measured compositions.
- If you need to fine-tune the output, you can adjust the program parameters directly in the `EPMA_Composition_MC_Modeling.m` file.
- Ensure that `Nak_pyroxene.xlsx` is up-to-date and contains accurate EPMA data before running the program.

This step provides a robust foundation for reducing uncertainties in P-T estimations, enabling more precise interpretations of nakhlite formation conditions.



### Third Step: P-T Calculations for Clinopyroxene Cores

This step involves calculating the pressure-temperature (P-T) conditions based on the generated EPMA data from **Step 2**. The calculations are performed using the `calculate_cpx_only_press_all_eq` function from the **Thermobar** package (version 1.0.44) as described by Wieser et al. (2022). For detailed documentation on Thermobar, visit [Thermobar Documentation](https://thermobar.readthedocs.io/).

#### **How to Implement This Step**

1. **Navigate to the Folder**:
   Open the `3 PT Calculations for Cores` folder and the `Cpx_only_pt_calculator_core.py` file.
2. **Input Files**:
   The program will read:
   - `Nak_pyroxene.xlsx` from the parent directory to retrieve worksheet labels.
   - `Output_EPMA_xxx.xlsx` files generated in Step 2 (stored in the `2 MC Modeling for Core Compositions` folder).
3. **Run the Program**:
   Simply click **Run** in your Python environment. No modifications to the code are required unless you wish to customize the behavior.

#### **Workflow Details**

- **File Traversal**:
  The program automatically scans all worksheets in `Nak_pyroxene.xlsx` to identify nakhlite meteorites and locate their corresponding EPMA composition files (`Output_EPMA_xxx.xlsx`) generated in Step 2.
- **P-T Calculations**:
  Using the **Thermobar** package, the `calculate_cpx_only_press_all_eq` function is applied to the EPMA data in each `Output_EPMA_xxx.xlsx` file to estimate P-T conditions for clinopyroxene cores.
- **Output Files**:
  Results are temporarily stored in the `Calc_PT` variable during execution and saved as Excel files in the `3 PT Calculations for Cores` folder.
  - **Filename Format**: `Output_PT_xxx.xlsx` (where `xxx` corresponds to the worksheet name in `Nak_pyroxene.xlsx`).
  - **Content**: These files store the calculated P-T values for the clinopyroxene cores of all nakhlites listed in `Nak_pyroxene.xlsx`.

#### **Notes**

- Ensure that Thermobar is correctly installed and updated to version 1.0.44.
- Before running this step, verify the accuracy and completeness of the EPMA composition files (`Output_EPMA_xxx.xlsx`) generated in Step 2.
- If any modifications are needed, such as adding custom functionality or changing output file locations, the code can be adjusted accordingly.



### Fourth Step: Compare and Plot the P-T Results of Cores

This step visualizes and compares the pressure-temperature (P-T) results obtained in **Step 3**, focusing on two primary goals:

1. **Intra-sample Comparison**: Testing for differences between P-T results calculated from Monte Carlo (MC)-generated EPMA data and those from the original measured EPMA data for individual nakhlite samples.
2. **Inter-sample Comparison**: Visualizing and comparing the P-T results across different nakhlite samples or groups to identify formation P-T variations.

#### **Intra-Sample Comparison of P-T Results**

**Purpose**: To determine if P-T values derived from MC-generated EPMA data (in Step 2) are statistically consistent with those derived from original measured EPMA data.

**Implementation**:

1. Navigate to the `4 Compare and Plot the PT Results of Cores` folder.
2. Open the `Comparison_PT.m` file.
3. Click **Run** without modifying the code.

**Workflow**:

- The code reads:
  - `Nak_pyroxene.xlsx` from the parent directory for P-T results derived from original EPMA data.
  - `Output_EPMA_xxx.xlsx` files from the `3 PT Calculations for Cores` folder for P-T results derived from generated EPMA data.
- Statistical tests are applied to compare the two datasets:
  - **Mann-Whitney U Test**: For differences in medians.
  - **t-Test**: For differences in means.
  - **F-Test**: For differences in standard deviations.
- Frequency distribution diagrams for pressures and temperatures are plotted for each nakhlite sample.
- Quantitative comparison results are displayed in the MATLAB command window. A "No significant difference between generated dataset and original dataset" message indicates the MC-generated dataset is reliable.

**Output**:

- Two PDF files summarizing the comparison:
  - `Output_P_summary.pdf` (Pressure Comparison)
  - `Output_T_summary.pdf` (Temperature Comparison)

**Note**: This step is optional. Previous results show no significant differences between the two datasets.

#### **Inter-Sample Comparison of P-T Results**

**Purpose**: To visualize P-T distributions across different nakhlite samples and identify variations.

**Implementation**:

1. Navigate to the `4 Compare and Plot the PT Results of Cores` folder.
2. Open the `PT_Raincloud_Diagram.m` file.
3. Click **Run**.

**Workflow**:

- The code reads `Output_EPMA_xxx.xlsx` files from the `3 PT Calculations for Cores` folder to extract P-T data from the MC-generated EPMA datasets.
- Raincloud distribution diagrams are generated for:
  - **Pressure**: Output as `Output_P_Raincloud.pdf`.
  - **Temperature**: Output as `Output_T_Raincloud.pdf`.
- Summarized P-T statistics (lower quartile, median, upper quartile) for each nakhlite sample are output to:
  - `Output_P_Raincloud.csv` (Pressure Summary)
  - `Output_T_Raincloud.csv` (Temperature Summary).

**Pressure vs. Temperature Plot**:

1. Open `PT_Plane_Diagram.m` in the same directory.
2. Click **Run** to plot the P-T plane diagram.
   - Input: `Output_P_Raincloud.csv` and `Output_T_Raincloud.csv`.
   - Output: `PT_Plane_Diagram.pdf`.

#### **Outputs Summary**

- Intra-Sample Comparison:
  - `Output_P_summary.pdf`
  - `Output_T_summary.pdf`
- Inter-Sample Comparison:
  - `Output_P_Raincloud.pdf` (Pressure Distribution)
  - `Output_T_Raincloud.pdf` (Temperature Distribution)
  - `Output_P_Raincloud.csv` (Pressure Summary Table)
  - `Output_T_Raincloud.csv` (Temperature Summary Table)
  - `PT_Plane_Diagram.pdf` (Pressure vs. Temperature Plane Plot)

#### **Notes**

- Ensure that prior steps (1-3) are successfully completed before proceeding to this step.
- You can customize comparison criteria in `Comparison_PT.m` or plotting preferences in `PT_Raincloud_Diagram.m` and `PT_Plane_Diagram.m`.
- These outputs are essential for analyzing and visualizing the P-T variations across nakhlite samples and evaluating consistency within datasets.



### Fifth Step: MC-modeling and Calculating T for Rims

This step focuses on calculating and visualizing temperature (T) results from EPMA rim data of clinopyroxene in nakhlites. It is structured similarly to Steps 2-4, with modifications tailored for rim data.

#### **Generating EPMA Data for Clinopyroxene Rims**

**Objective**: Use Monte Carlo (MC) modeling to generate EPMA compositions for clinopyroxene rims, accounting for analytical uncertainty and sampling variability.

**Steps**:

1. Navigate to the `5 Calculation of T for Rims` folder.
2. Open the `EPMA_Composition_MC_Modeling2.m` file.
3. Click **Run**.

**Details**:

- The program reads clinopyroxene rim data from all worksheets in `Nak_pyroxene.xlsx`.
- Generated EPMA rim compositions are saved in `Output_EPMA2_xxx.xlsx` files, where `xxx` corresponds to each worksheet name.
- The user can modify the `numValidSamples` variable to control the number of generated samples. The default value is set to 1000.

#### **Implementing Temperature Calculations**

**Objective**: Estimate rim-formation temperatures using two thermometers:

- A machine-learning-based thermometer (Ágreda-López et al., 2024).
- An empirical formula-based thermometer (Wang et al., 2021).

**Steps**:

1. Open the `Cpx_only_t_calculator_rim.py` file in the same directory.
2. Click **Run**. Ensure Python is properly configured with the necessary libraries.

**Details**:

- Machine-Learning Thermometer:
  - Implemented in the `ML_PT_Pyworkflow_r.py` script and uses pre-trained models stored in the `models` folder.
  - Modified from Ágreda-López et al. (2024) (see https://bit.ly/ml-pt-py).
- Empirical-Formula Thermometer:
  - Implemented via the `Thermobar` package (Wieser et al., 2022). Ensure `Thermobar` is installed and accessible in Python.

**Outputs**:

- The program generates Excel files named `Output_T_Rim_xxx.xlsx`:
  - **Workbook A24**: Results from the machine-learning thermometer, with temperatures in °C.
  - **Workbook W21**: Results from the empirical formula thermometer, with temperatures in K.

#### **Visualizing Temperature Results**

**Objective**: Generate raincloud distribution diagrams for rim-formation temperatures and summarize temperature statistics for different nakhlites.

**Steps**:

1. Open the `T_Raincloud_Diagram_for_Rim.m` file in the same directory.
2. Click **Run**.

**Details**:

- The program reads temperature data from `Output_T_Rim_xxx.xlsx` files.
- Averages the results from the two thermometers for each dataset.
- Outputs the following:
  - **Raincloud Distribution Diagram**: Visualizes temperature distributions for different nakhlites. Saved as `Output_T_Raincloud_Rim.pdf`.
  - **Temperature Summary Table**: Summarizes lower quartile, median, and upper quartile values. Saved as `Output_T_Raincloud_Rim.csv`.

**Example Outputs**:

- `Output_T_Raincloud_Rim.csv`: A CSV file containing summarized temperature statistics for all samples.
- `Output_T_Raincloud_Rim.pdf`: A PDF file with raincloud distribution plots.

#### **Notes**

- Modify `T_Raincloud_Diagram_for_Rim.m` to customize visualization parameters if needed.
- Demo files in the directory illustrate expected outputs for both raincloud plots and summary tables.



## Remarks

If you would like to contribute to the program's development, or if you have any questions or feedback, please contact the author via email at `zilong.wang@pku.edu.cn`.



## References

Ágreda-López M., Parodi V., Musu A., et al. 2024. Enhancing machine learning thermobarometry for clinopyroxene-bearing magmas. *Computers & Geosciences*, 193: 105707. https://doi.org/10.1016/j.cageo.2024.105707.

Baker D. R., Callegaro S., Marzoli A., et al. 2023. Sulfur and chlorine in nakhlite clinopyroxenes: Source region concentrations and magmatic evolution. *Geochimica et Cosmochimica Acta*, 359: 1-19. https://doi.org/10.1016/j.gca.2023.08.007.

Balta J., Sanborn M., Mayne R., et al. 2017. Northwest Africa 5790: A previously unsampled portion of the upper part of the nakhlite pile. *Meteoritics and Planetary Science*, 52: 36-59. https://doi.org/10.1111/maps.12744.

Cao H. J., Chen J., Fu X. H., et al. 2022. Raman spectroscopic and geochemical studies of primary and secondary minerals in Martian meteorite Northwest Africa 10720. *Journal of Raman Spectroscopy*, 53: 420-434. https://doi.org/10.1002/jrs.6254.

McCubbin F., Elardo S., Shearer C., et al. 2013. A petrogenetic model for the comagmatic origin of chassignites and nakhlites: Inferences from chlorine-rich minerals, petrology, and geochemistry. *Meteoritics & Planetary Science*, 48: 819-853. https://doi.org/10.1111/maps.12095

Ostwald A., Udry A., Day J. M. D., et al. 2024. Melt inclusion heterogeneity in nakhlite and chassignite meteorites and evidence for complicated, multigenerational magmas. *Meteoritics & Planetary Science*, 59(6): 1473-1494. https://doi.org/10.1111/maps.14159.

Ramsey S. R., Ostwald A. M., Udry A., et al. 2024. Northwest Africa 13669, a reequilibrated nakhlite from a previously unsampled portion of the nakhlite igneous complex. *Meteoritics & Planetary Science*, 59(1): 134-170. https://doi.org/10.1111/maps.14112.

Krämer Ruggiu L., Gattacceca J., Devouard B., et al. 2020. Caleta el Cobre 022 Martian meteorite: Increasing nakhlite diversity. *Meteoritics & Planetary Science*, 55(7): 1539-1563. https://doi.org/10.1111/maps.13534.

Udry A., Day J. M. D. 2020. 1.34 billion-year-old magmatism on Mars evaluated from the co-genetic nakhlite and chassignite meteorites. *Geochimica et Cosmochimica Acta*, 238: 292-315. https://doi.org/10.1016/j.gca.2018.07.006.

Wang X. D., Hou T., Wang M., et al. 2021. A new clinopyroxene thermobarometer for mafic to intermediate magmatic systems. *European Journal of Mineralogy*, 33(5): 621-637. https://doi.org/10.5194/ejm-33-621-2021.

Wieser P., Petrelli M., Lubbers J., et al. 2022. Thermobar: an open-source Python3 tool for thermobarometry and hygrometry. *Volcanica*, 5: 349-384. https://doi.org/10.30909/vol.05.02.349384.
