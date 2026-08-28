# ============================================================
# 10_PLS_vs_Random_Forest_comparison.R
# PLS vs Random Forest Model Comparison
# ============================================================

library(tidyverse)
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
# 2. PLS model performance
# ------------------------------------------------------------

pls_results <- tibble(
  Soil_Property = c(
    "Total Nitrogen",
    "Total Carbon",
    "Acidified Nitrogen",
    "Acidified Carbon"
  ),
  
  R2 = c(
    0.675,
    0.760,
    0.822,
    0.740
  ),
  
  RMSE = c(
    0.0206,
    0.2386,
    0.0150,
    0.2546
  ),
  
  RPD = c(
    1.78,
    1.83,
    2.38,
    1.95
  ),
  
  Model = "PLS"
)

# ------------------------------------------------------------
# 3. Random Forest model performance
# ------------------------------------------------------------

rf_results <- tibble(
  Soil_Property = c(
    "Total Nitrogen",
    "Total Carbon",
    "Acidified Nitrogen",
    "Acidified Carbon"
  ),
  
  R2 = c(
    0.5600,
    0.6436,
    0.5752,
    0.5578
  ),
  
  RMSE = c(
    0.0243,
    0.2578,
    0.0237,
    0.3259
  ),
  
  RPD = c(
    1.5045,
    1.6913,
    1.5038,
    1.5213
  ),
  
  Model = "Random Forest"
)

# ------------------------------------------------------------
# 4. Combine results
# ------------------------------------------------------------

comparison_data <- bind_rows(
  pls_results,
  rf_results
)

comparison_data$Soil_Property <- factor(
  comparison_data$Soil_Property,
  levels = c(
    "Total Nitrogen",
    "Total Carbon",
    "Acidified Nitrogen",
    "Acidified Carbon"
  )
)

# ------------------------------------------------------------
# 5. R-squared comparison figure
# ------------------------------------------------------------

p <- ggplot(
  comparison_data,
  aes(
    x = Soil_Property,
    y = R2,
    fill = Model
  )
) +
  geom_col(
    position = position_dodge(width = 0.75),
    width = 0.65
  ) +
  geom_text(
    aes(
      label = sprintf("%.3f", R2)
    ),
    position = position_dodge(width = 0.75),
    vjust = -0.35,
    size = 4
  ) +
  scale_y_continuous(
    limits = c(0, 0.9),
    expand = expansion(mult = c(0, 0.05))
  ) +
  labs(
    title = "PLS vs Random Forest Model Performance",
    subtitle = "Comparison of R² across four soil properties",
    x = "Soil property",
    y = expression(R^2),
    fill = "Model"
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
    axis.text.x = element_text(
      angle = 20,
      hjust = 1
    ),
    legend.position = "top"
  )

# ------------------------------------------------------------
# 6. Save comparison figure
# ------------------------------------------------------------

ggsave(
  "Outputs/Figures/PLS_vs_Random_Forest_comparison.png",
  p,
  width = 12,
  height = 7,
  dpi = 300
)

cat("\nComparison figure saved successfully:\n")
cat("Outputs/Figures/PLS_vs_Random_Forest_comparison.png\n")

# ------------------------------------------------------------
# 7. Display results
# ------------------------------------------------------------

print(comparison_data)