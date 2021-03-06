% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/quantile.R
\name{quantile_data_frame_from_forecast_data}
\alias{quantile_data_frame_from_forecast_data}
\title{Converts forecast data from Zoltar's native `list` format to a quantile `data.frame`}
\usage{
quantile_data_frame_from_forecast_data(forecast_data)
}
\arguments{
\item{forecast_data}{Forecast data as a `list` in the Zoltar standard format}
}
\value{
A `data.frame` from forecast_data that's the same as `data_frame_from_forecast_data` does except
  only includes point and quantile rows, and with this header: 'location', 'target', 'type', 'quantile',
  'value', i.e., 'unit' -> 'location' and 'class' -> 'type'
}
\description{
Converts forecast data from Zoltar's native `list` format to a quantile `data.frame`
}
\examples{
\dontrun{
  forecast_data <- jsonlite::read_json("docs-predictions.json")
  data_frame <- quantile_data_frame_from_forecast_data(forecast_data)
}
}
