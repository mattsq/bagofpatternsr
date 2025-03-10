
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
#' @importFrom data.table rbindlist dcast as.data.table
#' @importFrom tidyr pivot_wider
#' @importFrom tidytext cast_dtm
#' @importFrom tm removeSparseTerms nTerms
convert_df_to_bag_of_words <- function(data,
                                     window_size,
                                     sparse_windows_val,
                                     normalize,
                                     alphabet_size,
                                     word_size, # Updated parameter name
                                     breakpoints,
                                     word_weighting,
                                     maximum_sparsity,
                                     verbose,
                                     windows) {
  
  # Convert input to data.table
  dt <- data.table::as.data.table(data)
  
  # More efficient processing with data.table
  bow_list <- vector("list", length = nrow(dt))
  
  for (i in 1:nrow(dt)) {
    if (verbose) cat("Processing row", i, "of", nrow(dt), "\n")
    
    vec <- unlist(dt[i])
    bow_list[[i]] <- convert_vector_to_word_hist(
      vec = vec,
      window_size = window_size,
      sparse_windows_val = sparse_windows_val,
      normalize = normalize,
      alphabet_size = alphabet_size,
      word_size = word_size,
      breakpoints = breakpoints,
      windows = windows
    )
    
    # Add row identifier
    bow_list[[i]][, .id := i]
  }
  
  # Combine and summarize with data.table
  bow <- data.table::rbindlist(bow_list)
  bow <- bow[, list(Freq = sum(Freq)), by = list(.id, words)]
  
  # Convert to document-term matrix
  bow_dtm <- tidytext::cast_dtm(bow, .id, words, Freq, weighting = word_weighting)
  
  return(bow_dtm)
}
