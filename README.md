
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
new_preds  <- bagofpatternsr::predict_bagofpatterns_knn(model, 
                                                        newdata = FaceAll_TEST,
                                                        verbose = FALSE)
table(new_preds, FaceAll_TEST$target)
#>          
#> new_preds  1 10 11 12 13 14  2  3  4  5  6  7  8  9
#>        1  26 12  0  3  4  4 11  1 14  6  8 10  9 14
#>        10  3 24  2  6 32  2  5 12  6  5  6  9 30 15
#>        11  4  1  0  4 23  0 11 11  6 20 14  5 19  5
#>        12  0  2  1 13 47  0  8 17  8  6  4  8 25  7
#>        13  2  9  3  3 19  0  3  9  4 17 11  5 20  4
#>        14  2  6  0  3  9  1  4  0 10  8 13  5 11  8
#>        2   9  3  0  3  5  2 19  2  8  5 12 10 11  7
#>        3   1  7  0  4 75  0  0 54  0 13  3  4 19  2
#>        4   4  3  0  2  4  2 15  1 32  5  9  4  5  4
#>        5   1  2  0  4 16  5  5  9  2 14 10  4 12  2
#>        6   2  3  0  3 16 10 21  3 15 13 33  3  5  6
#>        7   3  2  1  5  8  1  8  4 10  8 11 18 10  3
#>        8   6  9  1  6 19  3 16 10  5  8  8 18 37  8
#>        9   9 12  0  7 10  2 12  3 11  8  5  6 20 15
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

preds <- predict_bagofpatterns_knn(model, FreezerRegularTrain_TEST, verbose = FALSE)

table(preds, FreezerRegularTrain_TEST$target)
#>      
#> preds    1    2
#>     1 1052  575
#>     2  373  850
mean(preds == FreezerRegularTrain_TEST$target)
#> [1] 0.6673684
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

preds <- predict_bagofpatterns_knn(model, FreezerRegularTrain_TEST, verbose = FALSE)

table(preds, FreezerRegularTrain_TEST$target)
#>      
#> preds    1    2
#>     1 1083  861
#>     2  342  564
mean(preds == FreezerRegularTrain_TEST$target)
#> [1] 0.5778947
```
