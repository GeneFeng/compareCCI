library(data.table)
library(dplyr)



Args <- commandArgs(trailingOnly = T)

input = Args[1]
output = paste0( 'BH_',basename( input ) ) 


#函数
get_padj <- function( input , p.column = 'pvalue' , output ){
    data <- fread( input  ,sep='\t'  ,header = T ) %>% setDF()
    data$padj <- data[  , p.column ] %>% as.numeric() %>% 
                    p.adjust(  method = 'BH'  )
    fwrite(  data , output  , sep = '\t' )
    
}



######调用函数
#setwd( dir )

get_padj(  input = input,
           p.column = 'pvalue',
           output = output
           
           )
