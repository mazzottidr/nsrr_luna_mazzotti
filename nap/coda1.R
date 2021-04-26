#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)

# -------------------------------------------------------------------------------
# expects 3 args:
#  1. script folder (containing this file)
#  2. NAP resource folder
#  3. NAP output for this EDF
# -------------------------------------------------------------------------------

if ( length(args) != 3 )
 stop( "usage: compile-tables.R <nap-script-folder> <nap-resources-folder> <nap-output-folder>" )

# ensure trailing folder delimiter

nap.dir             <- paste( args[1] , "/" , sep="" )
nap.resources.dir   <- paste( args[2] , "/" , sep="" )
nap.output.dir      <- paste( args[3] , "/" , sep="" )

# -------------------------------------------------------------------------------
#
# Attach library dependencies
#
# -------------------------------------------------------------------------------

nap.paths <- .libPaths()

# add any nonstandard library paths here: 
nap.paths <- c( "/data/nsrr/lib/" , nap.paths )

.libPaths( nap.paths )

suppressMessages( library( data.table ) )
suppressMessages( library( matlab ) )


# -------------------------------------------------------------------------------
# 
# Table/figure formats
#
# -------------------------------------------------------------------------------

# The Shiny app looks for files *-tab.RData  (tables)
#                           and *-fig.RData  (images)

# format expected by shiny app (w/ unique 'g's ):
#
# g <- list( desc = "group description" ,
#            d1 = list( desc = "description1" , data = data.frame() ) ,
#            d2 = list( desc = "description2" , data = data.frame() ) )


# g <- list( desc = "group description" ,
#            d1 = list( desc = "image description1" , figure = "fig1.png" ) , 
#            d2 = list( desc = "image description2" , figure = "fig2.png" ) )



# -------------------------------------------------------------------------------
# 
# Helper functions
#
# -------------------------------------------------------------------------------

# save a dataframe with a given variable name
saveit <- function(dat, str, file) {
  x <- list(dat)
  names(x) <- str
  save(list=names(x), file=file, envir=list2env(x))
}



# ------------------------------------------------------------------------------------------------------
#
# SIGSTATS and STATS processing for Signals View
#
# ------------------------------------------------------------------------------------------------------

# Hjorth
sigstats.filename <- paste( nap.output.dir , "luna_stats_SIGSTATS_E_CH.txt" , sep="" )

# Means
stats.filename <- paste( nap.output.dir , "luna_stats_STATS_E_CH.txt" , sep="" )   

df1 <- df2 <- data.frame()

if ( file.exists( sigstats.filename ) ) {
df1 <- read.table( sigstats.filename , header=T , stringsAsFactors=F , sep="\t" )
df1 <- df1[ , c( "ID" , "CH" , "E" , "H1" , "H2" ) ]
df1$H1 <- log( df1$H1 )
names(df1) <- c("ID","CH","E","S1","S2")
}

if ( file.exists( stats.filename ) ) {
df2 <- read.table( stats.filename , header=T , stringsAsFactors=F , sep="\t" )
df2 <- df2[ , c( "ID" , "CH" , "E" , "MEAN" ) ]
df2$S2 <- NA
names(df2) <- c("ID","CH","E","S1","S2")
}

# merge
if ( dim(df1)[1] > 0 ) {
 df <- df1
 if ( dim(df2)[1] > 0 ) df <- rbind( df , df2 )
} else {
 df <- df2
}
# save
if ( dim(df)[1]>0) 
 saveit( df , "sigstats" , file= paste( nap.output.dir , "nap.sigstats.RData" , sep="" ) )



# ------------------------------------------------------------------------------------------------------
#
# MTM spectrograms
#
# ------------------------------------------------------------------------------------------------------

try( { 
 mtm <- read.table( paste( nap.output.dir , "luna_spec_MTM_F_CH_SEG.txt.gz" , sep="/" ) , header=T , stringsAsFactors = F )
 mtm$MTM <- 10*log10( mtm$MTM )
 mtm <- mtm[ mtm$F >= 0.5 , ] 
 spectrograms <- list( desc = "MTM EEG spectrograms" )
 chs <- unique( mtm$CH )
 for (ch in chs)
 { 
  png( file = paste( nap.output.dir , paste( "mtm-" , ch , ".png" , sep="" ) , sep="/" ) , res=100 , width=1000  , height = 400 )
  par(mar=c(1.5,2.5,0.5,0.5))
  x <- mtm$SEG[ mtm$CH == ch ]
  y <- mtm$F[ mtm$CH == ch ]
  z <- mtm$MTM[ mtm$CH == ch ]
  nx <- length(unique(x))
  ny <- length(unique(y))
  nz <- length(z)
  if (nz != nx * ny) stop("requires square data")
  d <- data.frame(x, y, z)
  d <- d[order(d$y, d$x), ]
  m <- matrix(d$z, byrow = T, nrow = ny, ncol = nx)
  hmcols <- jet.colors(100)
  image(t(m[1:ny, ]), col = hmcols, xaxt = "n", yaxt = "n")
  axis(1,0.95,labels="Epochs",tick=F,line=-1,cex.axis=0.8)
  axis(2,0.98,labels=paste(round(max(y)),"Hz ") ,line=-1,tick=F,las=2,cex.axis=0.8)
  axis(2,0.02,labels="0.5 Hz " ,tick=F,las=2,line=-1,cex.axis=0.8)
  dev.off()
  spectrograms[[ ch ]] <- list( desc = ch , figure = paste( "mtm-" , ch , ".png" , sep="" )  )
} # next EEG channel

if ( length( spectrograms ) > 0 ) 
  saveit( spectrograms , str = "spec" , file = paste( nap.output.dir , "mtm-spectrograms-fig.RData" , sep="" ) )

}) # end of MTM block
