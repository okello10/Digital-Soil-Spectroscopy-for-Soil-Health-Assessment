# ================================================================
# Digital Soil Spectroscopy for Soil Health Assessment
# Script: 08_random_forest.R
# Purpose: Random Forest regression of soil properties from MIR spectra
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

cat("\n--- Random Forest Calibration ---\n")

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
# 5. Target variables
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
library(randomForest)
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
  "Data/processed/RF_models",
  recursive = TRUE,
  showWarnings = FALSE
)


# ----------------------------------------------------------------
# 9. Random Forest model function
# ----------------------------------------------------------------

run_rf_model <- function(
    property,
    property_label,
    spectra,
    reference_data
) {
  
  cat("\n----------------------------------------\n")
  cat("Random Forest model:", property_label, "\n")
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
  # Random Forest tuning grid
  # --------------------------------------------------------------
  
  tuning_grid <- data.frame(
    mtry = c(10, 25, 50, 75, 100)
  )
  
  
  # --------------------------------------------------------------
  # Train Random Forest model
  # --------------------------------------------------------------
  
  cat("\nRunning Random Forest cross-validation...\n")
  
  rf_model <- train(
    x = x_train,
    y = y_train,
    method = "rf",
    tuneGrid = tuning_grid,
    trControl = control,
    metric = "RMSE",
    ntree = 500,
    importance = TRUE
  )
  
  
  # --------------------------------------------------------------
  # Optimal mtry
  # --------------------------------------------------------------
  
  optimal_mtry <- rf_model$bestTune$mtry
  
  cat(
    "Optimal mtry:",
    optimal_mtry,
    "\n"
  )
  
  
  # --------------------------------------------------------------
  # Predictions
  # --------------------------------------------------------------
  
  predictions <- predict(
    rf_model,
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
        "Random Forest Calibration -",
        property_label
      ),
      
      subtitle = paste(
        "mtry:",
        optimal_mtry,
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
  # Save observed vs predicted plot
  # --------------------------------------------------------------
  
  plot_filename <- paste0(
    "Outputs/Figures/RF_",
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
  # Variable importance
  # --------------------------------------------------------------
  
  importance_data <- as.data.frame(
    varImp(rf_model)$importance
  )
  
  importance_data$Wavelength <- rownames(
    importance_data
  )
  
  importance_data <- importance_data[
    order(
      importance_data$Overall,
      decreasing = TRUE
    ),
  ]
  
  top_importance <- head(
    importance_data,
    20
  )
  
  
  # --------------------------------------------------------------
  # Variable importance plot
  # --------------------------------------------------------------
  
  importance_plot <- ggplot(
    top_importance,
    aes(
      x = reorder(Wavelength, Overall),
      y = Overall
    )
  ) +
    
    geom_col() +
    
    coord_flip() +
    
    labs(
      title = paste(
        "Random Forest Variable Importance -",
        property_label
      ),
      
      x = "Spectral Variable",
      
      y = "Importance"
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
  # Save variable importance plot
  # --------------------------------------------------------------
  
  importance_filename <- paste0(
    "Outputs/Figures/RF_",
    property,
    "_Variable_Importance.png"
  )
  
  ggsave(
    importance_filename,
    importance_plot,
    width = 9,
    height = 7,
    dpi = 300
  )
  
  
  # --------------------------------------------------------------
  # Save model
  # --------------------------------------------------------------
  
  model_filename <- paste0(
    "Data/processed/RF_models/RF_",
    property,
    ".rds"
  )
  
  saveRDS(
    rf_model,
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
    Optimal_mtry = optimal_mtry,
    RMSE = rmse,
    R2 = r2,
    RPD = rpd
  )
  
  return(results)
}


# ----------------------------------------------------------------
# 10. Run Random Forest models
# ----------------------------------------------------------------

rf_TN <- run_rf_model(
  "Total_Nitrogen",
  "Total Nitrogen",
  spectra_snv,
  model_data
)

rf_TC <- run_rf_model(
  "Total_Carbon",
  "Total Carbon",
  spectra_snv,
  model_data
)

rf_AN <- run_rf_model(
  "Acidified_Nitrogen",
  "Acidified Nitrogen",
  spectra_snv,
  model_data
)

rf_AC <- run_rf_model(
  "Acidified_Carbon",
  "Acidified Carbon",
  spectra_snv,
  model_data
)


# ----------------------------------------------------------------
# 11. Combine model performance
# ----------------------------------------------------------------

rf_results <- rbind(
  rf_TN,
  rf_TC,
  rf_AN,
  rf_AC
)


# ----------------------------------------------------------------
# 12. Display results
# ----------------------------------------------------------------

cat("\n========================================\n")
cat("RANDOM FOREST MODEL PERFORMANCE SUMMARY\n")
cat("========================================\n")

print(
  round(
    rf_results[, c(
      "Samples",
      "Calibration_Samples",
      "Test_Samples",
      "Optimal_mtry",
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
  rf_results,
  "Data/processed/RF_model_performance.csv"
)


# ----------------------------------------------------------------
# 14. Completion message
# ----------------------------------------------------------------

cat(
  "\nRandom Forest calibration completed successfully.\n"
)

cat(
  "Random Forest models saved to Data/processed/RF_models/\n"
)

cat(
  "Random Forest performance saved to Data/processed/RF_model_performance.csv\n"
)

cat(
  "Random Forest figures saved to Outputs/Figures/\n"
)