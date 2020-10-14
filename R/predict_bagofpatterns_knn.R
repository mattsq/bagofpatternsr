#' Predict using a Bag of Patterns KNN Model
#'
#' Classifies new time series according to a trained BoP model using KNN
#'
#' This function uses a trained Bag of Patterns model and K-Nearest Neighbours
#' to classify new time series as members of a class. It converts the new
#' data using the same `SAX` parameters as the original model and then uses only
#' the words present in the training data as the basis for neighbour matching.
#'
#' @param model a fitted model returned by `bagofpatterns_knn`
#' @param newdata optional new data frame - if not passed, will return training set predictions
#'
#' @importFrom class knn
#' @export
predict_bagofpatterns_knn <- function(model, newdata = NULL) {
  if(is.null(newdata)) {
    preds <- class::knn(model$converted_training_data[,!colnames(model$converted_training_data) == model$target],
                        model$converted_training_data[,!colnames(model$converted_training_data) == model$target],
                        cl = model$converted_training_data[model$target],
                        k = model$k)
  } else {
    X_test_df <- newdata[,!colnames(newdata) == model$target]
    converted_test_data <- convert_df_to_bag_of_words(X_test_df,
                                                      window_size = model$SAX_args$window_size,
                                                      alphabet_size = model$SAX_args$alphabet_size,
                                                      PAA_number = model$SAX_args$PAA_number,
                                                      breakpoints = model$SAX_args$breakpoints)

    converted_test_data_training_only <- converted_test_data[,which(colnames(converted_test_data) %in% colnames(model$converted_training_data))]

    missing_colnames <- colnames(model$converted_training_data)[which(!colnames(model$converted_training_data) %in% colnames(converted_test_data_training_only))]
    converted_test_data_training_only[missing_colnames] <- 0

    preds <- class::knn(train = model$converted_training_data[,!colnames(model$converted_training_data) == model$target],
                        test = converted_test_data_training_only[,!colnames(converted_test_data_training_only) == model$target],
                        cl = unlist(model$converted_training_data[model$target]),
                        k = model$k)
  }
  return(preds)
}