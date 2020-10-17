
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
#>        1   11   3   1   2  24   0  17  26  11  14   5   8  21   4
#>        10   0   2   0   2   5   3   3   2   5   3   4   0   9   0
#>        11   1   6   1   2   9   0   1   1   3   3   4   2   7   0
#>        12   2   0   1   3  11   2   0   2   1   2   5   4   7   6
#>        13   3   2   1   4   6   3   2   3   1   2   8   3   4   2
#>        14   4  10   0   4  21   3   7  18  13  11  12   4  12   9
#>        2    3   1   0   1   8   2   4   2   1   0   3   0   2   2
#>        3    4   1   0   0   8   0   6   4   7   3   0   2   1   7
#>        4    1   4   0   1   6   2   6   3   2   0   1   0   1   1
#>        5    0   3   0   0   5   0   2   4   3   0   3   1   2   1
#>        6    0   0   0   2   3   3   4   7   2   7   4   3   2   2
#>        7    0   2   1   0   9   1   1   1   2   0   3   1   4   0
#>        8    1   1   0   2  10   2   1   3   1   1   2   4   9   1
#>        9   42  60   3  43 162  11  84  60  79  90  93  77 152  65
```
