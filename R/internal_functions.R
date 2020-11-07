
#' @importFrom seewave SAX
#' @importFrom dplyr slice_sample
#' @importFrom stats sd
convert_vector_to_word_hist <- function(vec,
                                        window_size,
                                        sparse_windows_val,
                                        normalize,
                                        alphabet_size,
                                        PAA_number,
                                        breakpoints,
                                        windows) {

  words <- character(nrow(windows))
  idx <- 1
  if (normalize) {
    vec <- (vec - mean(vec))/stats::sd(vec)
  }

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
#' @importFrom tidytext cast_dtm
#' @importFrom tm removeSparseTerms nTerms
convert_df_to_bag_of_words <- function(data,
                                       window_size,
                                       sparse_windows_val,
                                       normalize,
                                       alphabet_size,
                                       PAA_number,
                                       breakpoints,
                                       word_weighting,
                                       maximum_sparsity,
                                       verbose,
                                       windows) {

  bow <- purrr::map(1:nrow(data), ~ {
    if (verbose) print(.x)
    convert_vector_to_word_hist(unlist(data[.x,]),
                                window_size = window_size,
                                sparse_windows_val = sparse_windows_val,
                                normalize = normalize,
                                alphabet_size = alphabet_size,
                                PAA_number = PAA_number,
                                breakpoints = breakpoints,
                                windows = windows)
  }, .id = "idx"
  ) %>% data.table::rbindlist(idcol = TRUE)

  bow <- bow[, list(Freq = sum(Freq)), keyby = list(.id,words)]
  bow_dtm <- tidytext::cast_dtm(bow, .id, words, Freq, weighting = word_weighting)
  return(bow_dtm)
}
