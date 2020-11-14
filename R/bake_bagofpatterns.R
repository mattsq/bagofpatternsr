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

    converted_test_data <- as.matrix(converted_test_data)
    converted_test_data <- tibble::as_tibble(converted_test_data)
    converted_test_data[bagofpatterns_obj$target] <- newdata[bagofpatterns_obj$target]

    test_cols_in_train_idx <- which(colnames(converted_test_data) %in% colnames(bagofpatterns_obj$converted_training_data))

    converted_test_data_training_only <- converted_test_data[,test_cols_in_train_idx]

    train_cols_not_in_test_idx <- which(!colnames(bagofpatterns_obj$converted_training_data) %in% colnames(converted_test_data_training_only))
    if(length(test_cols_in_train_idx)/(length(test_cols_in_train_idx) + length(train_cols_not_in_test_idx)) < .8) {
      warning("More than 20% of the detected words in the new data weren't present in the training data.
              Consider making the word size or alphabet smaller, or lowering the sparsity.")
    }

    missing_colnames <- colnames(bagofpatterns_obj$converted_training_data)[train_cols_not_in_test_idx]
    converted_test_data_training_only[missing_colnames] <- 0
    return(converted_test_data_training_only)
  }
}
