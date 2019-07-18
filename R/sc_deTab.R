#' Single Cell Differential Expession Tab UI
#'
#' @export
#' @return None
sc_deUI <- function(id) {
  ns <- NS(id)
  tagList(

    # Sidebar panel for inputs ----
    sidebarPanel(
      tabsetPanel(id = ns("goSideTabSet"),
                  tabPanel(title = "DGE test",

                           selectInput(ns("dgeTestCombo"), label = "Select Test Type",
                                       choices = list("MAST" = "MAST",
                                                      "Wilcoxon Rank Sum test" = "wilcox",
                                                      "Student's T-test" = "t",
                                                      "ROC analysis" = "roc",
                                                      "Likelihood-ratio test(bimod)" = "bimod",
                                                      "Negative Binomial" = "Negative Binomial",
                                                      "Logistic Regression" = "LR")),

                           numericInput(ns("logFCdgeInput"), label = "FC Threshold",
                                        min = 0, max = 10, value = 1.5),

                           numericInput(ns("pctdgeInput"), label = "Minimum Cell Fraction of Genes",
                                        min = 0, max = 0.5, value = 0.25),

                           actionButton(ns("dgeButton"), label = "Get Gene Markers"),


                           conditionalPanel(condition = "input.dgeButton > 0",
                             ns = ns,

                             checkboxInput(ns("dgeClusterCheck"), h4("Show All Clusters"), TRUE),

                             conditionalPanel(condition = "!input.dgeClusterCheck",
                                              ns = ns,

                                              numericInput(ns("dgeClustInput"), label = "Cluster to Display",
                                                           min = 1, max = 8, value = 0)
                             )
                           )
                  ),

                  tabPanel(title = "Plots",

                           h4("Cluster Heatmap"),

                           numericInput(ns("clustHeatInput"), label = "Genes to display",
                                        min = 1, value = 10),

                           actionButton(ns("dgeHeatButton"), label = "Generate Heatmap"),

                           tags$hr(),

                           h4("Choose Gene and Plot"),

                           textInput(ns("geneNameInput"), "Enter Gene Name"),

                           radioButtons(ns("dgePlotType"), label = "Plot Type",
                                        c("Violin Plot" = 1,
                                          "Feature Plot" = 2,
                                          "RidgePlot" = 3)),

                           actionButton(ns("dgePlotButton"), label = "Generate Plot")
                  )
      )
    ),

    # Main panel for displaying outputs ----
    mainPanel(

      tabsetPanel(id = ns("deMainTabSet"),
                  tabPanel(title = "Table",

                           DT::dataTableOutput(ns("dgeTable"))
                  ),
                  tabPanel(title = "Plot", value = "dePlotTab",

                           plotOutput(ns("dgePlot")),
                           downloadButton(ns("downloaddgePlot"), "Download Curret Plot")
                  )
      )
    )
  )
}

#' Single Cell Differential Expession Tab Server
#'
#' @param finData Reactive value containing a seurat object with clustered data
#'
#' @export
#' @return Diffenretial Expression data
sc_de <- function(input, output, session, finData) {

  de <- reactiveValues()

  ## Generate DE Data
  observeEvent(input$dgeButton, {
    # if(!is.null(finData$finalData)){

      de$markers <- FindAllMarkers(finData$finalData,
                                   test.use = input$dgeTestCombo,
                                   min.pct = input$pctdgeInput,
                                   logfc.threshold = log(input$logFCdgeInput))

      write.csv(de$markers, file="output/AllMarkerGenes.csv", row.names = FALSE)

      output$dgeTable <- DT::renderDataTable(

        if(input$dgeClusterCheck){
          DT::datatable(de$markers, options = list(pageLength = 10))
        } else{
          DT::datatable(de$markers[de$markers$cluster==input$dgeClustInput,], options = list(pageLength = 10))
        }

      )
    # }
  })


  ## Cluster Heatmap
  observeEvent(input$dgeHeatButton, {
    if(!is.null(de$markers)){
      de$dgePlot <- getClusterHeatmap(finData$finalData, de$markers, input$clustHeatInput)

      output$dgePlot <- renderPlot({
        de$dgePlot
      })

      updateTabsetPanel(session, "deMainTabSet", selected = "dePlotTab")
    }
  })


  ## DE Plots
  observeEvent(input$dgePlotButton, {

    print(input$geneNameInput)
    class(input$geneNameInput)

    if(!is.null(finData$finalData)){

      if(input$dgePlotType == 1){
        de$dgePlot <- VlnPlot(finData$finalData, features = input$geneNameInput)
      }else if(input$dgePlotType == 2){
        de$dgePlot <- FeaturePlot(finData$finalData, features = input$geneNameInput)
      }else if(input$dgePlotType == 3){
        de$dgePlot <- RidgePlot(finData$finalData, features = as.character(input$geneNameInput))
      }


      output$dgePlot <- renderPlot({
        de$dgePlot
      })
    }
  })


  output$downloaddgePlot <- downloadHandler(
    filename = function() {
      paste("DEplot", device=".png", sep="")
    },
    content = function(file) {
      device <- function(..., width, height) {
        grDevices::png(..., width = width, height = height, units = "in", pointsize = 12)
      }
      ggsave(file, plot = de$dgePlot, device = device, width = 12, height = 8, limitsize = FALSE)
    }
  )

  return(de)
}


#' Cluster Heatmap
#'
#' Heatmap generated with Suerat
#'
#' @param s_object Seurat object with clustered data
#' @param markers Differential expression data
#' @param geneNo Number of genes to be displayed
#'
#' @export
#' @return Diffenretial Expression data
getClusterHeatmap <- function(s_object, markers, geneNo){
  topMarkers <- markers %>% group_by(cluster) %>% top_n(n = geneNo, wt = avg_logFC)
  p <- DoHeatmap(s_object, features = topMarkers$gene)
  return(p)
}