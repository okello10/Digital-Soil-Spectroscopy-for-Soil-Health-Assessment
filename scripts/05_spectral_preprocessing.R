# ================================================================
# Digital Soil Spectroscopy for Soil Health Assessment
# Script: 05_spectral_preprocessing.R
# Purpose: Preprocess MIR soil spectra
# Author: Gard Okello
# ================================================================


# ----------------------------------------------------------------
# 1. Project setup
# ----------------------------------------------------------------

source("scripts/00_setup.R")


# ----------------------------------------------------------------
# 2. Load matched modelling dataset
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
# 6. Check spectral data
# ----------------------------------------------------------------

cat("\n--- Spectral Preprocessing ---\n")

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
  "Missing spectral values:",
  sum(is.na(spectral_matrix)),
  "\n"
)


# Stop if spectral data contain missing values

if (anyNA(spectral_matrix)) {
  stop("Missing values detected in spectral data.")
}


# ----------------------------------------------------------------
# 7. Standard Normal Variate (SNV)
# ----------------------------------------------------------------

cat("\nApplying Standard Normal Variate (SNV)...\n")

spectra_snv <- prospectr::standardNormalVariate(
  spectral_matrix
)


# ----------------------------------------------------------------
# 8. Savitzky-Golay first derivative
# ----------------------------------------------------------------

cat("Applying Savitzky-Golay first derivative...\n")

spectra_sg1 <- prospectr::savitzkyGolay(
  spectral_matrix,
  m = 1,
  p = 2,
  w = 11
)


# ----------------------------------------------------------------
# 9. Basic checks
# ----------------------------------------------------------------

cat("\n--- Preprocessing Checks ---\n")

cat(
  "SNV dimensions:",
  nrow(spectra_snv),
  "x",
  ncol(spectra_snv),
  "\n"
)

cat(
  "SG first derivative dimensions:",
  nrow(spectra_sg1),
  "x",
  ncol(spectra_sg1),
  "\n"
)


# ----------------------------------------------------------------
# 10. Create output folders
# ----------------------------------------------------------------

dir.create(
  "Outputs/Figures",
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  "Data/processed",
  recursive = TRUE,
  showWarnings = FALSE
)


# ----------------------------------------------------------------
# 11. Plot raw versus SNV spectra
# ----------------------------------------------------------------

png(
  "Outputs/Figures/raw_vs_SNV_spectra.png",
  width = 1400,
  height = 800,
  res = 150
)

plot(
  wavenumbers,
  spectral_matrix[1, ],
  type = "l",
  xlim = rev(range(wavenumbers)),
  xlab = "Wavenumber (cm-1)",
  ylab = "Spectral Response",
  main = "Raw MIR Spectra vs SNV - Bungoma Soil"
)

for (i in 2:min(20, nrow(spectral_matrix))) {
  lines(
    wavenumbers,
    spectral_matrix[i, ]
  )
}

dev.off()


# ----------------------------------------------------------------
# 12. Plot SNV spectra
# ----------------------------------------------------------------

png(
  "Outputs/Figures/SNV_spectra.png",
  width = 1400,
  height = 800,
  res = 150
)

plot(
  wavenumbers,
  spectra_snv[1, ],
  type = "l",
  xlim = rev(range(wavenumbers)),
  xlab = "Wavenumber (cm-1)",
  ylab = "SNV Spectral Response",
  main = "SNV-Processed MIR Spectra - Bungoma Soil"
)

for (i in 2:min(20, nrow(spectra_snv))) {
  lines(
    wavenumbers,
    spectra_snv[i, ]
  )
}

dev.off()


# ----------------------------------------------------------------
# 13. Plot first derivative spectra
# ----------------------------------------------------------------

sg_wavenumbers <- wavenumbers[6:(length(wavenumbers) - 5)]

png(
  "Outputs/Figures/SG_first_derivative_spectra.png",
  width = 1400,
  height = 800,
  res = 150
)

plot(
  sg_wavenumbers,
  spectra_sg1[1, ],
  type = "l",
  xlim = rev(range(sg_wavenumbers)),
  xlab = "Wavenumber (cm-1)",
  ylab = "First Derivative",
  main = "Savitzky-Golay First Derivative - Bungoma Soil"
)

for (i in 2:min(20, nrow(spectra_sg1))) {
  lines(
    sg_wavenumbers,
    spectra_sg1[i, ]
  )
}

dev.off()


# ----------------------------------------------------------------
# 14. Save preprocessed spectra
# ----------------------------------------------------------------

saveRDS(
  spectra_snv,
  "Data/processed/MIR_spectra_SNV.rds"
)

saveRDS(
  spectra_sg1,
  "Data/processed/MIR_spectra_SG_first_derivative.rds"
)

saveRDS(
  wavenumbers,
  "Data/processed/MIR_wavenumbers.rds"
)


# ----------------------------------------------------------------
# 15. Completion message
# ----------------------------------------------------------------

cat("\nPreprocessing completed successfully.\n")

cat(
  "Created: SNV spectra\n"
)

cat(
  "Created: Savitzky-Golay first derivative spectra\n"
)

cat(
  "Created: preprocessing figures\n"
)