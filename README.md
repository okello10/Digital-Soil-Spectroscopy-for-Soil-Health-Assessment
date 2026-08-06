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

This repository demonstrates an end-to-end workflow for analyzing soil spectroscopy data using statistical and machine learning techniques...
## Overview

This repository demonstrates an end-to-end workflow for analyzing soil spectroscopy data using statistical and machine learning techniques. The project uses Mid-Infrared (MIR) spectra, laboratory reference measurements, and Portable X-Ray Fluorescence (pXRF) data collected from soil samples in Bungoma County, Kenya.

The objective is to evaluate the potential of digital soil spectroscopy for predicting soil properties and supporting soil health assessment.

---

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

Data Analyst | Soil Spectroscopy | Agricultural Data Science | Machine Learning

#Digital-Soil-Spectroscopy-for-Soil-Health-Assessment
│
├── data
│   ├── raw
│   ├── processed
│   └── metadata
│
├── scripts
│
├── figures
│
├── reports
│
├── dashboard
│
├── presentation
│
└── docs
