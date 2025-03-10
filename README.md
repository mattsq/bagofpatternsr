
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
                                           verbose = FALSE,
                                           normalize = TRUE,
                                           alphabet_size = 2, 
                                           word_size = 4,
                                           k = 1)
print(model)
#> A trained Bag Of Patterns object with:
#> A time series of length 131 converted into a word histogram with 17 entries, predicting class: target 
#> The object has the following hyperparameters:
#>   Window Size: 20 
#>   Alphabet Size: 2 
#>   Word Size: 4 
#>   SAX breakpoint method: quantiles 
#>   Term weighting method: term frequency 
#>   Sparsity constraint: 1.00 
#>   Trained with sparse windows:  
#>   Windows Z-normalized before creating words: TRUE 
#> 
#> Examples of words in dictionary include: aaab, aaba, aabb, abaa, abab 
#>   K-Nearest Neighbours to be used: 1
```

Predictions on new datasets can be retrieved like so:

``` r
new_preds  <- predict(model, 
                newdata = FaceAll_TEST,
                verbose = FALSE)
table(new_preds, FaceAll_TEST$target)
#>          
#> new_preds  1 10 11 12 13 14  2  3  4  5  6  7  8  9
#>        1  44  2  0  0 17  0  2  6  5  5  4  6 11  5
#>        10  3 26  0  3 37  3  3 18  3 11  6  3 59  8
#>        11  2  3  3  1 55  1  6 11  8  2  8  4  9  0
#>        12  0  4  0 31 10  1 12  9  6  7 13  3 24  5
#>        13  4  6  1  0 51  4  9 10  1  4  2  3 10  1
#>        14  1  3  2  1  2  3 18  1  6  4  5  7  3 15
#>        2   0  3  0  5  5  3 20  0  9  3  8  4  5  5
#>        3   3 16  0 12 80  1  7 62  1 12  2  1 34  1
#>        4   2  1  0  1  1  1  9  2 26  1 15  2  4  2
#>        5   6  9  0  0  5  3  5  6  4 55 13  5 15 10
#>        6   0  0  0  1  1  4 10  0 18  5 29 10  5  3
#>        7   4  3  1  4  5  6 15  1 18  7 20 50  5  8
#>        8   0  8  0  6 10  2 12 10  9 17 14  5 36  1
#>        9   3 11  1  1  8  0 10  0 17  3  8  6 13 36
mean(as.character(new_preds) == as.character(FaceAll_TEST$target))
#> [1] 0.2792899
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
                           window_size = 20, 
                           sparse_windows = FALSE,
                           normalize = TRUE,
                           verbose = FALSE, 
                           alphabet_size = 3,
                           word_size = 8,
                           k = 1)

preds <- predict(model, FreezerRegularTrain_TEST, verbose = FALSE)

table(preds, FreezerRegularTrain_TEST$target)
#>      
#> preds    1    2
#>     1 1006  510
#>     2  419  915
mean(preds == FreezerRegularTrain_TEST$target)
#> [1] 0.6740351
```

With:

``` r
data("FreezerRegularTrain_TRAIN")

model <- bagofpatterns_knn(FreezerRegularTrain_TRAIN, 
                           window_size = 20, 
                           sparse_windows = TRUE, 
                           verbose = FALSE, 
                           alphabet_size = 3,
                           word_size = 8,
                           k = 1)

preds <- predict(model, FreezerRegularTrain_TEST, verbose = FALSE)

table(preds, FreezerRegularTrain_TEST$target)
#>      
#> preds   1   2
#>     1 994 880
#>     2 431 545
mean(preds == FreezerRegularTrain_TEST$target)
#> [1] 0.54
```

You can also use `fit_bagofpatterns` and `bake_bagofpatterns` to use the
underlying Bag Of Patterns representation for other models. Here’s a
simple example using logistic regression instead of K-Nearest Neighbors:

``` r
data("FreezerRegularTrain_TRAIN")
data("FreezerRegularTrain_TEST")

bop_obj <- fit_bagofpatterns(FreezerRegularTrain_TRAIN,
                              window_size = 20, 
                              sparse_windows = FALSE, 
                              verbose = FALSE, 
                              alphabet_size = 2,
                              word_size = 3)

FreezerRegularTrain_TRAIN_conv <- bake_bagofpatterns(bop_obj)

glm_model <- glm(target ~ ., data = FreezerRegularTrain_TRAIN_conv, family = "binomial")
summary(glm_model)
#> 
#> Call:
#> glm(formula = target ~ ., family = "binomial", data = FreezerRegularTrain_TRAIN_conv)
#> 
#> Deviance Residuals: 
#>      Min        1Q    Median        3Q       Max  
#> -1.89414  -1.01502   0.06302   1.04366   2.05352  
#> 
#> Coefficients:
#>             Estimate Std. Error z value Pr(>|z|)   
#> (Intercept)  5.69392    2.02425   2.813  0.00491 **
#> aaa         -0.02959    0.07189  -0.412  0.68063   
#> aab         -0.07574    0.09457  -0.801  0.42320   
#> aba          0.01853    0.09922   0.187  0.85187   
#> abb          0.05246    0.09540   0.550  0.58240   
#> baa         -0.01049    0.07977  -0.132  0.89533   
#> bab         -0.20666    0.10068  -2.053  0.04010 * 
#> bba         -0.23673    0.07919  -2.989  0.00280 **
#> bbb          0.11444    0.07018   1.631  0.10298   
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> (Dispersion parameter for binomial family taken to be 1)
#> 
#>     Null deviance: 207.94  on 149  degrees of freedom
#> Residual deviance: 186.61  on 141  degrees of freedom
#> AIC: 204.61
#> 
#> Number of Fisher Scoring iterations: 4
```

We can generate predictions by calling `bake_bagofpatterns` on a new
dataset:

``` r
FreezerRegularTrain_TEST_conv  <- bake_bagofpatterns(bop_obj, FreezerRegularTrain_TEST)

preds <- predict(glm_model, FreezerRegularTrain_TEST_conv, type = "response")

preds <- as.numeric(preds>=0.5) + 1

table(preds, FreezerRegularTrain_TEST$target)
#>      
#> preds   1   2
#>     1 877 452
#>     2 548 973
```
