
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
                                           word_size = 3,
                                           k = 1)
print(model)
#> A trained Bag Of Patterns model with:
#> A time series of length 131 converted into a word histogram with 9 entries, predicting class: target 
#> The model has the following hyperparameters:
#>   K-Nearest Neighbours to be used: 
#>   Window Size: 11 
#>   Alphabet Size: 2 
#>   Word Size: 3 
#>   SAX breakpoint method: quantiles 
#>   Trained with sparse windows:  
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
#>        1  24 11  0  5  4  4 14  2 16  5  8  9  8 13
#>        10  2 24  0  3 31  1  5 14  3  5  5  9 30 14
#>        11  3  2  1  4 23  0 11 13  8 20 12  6 15  3
#>        12  2  2  0 12 43  1  6 15  6  7  3 11 22  5
#>        13  3  7  3  4 22  0  4  8  4 15 12  3 24  4
#>        14  2  7  0  3  9  1  5  0  8  8 16  7 14  8
#>        2   5  3  0  2  4  3 14  2  6  6 15  9 11  5
#>        3   3  7  0  7 76  0  1 55  1 14  3  4 21  3
#>        4   4  3  0  2  3  3 14  2 33  6  8  4  5  4
#>        5   1  1  0  3 16  6  7  6  2 14  7  4  8  2
#>        6   5  4  0  4 14  6 18  3 16 15 30  4  5  8
#>        7   5  3  1  5  8  1  8  3 10  8 12 18 11  3
#>        8   5 10  3  6 20  4 20 10  7  6 10 16 32 10
#>        9   8 11  0  6 14  2 11  3 11  7  6  5 27 18
mean(new_preds == FaceAll_TEST$target)
#> [1] 0.1763314
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
                           verbose = FALSE, 
                           alphabet_size = 2,
                           word_size = 3,
                           k = 1)

preds <- predict(model, FreezerRegularTrain_TEST, verbose = FALSE)

table(preds, FreezerRegularTrain_TEST$target)
#>      
#> preds   1   2
#>     1 845 498
#>     2 580 927
mean(preds == FreezerRegularTrain_TEST$target)
#> [1] 0.6217544
```

With:

``` r
data("FreezerRegularTrain_TRAIN")

model <- bagofpatterns_knn(FreezerRegularTrain_TRAIN, 
                           window_size = 100, 
                           sparse_windows = TRUE, 
                           verbose = FALSE, 
                           alphabet_size = 2,
                           word_size = 3,
                           k = 1)

preds <- predict(model, FreezerRegularTrain_TEST, verbose = FALSE)

table(preds, FreezerRegularTrain_TEST$target)
#>      
#> preds   1   2
#>     1 917 526
#>     2 508 899
mean(preds == FreezerRegularTrain_TEST$target)
#> [1] 0.637193
```

You can also use `fit_bagofpatterns` and `bake_bagofpatterns` to use the
underlying Bag Of Patterns representation for other models. Here’s a
simple example using logistic regression instead of K-Nearest Neighbors:

``` r
data("FreezerRegularTrain_TRAIN")
data("FreezerRegularTrain_TEST")

bop_obj <- fit_bagofpatterns(FreezerRegularTrain_TRAIN,
                              window_size = 100, 
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
#> -2.35829  -1.07808   0.03738   1.15755   1.78896  
#> 
#> Coefficients:
#>             Estimate Std. Error z value Pr(>|z|)   
#> (Intercept)  5.08430    1.71183   2.970  0.00298 **
#> aab         -0.96603    1.02828  -0.939  0.34749   
#> aba         -1.26785    1.20479  -1.052  0.29264   
#> abb         -0.58975    0.64354  -0.916  0.35945   
#> baa         -0.67180    0.31217  -2.152  0.03139 * 
#> bba          0.19452    0.29899   0.651  0.51531   
#> aaa          0.08889    0.33553   0.265  0.79108   
#> bbb          1.20984    0.41070   2.946  0.00322 **
#> bab          0.27304    0.62333   0.438  0.66136   
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> (Dispersion parameter for binomial family taken to be 1)
#> 
#>     Null deviance: 207.94  on 149  degrees of freedom
#> Residual deviance: 181.65  on 141  degrees of freedom
#> AIC: 199.65
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
#> preds    1    2
#>     1 1104  667
#>     2  321  758
```
