% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bulk_footprintTab.R
\name{get_progeny_scatter}
\alias{get_progeny_scatter}
\title{Fetch Progeny Scatter with top Genes}
\usage{
get_progeny_scatter(de_results_matrix, x_pathway, organism, top, de_data)
}
\arguments{
\item{x_pathway}{pathway to be plotted}

\item{organism}{Human or Mouse}

\item{top}{# of significant genes for each pathway}

\item{de_data_results}{de results matrix as returned by get_pathway_activity}

\item{session}{current R session}
}
\value{
a scatter plot with the top most signif signature genes
}
\description{
Fetch Progeny Scatter with top Genes
}
