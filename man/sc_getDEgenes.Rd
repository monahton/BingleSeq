% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sc_goTab.R
\name{sc_getDEgenes}
\alias{sc_getDEgenes}
\title{Get Differentially Expressed Genes (Single Cell)}
\usage{
sc_getDEgenes(data, type, pvalue, fchange, byClust, clusterNo)
}
\arguments{
\item{data}{Differential Expression Reslts Table}

\item{type}{Filters by abs. significant, upregulation or downregulation}

\item{pvalue}{P-value threshold}

\item{fchange}{Fold-Change threshold}

\item{condition}{Filters by a given condition (AvB, BvC, etc.)}
}
\value{
Returns a vector with DE gene names
}
\description{
Filters the DE results table and returns the names of the DE genes
}
