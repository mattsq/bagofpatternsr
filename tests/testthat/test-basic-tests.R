test_that("Basic model fit and predict works correctly", {

    library(bagofpatternsr)
    data("FaceAll_TRAIN")
    data("FaceAll_TEST")
    model <- bagofpatternsr::bagofpatterns_knn(FaceAll_TRAIN,
                                               target = "target",
                                               window_size = floor(sqrt(ncol(FaceAll_TRAIN))),
                                               verbose = FALSE,
                                               normalize = TRUE,
                                               alphabet_size = 2,
                                               PAA_number = 3,
                                               k = 1)

    new_preds  <- predict(model,
                          newdata = FaceAll_TEST,
                          verbose = FALSE)

    expect_equal(length(new_preds), 1690)

})
