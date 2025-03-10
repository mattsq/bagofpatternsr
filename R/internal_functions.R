
#' @importFrom seewave SAX
#' @importFrom dplyr slice_sample
#' @importFrom stats sd
convert_vector_to_word_hist <- function(vec,
                                      window_size,
                                      sparse_windows_val,
                                      normalize,
                                      alphabet_size,
                                      word_size, # Now using consistent naming
                                      breakpoints,
                                      windows) {

  # Normalize once if needed
  if (normalize) {
    vec <- (vec - mean(vec))/stats::sd(vec)
  }
  
  # Use lapply instead of for loop
  words <- lapply(1:nrow(windows), function(k) {
    start <- windows$window_starts[k]
    end <- windows$window_ends[k]
    vec_window <- vec[start:end]
    
    seewave::SAX(vec_window,
                alphabet_size = alphabet_size,
                PAA_number = word_size,
                breakpoints = breakpoints,
                collapse = "")
  })
  
  # Convert to vector and remove duplicates in one step
  words <- unique(unlist(words))
  
  # Create frequency table directly with data.table
  word_counts <- data.table::as.data.table(table(words))
  colnames(word_counts) <- c("words", "Freq")
  
  return(word_counts)
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
                                       word_size,
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
                                word_size = word_size,
                                breakpoints = breakpoints,
                                windows = windows)
  }, .id = "idx"
  ) %>% data.table::rbindlist(idcol = TRUE)

  bow <- bow[, list(Freq = sum(Freq)), keyby = list(.id,words)]
  bow_dtm <- tidytext::cast_dtm(bow, .id, words, Freq, weighting = word_weighting)
  return(bow_dtm)
}
