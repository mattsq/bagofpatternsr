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
#' @param verbose whether to print the fitting steps when creating the BoP representation
#' @param ... Not used, left for generics consistency.
#' @examples
#' data("FaceAll_TRAIN")
#' data("FaceAll_TEST")
#' model <- bagofpatterns_knn(FaceAll_TRAIN, window_size = 10, verbose = FALSE, k = 1)
#' new_preds  <- predict(model, newdata = FaceAll_TEST, verbose = FALSE)
#' @importFrom FNN knn
#' @export
predict.bagofpatterns <- function(model, newdata = NULL, ...) {
  if(is.na(model$model_args)) {
    stop("Bag Of Patterns model not trained with any KNN arguments.\n    Use 'bagofpatterns_knn' not 'fit_bagofpatterns'.")
  }

  if(is.null(newdata)) {

    FNN_knn_args <- append(
      list(
        train = model$converted_training_data[,!colnames(model$converted_training_data) == model$target],
        test = model$converted_training_data[,!colnames(model$converted_training_data) == model$target],
        cl = unlist(model$converted_training_data[model$target])
      ),
      model$model_args
    )

  } else {
    converted_test_data_training_only <- bake_bagofpatterns(model, newdata)
    FNN_knn_args <- append(
                        list(
                            train = model$converted_training_data[,!colnames(model$converted_training_data) == model$target],
                            test = converted_test_data_training_only[,!colnames(converted_test_data_training_only) == model$target],
                            cl = unlist(model$converted_training_data[model$target])
                          ),
                          model$model_args
                        )
  }

  preds <- do.call(FNN::knn, FNN_knn_args)

  return(preds)
}
