# ================================================================
# Digital Soil Spectroscopy for Soil Health Assessment
# Script: 07_pls_calibration.R
# Purpose: PLS regression calibration of soil properties from MIR spectra
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
# 4. Check dimensions
# ----------------------------------------------------------------

cat("\n--- PLS Calibration ---\n")

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
# 5. Check target variables
# ----------------------------------------------------------------

target_variables <- c(
  "Total_Nitrogen",
  "Total_Carbon",
  "Acidified_Nitrogen",
  "Acidified_Carbon"
)

cat("\n--- Target Variables ---\n")

print(target_variables)

cat("\nMissing values:\n")

print(
  sapply(
    model_data[target_variables],
    function(x) sum(is.na(x))
  )
)


# ----------------------------------------------------------------
# 6. Load required packages
# ----------------------------------------------------------------

library(caret)
library(pls)
library(ggplot2)


# ----------------------------------------------------------------
# 7. Set reproducibility
# ----------------------------------------------------------------

set.seed(123)


# ----------------------------------------------------------------
# 8. Create output directories
# ----------------------------------------------------------------

dir.create(
  "Outputs/Figures",
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  "Data/processed/PLS_models",
  recursive = TRUE,
  showWarnings = FALSE
)


# ----------------------------------------------------------------
# 9. PLS model function
# ----------------------------------------------------------------

run_pls_model <- function(
    property,
    property_label,
    spectra,
    reference_data
) {
  
  cat("\n----------------------------------------\n")
  cat("PLS model:", property_label, "\n")
  cat("----------------------------------------\n")
  
  
  # --------------------------------------------------------------
  # Select samples with available target values
  # --------------------------------------------------------------
  
  valid_samples <- !is.na(reference_data[[property]])
  
  x <- spectra[valid_samples, , drop = FALSE]
  
  y <- reference_data[[property]][valid_samples]
  
  
  cat(
    "Samples available:",
    length(y),
    "\n"
  )
  
  
  # --------------------------------------------------------------
  # Train/test split
  # --------------------------------------------------------------
  
  set.seed(123)
  
  train_index <- createDataPartition(
    y,
    p = 0.80,
    list = FALSE
  )
  
  x_train <- x[train_index, , drop = FALSE]
  x_test  <- x[-train_index, , drop = FALSE]
  
  y_train <- y[train_index]
  y_test  <- y[-train_index]
  
  
  cat(
    "Calibration samples:",
    length(y_train),
    "\n"
  )
  
  cat(
    "Test samples:",
    length(y_test),
    "\n"
  )
  
  
  # --------------------------------------------------------------
  # Cross-validation settings
  # --------------------------------------------------------------
  
  control <- trainControl(
    method = "repeatedcv",
    number = 10,
    repeats = 5
  )
  
  
  # --------------------------------------------------------------
  # Number of PLS components to test
  # --------------------------------------------------------------
  
  max_components <- min(
    20,
    nrow(x_train) - 1
  )
  
  tuning_grid <- data.frame(
    ncomp = 1:max_components
  )
  
  
  # --------------------------------------------------------------
  # Train PLS model
  # --------------------------------------------------------------
  
  cat("\nRunning PLS cross-validation...\n")
  
  pls_model <- train(
    x = x_train,
    y = y_train,
    method = "pls",
    tuneGrid = tuning_grid,
    trControl = control,
    metric = "RMSE"
  )
  
  
  # --------------------------------------------------------------
  # Optimal number of components
  # --------------------------------------------------------------
  
  optimal_components <- pls_model$bestTune$ncomp
  
  cat(
    "Optimal number of PLS components:",
    optimal_components,
    "\n"
  )
  
  
  # --------------------------------------------------------------
  # Predictions
  # --------------------------------------------------------------
  
  predictions <- predict(
    pls_model,
    newdata = x_test
  )
  
  
  # --------------------------------------------------------------
  # Calculate performance metrics
  # --------------------------------------------------------------
  
  rmse <- sqrt(
    mean(
      (y_test - predictions)^2
    )
  )
  
  r2 <- cor(
    y_test,
    predictions
  )^2
  
  rpd <- sd(y_test) / rmse
  
  
  # --------------------------------------------------------------
  # Performance output
  # --------------------------------------------------------------
  
  cat("\n--- Test Set Performance ---\n")
  
  cat(
    "RMSE:",
    round(rmse, 4),
    "\n"
  )
  
  cat(
    "R-squared:",
    round(r2, 4),
    "\n"
  )
  
  cat(
    "RPD:",
    round(rpd, 4),
    "\n"
  )
  
  
  # --------------------------------------------------------------
  # Observed vs predicted data
  # --------------------------------------------------------------
  
  prediction_data <- data.frame(
    Observed = y_test,
    Predicted = as.numeric(predictions)
  )
  
  
  # --------------------------------------------------------------
  # Observed vs predicted plot
  # --------------------------------------------------------------
  
  p <- ggplot(
    prediction_data,
    aes(
      x = Observed,
      y = Predicted
    )
  ) +
    
    geom_point(
      size = 3,
      alpha = 0.8
    ) +
    
    geom_abline(
      slope = 1,
      intercept = 0,
      linetype = "dashed"
    ) +
    
    labs(
      title = paste(
        "PLS Calibration -",
        property_label
      ),
      
      subtitle = paste(
        "Components:",
        optimal_components,
        "| R²:",
        round(r2, 3),
        "| RMSE:",
        round(rmse, 4),
        "| RPD:",
        round(rpd, 2)
      ),
      
      x = paste(
        "Observed",
        property_label
      ),
      
      y = paste(
        "Predicted",
        property_label
      )
    ) +
    
    theme_minimal(
      base_size = 13
    ) +
    
    theme(
      plot.title = element_text(
        face = "bold"
      )
    )
  
  
  # --------------------------------------------------------------
  # Save plot
  # --------------------------------------------------------------
  
  plot_filename <- paste0(
    "Outputs/Figures/PLS_",
    property,
    "_Observed_vs_Predicted.png"
  )
  
  ggsave(
    plot_filename,
    p,
    width = 9,
    height = 7,
    dpi = 300
  )
  
  
  # --------------------------------------------------------------
  # Save model
  # --------------------------------------------------------------
  
  model_filename <- paste0(
    "Data/processed/PLS_models/PLS_",
    property,
    ".rds"
  )
  
  saveRDS(
    pls_model,
    model_filename
  )
  
  
  # --------------------------------------------------------------
  # Return results
  # --------------------------------------------------------------
  
  results <- data.frame(
    Property = property,
    Property_Label = property_label,
    Samples = length(y),
    Calibration_Samples = length(y_train),
    Test_Samples = length(y_test),
    Optimal_Components = optimal_components,
    RMSE = rmse,
    R2 = r2,
    RPD = rpd
  )
  
  return(results)
}


# ----------------------------------------------------------------
# 10. Run PLS models
# ----------------------------------------------------------------

pls_TN <- run_pls_model(
  "Total_Nitrogen",
  "Total Nitrogen",
  spectra_snv,
  model_data
)

pls_TC <- run_pls_model(
  "Total_Carbon",
  "Total Carbon",
  spectra_snv,
  model_data
)

pls_AN <- run_pls_model(
  "Acidified_Nitrogen",
  "Acidified Nitrogen",
  spectra_snv,
  model_data
)

pls_AC <- run_pls_model(
  "Acidified_Carbon",
  "Acidified Carbon",
  spectra_snv,
  model_data
)


# ----------------------------------------------------------------
# 11. Combine model performance
# ----------------------------------------------------------------

pls_results <- rbind(
  pls_TN,
  pls_TC,
  pls_AN,
  pls_AC
)


# ----------------------------------------------------------------
# 12. Display results
# ----------------------------------------------------------------

cat("\n========================================\n")
cat("PLS MODEL PERFORMANCE SUMMARY\n")
cat("========================================\n")

print(
  round(
    pls_results[, c(
      "Samples",
      "Calibration_Samples",
      "Test_Samples",
      "Optimal_Components",
      "RMSE",
      "R2",
      "RPD"
    )],
    4
  )
)


# ----------------------------------------------------------------
# 13. Save performance results
# ----------------------------------------------------------------

readr::write_csv(
  pls_results,
  "Data/processed/PLS_model_performance.csv"
)


# ----------------------------------------------------------------
# 14. Completion message
# ----------------------------------------------------------------

cat(
  "\nPLS calibration completed successfully.\n"
)

cat(
  "PLS models saved to Data/processed/PLS_models/\n"
)

cat(
  "PLS performance saved to Data/processed/PLS_model_performance.csv\n"
)

cat(
  "PLS figures saved to Outputs/Figures/\n"
)