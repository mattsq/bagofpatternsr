
#' @importFrom seewave SAX
#' @importFrom dplyr slice_sample
convert_vector_to_word_hist <- function(vec, window_size, sparse_windows_val, alphabet_size, PAA_number, breakpoints) {
  vec_length <- length(vec)

  windows <- data.frame(
    window_starts = 1:(vec_length - window_size + 1),
    window_ends = window_size:vec_length
  )

  if(!is.na(sparse_windows_val)) {
    windows <- dplyr::slice_sample(windows, n = sparse_windows_val)
  }

  words <- character(nrow(windows))
  idx <- 1

  for (k2 in 1:nrow(windows)) {
    start <- (windows$window_starts[k2])
    end <- (windows$window_ends[k2])
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
  return(words)
}

#' @importFrom purrr map
#' @importFrom dplyr bind_rows group_by summarise select
#' @importFrom tibble as_tibble
#' @importFrom data.table rbindlist dcast
#' @importFrom tidyr pivot_wider
convert_df_to_bag_of_words <- function(data, window_size, sparse_windows_val, alphabet_size, PAA_number, breakpoints, verbose) {
  bow <- purrr::map(1:nrow(data), ~ {
    if (verbose) print(.x)
    convert_vector_to_word_hist(unlist(data[.x,]),
                                window_size = window_size,
                                sparse_windows_val = sparse_windows_val,
                                alphabet_size = alphabet_size,
                                PAA_number = PAA_number,
                                breakpoints = breakpoints)
  }, .id = "idx"
  ) %>% data.table::rbindlist(idcol = TRUE)

  bow <- bow[, list(Freq = sum(Freq)), keyby = list(.id,words)]
  bow <-   data.table::dcast(bow,
                             .id ~ words,
                             fun.aggregate = sum,
                             fill = 0,
                             value.var = "Freq")

  bow <- bow[,!c(".id")]
  bow <- tibble::as_tibble(bow)
    return(bow)
}
