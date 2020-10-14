
#' @importFrom seewave SAX
#' @importFrom tidyr pivot_wider
convert_vector_to_word_hist <- function(vec, window_size, alphabet_size, PAA_number, breakpoints) {
  words <- character(length = length(vec))
  idx <- 1
  for (k2 in 1:length(vec)) {
    start <- k2
    end <- min(c(k2 + window_size, length(vec)))
    vec_window <- vec[start:end]
    word <- seewave::SAX(vec_window,
                         alphabet_size = alphabet_size,
                         PAA_number = PAA_number,
                         breakpoints = breakpoints,
                         collapse = "")
    if (k2 > 1 & idx > 1) {
      if (word == words[idx-1]) {
        next
      }
    }
    words[idx] <- word
    idx <- idx + 1
  }
  words <- words[!words == ""]
  words <- as.data.frame(table(words))
  words <- tidyr::pivot_wider(words, names_from = words, values_from = Freq)
  return(words)
}

#' @importFrom purrr map
#' @importFrom dplyr bind_rows
convert_df_to_bag_of_words <- function(data, window_size, alphabet_size, PAA_number, breakpoints, verbose) {
  purrr::map(1:nrow(data), ~ {
    if (verbose) print(.x)
    convert_vector_to_word_hist(unlist(data[.x,]),
                                window_size = window_size,
                                alphabet_size = alphabet_size,
                                PAA_number = PAA_number,
                                breakpoints = breakpoints)
  }
  ) %>%
    dplyr::bind_rows() %>%
    replace(is.na(.), 0)
}
