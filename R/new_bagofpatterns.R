

new_bagofpatterns <- function(data, target, ...) {
  return(
    structure(
      list(
        training_data = data,
        converted_training_data = NA,
        target = target,
        SAX_args = list(...),
        model_args = NA
      ),
      class = "bagofpatterns")
  )
}
