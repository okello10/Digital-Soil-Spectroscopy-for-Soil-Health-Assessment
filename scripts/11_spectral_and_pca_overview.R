# ================================================================
# Digital Soil Spectroscopy for Soil Health Assessment
# Script: 11_spectral_and_pca_overview.R
# Purpose: Create combined MIR spectral and PCA portfolio figure
# Author: Gard Okello
# ================================================================


# ----------------------------------------------------------------
# 1. Project setup
# ----------------------------------------------------------------

source("scripts/00_setup.R")


# ----------------------------------------------------------------
# 2. Load required packages
# ----------------------------------------------------------------

library(tidyverse)
library(ggplot2)
library(viridis)
library(patchwork)


# ----------------------------------------------------------------
# 3. Load matched modelling dataset
# ----------------------------------------------------------------

model_data <- readr::read_csv(
  "Data/processed/mir_reference_matched.csv",
  show_col_types = FALSE
)


# ----------------------------------------------------------------
# 4. Load SNV spectra
# ----------------------------------------------------------------

spectra_snv <- readRDS(
  "Data/processed/MIR_spectra_SNV.rds"
)


# ----------------------------------------------------------------
# 5. Load PCA results
# ----------------------------------------------------------------

pca_result <- readRDS(
  "Data/processed/PCA_SNV_results.rds"
)


# ----------------------------------------------------------------
# 6. Identify spectral variables
# ----------------------------------------------------------------

spectral_columns <- names(model_data)[
  grepl("^m", names(model_data))
]


# ----------------------------------------------------------------
# 7. Extract wavenumbers
# ----------------------------------------------------------------

wavenumbers <- as.numeric(
  sub("^m", "", spectral_columns)
)


# ----------------------------------------------------------------
# 8. Basic checks
# ----------------------------------------------------------------

cat("\n========================================\n")
cat("MIR SPECTRAL AND PCA OVERVIEW\n")
cat("========================================\n")

cat(
  "Number of samples:",
  nrow(model_data),
  "\n"
)

cat(
  "Number of raw spectral variables:",
  length(wavenumbers),
  "\n"
)

cat(
  "Number of SNV spectral variables:",
  ncol(spectra_snv),
  "\n"
)

cat(
  "Wavenumber range:",
  min(wavenumbers),
  "to",
  max(wavenumbers),
  "cm-1\n"
)


# ----------------------------------------------------------------
# 9. Calculate PCA variance explained
# ----------------------------------------------------------------

variance_explained <- (
  pca_result$sdev^2 /
    sum(pca_result$sdev^2)
) * 100


pc1_var <- variance_explained[1]
pc2_var <- variance_explained[2]

cumulative_pc12 <- pc1_var + pc2_var


cat(
  "PC1 variance explained:",
  round(pc1_var, 2),
  "%\n"
)

cat(
  "PC2 variance explained:",
  round(pc2_var, 2),
  "%\n"
)

cat(
  "PC1 + PC2:",
  round(cumulative_pc12, 2),
  "%\n"
)


# ----------------------------------------------------------------
# 10. Create output directory
# ----------------------------------------------------------------

dir.create(
  "Outputs/Figures",
  recursive = TRUE,
  showWarnings = FALSE
)


# ================================================================
# SECTION A: RAW MIR SPECTRAL SIGNATURES
# ================================================================


# ----------------------------------------------------------------
# 11. Convert raw spectra to plotting format
# ----------------------------------------------------------------

spectral_data <- as.data.frame(
  model_data[spectral_columns]
)

spectral_data$Sample_ID <- seq_len(
  nrow(spectral_data)
)


spectral_long <- spectral_data %>%
  pivot_longer(
    cols = -Sample_ID,
    names_to = "Wavenumber",
    values_to = "Response"
  )


spectral_long$Wavenumber <- as.numeric(
  sub(
    "^m",
    "",
    spectral_long$Wavenumber
  )
)


# ----------------------------------------------------------------
# 12. Raw spectral signatures plot
# ----------------------------------------------------------------

raw_spectra_plot <- ggplot(
  spectral_long,
  aes(
    x = Wavenumber,
    y = Response,
    group = Sample_ID,
    color = Sample_ID
  )
) +
  
  geom_line(
    linewidth = 0.35,
    alpha = 0.45
  ) +
  
  scale_x_reverse() +
  
  scale_color_viridis_c(
    option = "viridis",
    name = "Sample order"
  ) +
  
  labs(
    title = "MIR Spectral Signatures (Raw Spectra)",
    subtitle = paste0(
      "Raw Mid-Infrared spectra of ",
      nrow(model_data),
      " soil samples from Bungoma County, Kenya"
    ),
    x = "Wavenumber (cm-1)",
    y = "Spectral response"
  ) +
  
  theme_minimal(
    base_size = 12
  ) +
  
  theme(
    plot.title = element_text(
      face = "bold",
      size = 16
    ),
    plot.subtitle = element_text(
      size = 11
    ),
    legend.position = "right",
    panel.grid.minor = element_blank()
  )


# ================================================================
# SECTION B: PCA SCORE PLOT
# ================================================================


# ----------------------------------------------------------------
# 13. Create PCA score data frame
# ----------------------------------------------------------------

pca_scores <- as.data.frame(
  pca_result$x[, 1:2]
)


pca_scores$Sample_ID <- seq_len(
  nrow(pca_scores)
)


# ----------------------------------------------------------------
# 14. PCA score plot
# ----------------------------------------------------------------

pca_score_plot <- ggplot(
  pca_scores,
  aes(
    x = PC1,
    y = PC2,
    color = Sample_ID
  )
) +
  
  geom_hline(
    yintercept = 0,
    linetype = "dashed",
    alpha = 0.35
  ) +
  
  geom_vline(
    xintercept = 0,
    linetype = "dashed",
    alpha = 0.35
  ) +
  
  geom_point(
    size = 2.8,
    alpha = 0.9
  ) +
  
  scale_color_viridis_c(
    option = "viridis",
    name = "Sample order"
  ) +
  
  labs(
    title = "PCA Score Plot (SNV-Processed Spectra)",
    subtitle = paste0(
      "PCA of ",
      ncol(spectra_snv),
      " spectral variables"
    ),
    x = paste0(
      "PC1 (",
      round(pc1_var, 1),
      "%)"
    ),
    y = paste0(
      "PC2 (",
      round(pc2_var, 1),
      "%)"
    )
  ) +
  
  theme_minimal(
    base_size = 12
  ) +
  
  theme(
    plot.title = element_text(
      face = "bold",
      size = 15
    ),
    plot.subtitle = element_text(
      size = 10
    ),
    legend.position = "none",
    panel.grid.minor = element_blank()
  )


# ================================================================
# SECTION C: PROPERTY-COLOURED PCA PLOTS
# ================================================================


# ----------------------------------------------------------------
# 15. Add soil properties to PCA scores
# ----------------------------------------------------------------

pca_scores$Total_Nitrogen <-
  model_data$Total_Nitrogen

pca_scores$Total_Carbon <-
  model_data$Total_Carbon

pca_scores$Acidified_Nitrogen <-
  model_data$Acidified_Nitrogen

pca_scores$Acidified_Carbon <-
  model_data$Acidified_Carbon


# ----------------------------------------------------------------
# 16. Function for property-coloured PCA
# ----------------------------------------------------------------

make_property_pca <- function(
    data,
    property,
    property_label
) {
  
  ggplot(
    data,
    aes(
      x = PC1,
      y = PC2,
      color = .data[[property]]
    )
  ) +
    
    geom_hline(
      yintercept = 0,
      linetype = "dashed",
      alpha = 0.25
    ) +
    
    geom_vline(
      xintercept = 0,
      linetype = "dashed",
      alpha = 0.25
    ) +
    
    geom_point(
      size = 1.9,
      alpha = 0.85,
      na.rm = TRUE
    ) +
    
    scale_color_viridis_c(
      option = "viridis",
      name = property_label,
      na.value = "grey70"
    ) +
    
    labs(
      title = property_label,
      x = paste0(
        "PC1 (",
        round(pc1_var, 1),
        "%)"
      ),
      y = paste0(
        "PC2 (",
        round(pc2_var, 1),
        "%)"
      )
    ) +
    
    theme_minimal(
      base_size = 10
    ) +
    
    theme(
      plot.title = element_text(
        face = "bold",
        size = 12,
        hjust = 0.5
      ),
      legend.position = "right",
      panel.grid.minor = element_blank()
    )
}


# ----------------------------------------------------------------
# 17. Generate four property-coloured PCA plots
# ----------------------------------------------------------------

pca_total_n <- make_property_pca(
  pca_scores,
  "Total_Nitrogen",
  "Total Nitrogen (%)"
)


pca_total_c <- make_property_pca(
  pca_scores,
  "Total_Carbon",
  "Total Carbon (%)"
)


pca_acid_n <- make_property_pca(
  pca_scores,
  "Acidified_Nitrogen",
  "Acidified Nitrogen (%)"
)


pca_acid_c <- make_property_pca(
  pca_scores,
  "Acidified_Carbon",
  "Acidified Carbon (%)"
)


# ================================================================
# SECTION D: COMBINE THE PANELS
# ================================================================


# ----------------------------------------------------------------
# 18. Property PCA panel
# ----------------------------------------------------------------

property_pca_panel <-
  (pca_total_n | pca_total_c) /
  (pca_acid_n | pca_acid_c)


# ----------------------------------------------------------------
# 19. Add section headers
# ----------------------------------------------------------------

raw_section <-
  raw_spectra_plot +
  plot_annotation(
    title = "1. MIR SPECTRAL SIGNATURES (RAW SPECTRA)"
  )


pca_section <-
  pca_score_plot +
  plot_annotation(
    title = "2. PCA SCORE PLOT (SNV-PROCESSED SPECTRA)"
  )


property_section <-
  property_pca_panel +
  plot_annotation(
    title = "3. PCA SCORES COLOURED BY SOIL PROPERTIES"
  )


# ----------------------------------------------------------------
# 20. Build final portfolio figure
# ----------------------------------------------------------------

final_figure <-
  raw_spectra_plot /
  (pca_score_plot | property_pca_panel)


# ----------------------------------------------------------------
# 21. Add overall title and subtitle
# ----------------------------------------------------------------

final_figure <-
  final_figure +
  plot_annotation(
    title = "MIR Spectral Signatures, PCA and Soil Property Relationships",
    subtitle = paste0(
      "Digital Soil Spectroscopy for Soil Health Assessment | ",
      "Bungoma County, Kenya | n = ",
      nrow(model_data)
    ),
    caption = paste0(
      "PCA performed on SNV-preprocessed MIR spectra. ",
      "PC1 = ",
      round(pc1_var, 2),
      "%; PC2 = ",
      round(pc2_var, 2),
      "%; ",
      "PC1 + PC2 = ",
      round(cumulative_pc12, 2),
      "%."
    ),
    theme = theme(
      plot.title = element_text(
        face = "bold",
        size = 20,
        hjust = 0.5
      ),
      plot.subtitle = element_text(
        size = 12,
        hjust = 0.5
      ),
      plot.caption = element_text(
        size = 9,
        hjust = 0.5
      )
    )
  )


# ----------------------------------------------------------------
# 22. Save final figure
# ----------------------------------------------------------------

output_file <-
  "Outputs/Figures/MIR_Spectral_PCA_Overview.png"


ggsave(
  filename = output_file,
  plot = final_figure,
  width = 16,
  height = 11,
  dpi = 300,
  bg = "white"
)


# ----------------------------------------------------------------
# 23. Completion message
# ----------------------------------------------------------------

cat("\n========================================\n")
cat("COMBINED FIGURE CREATED SUCCESSFULLY\n")
cat("========================================\n")

cat(
  "Output:",
  output_file,
  "\n"
)

cat(
  "Figure dimensions:",
  "16 x 11 inches at 300 dpi\n"
)

cat(
  "Samples:",
  nrow(model_data),
  "\n"
)

cat(
  "Spectral variables:",
  ncol(spectra_snv),
  "\n"
)

cat(
  "PC1 + PC2 variance:",
  round(cumulative_pc12, 2),
  "%\n"
)

cat(
  "\nMIR spectral and PCA overview completed successfully.\n"
)