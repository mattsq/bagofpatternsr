#' @export
print.bagofpatterns <- function(x, ...) {
  # Safety checks for required components
  if (is.null(x$training_data)) {
    cat("Empty bagofpatterns object (no training data)\n")
    return(invisible(x))
  }

  # Get dimensions safely
  training_data_col <- if (!is.null(x$training_data)) ncol(x$training_data) - 1 else NA
  converted_data_col <- if (!is.null(x$converted_training_data) &&
                            !identical(x$converted_training_data, NA)) ncol(x$converted_training_data) else NA

  # Extract model information
  target <- x$target

  # Get dictionary information safely
  if (!is.null(x$converted_training_data) &&
      !identical(x$converted_training_data, NA) &&
      is.data.frame(x$converted_training_data) &&
      ncol(x$converted_training_data) > 0) {

    X_df <- x$converted_training_data[, !colnames(x$converted_training_data) %in% target, drop = FALSE]
    if (ncol(X_df) > 0) {
      mat <- as.matrix(X_df)
      if (is.numeric(mat)) {
        dict <- sort(colSums(mat), decreasing = TRUE)
        dict_len <- min(5, length(dict))
        first_x_words <- if(dict_len > 0) names(dict)[1:dict_len] else "None"
      } else {
        first_x_words <- "None (non-numeric data)"
      }
    } else {
      first_x_words <- "None (no columns)"
    }
  } else {
    first_x_words <- "None (model not fitted)"
  }

  # Calculate window size safely
  if (!is.null(x$SAX_args)) {
    window_size <- x$SAX_args$window_size
    actual_window_length <- if(is.numeric(window_size) && window_size <= 1) {
      floor(training_data_col * window_size)
    } else {
      window_size
    }
  } else {
    window_size <- NA
    actual_window_length <- NA
  }

  # Print model summary
  cat("A trained Bag Of Patterns object with:\n")
  cat("Time series length:", if(!is.na(training_data_col)) training_data_col else "Unknown", "\n")
  cat("Word histogram size:", if(!is.na(converted_data_col)) converted_data_col else "Not fitted", "\n")
  cat("Target variable:", target, "\n")

  # Only print hyperparameters if SAX_args exists
  if (!is.null(x$SAX_args)) {
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
  }

  # Print top words
  cat("\nTop words by frequency:",
      if(is.character(first_x_words)) paste(first_x_words, collapse = ", ") else "None", "\n")

  # Print KNN info if available
  if(!is.null(x$model_args) &&
     is.list(x$model_args) &&
     !identical(x$model_args, NA) &&
     !is.null(x$model_args$k)) {
    cat("K-Nearest Neighbours:", x$model_args$k, "\n")
  }

  invisible(x)
}
