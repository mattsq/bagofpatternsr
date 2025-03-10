
#' @export
print.bagofpatterns <- function(x, ...) {
  # Get dimensions safely
  training_data_col <- ncol(x$training_data) - 1
  converted_data_col <- ncol(x$converted_training_data)
  
  # Extract model information
  target <- x$target
  
  # Get dictionary information safely
  if (!is.na(x$converted_training_data) && 
      is.data.frame(x$converted_training_data) && 
      ncol(x$converted_training_data) > 0) {
    
    X_df <- x$converted_training_data[, !colnames(x$converted_training_data) %in% target, drop = FALSE]
    dict <- sort(colSums(as.matrix(X_df)), decreasing = TRUE)
    dict_len <- min(5, length(dict))
    first_x_words <- if(dict_len > 0) names(dict)[1:dict_len] else "None"
  } else {
    first_x_words <- "None (model not fitted)"
  }
  
  # Calculate window size
  window_size <- x$SAX_args$window_size
  actual_window_length <- if(is.numeric(window_size) && window_size <= 1) {
    floor(training_data_col * window_size)
  } else {
    window_size
  }
  
  # Print model summary
  cat("A trained Bag Of Patterns object with:\n")
  cat("Time series length:", training_data_col, "\n")
  cat("Word histogram size:", converted_data_col, "\n")
  cat("Target variable:", target, "\n")
  cat("\nHyperparameters:\n")
  
  # Handle window size display
  if (is.numeric(window_size) && window_size <= 1) {
    cat("  Window Size:", window_size, "(", actual_window_length, "timepoints )\n")
  } else {
    cat("  Window Size:", window_size, "\n")
  }
  
  # Print remaining parameters safely
  cat("  Alphabet Size:", x$SAX_args$alphabet_size, "\n")
  cat("  Word Size:", x$SAX_args$PAA_number, "\n")
  cat("  SAX breakpoint method:", x$SAX_args$breakpoints, "\n")
  
  # Only show weighting method if available
  if (!is.null(x$SAX_args$word_weighting)) {
    weight_name <- attr(x$SAX_args$word_weighting, "name")
    if (!is.null(weight_name)) {
      cat("  Term weighting method:", weight_name, "\n")
    }
  }
  
  # Print sparsity constraint
  sparsity <- x$SAX_args$maximum_sparsity
  cat("  Sparsity constraint:", if(is.na(sparsity)) "1.00" else format(sparsity, digits = 2), "\n")
  
  # Print boolean parameters
  cat("  Trained with sparse windows:", x$SAX_args$sparse_windows, "\n")
  cat("  Windows Z-normalized:", x$SAX_args$normalize, "\n")
  
  # Print top words
  cat("\nTop words by frequency:", 
      if(is.character(first_x_words)) paste(first_x_words, collapse = ", ") else "None", "\n")
  
  # Print KNN info if available
  if(!is.null(x$model_args) && !is.na(x$model_args) && is.list(x$model_args) && !is.null(x$model_args$k)) {
    cat("K-Nearest Neighbours:", x$model_args$k, "\n")
  }
  
  invisible(x)
}
