% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/project.R
\name{do_zoltar_query}
\alias{do_zoltar_query}
\title{A convenience function to construct and execute a Zoltar query for either forecast or score data.}
\usage{
do_zoltar_query(
  zoltar_connection,
  project_url,
  query_type,
  models = NULL,
  units = NULL,
  targets = NULL,
  timezeros = NULL,
  types = NULL,
  scores = NULL,
  as_of = NULL,
  verbose = TRUE
)
}
\arguments{
\item{zoltar_connection}{A `ZoltarConnection` object as returned by \code{\link{new_connection}}}

\item{project_url}{URL of a project in zoltar_connection's projects}

\item{query_type}{A character indicating the type of query to run. Must be one of: "forecasts", "scores",
or "truth".}

\item{models}{Character vector of model abbreviations. Used for query_type = "forecasts" and "scores".}

\item{units}{Character vector of units to retrieve. Used for all query_types.}

\item{targets}{Character vector of targets to retrieve. Used for all query_types.}

\item{timezeros}{Character vector of timezeros to retrieve in YYYY_MM_DD_DATE_FORMAT, e.g., '2017-01-17'.
Used for all query_types.}

\item{types}{Character vector of prediction types to retrieve. Used for query_type = "forecasts".}

\item{scores}{Character vector of score abbreviations to retrieve. Used for query_type = "scores".}

\item{as_of}{A date in YYYY_MM_DD_DATE_FORMAT that constrains based on forecast `issue_date`. See
documentation on forecast versions for details. Used for query_type = "forecasts".}

\item{verbose}{if TRUE, print messages on job status poll}
}
\value{
A `data.frame` of Job's data. Full documentation at \url{https://docs.zoltardata.com/}.
}
\description{
A convenience function to construct and execute a Zoltar query for either forecast or score data.
}
\examples{
\dontrun{
  forecast_data <- do_zoltar_query(
    conn, "https://www.zoltardata.com/api/project/44/", "forecasts",
    models=c("CMU-TimeSeries", "UMass-MechBayes"), units=c("01003", "US"),
    targets=c("1 wk ahead inc death"), targets=c("2020-07-19", "2020-07-20"),
    types=c("quantile"), as_of="2020-07-10")
  score_data <- do_zoltar_query(
    conn, "https://www.zoltardata.com/api/project/44/", "scores",
    c("CMU-TimeSeries", "UMass-MechBayes"), c("01003", "US"), c("1 wk ahead inc death"),
    c("2020-07-19", "2020-07-20"), c("abs_error", "pit"))
  truth_data <- do_zoltar_query(
    conn, "https://www.zoltardata.com/api/project/44/", "truth", c("01003", "US"),
    c("1 wk ahead inc death"), c("2020-07-19", "2020-07-20"))
}
}
