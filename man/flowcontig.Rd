% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/flowcontig.R
\name{flowcontig}
\alias{flowcontig}
\title{Computes an ordinal distance matrices based on geographical background}
\usage{
flowcontig(fdc, code, ordre)
}
\arguments{
\item{fdc}{is the map background file (ie. a shapefile of polygons)}

\item{code}{identifiant}

\item{ordre}{number of borders to cross between origin and destination place. See details.}
}
\value{
a (k) contiguity matrice with the (k) contiguity measures
}
\description{
From a geographical background, compute an ordinal distance matrice based on a k-contiguity.
The result is a neighbourhood graph that can be used for filtering flow values beor flow mapping (\link{flowmap})
}
\details{
Contiguity is in terms of the (k=1,2,4) number of spatial boundaries to be crossed between
a place of origin and a place of destination
-\code{ordre=1 is when the flow have to cross only 1 boundary}\cr
-\code{ordre=2 is when the origin-destinations places are distant from 2 borders}\cr
-\code{ordre=4 is when the origin-destinations places are distant from 4 borders}
}
\examples{
library(cartograflow)
data(flowdata)
bkg<- system.file("shape/MGP_TER.shp", package="cartograflow",
                   lib.loc = NULL, mustWork = TRUE)
graph_ckij_1<-flowcontig(bkg,"EPT_NUM",ordre =1)
\donttest{
flowmap(graph_ckij_1,format="L",bkg,"EPT_NUM",
        filter = TRUE, taille = 0.5)}
}
