#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)

# -------------------------------------------------------------------------------
# expects 3 args:
#  1. script folder (containing this file)
#  2. NAP resource folder
#  3. NAP output for this EDF
# -------------------------------------------------------------------------------

if ( length(args) != 3 )
 stop( "usage: coda2.R <nap-script-folder> <nap-resources-folder> <nap-output-folder>" )

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


fextract <- function( outdir , cmd , desc , tables , transpose = rep( F , length( tables ) ) ) {

# if transposes not specified directly (i.e. differently) for each table:
# nb. otherwise, transpose assumes to match by **alphabetical** order of present tables

if ( length( transpose ) == 1 ) 
 transpose <- rep( transpose , length( tables ) )

# get all file names ending .txt or .txt.gz in the output folder
nap.files <- c( list.files( outdir , full.names = T , pattern = glob2rx( paste( cmd , "*.txt" , sep="" ) ) ) , 
                list.files( outdir , full.names = T , pattern = glob2rx( paste( cmd , "*.txt.gz" , sep="" ) ) ) ) 

# same, but ignore full paths (for display)
nap.files.short <- c( list.files( outdir , full.names = F , pattern = glob2rx( paste( cmd , "*.txt" , sep="" ) ) ) , 
                      list.files( outdir , full.names = F , pattern = glob2rx( paste( cmd , "*.txt.gz" , sep="" ) ) ) )
nap.files.short <- gsub( "*.txt" , "" , gsub( ".txt.gz" , "" , nap.files.short ) ) 

# only extract requested
inc <- nap.files.short %in% paste( cmd  , tables , sep="") 
nap.files <- nap.files[inc]
nap.files.short <- nap.files.short[inc]

# ensure 1+ files are given prior to output
if ( length( nap.files ) > 0 ) { 
 data  <- list( desc = desc ) 
 for (x in nap.files.short ) data[[ x ]] <- list( desc = x , data = NA )
 #lapply( nap.files.short , function( x ) { data[[ x ]] <<- list( desc = x , data = NA ) } )
 
 for (g in 1:length(nap.files)) {
  dt <- read.table( nap.files[g], header=T, stringsAsFactors=F, sep="\t" )
  if ( transpose[g] ) 
   { 
      dt <- as.data.frame( cbind( names(dt) , t( dt ) ) )  
      names(dt) <- c("ID" , paste("R",1:(dim(dt)[2]-1),sep="" ) ) 
   } 
  data[[ nap.files.short[g] ]]$data <- dt
 }
 saveit( data , str = cmd , file = paste( outdir , cmd , "-tab.RData" , sep="" ) ) 
}
# all done
}


# ------------------------------------------------------------------------------------------------------
#
# By convention, we have special filename encoding to recognize particular outputs, e.g. HEADER-CH.txt
#
# nb. if a vector of transpose values is given, currently this transposes based on alphabetic table order
# e.g. for SOAP: this is the base ("") table only (based on alphabetic sort order) , so "_E", "_SS" then ""
# 
# ------------------------------------------------------------------------------------------------------

try( fextract( nap.output.dir , "luna_core_CANONICAL" , "Canonical signals" , tables = "_CS" , transpose = F ) )

try( fextract( nap.output.dir , "luna_core_FLIP" , "EEG polarity flips" , tables = c( "_CH" , "_CH_METHOD") , transpose = F ) )

try( fextract( nap.output.dir , "luna_spec_PSD" , "Power spectral density" , tables = c( "_B_CH_SS-N2" , "_B_CH_SS-N3" ) ) )

try( fextract( nap.output.dir , "luna_spso_SPINDLES" , "Spindles/SO" , tables = c( "_F_CH_SS-N2" , "_F_CH_SS-N23" , "_CH_SS-N2" , "_CH_SS-N23"  ) , transpose = T ) )

try( fextract( nap.output.dir , "luna_macro_HYPNO" , "NREM cycles" , tables = c( "_C" ) ,  transpose = T ) )

try( fextract( nap.output.dir , "luna_suds_SOAP" , "SOAP" , tables = c( "" , "_SS" , "_E" ) , transpose = c(F,F,T) ) )



# ------------------------------------------------------------------------------------------------------
#
# PSD spectra
#
# ------------------------------------------------------------------------------------------------------

try( {
 psd <- list()
 sss <- "N2"
 psd[[ "N2" ]] <- read.table( paste( nap.output.dir , "luna_spec_PSD_F_CH_SS-N2.txt" , sep="/" ) , header=T , stringsAsFactors = F )
 if ( file.exists( paste( nap.output.dir , "luna_spec_PSD_F_CH_SS-N3.txt" , sep="/" ) ) )
 {
  sss <- c( sss , "N3" )  
  psd[[ "N3" ]] <- read.table( paste( nap.output.dir , "luna_spec_PSD_F_CH_SS-N3.txt" , sep="/" ) , header=T , stringsAsFactors = F )
 }
 # already log-scaled, etc 
 psd.spec <- list( desc = "Welch EEG PSD (QC+ epochs)" )
 for (ss in sss )
 {
  dt <- psd[[ ss ]]
  chs <- unique( dt$CH )
  for (ch in chs )
  { 
   png( file = paste( nap.output.dir , paste( "psd-" , ch , "-" , ss , ".png" , sep="" ) , sep="/" ) , res=100 , width=500  , height = 300 )
   x <- dt$F[ dt$CH == ch ]
   y <- dt$PSD[ dt$CH == ch ]
   nx <- length(unique(x))
   ny <- length(unique(y))
   plot( x , y , lwd=2 , type="l" , xlab="Frequency (Hz)" , ylab="Absolute log(power)" )
   dev.off()
   psd.spec[[ paste( ch , ss ) ]] <- list( desc = paste( ch, ss ) , figure = paste( "psd-" , ch , "-" , ss , ".png" , sep="" )  )
 }} # next channel / SS
 if ( length( psd.spec ) > 0 ) 
  saveit( psd.spec , str = "psd" , file = paste( nap.output.dir , "psd-fig.RData" , sep="" ) )
}) # end of PSD block
