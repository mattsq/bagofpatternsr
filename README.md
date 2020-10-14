
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
#>        1   53   0   0   0   0   0   0   0   0   0   0   0   0   0
#>        10   0   0   0   0   0   0   0   0   0   0   0   0   0   0
#>        11   0   0   0   0   0   0   0   0   0   0   0   0   0   0
#>        12   0   0   0   0   0   0   0   0   0   0   0   0   0   0
#>        13   0   0   0   0   0   0   0   0   0   0   0   0   0   0
#>        14   0   0   0   0   0   0   0   0   0   0   0   0   0   0
#>        2    1   0   0   0   0   0  31   0   0   0   0   0   0   0
#>        3   18  95   8  66 287  32 107 134 131 135 147 108 233 100
#>        4    0   0   0   0   0   0   0   2   0   0   0   0   0   0
#>        5    0   0   0   0   0   0   0   0   0   0   0   0   0   0
#>        6    0   0   0   0   0   0   0   0   0   1   0   0   0   0
#>        7    0   0   0   0   0   0   0   0   0   0   0   0   0   0
#>        8    0   0   0   0   0   0   0   0   0   0   0   1   0   0
#>        9    0   0   0   0   0   0   0   0   0   0   0   0   0   0
```
