

new_bagofpatterns <- function(data, target, ...) {
  # Validate input
  if (!is.data.frame(data)) {
    stop("'data' must be a data frame", call. = FALSE)
  }
  
  if (!(target %in% colnames(data))) {
    stop("Target column '", target, "' not found in data", call. = FALSE)
  }
  
  # Create and return object
  structure(
    list(
      training_data = data,
      converted_training_data = NULL,  # Initialize as NULL instead of NA
      target = target,
      SAX_args = list(...),
      model_args = NULL  # Initialize as NULL instead of NA
    ),
    class = "bagofpatterns"
  )
}