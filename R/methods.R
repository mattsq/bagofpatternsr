
#' @export

print.bagofpatterns <- function(x, ...) {
  force(x)
  X_df <- x$converted_training_data[,!colnames(x$converted_training_data) == x$target]
  dict <- sort(colSums(as.matrix(X_df)), decreasing = TRUE)
  dict_len <- min(5, length(dict))

  training_data_col <- ncol(x$training_data) - 1
  converted_data_col <- ncol(x$converted_training_data)
  sparse_windows <- !is.na(x$SAX_args$sparse_windows_val)
  first_x_words <- names(dict)[1:dict_len]
  actual_window_length <- floor(training_data_col*x$SAX_args$window_size)

  cat("A trained Bag Of Patterns object with:\n")
  cat("A time series of length", training_data_col, "converted into a word histogram with", converted_data_col, "entries, predicting class:", x$target, "\n")
  cat("The object has the following hyperparameters:\n")
  if (x$SAX_args$window_size <= 1) {
    cat("  Window Size:", x$SAX_args$window_size, "(consisting of", actual_window_length, "timepoints)", "\n")
  } else {
    cat("  Window Size:", x$SAX_args$window_size, "\n")
  }
  cat("  Alphabet Size:", x$SAX_args$alphabet_size, "\n")
  cat("  Word Size:", x$SAX_args$PAA_number, "\n")
  cat("  SAX breakpoint method:", x$SAX_args$breakpoints, "\n")
  cat("  Term weighting method:", attr(x$SAX_args$word_weighting, "name"), "\n")
  if (is.na(x$SAX_args$maximum_sparsity)) {
    cat("  Sparsity constraint: 1.00 \n")
  } else {
    cat("  Sparsity constraint:", x$SAX_args$maximum_sparsity, "\n")
  }
  cat("  Trained with sparse windows:", x$SAX_args$sparse_windows, "\n")
  cat("  Windows Z-normalized before creating words:", x$SAX_args$normalize, "\n")
  cat("\n")
  cat("The top five words by frequency are:", paste(first_x_words, collapse = ", "), "\n")

  if(!is.na(x[["model_args"]])) {
    cat("  K-Nearest Neighbours to be used:", x$model_args$k, "\n")
  }
  invisible(x)
}
