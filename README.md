
<!-- README.md is generated from README.Rmd. Please edit that file -->

# bagofpatternsr

<!-- badges: start -->

<!-- badges: end -->

The goal of bagofpatternsr is to provide a simple implementation of the
‘Bag of Patterns’ time series classification algorithm as described by
Lin et al (2012). It’s based on the description at
timeseriesclassification.com - there are other implementations of it in
R, but some are built in Java which can be tricky to run.

It uses the `seewave::` implementation of Symbolic Aggregate eXPressions
(SAX) for the patterns, `data.table::` for data munging and `FNN::` for
fast K-Nearest Neighbours matching.

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("mattsq/bagofpatternsr")
```

## Example

Using it is easy\! Models are fit like so:

``` r
library(bagofpatternsr)
data("FaceAll_TRAIN")
data("FaceAll_TEST")
model <- bagofpatternsr::bagofpatterns_knn(FaceAll_TRAIN, 
                                           target = "target",
                                           window_size = floor(sqrt(ncol(FaceAll_TRAIN))),
                                           verbose = FALSE,
                                           normalize = TRUE,
                                           alphabet_size = 2, 
                                           PAA_number = 3)
print(model)
#> A trained Bag Of Patterns model with:
#> A time series of length 131 converted into a word histogram with 9 entries, predicting class: target 
#> The model has the following hyperparameters:
#>   K-Nearest Neighbours to be used: 1 
#>   Window Size: 11 
#>   Alphabet Size: 2 
#>   Word Size: 3 
#>   SAX breakpoint method: quantiles 
#>   Trained with sparse windows: FALSE 
#>   Windows Z-normalized before creating words: TRUE 
#> 
#> Examples of words in dictionary include: aaa, aab, aba, abb, baa
```

Predictions on new datasets can be retrieved like so:

``` r
new_preds  <- predict(model, 
                newdata = FaceAll_TEST,
                verbose = FALSE)
table(new_preds, FaceAll_TEST$target)
#>          
#> new_preds  1 10 11 12 13 14  2  3  4  5  6  7  8  9
#>        1  27 10  0  4  3  4 14  1 14  3  8  8 10 15
#>        10  4 25  0  5 35  1  4 13  4  6  6  8 31 18
#>        11  3  1  0  3 24  1 12 11  5 20 16  6 16  3
#>        12  0  1  1 14 46  1  8 19  7  7  5  8 25  5
#>        13  4 10  3  2 15  0  3  8  4 15 10  4 17  3
#>        14  2  6  0  4 10  1  5  0  9  8 13  7 15  7
#>        2   5  3  0  2  6  2 19  2  9  6 14 11 11  6
#>        3   1  8  0  5 76  0  1 56  2 15  2  2 22  2
#>        4   4  3  0  2  4  2 14  2 32  7 10  5  6  3
#>        5   1  1  0  2 18  5  6  7  2 16 10  4 10  1
#>        6   2  4  0  3 17  9 19  3 17 13 32  4  4 10
#>        7   3  0  1  6  6  1  7  5  9  8 10 20  8  3
#>        8   6 10  3  5 18  3 16  6  6  5  6 16 34  9
#>        9  10 13  0  9  9  2 10  3 11  7  5  6 24 15
mean(new_preds == FaceAll_TEST$target)
#> [1] 0.1810651
```

There’s support for the entirely atheoretical idea of ‘sparse windows’ -
essentially, rather than generating a dictionary out of every single
window, we take inspiration from Time Series Forest by taking `sqrt(m)`
random windows from each vector. It speed up training dramatically, and
seems to improve generalization - compare:

``` r
library(tsforest)
data("FreezerRegularTrain_TRAIN")

model <- bagofpatterns_knn(FreezerRegularTrain_TRAIN, 
                           window_size = 100, 
                           sparse_windows = FALSE,
                           normalize = TRUE,
                           k = 1, 
                           verbose = FALSE, 
                           alphabet_size = 2,
                           PAA_number = 3)

preds <- predict(model, FreezerRegularTrain_TEST, verbose = FALSE)

table(preds, FreezerRegularTrain_TEST$target)
#>      
#> preds    1    2
#>     1 1053  578
#>     2  372  847
mean(preds == FreezerRegularTrain_TEST$target)
#> [1] 0.6666667
```

With:

``` r
data("FreezerRegularTrain_TRAIN")

model <- bagofpatterns_knn(FreezerRegularTrain_TRAIN, 
                           window_size = 100, 
                           sparse_windows = TRUE, k = 1, 
                           verbose = FALSE, 
                           alphabet_size = 2,
                           PAA_number = 3)

preds <- predict(model, FreezerRegularTrain_TEST, verbose = FALSE)

table(preds, FreezerRegularTrain_TEST$target)
#>      
#> preds   1   2
#>     1 769 669
#>     2 656 756
mean(preds == FreezerRegularTrain_TEST$target)
#> [1] 0.5350877
```
