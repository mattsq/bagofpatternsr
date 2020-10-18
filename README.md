
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
                                           window_size = 20,
                                           verbose = FALSE)
```

Predictions on new datasets can be retrieved like so:

``` r
new_preds  <- bagofpatternsr::predict_bagofpatterns_knn(model, 
                                                        newdata = FaceAll_TEST,
                                                        verbose = FALSE)
table(new_preds, FaceAll_TEST$target)
#>          
#> new_preds   1  10  11  12  13  14   2   3   4   5   6   7   8   9
#>        1   61  11   0  23  57   0   0  24   0   4   6   5  23   0
#>        10   0   0   0   0   0   1   0   0   0   0   0   0   0   0
#>        11   0  83   8  42 228  31   7  58  28  78 113  99 202  96
#>        12   0   0   0   0   0   0   0   0   0   0   0   0   0   0
#>        13   0   0   0   0   0   0   0   0   0   0   0   0   0   0
#>        14   0   0   0   0   0   0   0   0   0   0   0   0   0   0
#>        2   11   0   0   0   0   0  58   0   0   0   0   0   1   0
#>        3    0   0   0   0   0   0  43   0   0   0   0   0   0   1
#>        4    0   0   0   0   0   0  30  54  19   0   0   0   0   0
#>        5    0   0   0   0   0   0   0   0  78   0   0   0   0   0
#>        6    0   0   0   0   0   0   0   0   6  54   8   0   0   0
#>        7    0   0   0   0   0   0   0   0   0   0  20   1   0   0
#>        8    0   0   0   1   1   0   0   0   0   0   0   4   6   0
#>        9    0   1   0   0   1   0   0   0   0   0   0   0   1   3
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
                           sparse_windows = FALSE, k = 1, 
                           verbose = FALSE, 
                           alphabet_size = 2,
                           PAA_number = 3)

preds <- predict_bagofpatterns_knn(model, FreezerRegularTrain_TEST, verbose = FALSE)

table(preds, FreezerRegularTrain_TEST$target)
#>      
#> preds    1    2
#>     1 1060  575
#>     2  365  850
mean(preds == FreezerRegularTrain_TEST$target)
#> [1] 0.6701754
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
#> preds   1   2
#>     1 813 782
#>     2 612 643
mean(preds == FreezerRegularTrain_TEST$target)
#> [1] 0.5108772
```
