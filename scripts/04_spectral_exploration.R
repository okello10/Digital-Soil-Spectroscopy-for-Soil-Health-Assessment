# ================================================================
# Digital Soil Spectroscopy for Soil Health Assessment
# Script: 04_spectral_exploration.R
# Purpose: Explore raw MIR soil spectra
# Author: Gard Okello
# ================================================================


# ----------------------------------------------------------------
# 1. Project setup
# ----------------------------------------------------------------

source("scripts/00_setup.R")


# ----------------------------------------------------------------
# 2. Load matched MIR-reference dataset
# ----------------------------------------------------------------

model_data <- readr::read_csv(
  "Data/processed/mir_reference_matched.csv",
  show_col_types = FALSE
)


# ----------------------------------------------------------------
# 3. Identify spectral variables
# ----------------------------------------------------------------

spectral_columns <- names(model_data)[
  grepl("^m", names(model_data))
]


# ----------------------------------------------------------------
# 4. Extract wavenumbers
# ----------------------------------------------------------------

wavenumbers <- as.numeric(
  sub("^m", "", spectral_columns)
)


# ----------------------------------------------------------------
# 5. Extract spectral matrix
# ----------------------------------------------------------------

spectral_matrix <- as.matrix(
  model_data[spectral_columns]
)


# ----------------------------------------------------------------
# 6. Basic spectral information
# ----------------------------------------------------------------

cat("\n--- Spectral Dataset ---\n")

cat(
  "Number of samples:",
  nrow(spectral_matrix),
  "\n"
)

cat(
  "Number of spectral variables:",
  ncol(spectral_matrix),
  "\n"
)

cat(
  "Wavenumber range:",
  min(wavenumbers),
  "to",
  max(wavenumbers),
  "\n"
)


# ----------------------------------------------------------------
# 7. Plot raw spectra
# ----------------------------------------------------------------

plot(
  wavenumbers,
  spectral_matrix[1, ],
  type = "l",
  xlim = rev(range(wavenumbers)),
  xlab = "Wavenumber (cm-1)",
  ylab = "Spectral Response",
  main = "Raw MIR Spectra - Bungoma Soil Samples"
)

for (i in 2:min(20, nrow(spectral_matrix))) {
  
  lines(
    wavenumbers,
    spectral_matrix[i, ]
  )
}


# ----------------------------------------------------------------
# 8. Save figure
# ----------------------------------------------------------------

dir.create(
  "Outputs/Figures",
  recursive = TRUE,
  showWarnings = FALSE
)

png(
  "Outputs/Figures/raw_MIR_spectra.png",
  width = 1200,
  height = 800,
  res = 150
)

matplot(
  wavenumbers,
  t(spectral_matrix[1:20, ]),
  type = "l",
  lty = 1,
  xlab = "Wavenumber (cm-1)",
  ylab = "Spectral Response",
  main = "Raw MIR Spectra - Bungoma Soil Samples"
)

dev.off()


# ----------------------------------------------------------------
# End of script
# ----------------------------------------------------------------

cat("\nRaw MIR spectral exploration completed successfully.\n")