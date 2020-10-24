test_that("Basic model fit and predict works correctly", {

    library(tsforest)
    data("LargeKitchenAppliances_TRAIN")
    data("LargeKitchenAppliances_TEST")
    model <- tsforest(LargeKitchenAppliances_TRAIN)
    preds <- predict(model, LargeKitchenAppliances_TEST)
    preds <- preds$predictions

    expect_equal(length(preds), 375)

})
