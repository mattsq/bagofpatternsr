#' Bake data into a Bag of Patterns
#'
#' Convert a dataset of timeseries into a bag of patterns representation
#'
#' This function uses a bag of patterns object trained on an example dataset
#' to return a histogram of 'words' representing the time series.
#' @param bagofpatterns_obj A model trained by `fit_bagofpatterns`
#' @param newdata An optional new data frame - if not supplied, the converted training data is returned.
#' @export


bake_bagofpatterns <- function(bagofpatterns_obj, newdata = NULL) {
  # Validate model object
  if (!inherits(bagofpatterns_obj, "bagofpatterns")) {
    stop("First argument must be a 'bagofpatterns' object", call. = FALSE)
  }
  
  # Return training data if no new data
  if (is.null(newdata)) {
    return(bagofpatterns_obj$converted_training_data)
  }
  
  # Validate new data
  if (!is.data.frame(newdata)) {
    stop("'newdata' must be a data frame", call. = FALSE)
  }
  
  target <- bagofpatterns_obj$target
  if (!(target %in% colnames(newdata))) {
    stop("Target column '", target, "' not found in newdata", call. = FALSE)
  }
  
  # Extract features and convert
  X_test_df <- newdata[, !colnames(newdata) == target, drop = FALSE]
  convert_call_args <- append(list(data = X_test_df), bagofpatterns_obj$SAX_args)
  converted_test_data <- do.call(convert_df_to_bag_of_words, convert_call_args)
  
  # Convert to tibble and add target
  converted_test_data <- tibble::as_tibble(as.matrix(converted_test_data))
  converted_test_data[[target]] <- newdata[[target]]
  
  # Use set operations for column matching
  training_cols <- setdiff(colnames(bagofpatterns_obj$converted_training_data), target)
  test_cols <- setdiff(colnames(converted_test_data), target)
  
  common_cols <- intersect(test_cols, training_cols)
  missing_cols <- setdiff(training_cols, common_cols)
  
  # Add missing columns with zeros
  result <- converted_test_data[, c(common_cols, target)]
  for (col in missing_cols) {
    result[[col]] <- 0
  }
  
  # Add warning with more precise percentage
  match_ratio <- length(common_cols) / length(training_cols)
  if (match_ratio < 0.8) {
    warning(sprintf("Only %.1f%% of training words found in new data.", match_ratio * 100))
  }
  
  # Return result with columns in same order as training data
  result <- result[, c(training_cols, target)]
  return(result)
}
