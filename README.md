
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
                                           alphabet_size = 2, 
                                           PAA_number = 3)
```

Predictions on new datasets can be retrieved like so:

``` r
new_preds  <- predict(model, 
                newdata = FaceAll_TEST,
                verbose = FALSE)
table(new_preds, FaceAll_TEST$target)
#>          
#> new_preds  1 10 11 12 13 14  2  3  4  5  6  7  8  9
#>        1  26 12  0  5  4  4 11  2 16  5  8  9  9 14
#>        10  4 22  1  3 36  1  4 12  4  4  4 11 30 19
#>        11  3  2  0  3 26  1  7 10  5 18 13  6 17  5
#>        12  0  1  2 12 45  1  8 21  7  8  5  8 27  4
#>        13  3  8  3  3 17  0  3  8  3 16 11  5 18  5
#>        14  1  7  0  5 10  1  5  0  9  9 15  7 13  8
#>        2   7  3  0  3  5  2 17  2  9  6 14 13 11  7
#>        3   1  7  0  6 73  0  0 52  2 15  2  3 20  2
#>        4   4  3  0  2  3  2 14  1 31  7  8  3  5  4
#>        5   1  1  0  4 16  5  7  8  2 13 11  3 10  2
#>        6   2  5  0  2 13  8 21  3 15 14 33  4  5  5
#>        7   3  1  1  5  9  1 10  4 11  8  9 17 10  3
#>        8   6 10  1  7 22  4 21 10  6  5  8 15 32  7
#>        9  11 13  0  6  8  2 10  3 11  8  6  5 26 15
mean(new_preds == FaceAll_TEST$target)
#> [1] 0.1704142
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
                           k = 1, 
                           verbose = FALSE, 
                           alphabet_size = 2,
                           PAA_number = 3)

preds <- predict(model, FreezerRegularTrain_TEST, verbose = FALSE)

table(preds, FreezerRegularTrain_TEST$target)
#>      
#> preds    1    2
#>     1 1058  578
#>     2  367  847
mean(preds == FreezerRegularTrain_TEST$target)
#> [1] 0.6684211
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
#> preds    1    2
#>     1 1284 1359
#>     2  141   66
mean(preds == FreezerRegularTrain_TEST$target)
#> [1] 0.4736842
```
