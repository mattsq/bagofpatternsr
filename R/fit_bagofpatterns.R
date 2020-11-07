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

  bagofpatterns_obj <- new_bagofpatterns(data = data,
                                         target = target,
                                         window_size = window_size,
                                         sparse_windows = sparse_windows,
                                         normalize = normalize,
                                         alphabet_size = alphabet_size,
                                         PAA_number = word_size,
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
  converted_training_data <- do.call(convert_df_to_bag_of_words, convert_call_args)

  if (!is.na(maximum_sparsity)) {
    converted_training_data_sparse <- tm::removeSparseTerms(converted_training_data, sparse = maximum_sparsity)
    if (tm::nTerms(converted_training_data_sparse) < 2) stop("Sparsity constraint resulted in less than two words used. Try a value closer to 1.")
    converted_training_data <- converted_training_data_sparse
  }
  converted_training_data <- as.matrix(converted_training_data)
  converted_training_data <- tibble::as_tibble(converted_training_data)

  converted_training_data[target] <- data[target]
  bagofpatterns_obj$converted_training_data <- converted_training_data

  return(bagofpatterns_obj)
}
