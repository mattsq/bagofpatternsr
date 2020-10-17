
<!-- README.md is generated from README.Rmd. Please edit that file -->

# bagofpatternsr

<!-- badges: start -->

<!-- badges: end -->

The goal of bagofpatternsr is to provide a simple implementation of the
‘Bag of Patterns’ time series classification algorithm as described by
Lin et al (2012). It’s based on the description at
timeseriesclassification.com - there are other implementations of it in
R, but some are built in Java which can be tricky to run.

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
#>        1   11   2   1   3  24   0  19  27  11  13   5   8  20   4
#>        10   0   3   0   2   5   3   4   2   4   4   4   0   8   2
#>        11   1   6   1   2   9   0   1   1   3   3   4   2   7   0
#>        12   2   0   1   3  12   2   0   2   0   2   5   4   7   5
#>        13   3   1   1   4   7   4   2   3   1   2   8   3   4   2
#>        14   4  11   0   4  24   3   8  15  11  10  10   8  10   7
#>        2    3   1   0   1   7   2   4   3   1   0   3   0   1   2
#>        3    4   1   0   0   9   0   6   3   7   4   0   2   1   6
#>        4    0   4   0   1   6   2   6   4   2   0   1   0   1   2
#>        5    0   3   0   0   5   0   2   4   4   1   3   1   3   1
#>        6    0   0   0   2   1   2   4   6   2   7   4   6   1   2
#>        7    0   2   1   0   9   1   1   1   2   0   3   1   5   0
#>        8    1   2   0   2  10   2   1   3   1   1   2   4   9   1
#>        9   43  59   3  42 159  11  80  62  82  89  95  70 156  66
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
#> preds   1   2
#>     1 539 466
#>     2 886 959
mean(preds == FreezerRegularTrain_TEST$target)
#> [1] 0.525614
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
#>     1 1278  103
#>     2  147 1322
mean(preds == FreezerRegularTrain_TEST$target)
#> [1] 0.9122807
```
