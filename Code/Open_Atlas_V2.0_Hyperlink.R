#Set working directory
setwd("/Volumes/Macintosh HD 2/alex/open-atlas/atlas/")

r_list <- list.files(path=".")
r_list_2 <- gsub(".pdf","",r_list)

file_info <- file.info(paste("",r_list,sep=''))
size <- round(file_info$size / 1048576)

code <- substr(r_list_2,1,9)
name <- gsub("_"," ",substr(r_list_2,11,nchar(r_list_2)))

#

sink("links.html")

for (i in 1:length(r_list_2)){  
  LAD_Name <- name[i]
  LAD_Code <- code[i]
  url_loc <- paste("http://data.alex-singleton.com/2011_ATLAS/",r_list[i],sep='')
  html_item <- paste("<a href='",url_loc,"'>",LAD_Code," (",LAD_Name,")"," [",size[i],"MB]</a></br>",sep='')
  cat(html_item)
}
sink()

