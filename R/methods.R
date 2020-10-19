
#' @export

print.bagofpatterns <- function(x) {
  training_data_col <- ncol(x$training_data) - 1
  converted_data_col <- ncol(x$converted_training_data)
  sparse_windows <- !is.na(x$SAX_args$sparse_windows_val)
  first_x_words <- (colnames(x$converted_training_data)[colnames(x$converted_training_data) != x$target])[1:5]
  cat("A trained Bag Of Patterns model with:\n")
  cat("A time series of length", training_data_col, "converted into a word histogram with", converted_data_col, "entries, predicting class:", x$target, "\n")
  cat("The model has the following hyperparameters:\n")
  cat("  K-Nearest Neighbours to be used:", x$k, "\n")
  cat("  Window Size:", x$SAX_args$window_size, "\n")
  cat("  Alphabet Size:", x$SAX_args$alphabet_size, "\n")
  cat("  Word Size:", x$SAX_args$PAA_number, "\n")
  cat("  SAX breakpoint method:", x$SAX_args$breakpoints, "\n")
  cat("  Trained with sparse windows:", sparse_windows, "\n")
  cat("\n")
  cat("Examples of words in dictionary include:", paste(first_x_words, collapse = ", "))

  invisible(x)
}
