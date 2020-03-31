context("model")

library(httr)
library(jsonlite)
library(mockery)
library(testthat)
library(webmockr)
library(zoltr)


test_that("model_info() returns a list", {
  zoltar_connection <- new_connection("http://example.com")
  exp_model_info <- jsonlite::read_json("data/model-1.json")
  exp_model_info$forecasts <- NULL
  exp_model_info$aux_data_url <- NA
  m <- mock(exp_model_info)
  testthat::with_mock("zoltr::get_resource" = m, {
    act_model_info <- model_info(zoltar_connection, "http://example.com/api/model/1/")
    expect_equal(length(mock_calls(m)), 1)
    expect_equal(mock_args(m)[[1]][[2]], "http://example.com/api/model/1/")
    expect_is(act_model_info, "list")
    expect_equal(act_model_info, exp_model_info)
  })
})


test_that("create_model() creates a Model", {
  zoltar_connection <- new_connection("http://example.com")
  model_info <- jsonlite::read_json("data/model-1.json")
  webmockr::stub_request("post", uri = "http://example.com/api/project/1/models/") %>%
    to_return(
      body = model_info,
      status = 200,
      headers = list('Content-Type' = 'application/json; charset=utf-8'))
  model_config <- jsonlite::read_json("data/example-model-config.json")
  model_url <- create_model(zoltar_connection, "http://example.com/api/project/1/", model_config)
  expect_equal(model_url, "http://example.com/api/model/1/")
})


test_that("create_model() calls re_authenticate_if_necessary() and returns a Model URL", {
  zoltar_connection <- new_connection("http://example.com")
  m <- mock()
  model_info <- jsonlite::read_json("data/model-1.json")
  testthat::with_mock("zoltr::re_authenticate_if_necessary" = m, {
    webmockr::stub_request("post", uri = "http://example.com/api/project/1/models/") %>%
      to_return(
        body = model_info,
        status = 200,
        headers = list('Content-Type' = 'application/json; charset=utf-8'))
    model_config <- jsonlite::read_json("data/example-model-config.json")
    model_url <- create_model(zoltar_connection, "http://example.com/api/project/1/", model_config)
    expect_equal(length(mock_calls(m)), 1)
    expect_equal(model_url, "http://example.com/api/model/1/")
  })
})


test_that("delete_model() calls delete_resource", {
  zoltar_connection <- new_connection("http://example.com")
  m <- mock()
  testthat::with_mock("zoltr::delete_resource" = m, {
    delete_model(zoltar_connection, "http://example.com/api/model/0/")
    expect_equal(length(mock_calls(m)), 1)
    expect_equal(mock_args(m)[[1]][[2]], "http://example.com/api/model/0/")
  })
})


test_that("forecasts() returns a data.frame", {
  zoltar_connection <- new_connection("http://example.com")
  forecasts_list_json <- jsonlite::read_json("data/forecasts-list.json")
  m <- mock(forecasts_list_json)  # return values in calling order
  testthat::with_mock("zoltr::get_resource" = m, {
    the_forecasts <- forecasts(zoltar_connection, "http://example.com/api/model/5/")
    expect_equal(length(mock_calls(m)), 1)
    expect_equal(mock_args(m)[[1]][[2]], "http://example.com/api/model/5/forecasts/")
    expect_is(the_forecasts, "data.frame")
    expect_equal(names(the_forecasts), c("id", "url", "forecast_model_url", "source", "timezero_url", "created_at",
                                         "forecast_data_url"))
    expect_equal(nrow(the_forecasts), 2)  # 2 forecasts
    expect_equal(ncol(the_forecasts), 7)

    exp_row <- data.frame(id = 3, url = "http://example.com/api/forecast/3/",
                          forecast_model_url = "http://example.com/api/model/5/",
                          source = "docs-predictions.json",
                          timezero_url = "http://example.com/api/timezero/5/",
                          created_at = as.Date("2020-03-05T15:47:47.369231-05:00"),
                          forecast_data_url = "http://example.com/api/forecast/3/data/",
                          stringsAsFactors = FALSE)
    forecast_row <- the_forecasts[1,]
    expect_equal(forecast_row, exp_row)
  })
})


test_that("upload_forecast() returns an UploadFileJob URL, and upload_info() is correct", {
  zoltar_connection <- new_connection("http://example.com")
  upload_file_job_json <- jsonlite::read_json("data/upload-file-job-2.json")
  mockery::stub(upload_forecast, 'httr::upload_file', NULL)
  webmockr::stub_request("post", uri = "http://example.com/api/model/1/forecasts/") %>%
    to_return(
      body = upload_file_job_json,
      status = 200,
      headers = list('Content-Type' = 'application/json; charset=utf-8'))
  upload_file_job_url <- upload_forecast(zoltar_connection, "http://example.com/api/model/1/", NULL, list())  # timezero_date, forecast_data
  expect_equal(upload_file_job_url, "http://example.com/api/uploadfilejob/2/")

  exp_upload_file_job_json <- upload_file_job_json
  exp_upload_file_job_json$status <- "SUCCESS"
  exp_upload_file_job_json$created_at <- as.Date("2019-03-26T14:55:31.028436-04:00")
  exp_upload_file_job_json$updated_at <- as.Date("2019-03-26T14:55:37.812924-04:00")
  exp_upload_file_job_json$input_json <- list("forecast_model_pk" = 1, "timezero_pk" = 2)
  exp_upload_file_job_json$output_json <- list("forecast_pk" = 3)

  # test upload_info()
  m <- mock(upload_file_job_json)
  testthat::with_mock("zoltr::get_resource" = m, {
    the_upload_info <- upload_info(zoltar_connection, "http://example.com/api/uploadfilejob/2/")
    expect_equal(length(mock_calls(m)), 1)
    expect_equal(mock_args(m)[[1]][[2]], "http://example.com/api/uploadfilejob/2/")
    expect_is(the_upload_info, "list")
    expect_equal(the_upload_info, exp_upload_file_job_json)
  })
})


test_that("upload_forecast() calls re_authenticate_if_necessary()", {
  zoltar_connection <- new_connection("http://example.com")
  m <- mock()
  upload_file_job_json <- jsonlite::read_json("data/upload-file-job-2.json")
  testthat::with_mock("zoltr::re_authenticate_if_necessary" = m, {
    upload_forecast(zoltar_connection, "http://example.com/api/model/1/", NULL, list())  # timezero_date, forecast_data
    expect_equal(length(mock_calls(m)), 1)
  })
})


test_that("upload_forecast() passes correct url to POST()", {
  zoltar_connection <- new_connection("http://example.com")
  called_args <- NULL
  timezero_date <- "2019-10-21"
  forecast_data <- jsonlite::read_json("data/docs-predictions.json")
  testthat::with_mock(
    "httr::POST" = function(...) {
      called_args <<- list(...)
      load("data/upload_response.rda")  # 'response' contains 200 response from sample upload_forecast() call
      response
    },
    upload_file_job_url <- upload_forecast(zoltar_connection, "http://example.com/api/model/1/", timezero_date,
                                           forecast_data))
  expect_equal(called_args$url, "http://example.com/api/model/1/forecasts/")
  expect_equal(called_args$body$timezero_date, timezero_date)
  expect_s3_class(called_args$body$data_file, "form_file")
})


test_that("upload_forecast() accepts a `list` and not a file", {
  # just a simple test to drive converting upload_forecast() from file to list
  zoltar_connection <- new_connection("http://example.com")
  expect_error(upload_forecast(zoltar_connection, "http://example.com/api/model/1/", NULL, NULL),  # timezero_date, forecast_data
               "forecast_data was not a `list`", fixed = TRUE)
})