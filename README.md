# Digital Soil Spectroscopy for Soil Health Assessment

![R](https://img.shields.io/badge/R-276DC3?style=for-the-badge&logo=r&logoColor=white)
![RStudio](https://img.shields.io/badge/RStudio-75AADB?style=for-the-badge&logo=rstudio&logoColor=white)
![Machine Learning](https://img.shields.io/badge/Machine-Learning-0A9396?style=for-the-badge)
![PLSR](https://img.shields.io/badge/PLSR-8E44AD?style=for-the-badge)
![Random Forest](https://img.shields.io/badge/Random-Forest-2E8B57?style=for-the-badge)
![PCA](https://img.shields.io/badge/PCA-1F77B4?style=for-the-badge)
![Soil Spectroscopy](https://img.shields.io/badge/Soil-Spectroscopy-B5651D?style=for-the-badge)
![Agricultural Data Science](https://img.shields.io/badge/Agricultural-Data%20Science-4CAF50?style=for-the-badge)

![GitHub last commit](https://img.shields.io/github/last-commit/okello10/Digital-Soil-Spectroscopy-for-Soil-Health-Assessment?style=for-the-badge)

![GitHub repo size](https://img.shields.io/github/repo-size/okello10/Digital-Soil-Spectroscopy-for-Soil-Health-Assessment?style=for-the-badge)

![GitHub stars](https://img.shields.io/github/stars/okello10/Digital-Soil-Spectroscopy-for-Soil-Health-Assessment?style=for-the-badge)

## Overview

This repository demonstrates an end-to-end workflow for analyzing soil spectroscopy data using statistical and machine learning techniques. The project uses Mid-Infrared (MIR) spectra, laboratory reference measurements, and Portable X-Ray Fluorescence (pXRF) data collected from soil samples in Bungoma County, Kenya.

The objective is to evaluate the potential of digital soil spectroscopy for predicting soil properties and supporting soil health assessment.

---

## Key Results

- Processed MIR spectral data from 140 soil samples.
- Developed PLS regression models for four soil properties.
- Achieved the strongest predictive performance for Acidified Nitrogen (R² = 0.822, RPD = 2.38).
- Applied spectral preprocessing, PCA, cross-validation, and independent test-set evaluation.
- Generated reproducible visualizations and model-performance reports using R.

## Objectives

- Import and clean soil spectroscopy datasets
- Explore laboratory reference data
- Perform spectral preprocessing
- Conduct Principal Component Analysis (PCA)
- Develop Partial Least Squares (PLS) regression models
- Compare PLS with Random Forest models
- Assess model performance using independent validation datasets
- Visualize spectral patterns and prediction accuracy

---

## Study Area

Bungoma County, Kenya

---

## Data Sources

The project integrates multiple datasets:

- MIR spectral data
- Laboratory reference soil properties
- Carbon and Nitrogen (CN) measurements
- Portable X-Ray Fluorescence (pXRF) data
- Calibration datasets
- Validation datasets

*Raw datasets are not included in this repository where they are subject to data ownership or confidentiality restrictions.*

---

## Project Workflow

1. Data Import
2. Data Cleaning
3. Exploratory Data Analysis
4. Spectral Preprocessing
5. Principal Component Analysis
6. Partial Least Squares Regression
7. Random Forest Modelling
8. Model Validation
9. Results Visualization
10. Reporting

---

## Spectral Exploration

The raw Mid-Infrared (MIR) spectra were explored to assess spectral variation across the 140 soil samples. The spectra covered a wavenumber range of approximately 601.7-4001.6 cm-1, with 1,764 spectral variables.

### Raw MIR Spectral Signatures

The spectral signatures provide an overview of the variation captured across the MIR wavelength range before spectral preprocessing.

![Raw MIR Spectral Signatures](Outputs/Figures/Raw_MIR_Spectral_Signatures.png)

---

## Principal Component Analysis

Principal Component Analysis (PCA) was performed on the SNV-preprocessed MIR spectra to explore major patterns of spectral variation and reduce the dimensionality of the 1,764 spectral variables.

The first principal component (PC1) explained **55.51%** of the total variance, while PC2 explained **25.60%**. Together, the first two components explained **81.11%** of the spectral variance.

### PCA Score Plot

![PCA Score Plot](Outputs/Figures/PCA_scores_PC1_PC2.png)

The PCA score plot shows the distribution of soil samples in the first two principal-component dimensions and provides an overview of spectral similarity and variation among samples.

### Property-Coloured PCA

PCA scores were additionally coloured according to laboratory reference measurements for the four target soil properties.

#### Total Nitrogen

![PCA Total Nitrogen](Outputs/Figures/PCA_Total_Nitrogen.png)

#### Total Carbon

![PCA Total Carbon](Outputs/Figures/PCA_Total_Carbon.png)

#### Acidified Nitrogen

![PCA Acidified Nitrogen](Outputs/Figures/PCA_Acidified_Nitrogen.png)

#### Acidified Carbon

![PCA Acidified Carbon](Outputs/Figures/PCA_Acidified_Carbon.png)

---

## PLS Regression Calibration

Partial Least Squares (PLS) regression was used to develop predictive models for four soil properties using preprocessed MIR spectral data:

- Total Nitrogen
- Total Carbon
- Acidified Nitrogen
- Acidified Carbon

The models were evaluated using an independent test set and assessed using R², RMSE, and Ratio of Performance to Deviation (RPD).

### Model Performance

| Soil Property | PLS Components | R² | RMSE | RPD |
|---|---:|---:|---:|---:|
| Total Nitrogen | 13 | 0.675 | 0.0206 | 1.78 |
| Total Carbon | 16 | 0.760 | 0.2386 | 1.83 |
| Acidified Nitrogen | 14 | **0.822** | **0.0150** | **2.38** |
| Acidified Carbon | 20 | 0.740 | 0.2546 | 1.95 |

### PLS Calibration Results

#### Total Nitrogen

![PLS Calibration - Total Nitrogen](Outputs/Figures/PLS_Total_Nitrogen_Observed_vs_Predicted.png)

#### Total Carbon

![PLS Calibration - Total Carbon](Outputs/Figures/PLS_Total_Carbon_Observed_vs_Predicted.png)

#### Acidified Nitrogen

![PLS Calibration - Acidified Nitrogen](Outputs/Figures/PLS_Acidified_Nitrogen_Observed_vs_Predicted.png)

#### Acidified Carbon

![PLS Calibration - Acidified Carbon](Outputs/Figures/PLS_Acidified_Carbon_Observed_vs_Predicted.png)

### Key Finding

The Acidified Nitrogen model achieved the strongest overall predictive performance, with an R² of **0.822**, RMSE of **0.015**, and RPD of **2.38**.


## Random Forest Calibration

Random Forest regression was used as an alternative machine-learning approach for predicting the same four soil properties from preprocessed MIR spectral data:

- Total Nitrogen
- Total Carbon
- Acidified Nitrogen
- Acidified Carbon

The Random Forest models were optimized using cross-validation to determine the optimal number of variables randomly sampled at each split (`mtry`). Model performance was evaluated using an independent test set based on R², RMSE, and Ratio of Performance to Deviation (RPD).

### Model Performance

| Soil Property      | Optimal mtry | R²    | RMSE   | RPD  |
| ------------------ | -----------: | ----: | ------: | ----: |
| Total Nitrogen     | 75           | 0.560 | 0.0243 | 1.50 |
| Total Carbon       | 50           | 0.644 | 0.2578 | 1.69 |
| Acidified Nitrogen | 10           | 0.575 | 0.0237 | 1.50 |
| Acidified Carbon   | 100          | 0.558 | 0.3259 | 1.52 |

### Random Forest Calibration Results

#### Total Nitrogen

![Random Forest Total Nitrogen](Outputs/Figures/RF_Total_Nitrogen_Observed_vs_Predicted.png)

#### Total Carbon

![Random Forest Total Carbon](Outputs/Figures/RF_Total_Carbon_Observed_vs_Predicted.png)

#### Acidified Nitrogen

![Random Forest Acidified Nitrogen](Outputs/Figures/RF_Acidified_Nitrogen_Observed_vs_Predicted.png)

#### Acidified Carbon

![Random Forest Acidified Carbon](Outputs/Figures/RF_Acidified_Carbon_Observed_vs_Predicted.png)


### Key Finding

Random Forest provided moderate predictive performance across the four soil properties. Total Carbon achieved the strongest Random Forest performance with an R² of 0.644 and RPD of 1.69.

Compared with the PLS models, Random Forest produced lower predictive performance for all four soil properties. This comparison demonstrates the importance of evaluating multiple modelling approaches when working with high-dimensional soil spectroscopy data.


## PLS vs Random Forest Comparison

The predictive performance of Partial Least Squares (PLS) regression and Random Forest models was compared across the four soil properties.

The comparison shows that PLS regression consistently outperformed Random Forest for the evaluated soil properties, with the strongest PLS performance observed for Acidified Nitrogen (R² = 0.822, RPD = 2.38).

![PLS vs Random Forest Model Comparison](Outputs/Figures/PLS_vs_Random_Forest_Comparison.png)

### Key Insight

PLS regression demonstrated stronger predictive performance than Random Forest across all four evaluated soil properties under the modelling and validation setup used in this study.


## Software

- R
- RStudio

### Main Packages

- tidyverse
- prospectr
- pls
- caret
- randomForest
- ggplot2
- plotly
- janitor
- readr

---

## Repository Structure

```text
scripts/
figures/
reports/
dashboard/
presentation/
```

---

## Sample Outputs

- Raw MIR spectra
- PCA score plots
- Soil property distributions
- PLS prediction plots
- Random Forest performance
- Variable importance
- Model comparison

---

## Future Development

- Interactive Shiny Dashboard
- Power BI Dashboard
- Soil Nutrient Prediction App
- Spatial Mapping using QGIS
- Deep Learning Models

---

## Author

Gard Okello

Data Analyst | Soil Spectroscopy | Agricultural Data Science | Machine Learning | Research Assistant 