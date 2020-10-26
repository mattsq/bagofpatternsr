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
  if (is.null(newdata)) {
    return(bagofpatterns_obj$converted_training_data)
  } else {
    X_test_df <- newdata[,!colnames(newdata) == bagofpatterns_obj$target]
    convert_call_args <- append(list(data = X_test_df), bagofpatterns_obj$SAX_args)
    converted_test_data <- do.call(convert_df_to_bag_of_words, convert_call_args)
    converted_test_data_training_only <- converted_test_data[,which(colnames(converted_test_data) %in% colnames(bagofpatterns_obj$converted_training_data))]
    missing_colnames <- colnames(bagofpatterns_obj$converted_training_data)[which(!colnames(bagofpatterns_obj$converted_training_data) %in% colnames(converted_test_data_training_only))]
    converted_test_data_training_only[missing_colnames] <- 0
    return(converted_test_data_training_only)
  }
}
