# ============================================================
# 09_SG_first_derivative_detail.R
# Savitzky-Golay First Derivative Spectral Detail
# ============================================================

library(tidyverse)
library(prospectr)
library(readr)
library(ggplot2)

# ------------------------------------------------------------
# 1. Project setup
# ------------------------------------------------------------

project_dir <- "~/GitHub/Digital-Soil-Spectroscopy-for-Soil-Health-Assessment"

setwd(project_dir)

dir.create(
  "Outputs/Figures",
  recursive = TRUE,
  showWarnings = FALSE
)

# ------------------------------------------------------------
# 2. Load MIR spectral data
# ------------------------------------------------------------

mir_file <- "Data/processed/mir_reference_matched.csv"

mir_data <- read_csv(mir_file, show_col_types = FALSE)

cat("Number of samples:", nrow(mir_data), "\n")

# ------------------------------------------------------------
# 3. Identify spectral variables
# ------------------------------------------------------------

# Spectral columns are numeric columns excluding reference variables
# Adjust this selection only if your processed dataset uses
# different column names.

spectral_cols <- names(mir_data)[
  grepl("^[0-9]", names(mir_data))
]

spectra <- as.matrix(mir_data[, spectral_cols])

cat("Number of spectral variables:", ncol(spectra), "\n")

# ------------------------------------------------------------
# 4. Convert column names to wavenumbers
# ------------------------------------------------------------

wavenumbers <- as.numeric(spectral_cols)

# Remove columns that could not be converted to numbers
valid <- !is.na(wavenumbers)

wavenumbers <- wavenumbers[valid]
spectra <- spectra[, valid]

# Sort by wavenumber
ord <- order(wavenumbers)

wavenumbers <- wavenumbers[ord]
spectra <- spectra[, ord]

# ------------------------------------------------------------
# 5. Apply Savitzky-Golay first derivative
# ------------------------------------------------------------

sg_first <- savitzkyGolay(
  X = spectra,
  m = 1,
  p = 2,
  w = 11
)

cat(
  "First derivative dimensions:",
  nrow(sg_first),
  "samples x",
  ncol(sg_first),
  "variables\n"
)

# The SG transformation reduces the number of usable
# spectral variables depending on the window size.

sg_wavenumbers <- wavenumbers[
  seq_len(ncol(sg_first))
]

# ------------------------------------------------------------
# 6. Convert to plotting format
# ------------------------------------------------------------

# Select a manageable number of representative samples
# for a clean portfolio figure.

n_show <- min(20, nrow(sg_first))

plot_data <- as.data.frame(sg_first[1:n_show, ])

plot_data$Sample <- paste0(
  "Sample ",
  seq_len(n_show)
)

plot_long <- plot_data %>%
  pivot_longer(
    cols = -Sample,
    names_to = "Variable",
    values_to = "Derivative"
  )

plot_long$Wavenumber <- rep(
  sg_wavenumbers,
  times = n_show
)

# ------------------------------------------------------------
# 7. Generate figure
# ------------------------------------------------------------

p <- ggplot(
  plot_long,
  aes(
    x = Wavenumber,
    y = Derivative,
    group = Sample
  )
) +
  geom_line(
    alpha = 0.55,
    linewidth = 0.6
  ) +
  scale_x_reverse() +
  labs(
    title = "Savitzky-Golay First Derivative Spectra",
    subtitle = "Detailed view of preprocessed MIR spectral signatures",
    x = expression("Wavenumber (cm"^{-1}*")"),
    y = "First derivative response"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 18
    ),
    plot.subtitle = element_text(
      size = 12
    ),
    legend.position = "none"
  )

# ------------------------------------------------------------
# 8. Save figure
# ------------------------------------------------------------

ggsave(
  "Outputs/Figures/SG_first_derivative_spectra_detail.png",
  p,
  width = 12,
  height = 7,
  dpi = 300
)

cat("\nFigure saved successfully:\n")
cat("Outputs/Figures/SG_first_derivative_spectra_detail.png\n")