
#' @importFrom seewave SAX
#' @importFrom dplyr slice_sample
#' @importFrom stats sd
#' @importFrom data.table data.table
#' @importFrom future plan multiprocess future_apply
convert_vector_to_word_hist <- function(vec,
                                      window_size,
                                      sparse_windows_val,
                                      normalize,
                                      alphabet_size,
                                      word_size, 
                                      breakpoints,
                                      windows) {

  # Normalize once if needed
  if (normalize) {
    vec <- (vec - mean(vec))/stats::sd(vec)
  }

# Setup parallel processing if not already done
if (!requireNamespace("future", quietly = TRUE) || 
    !requireNamespace("future.apply", quietly = TRUE)) {
  # Fall back to serial processing if packages not available
  words <- apply(window_matrix, 2, function(window) {
    seewave::SAX(window,
                alphabet_size = alphabet_size,
                PAA_number = word_size,
                breakpoints = breakpoints,
                collapse = "")
  })
} else {
  # Use parallel processing
  old_plan <- future::plan(future::multiprocess)
  on.exit(future::plan(old_plan), add = TRUE)
  
  # Process windows in parallel 
  words <- future.apply::future_apply(window_matrix, 2, function(window) {
    seewave::SAX(window,
                alphabet_size = alphabet_size,
                PAA_number = word_size,
                breakpoints = breakpoints,
                collapse = "")
  })
}
  
  # Unlist words (keeping all occurrences for frequency counting)
  words <- unlist(words)
  
  # Create word frequency table more efficiently with data.table
  word_counts <- data.table::data.table(words = words)[, .(Freq = .N), by = words]
  
  return(word_counts)
}

#' @importFrom purrr map
#' @importFrom dplyr bind_rows group_by summarise select
#' @importFrom tibble as_tibble
#' @importFrom data.table rbindlist dcast as.data.table setDT set dcast
#' @importFrom tidyr pivot_wider
#' @importFrom tidytext cast_dtm
#' @importFrom tm removeSparseTerms nTerms as.DocumentTermMatrix
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
  
  # Ensure data is a data.table
  dt <- data.table::setDT(data.table::copy(data))
  
  # Pre-allocate list with exact size
  bow_list <- vector("list", length = nrow(dt))
  
  for (i in 1:nrow(dt)) {
    if (verbose && i %% 10 == 0) cat("Processing row", i, "of", nrow(dt), "\n")
    
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
    data.table::set(bow_list[[i]], j = ".id", value = i)
  }
  
  # Combine all results efficiently
  bow <- data.table::rbindlist(bow_list, use.names = TRUE)
  
  # Aggregate by document and term
  bow <- bow[, list(Freq = sum(Freq)), by = list(.id, words)]
  
  # Create document-term matrix directly with data.table
  dtm <- data.table::dcast(bow, .id ~ words, value.var = "Freq", fill = 0)
  
  # Apply term weighting if needed
  if (!identical(word_weighting, tm::weightTf)) {
    # Convert to matrix for weighting
    mat <- as.matrix(dtm[, -1, with = FALSE])
    rownames(mat) <- dtm[[".id"]]
    
    # Apply weighting function
    weighted_mat <- word_weighting(mat)
    
    # Convert back to document-term matrix format
    dtm_weighted <- tm::as.DocumentTermMatrix(
      weighted_mat,
      weighting = word_weighting
    )
    return(dtm_weighted)
  } else {
    # Convert to DocumentTermMatrix format for consistency
    mat <- as.matrix(dtm[, -1, with = FALSE])
    rownames(mat) <- dtm[[".id"]]
    dtm_result <- tm::as.DocumentTermMatrix(
      mat,
      weighting = tm::weightTf
    )
    return(dtm_result)
  }
}
