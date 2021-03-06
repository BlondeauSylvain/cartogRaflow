#' @title Analysis of flow concentration (Gini coefficient)
#' @description
#' Calculates Gini coefficient, plot Lorenz curve and
#' threshold the matrice according to a global concentration criterion for mapping flow intensity or flow density).\cr
#' To be use before \link{flowanalysis}
#' @param tab dataset is a matrice or long format
#' @param format is a variable that identify the data : matrice or long format
#' @param origin origin place to be used with the long format
#' @param dest destination place to be used with the list format
#' @param valflow to be used with the list format
#' @param fdc is the map background file, ie. a shapefile.
#' @param code is the map background IDs code
#' @param lorenz.plot allows to plot the Lorenz curve associate to the gini coefficient
#' @return plot Lorenz curve for the cumulated flow and links : flowgini(...,gini.plot = TRUE),warning : the function must be not assign a variable
#' @return value of the Gini's coefficent and the table : table<-flowgini(...,missing(gini.plot) or gini.plot = FALSE )
#' @details
#' flowgini(...,lorenz.plot = TRUE) for ploting Lorenz curve from cumulated flows and links.
#' @rawNamespace import(plotly, except = last_plot)
#' @importFrom ggplot2 ggplot
#' @importFrom ggplot2 aes
#' @importFrom ggplot2 geom_line
#' @importFrom ggplot2 xlab
#' @importFrom ggplot2 ylab
#' @importFrom ggplot2 ggtitle
#' @importFrom ggplot2 theme
#' @importFrom ggplot2 element_blank
#' @importFrom ggplot2 element_line
#' @importFrom ggplot2 element_text
#' @references
#' Bahoken Françoise, 2016,« La cartographie d’une sélection globale de flux, entre ‘significativité’ et ‘densité’ »,
#' Netcom Online, 30-3/4 | 2016, Online since 23 March 2017, connection on 05 May 2019. URL : http://journals.openedition.org/netcom/2565 ;
#' DOI : 10.4000/netcom.2565. \cr
#' Grasland Claude, 2014, "Flows analysis carto", unpublished R functions.
#' @import dplyr
#' @import sp
#' @importFrom rlang .data
#' @importFrom utils tail
#' @examples
#' library(cartograflow)
#' data(flowdata)
#' bkg<- system.file("shape/MGP_TER.shp", package="cartograflow",
#'                   lib.loc = NULL, mustWork = TRUE)
#' #Computes Gini's coefficent
#' tab_gini<-flowgini(flows,format="L",origin="i",dest="j",valflow="Fij",
#'           bkg,code="EPT_NUM",lorenz.plot = FALSE)
#' #Plot Lorenz curve
#' flowgini(tab_gini,format="L",origin="i",dest="j",valflow="ydata",
#'           bkg,code="EPT_NUM",lorenz.plot = TRUE)
#' #See \link{flowanalysis} for viewing the tab_gini table
#' @export

flowgini<-function(tab, origin, dest, valflow,format,
                   fdc,code,lorenz.plot){

  if(missing(tab) && missing(format) && missing(fdc) && missing (code))
    stop("one of 'tab' and 'format' and 'fdc' and 'code' must be given")

  gini<-function(vec1,vec2){
    tot<-vec2[1]/2*vec1[1]
    i<-2
    while(i <=length(vec1))
    {tot<-tot+(vec1[i]-vec1[i-1])*(vec2[i]+vec2[i-1])/2
    i<-i+1
    }
    res<-2*(0.5-tot)
    return(res)}

  ginigraph<-function(x,y){
    p<-ggplot(x) +
      geom_line(aes(x =x$flowcum, y = x$linkcum )) +
      geom_line(aes(x =x$flowcum, y = x$flowcum )) +
      xlab("Cumulative links") + ylab("Cumulative flows") +
      ggtitle(paste("Gini's coefficent =",round(y*100,2)," %")) +
      theme(
        panel.background = element_blank(),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = "gray50", size = 0.5),
        panel.grid.major.x = element_blank(),
        axis.text.y = element_text(colour="#68382C", size = 9))
    ggplotly(p) %>% layout(dragmode = "select")
  }

  gini.tab<-function(g.tab,fdc,code){
    gini.tab<-flowjointure(g.tab,fdc,code)
    gini.tab$link<-1
    gini.tab<-gini.tab[gini.tab$ydata>0,]
    gini.tab<-gini.tab[order(gini.tab$ydata,decreasing=TRUE),]
    gini.tab$flowcum<-cumsum(gini.tab$ydata)/sum(gini.tab$ydata)
    gini.tab$linkcum<-cumsum(gini.tab$link)/sum(gini.tab$link)
    return(gini.tab)}

  if(format == "M"){
    tabflow<-flowstructmat(tab)
    tabflow<-flowtabmat(tabflow,matlist ="L")
    tabgini<-gini.tab(tabflow,fdc,code)
  }

  if(format == "L"){
    tabmap <- tab %>%
      select(origin, dest, valflow)
    names(tabmap) = c("i", "j", "ydata")

    tabgini<-gini.tab(tabmap,fdc,code)
    }

  indice<-gini(tabgini$flowcum,tabgini$linkcum)

  if(missing(lorenz.plot) || lorenz.plot == FALSE){
    message("Gini's coefficent =",paste(round(indice*100,2),"%"),"\n")
    return(tabgini)}
  if (lorenz.plot == TRUE){ginigraph(tabgini,indice)}

}






















