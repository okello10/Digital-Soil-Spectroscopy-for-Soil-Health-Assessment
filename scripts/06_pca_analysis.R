# ================================================================
# Digital Soil Spectroscopy for Soil Health Assessment
# Script: 06_pca_analysis.R
# Purpose: PCA analysis of preprocessed MIR spectra
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
# 3. Load SNV spectra
# ----------------------------------------------------------------

spectra_snv <- readRDS(
  "Data/processed/MIR_spectra_SNV.rds"
)


# ----------------------------------------------------------------
# 4. Identify spectral variables
# ----------------------------------------------------------------

spectral_columns <- names(model_data)[
  grepl("^m", names(model_data))
]


# ----------------------------------------------------------------
# 5. Extract wavenumbers
# ----------------------------------------------------------------

wavenumbers <- as.numeric(
  sub("^m", "", spectral_columns)
)


# ----------------------------------------------------------------
# 6. Check dimensions
# ----------------------------------------------------------------

cat("\n--- PCA Analysis ---\n")

cat(
  "Number of samples:",
  nrow(spectra_snv),
  "\n"
)

cat(
  "Number of spectral variables:",
  ncol(spectra_snv),
  "\n"
)


# ----------------------------------------------------------------
# 7. Run PCA
# ----------------------------------------------------------------

cat("\nRunning PCA...\n")

pca_result <- prcomp(
  spectra_snv,
  center = TRUE,
  scale. = FALSE
)


# ----------------------------------------------------------------
# 8. PCA variance explained
# ----------------------------------------------------------------

variance_explained <- (
  pca_result$sdev^2 /
    sum(pca_result$sdev^2)
) * 100

cat("\n--- Variance Explained ---\n")

print(
  round(
    variance_explained[1:10],
    2
  )
)


# ----------------------------------------------------------------
# 9. Cumulative variance
# ----------------------------------------------------------------

cumulative_variance <- cumsum(
  variance_explained
)

cat("\nCumulative variance explained:\n")

print(
  round(
    cumulative_variance[1:10],
    2
  )
)


# ----------------------------------------------------------------
# 10. Create output directories
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
# 11. PCA scores plot
# ----------------------------------------------------------------

png(
  "Outputs/Figures/PCA_scores_PC1_PC2.png",
  width = 1400,
  height = 900,
  res = 150
)

plot(
  pca_result$x[, 1],
  pca_result$x[, 2],
  xlab = paste0(
    "PC1 (",
    round(variance_explained[1], 1),
    "%)"
  ),
  ylab = paste0(
    "PC2 (",
    round(variance_explained[2], 1),
    "%)"
  ),
  main = "PCA Scores - SNV-Processed MIR Spectra",
  pch = 19
)

grid()

dev.off()


# ----------------------------------------------------------------
# 12. PCA scree plot
# ----------------------------------------------------------------

png(
  "Outputs/Figures/PCA_variance_explained.png",
  width = 1400,
  height = 900,
  res = 150
)

plot(
  variance_explained[1:min(20, length(variance_explained))],
  type = "b",
  xlab = "Principal Component",
  ylab = "Variance Explained (%)",
  main = "PCA Variance Explained",
  pch = 19
)

grid()

dev.off()


# ----------------------------------------------------------------
# 13. Save PCA results
# ----------------------------------------------------------------

saveRDS(
  pca_result,
  "Data/processed/PCA_SNV_results.rds"
)


readr::write_csv(
  data.frame(
    PC = seq_along(variance_explained),
    Variance_Explained = variance_explained,
    Cumulative_Variance = cumulative_variance
  ),
  "Data/processed/PCA_variance_explained.csv"
)


# ----------------------------------------------------------------
# 14. Create PCA scores dataset
# ----------------------------------------------------------------

pca_scores <- as.data.frame(
  pca_result$x[, 1:2]
)


# ----------------------------------------------------------------
# 15. Add soil properties
# ----------------------------------------------------------------

pca_scores$Total_Nitrogen <- model_data$Total_Nitrogen

pca_scores$Total_Carbon <- model_data$Total_Carbon

pca_scores$Acidified_Nitrogen <-
  model_data$Acidified_Nitrogen

pca_scores$Acidified_Carbon <-
  model_data$Acidified_Carbon


# ----------------------------------------------------------------
# 16. Load ggplot2
# ----------------------------------------------------------------

library(ggplot2)

library(viridis)


# ----------------------------------------------------------------
# 17. Function for property-coloured PCA plots
# ----------------------------------------------------------------

create_property_pca <- function(
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
    
    geom_point(
      size = 3,
      alpha = 0.85,
      na.rm = TRUE
    ) +
    
    scale_color_viridis_c(
      name = property_label,
      na.value = "grey70"
    ) +
    
    labs(
      title = paste(
        "PCA Scores -",
        property_label
      ),
      
      x = paste0(
        "PC1 (",
        round(
          variance_explained[1],
          1
        ),
        "%)"
      ),
      
      y = paste0(
        "PC2 (",
        round(
          variance_explained[2],
          1
        ),
        "%)"
      )
    ) +
    
    theme_minimal(
      base_size = 13
    ) +
    
    theme(
      plot.title = element_text(
        face = "bold"
      ),
      
      legend.position = "right"
    )
}


# ----------------------------------------------------------------
# 18. Create four property-coloured PCA plots
# ----------------------------------------------------------------

# Total Nitrogen

pca_TN <- create_property_pca(
  pca_scores,
  "Total_Nitrogen",
  "Total Nitrogen"
)


# Total Carbon

pca_TC <- create_property_pca(
  pca_scores,
  "Total_Carbon",
  "Total Carbon"
)


# Acidified Nitrogen

pca_AN <- create_property_pca(
  pca_scores,
  "Acidified_Nitrogen",
  "Acidified Nitrogen"
)


# Acidified Carbon

pca_AC <- create_property_pca(
  pca_scores,
  "Acidified_Carbon",
  "Acidified Carbon"
)


# ----------------------------------------------------------------
# 19. Save property-coloured PCA plots
# ----------------------------------------------------------------

ggsave(
  "Outputs/Figures/PCA_Total_Nitrogen.png",
  pca_TN,
  width = 10,
  height = 7,
  dpi = 300
)


ggsave(
  "Outputs/Figures/PCA_Total_Carbon.png",
  pca_TC,
  width = 10,
  height = 7,
  dpi = 300
)


ggsave(
  "Outputs/Figures/PCA_Acidified_Nitrogen.png",
  pca_AN,
  width = 10,
  height = 7,
  dpi = 300
)


ggsave(
  "Outputs/Figures/PCA_Acidified_Carbon.png",
  pca_AC,
  width = 10,
  height = 7,
  dpi = 300
)


# ----------------------------------------------------------------
# 20. Save PCA scores with soil properties
# ----------------------------------------------------------------

readr::write_csv(
  pca_scores,
  "Data/processed/PCA_scores_with_properties.csv"
)


# ----------------------------------------------------------------
# 21. Completion message
# ----------------------------------------------------------------

cat(
  "\nPCA analysis completed successfully.\n"
)

cat(
  "PCA results saved to Data/processed/\n"
)

cat(
  "PCA figures saved to Outputs/Figures/\n"
)

cat(
  "\nProperty-coloured PCA plots created successfully.\n"
)

cat(
  "Four property-coloured plots saved:\n"
)

cat(
  "- PCA_Total_Nitrogen.png\n"
)

cat(
  "- PCA_Total_Carbon.png\n"
)

cat(
  "- PCA_Acidified_Nitrogen.png\n"
)

cat(
  "- PCA_Acidified_Carbon.png\n"
)