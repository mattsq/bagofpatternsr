#' Fit Bag Of Patterns Histogram
#'
#' Fit a dictionary to a dataset using SAX to create a 'bag of patterns'
#'
#' This function creates a dictionary to a dataset of time series using `seewave::SAX`
#' and returns an model that can be used by `bake_bagofpatterns` to convert that series
#' into a histogram of 'words'.
#' @param data a data frame where each row is a time series, along with a column for class
#' @param target the name of the column where the class of each row is stored
#' @param window_size The size of the sliding windows as applied to the time series
#' @param sparse_windows a logical, indicating whether `sqrt(m)` random windows should be taken instead of all
#' @param normalize a logical, indicating whether each window should be z-normalized (`(x - mean(x)/sd(x)`)
#' @param alphabet_size the number of distinct letters to use in the compressed SAX representation
#' @param word_size the size of the 'words' generated out of the alphabet by SAX
#' @param breakpoints the method used to assign letters (see `seewave::SAX`)
#' @param verbose whether to print the progress of model creation.
#' @importFrom dplyr slice_sample
#' @export

fit_bagofpatterns <- function(data,
                              target = "target",
                              window_size = 200,
                              sparse_windows = FALSE,
                              normalize = TRUE,
                              alphabet_size = 4,
                              word_size = 8,
                              breakpoints = "quantiles",
                              verbose = TRUE) {

  bagofpatterns_obj <- new_bagofpatterns(data = data,
                                         target = target,
                                         window_size = window_size,
                                         sparse_windows = sparse_windows,
                                         normalize = normalize,
                                         alphabet_size = alphabet_size,
                                         PAA_number = word_size,
                                         breakpoints = breakpoints,
                                         verbose = verbose)

  X_df <- data[,!colnames(data) == target]

  vec_length <- ncol(X_df)

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
  converted_training_data[target] <- data[target]
  bagofpatterns_obj$converted_training_data <- converted_training_data

  return(bagofpatterns_obj)
}
