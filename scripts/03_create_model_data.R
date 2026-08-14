# ================================================================
# Digital Soil Spectroscopy for Soil Health Assessment
# Script: 03_create_model_data.R
# Purpose: Create matched MIR spectroscopy and reference dataset
# Author: Gard Okello
# ================================================================


# ----------------------------------------------------------------
# 1. Project setup
# ----------------------------------------------------------------

source("scripts/00_setup.R")


# ----------------------------------------------------------------
# 2. Data directory
# ----------------------------------------------------------------

data_dir <- "Data/SOIL"


# ----------------------------------------------------------------
# 3. Import datasets
# ----------------------------------------------------------------

spectra <- readr::read_csv(
  file.path(data_dir, "2017_2018 soil mir spectra.csv"),
  show_col_types = FALSE
)

reference <- readr::read_csv(
  file.path(data_dir, "Bungoma 2017_2018 reference data.csv"),
  show_col_types = FALSE
)


# ----------------------------------------------------------------
# 4. Identify matched samples
# ----------------------------------------------------------------

matched_ssn <- intersect(
  spectra$SSN,
  reference$SSN
)

cat(
  "Number of matched samples:",
  length(matched_ssn),
  "\n"
)


# ----------------------------------------------------------------
# 5. Create modelling dataset
# ----------------------------------------------------------------

model_data <- spectra |>
  dplyr::inner_join(
    reference,
    by = "SSN"
  )


# ----------------------------------------------------------------
# 6. Check dimensions
# ----------------------------------------------------------------

cat(
  "Modelling dataset:",
  nrow(model_data),
  "rows x",
  ncol(model_data),
  "columns\n"
)


# ----------------------------------------------------------------
# 7. Check target variables
# ----------------------------------------------------------------

target_variables <- c(
  "Total_Nitrogen",
  "Total_Carbon",
  "Acidified_Nitrogen",
  "Acidified_Carbon"
)

cat("\nTarget variable missing values:\n")

print(
  sapply(
    model_data[target_variables],
    function(x) sum(is.na(x))
  )
)


# ----------------------------------------------------------------
# 8. Display target variable summary
# ----------------------------------------------------------------

cat("\nTarget variable summary:\n")

print(
  summary(model_data[target_variables])
)


# ----------------------------------------------------------------
# 9. Check duplicate SSNs
# ----------------------------------------------------------------

duplicate_ssn <- model_data$SSN[
  duplicated(model_data$SSN)
]

cat(
  "\nDuplicate SSNs:",
  length(duplicate_ssn),
  "\n"
)

# ----------------------------------------------------------------
# 11. Identify spectral variables
# ----------------------------------------------------------------

spectral_columns <- names(spectra)[
  grepl("^m", names(spectra))
]

cat(
  "\nNumber of spectral variables:",
  length(spectral_columns),
  "\n"
)

cat("\nFirst 10 spectral variables:\n")
print(head(spectral_columns, 10))

cat("\nLast 10 spectral variables:\n")
print(tail(spectral_columns, 10))


# ----------------------------------------------------------------
# 12. Convert spectral column names to numeric wavenumbers
# ----------------------------------------------------------------

wavenumbers <- as.numeric(
  sub("^m", "", spectral_columns)
)

cat("\nWavenumber range:\n")
print(range(wavenumbers, na.rm = TRUE))

cat("\nNumber of invalid wavenumbers:\n")
print(sum(is.na(wavenumbers)))


# ----------------------------------------------------------------
# 13. Check ordering of spectral variables
# ----------------------------------------------------------------

cat("\nAre spectral variables ordered?\n")

print(
  all(diff(wavenumbers) < 0)
)


# ----------------------------------------------------------------
# 10. Save modelling dataset
# ----------------------------------------------------------------

dir.create(
  "Data/processed",
  recursive = TRUE,
  showWarnings = FALSE
)

readr::write_csv(
  model_data,
  "Data/processed/mir_reference_matched.csv"
)


# ----------------------------------------------------------------
# End of script
# ----------------------------------------------------------------