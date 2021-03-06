% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/connection.R
\name{zoltar_authenticate}
\alias{zoltar_authenticate}
\title{Log in to a Zoltar host}
\usage{
zoltar_authenticate(zoltar_connection, username, password)
}
\arguments{
\item{zoltar_connection}{A `ZoltarConnection` object as returned by \code{\link{new_connection}}.}

\item{username}{Username for the account to use on the connection's host}

\item{password}{Password ""}
}
\value{
None
}
\description{
Returns a new `ZoltarConnection` object, which is the starting point for working with the Zoltar API.
Once you have the connection you can call zoltar_authenticate() on it, and call projects() to get a list of objects
to start working with.
}
\examples{
\dontrun{
  zoltar_authenticate(conn, "USERNAME", "PASSWORD")
}
}
