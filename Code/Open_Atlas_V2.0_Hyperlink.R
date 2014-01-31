#Set working directory
setwd("/Volumes/Macintosh HD 2/alex/open-atlas/atlas/")

r_list <- list.files(path=".")
r_list <- r_list[order(substr(r_list,11,nchar(r_list)))]

r_list_2 <- gsub(".pdf","",r_list)


file_info <- file.info(paste("",r_list,sep=''))
size <- round(file_info$size / 1048576)

code <- substr(r_list_2,1,9)
name <- gsub("_"," ",substr(r_list_2,11,nchar(r_list_2)))





#MD Version

sink("links.md")

for (i in 1:length(r_list_2)){  
  LAD_Name <- name[i]
  LAD_Code <- code[i]
  url_loc <- paste("http://data.alex-singleton.com/2011_ATLAS/",r_list[i],sep='')
  md_item <- paste("* [",LAD_Code,": ",LAD_Name,"]","(",url_loc,")\n")
  cat(md_item)
}
sink()

#HTML Version

sink("links.html")

for (i in 1:length(r_list_2)){  
  LAD_Name <- name[i]
  LAD_Code <- code[i]
  url_loc <- paste("http://data.alex-singleton.com/2011_ATLAS/",r_list[i],sep='')
  tracker <- paste("onClick=\"_gaq.push(['_trackEvent', 'CensusAtlas2011V2', 'Download', '",LAD_Name,"']);",sep='')
  
md_item <- paste("<a href='",url_loc,"'",tracker,">",LAD_Code,": ",LAD_Name,"</a><br>")
  

  cat(md_item)
}
sink()

