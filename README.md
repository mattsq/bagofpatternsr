
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
#>        1  30 12  0  4  3  4 16  2 13  4  7 11 10 16
#>        10  3 26  2  4 34  2  6 11  4  5  4  8 30 16
#>        11  4  3  0  4 25  0  8 13  5 20 14  5 18  5
#>        12  0  0  1 13 46  0  9 21  7 10  4  9 23  7
#>        13  2  7  3  4 22  0  3  6  5 14  9  4 15  3
#>        14  1  6  0  2 10  1  7  0 10  8 16  5 13  8
#>        2   7  3  0  3  5  3 18  2  9  8 14 14 16  6
#>        3   1  8  0  4 70  0  0 51  3 13  3  2 19  2
#>        4   4  3  0  2  3  1 14  2 32  6  8  6  5  4
#>        5   1  1  0  4 16  5  5 11  2 13 11  4 10  1
#>        6   3  3  0  3 15  9 18  3 14 13 32  3  4  8
#>        7   2  1  1  5 10  1  5  4 10  7 10 14 11  2
#>        8   4  9  1  6 19  4 19  6  7  6  9 18 35  7
#>        9  10 13  0  8  9  2 10  4 10  9  6  6 24 15
mean(new_preds == FaceAll_TEST$target)
#> [1] 0.1786982
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
#>     1 1057  584
#>     2  368  841
mean(preds == FreezerRegularTrain_TEST$target)
#> [1] 0.6659649
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
#>     1 925 782
#>     2 500 643
mean(preds == FreezerRegularTrain_TEST$target)
#> [1] 0.5501754
```
