#' Fit Bag Of Patterns Histogram
#'
#' Fit a dictionary to a dataset using SAX to create a 'bag of patterns'
#'
#' This function creates a dictionary to a dataset of time series using `seewave::SAX`
#' and returns an model that can be used by `bake_bagofpatterns` to convert that series
#' into a histogram of 'words'.
#' @param data a data frame where each row is a time series, along with a column for class
#' @param target the name of the column where the class of each row is stored
#' @param window_size The size of the sliding windows as applied to the time series, either as a fraction of the length or an integer of precise length.
#' @param sparse_windows a logical, indicating whether `sqrt(m)` random windows should be taken instead of all
#' @param normalize a logical, indicating whether each window should be z-normalized (`(x - mean(x)/sd(x)`)
#' @param alphabet_size the number of distinct letters to use in the compressed SAX representation
#' @param word_size the size of the 'words' generated out of the alphabet by SAX
#' @param breakpoints the method used to assign letters (see `seewave::SAX`)
#' @param word_weighting The weighting function for the DTM/TDM (default is term-frequency, effectively unweighted)
#' @param maximum_sparsity A optional numeric for the maximal allowed sparsity in the range from bigger zero to smaller one.
#' @param verbose whether to print the progress of model creation.
#' @importFrom dplyr slice_sample
#' @importFrom tm removeSparseTerms nTerms
#' @importFrom Matrix sparseMatrix
#' @importFrom tibble tibble
#' @export

fit_bagofpatterns <- function(data,
                              target = "target",
                              window_size = .2,
                              sparse_windows = FALSE,
                              normalize = FALSE,
                              alphabet_size = 4,
                              word_size = 8,
                              breakpoints = "quantiles",
                              word_weighting = tm::weightTf,
                              maximum_sparsity = NA,
                              verbose = TRUE) {

  # Add input validation
  if (!is.data.frame(data)) {
    stop("'data' must be a data frame", call. = FALSE)
  }
  
  if (!(target %in% colnames(data))) {
    stop("Target column '", target, "' not found in data", call. = FALSE)
  }
  
  if (!is.numeric(alphabet_size) || alphabet_size < 2 || alphabet_size != round(alphabet_size)) {
    stop("'alphabet_size' must be an integer >= 2", call. = FALSE)
  }
  
  if (!is.numeric(word_size) || word_size < 1 || word_size != round(word_size)) {
    stop("'word_size' must be a positive integer", call. = FALSE)
  }
  
  valid_breakpoints <- c("quantiles", "uniform", "gaussian", "kmeans")
  if (!(breakpoints %in% valid_breakpoints)) {
    stop("'breakpoints' must be one of: ", paste(valid_breakpoints, collapse = ", "), call. = FALSE)
  }
  
  if (!is.na(maximum_sparsity) && (!is.numeric(maximum_sparsity) || maximum_sparsity <= 0 || maximum_sparsity >= 1)) {
    stop("'maximum_sparsity' must be between 0 and 1", call. = FALSE)
  }                            

  bagofpatterns_obj <- new_bagofpatterns(data = data,
                                         target = target,
                                         window_size = window_size,
                                         sparse_windows = sparse_windows,
                                         normalize = normalize,
                                         alphabet_size = alphabet_size,
                                         word_size = word_size,
                                         breakpoints = breakpoints,
                                         word_weighting = word_weighting,
                                         maximum_sparsity = maximum_sparsity,
                                         verbose = verbose)

  X_df <- data[,!colnames(data) == target]

  vec_length <- ncol(X_df)

  if (window_size <= 1) {
    window_size <- floor(vec_length*window_size)
  }

  if (window_size > vec_length) {
    stop("Window size must be smaller than the length of the time series.")
  }

  windows <- data.frame(
    window_starts = 1:(vec_length - window_size + 1),
    window_ends = window_size:vec_length
  )

  if(sparse_windows) {
    windows <- dplyr::slice_sample(windows, n = floor(sqrt(ncol(X_df))))
  }

  bagofpatterns_obj$SAX_args$windows <- windows

  convert_call_args <- append(list(data = X_df), bagofpatterns_obj$SAX_args)
# Get document-term matrix
dtm <- do.call(convert_df_to_bag_of_words, convert_call_args)

# Apply sparsity constraint if needed
if (!is.na(maximum_sparsity)) {
  dtm_sparse <- tm::removeSparseTerms(dtm, sparse = maximum_sparsity)
  if (tm::nTerms(dtm_sparse) < 2) stop("Sparsity constraint resulted in less than two words used. Try a value closer to 1.")
  dtm <- dtm_sparse
}

# Store sparse structure in model for later use
bagofpatterns_obj$sparse_dtm <- dtm

# Convert to tibble efficiently - only materialize if needed
if (inherits(dtm, "DocumentTermMatrix")) {
  # Extract sparse components
  dtm_summary <- Matrix::summary(dtm)
  
  # Create sparse matrix directly
  sparse_matrix <- Matrix::sparseMatrix(
    i = dtm_summary$i,
    j = dtm_summary$j,
    x = dtm_summary$v,
    dims = dim(dtm),
    dimnames = list(rownames(dtm), colnames(dtm))
  )
  
  # Convert to regular matrix only for final step
  converted_training_data <- tibble::as_tibble(as.matrix(sparse_matrix))
} else {
  # Fallback for non-DTM objects
  converted_training_data <- tibble::as_tibble(as.matrix(dtm))
}

  # Add target column by reference
  converted_training_data[[target]] <- data[[target]]
  bagofpatterns_obj$converted_training_data <- converted_training_data

  return(bagofpatterns_obj)
}
