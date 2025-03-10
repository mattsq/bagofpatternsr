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
  # Validate model object
  if (!inherits(model, "bagofpatterns")) {
    stop("First argument must be a 'bagofpatterns' object", call. = FALSE)
  }
  
  # Check if model has KNN parameters
  if (is.null(model$model_args) || is.na(model$model_args) || !is.list(model$model_args)) {
    stop("Model not trained with KNN arguments. Use 'bagofpatterns_knn' not 'fit_bagofpatterns'.", 
         call. = FALSE)
  }
  
  # Extract target column name
  target <- model$target
  
  # For training data predictions 
  if (is.null(newdata)) {
    # Extract training features
    train_features <- model$converted_training_data[, !colnames(model$converted_training_data) == target, drop = FALSE]
    train_labels <- unlist(model$converted_training_data[target])
    
    # Prepare KNN arguments
    FNN_knn_args <- c(
      list(
        train = train_features,
        test = train_features,
        cl = train_labels
      ),
      model$model_args
    )
  } else {
    # Validate new data
    if (!is.data.frame(newdata)) {
      stop("'newdata' must be a data frame", call. = FALSE)
    }
    
    # Convert test data to bag of patterns format
    converted_test_data <- bake_bagofpatterns(model, newdata)
    
    # Extract features
    train_features <- model$converted_training_data[, !colnames(model$converted_training_data) == target, drop = FALSE]
    train_labels <- unlist(model$converted_training_data[target])
    test_features <- converted_test_data[, !colnames(converted_test_data) == target, drop = FALSE]
    
    # Prepare KNN arguments
    FNN_knn_args <- c(
      list(
        train = train_features,
        test = test_features,
        cl = train_labels
      ),
      model$model_args
    )
  }
  
  # Run prediction
  preds <- do.call(FNN::knn, FNN_knn_args)
  return(preds)
}
