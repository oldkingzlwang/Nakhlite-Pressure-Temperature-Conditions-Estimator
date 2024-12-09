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



Second Step: 





References

Baker D. R., Callegaro S., Marzoli A., et al. 2023. Sulfur and chlorine in nakhlite clinopyroxenes: Source region concentrations and magmatic evolution. *Geochimica et Cosmochimica Acta*, 359: 1-19. https://doi.org/10.1016/j.gca.2023.08.007.

Balta J., Sanborn M., Mayne R., et al. 2017. Northwest Africa 5790: A previously unsampled portion of the upper part of the nakhlite pile. *Meteoritics and Planetary Science*, 52: 36-59. https://doi.org/10.1111/maps.12744.

Cao H. J., Chen J., Fu X. H., et al. 2022. Raman spectroscopic and geochemical studies of primary and secondary minerals in Martian meteorite Northwest Africa 10720. *Journal of Raman Spectroscopy*, 53: 420-434. https://doi.org/10.1002/jrs.6254.

McCubbin F., Elardo S., Shearer C., et al. 2013. A petrogenetic model for the comagmatic origin of chassignites and nakhlites: Inferences from chlorine-rich minerals, petrology, and geochemistry. *Meteoritics & Planetary Science*, 48: 819-853. https://doi.org/10.1111/maps.12095

Ostwald A., Udry A., Day J. M. D., et al. 2024. Melt inclusion heterogeneity in nakhlite and chassignite meteorites and evidence for complicated, multigenerational magmas. *Meteoritics & Planetary Science*, 59(6): 1473-1494. https://doi.org/10.1111/maps.14159.

Ramsey S. R., Ostwald A. M., Udry A., et al. 2024. Northwest Africa 13669, a reequilibrated nakhlite from a previously unsampled portion of the nakhlite igneous complex. *Meteoritics & Planetary Science*, 59(1): 134-170. https://doi.org/10.1111/maps.14112.

Krämer Ruggiu L., Gattacceca J., Devouard B., et al. 2020. Caleta el Cobre 022 Martian meteorite: Increasing nakhlite diversity. *Meteoritics & Planetary Science*, 55(7): 1539-1563. https://doi.org/10.1111/maps.13534.

Udry A., Day J. M. D. 2020. 1.34 billion-year-old magmatism on Mars evaluated from the co-genetic nakhlite and chassignite meteorites. *Geochimica et Cosmochimica Acta*, 238: 292-315. https://doi.org/10.1016/j.gca.2018.07.006.

Wieser P., Petrelli M., Lubbers J., et al. 2022. Thermobar: an open-source Python3 tool for thermobarometry and hygrometry. *Volcanica*, 5: 349-384. https://doi.org/10.30909/vol.05.02.349384.
