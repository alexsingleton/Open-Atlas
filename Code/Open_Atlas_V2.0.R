#Load Libraries
library(rgdal)
library(RColorBrewer)
library("sp")
library(GISTools)
library(classInt)
library(maptools)



#Hacked version of the map.scale function
map.scale2 <- function (xc, yc, len, units, ndivs, subdiv = 1, tcol = "black", 
                        scol = "black", sfcol = "black") 
{
  frame = par("usr")
  l <- len
  tic = (frame[4] - frame[3])/100
  ul = l/ndivs
  for (i in seq(0, ndivs - 1, by = 2)) rect(xc - l/2 + i * ul, yc, xc - l/2 + (i + 1) * ul, yc + tic/2, border = NA, col = sfcol)
  lines(c(xc - l/2, xc - l/2, xc + l/2, xc + l/2), c(yc + tic, yc, yc, yc + tic), col = scol)
  lines(c(xc - l/2, xc + l/2), c(yc + tic/2, yc + tic/2), col = scol)
  for (i in c(0,ndivs)) text(xc - l/2 + ul * i, yc - strheight(i * subdiv) * 0.7, (i * subdiv)/100, col = tcol,cex = 0.7,font=1, family="sans")
  text(xc, yc - 2 * strheight(units), units, col = tcol,cex = 0.7,font=1, family="sans")
}


#Function to deal with rounding
mround <- function(x,base){ 
  base*round(x/base) 
}

#Create a list of tables
table_list <- c('KS101EW','KS102EW','KS103EW','KS104EW','KS105EW','KS106EW','KS107EW','KS201EW','KS202EW','KS204EW','KS205EW','KS206EW','KS207WA','KS208WA','KS209EW','KS301EW','KS401EW','KS402EW','KS403EW','KS404EW','KS405EW','KS501EW','KS601EW','KS602EW','KS603EW','KS604EW','KS605EW','KS606EW','KS607EW','KS608EW','KS609EW','KS610EW','KS611EW','KS612EW','KS613EW')
table_list <- tolower(paste(table_list,"_2011_oa",sep=''))

#Set a download folder for the census CSV files
setwd("/Users/alex/open-atlas/data/")

#Download Files
for (n in 1:length(table_list)){
  file <- as.character(table_list[n])
  temp <- tempfile(fileext='.zip')
  download.file(paste("http://www.nomisweb.co.uk/output/census/2011/",file,".zip",sep=''),temp)
  unzip(temp,junkpaths=TRUE)
  unlink(temp)
  csv_file <- paste(toupper(sub("_2011_oa", "",file)),"DATA.CSV",sep='')
  assign(file,read.csv(csv_file))
}



#Create lookup
Key_Statistics_2011 <- as.data.frame(ks101ew_2011_oa[,1])
colnames(Key_Statistics_2011) <- "GeographyCode"

#Merge Loop
for (n in 1:length(table_list)){
  Key_Statistics_2011 <- merge(Key_Statistics_2011, get(as.character(table_list[n])),by="GeographyCode",all.x=TRUE)
}

#Create Descriptions
Variable_Desc <- NULL
for (n in 1:length(table_list)){
  file <- as.character(table_list[n])
  csv_file <- paste(toupper(sub("_2011_oa", "",file)),"DESC0.CSV",sep='')
  temp <- read.csv(csv_file)
  Variable_Desc <- rbind(Variable_Desc,temp)
  remove(temp)
}

Variable_Desc$ColumnVariableDescription <- gsub("\\n","",Variable_Desc$ColumnVariableDescription,fixed=TRUE)

#Get 2011 OA
temp <- tempfile(fileext='.zip')
download.file("http://www.ons.gov.uk/ons/external-links/other-ns-online/census-geography/2011-oa-boundary/oa-2011-ew-bgc-shp.html",temp)
unzip(temp)
OA <- readOGR(".","OA_2011_EW_BGC")
unlink(temp)

#Get 2011 Merged Wards
temp <- tempfile(fileext='.zip')
download.file("http://www.ons.gov.uk/ons/external-links/other-ns-online/census-geography/2011-cmw-boundary/cmwd-2011-ew-bgc-shp.html",temp)
unzip(temp)
WARD <- readOGR(".","CMWD_2011_EW_BGC")
unlink(temp)

#Get 2011 OA higher geog lookup
temp <- tempfile(fileext='.zip')
download.file("http://www.ons.gov.uk/ons/external-links/other-ns-online/census-geography/exact-fit-2011-lookup/oa11-lsoa11-msoa11-lad11-ew-lu-csv.html",temp)
unzip(temp)
oa_higher_lookup <- read.csv("OA11_LSOA11_MSOA11_LAD11_EW_LUv2.csv")
unlink(temp)


#Create key stats table List
a <- c("KS101EW",  "KS102EW","KS103EW","KS104EW","KS105EW","KS106EW","KS107EW","KS201EW","KS202EW","KS204EW","KS205EW","KS206EW","KS207WA","KS208WA","KS209EW","KS301EW","KS401EW","KS402EW","KS403EW","KS404EW","KS405EW","KS501EW","KS601EW","KS602EW","KS603EW","KS604EW","KS605EW","KS606EW","KS607EW","KS608EW","KS609EW","KS610EW","KS611EW","KS612EW","KS613EW")
b <- c("Usual resident population","Age structure","Marital and civil partnership status","Living arrangements","Household composition","Adults not in employment and dependent children and persons with long-term health problem or disability for all households","Lone parent households with dependent children","Ethnic group","National identity","Country of birth","Passports held","Household language","Welsh language skills","Welsh language profile","Religion","Health and provision of unpaid care","Dwellings, household spaces and accommodation type","Tenure","Rooms, bedrooms and central heating","Car or van availability","Communal establishment residents","Qualifications and students","Economic activity","Economic activity - Males","Economic activity - Females","Hours worked","Industry","Industry - Males","Industry - Females","Occupation","Occupation - Males","Occupation - Females","NS-SeC","NS-SeC - Males","NS-SeC - Females")

Key_stat_tables <- data.frame(a,b)
colnames(Key_stat_tables) <- c("KS2011_Tab_Code","KS2011_Tab_Name")

#Join key statistics data onto 2011 OA
OA@data = data.frame(OA@data, Key_Statistics_2011[match(OA@data[,"OA11CD"], Key_Statistics_2011[,"GeographyCode"]),])
#OA@data = data.frame(OA@data, Key_Statistics_2011_Wales[match(OA@data[,"OA11CD"], Key_Statistics_2011_Wales[,"GeographyCode"]),])

#Join higher geog onto OA
OA@data = data.frame(OA@data, oa_higher_lookup[match(OA@data[,"OA11CD"], oa_higher_lookup[,"OA11CD"]),])


#############

#Map Counter
map_count <- 0

#Create LAD list
LAD_LIST <- as.data.frame(table(OA@data$LAD11CD,OA@data$LAD11NM))
LAD_LIST <- LAD_LIST[LAD_LIST$Freq > 0,c("Var1","Var2")]
colnames(LAD_LIST) <- c("LAD11CD","LAD11NM")

setwd("/Users/alex/open-atlas/map_junk")

  
  #Create plot
  
  for (i in 1:nrow(LAD_LIST)){#LAD loop
    
    print(LAD_LIST[i,1:2])
    
    #A check if the LAD is in England, if so, exclude the Welsh tables
    if (substr(LAD_LIST$LAD11CD[i],1,1) == "E") {
      tmp_Key_stat_tables <-  Key_stat_tables[regexpr("WA", Key_stat_tables$KS2011_Tab_Code) < 0,]
    } else {
      tmp_Key_stat_tables <-  Key_stat_tables
    }
    
    ##REMOVE - limits number of tables to plot##
    #tmp_Key_stat_tables <- tmp_Key_stat_tables[sample(1:nrow(tmp_Key_stat_tables), 5),1:2]
    
    #Subset OA and Ward for LAD
    OA_to_Map <- OA[OA@data$LAD11CD  == LAD_LIST$LAD11CD[i],]
    WARD_to_Map <- WARD[WARD@data$LAD11CD  == LAD_LIST$LAD11CD[i],]
    
    #work out scale position and buffers
    lrg_buff <- c("E06000010","E06000013","E07000031", "E07000061","E07000062","E07000064", "E07000079", "E07000080", "E07000089", "E07000098", "E07000097", "E07000155", "E07000210","E07000224", "E07000228","E07000229","E07000236","E08000004", "E08000025", "E09000021", "E09000022", "W06000023","E07000128", "E07000204", "E07000111", "E07000195", "E07000129")#These LAD need a slightly larger buffer than the default
      plot_width <- (OA_to_Map@bbox[3] - OA_to_Map@bbox[1])/1000
    scale_width <- mround(plot_width,10) *100
    if (scale_width == 0) { scale_width <- 1000}
    if (LAD_LIST$LAD11CD[i] %in% lrg_buff) {buff_w <- scale_width*1.6} else {buff_w <- scale_width*1.1}
    
    OA_to_Map_Buffers <- gBuffer(OA_to_Map, width = buff_w, byid = TRUE)
    
    scale_break <- 500
    scale_divs <- scale_width / scale_break
    X <- OA_to_Map_Buffers@bbox[1] + (scale_width * 1.5)
    Y <- OA_to_Map_Buffers@bbox[2] + (scale_width * 1.1)  
    
    
    for (j in 1:nrow(tmp_Key_stat_tables)){#Census table loop
      
      #Get a list of variables within the table (only ratio or percentage)
      Variable_List <- Variable_Desc[substr(Variable_Desc$ColumnVariableCode,1,7) == tmp_Key_stat_tables[j,1] & Variable_Desc$ColumnVariableMeasurementUnit %in% c("Ratio","Percentage","Years","Average"), ]
      
     for (k in 1:nrow(Variable_List)){#Start variable loop
     # for (k in 1){#REMOVE
        
        #Get the variables to plot
        tmp_plot_vars <- OA_to_Map@data[,paste(Variable_List[k,1])]
        
        if (length(unique(tmp_plot_vars)) > 5) {#Loop to check if there are more than 5 unique values 
        
          #Create colour pallet
            my_colours <- brewer.pal(5, "Blues")
            breaks <- classIntervals(tmp_plot_vars, n = 5, style = "fisher", unique = TRUE)
            breaks <- breaks$brks
          
          #Create map output as PDF
          pdf(paste("MAP_",LAD_LIST[i,1],"_VAR___",tmp_Key_stat_tables[j,1],"___",Variable_List[k,1],".pdf",sep=""))
          par(oma=c(0,0,0,0),mar=c(0, 0, 0, 0),bty="n",family="sans",bg = '#FFFFFF')
          
          #plot boundaries
          plot(OA_to_Map_Buffers,col=NA,border=NA)  
          plot(OA_to_Map, col = my_colours[findInterval(OA_to_Map@data[,paste(Variable_List[k,1])], breaks, all.inside = TRUE)], axes = FALSE, border = NA,add=TRUE)
          plot(WARD_to_Map,border="#707070",add=TRUE)
        
            #Count Maps
            map_count <- map_count + 1
            
            #A loop to check that ward labels are appropriate
            ig_lab <- c("E06000052","E07000031","E07000165", "E07000168", "W06000002", "W06000006","W06000008","W06000009","E09000001","E06000054","E06000048")
            #Add on text labels for the wards
              if (!LAD_LIST$LAD11CD[i] %in% ig_lab){
               pointLabel(coordinates(WARD_to_Map)[,1],coordinates(WARD_to_Map)[,2],labels=WARD_to_Map@data$CMWD11NM, cex=.5)
              }
                
          #plot scale
          map.scale2(X,Y,scale_width,"km",scale_divs,scale_break,sfcol='#08519C')
          dev.off()
          
          #Create legend output as PDF
          pdf(paste("LEG_",LAD_LIST[i,1],"_VAR___",tmp_Key_stat_tables[j,1],"___",Variable_List[k,1],".pdf",sep=""))
          plot.new()
        
        #Create a title attribute for the legend
        if (Variable_List[k,2] == "Ratio") {
          title <- "Density - Persons / ha"
        } else if (Variable_List[k,2] == "Percentage") {
          title <- "Percentage"
        } else if (Variable_List[k,2] == "Years") {
          title <- Variable_List[k,4] 
        } else {
          title <- Variable_List[k,4]
        }
        
          legend("topleft", legend = leglabs(round(breaks, digits = 1), between = " to "), fill = my_colours, bty = "o", ,bg="#FFFFFF", border = NA, title=title ,box.lty=0)
          dev.off()
          
          #Trim the PDF that were created to remove whitespace around the plots - this uses an external  library that runs on OSX (need PDFCrop installed - http://users.skynet.be/tools/PDFTools.tgz installed)
          
          #crop map
          system(paste("pdfcrop '",getwd(),"/",paste("MAP_",LAD_LIST[i,1],"_VAR___",tmp_Key_stat_tables[j,1],"___",Variable_List[k,1],".pdf","'",sep="")," '",getwd(),"/",paste("MAP_",LAD_LIST[i,1],"_VAR___",tmp_Key_stat_tables[j,1],"___",Variable_List[k,1],".pdf","'",sep=""),sep=''),wait=TRUE,ignore.stdout = TRUE, ignore.stderr = TRUE)
          #crop legend
          system(paste("pdfcrop '",getwd(),"/",paste("LEG_",LAD_LIST[i,1],"_VAR___",tmp_Key_stat_tables[j,1],"___",Variable_List[k,1],".pdf","'",sep="")," '",getwd(),"/",paste("LEG_",LAD_LIST[i,1],"_VAR___",tmp_Key_stat_tables[j,1],"___",Variable_List[k,1],".pdf","'",sep=""),sep=''),wait=TRUE,ignore.stdout = TRUE, ignore.stderr = TRUE)
          
            
            
        }#Loop to check if the values are all 0
        else{
          next
        }
      }#Variable loop
      remove(Variable_List)
    }#Table loop
    remove(tmp_Key_stat_tables)
    
    remove(OA_to_Map)
    remove(OA_to_Map_Buffers)
    remove(WARD_to_Map) 
  #}#LAD Loop
  
  
  #############
  #Create Maps...
  
  #Create a list of the maps, and a table - variable lookup
  maps_list <- list.files(path=".")
  maps_list <- gsub("LEG_","",maps_list)
  maps_list <- gsub("MAP_","",maps_list)
  maps_list <- gsub(".pdf","",maps_list)
  maps_list <- gsub("_VAR","",maps_list)
  maps_list <- strsplit(maps_list,"___")
  
  maps_list <- data.frame(matrix(unlist(maps_list), nrow=length(maps_list), byrow=T))
  colnames(maps_list) <- c("LAD","C_Tab","C_Var")
  maps_list <- unique(maps_list)
  
  #Create a tailored ATLAS_LIST for those LAD where maps created
  ATLAS_LIST <- LAD_LIST[as.character(LAD_LIST$LAD11CD) %in% as.character(unique(maps_list$LAD)),]
  
  #Create Atlas
  for (z in 1:nrow(ATLAS_LIST)){#ATLAS loop
      
    LAD_Name_No_Non_Char <- ATLAS_LIST$LAD11NM[z]
    LAD_Name_No_Non_Char <- gsub("'","",LAD_Name_No_Non_Char, fixed = TRUE)
    LAD_Name_No_Non_Char <- gsub(",","",LAD_Name_No_Non_Char, fixed = TRUE)
    LAD_Name_No_Non_Char <- gsub(".","",LAD_Name_No_Non_Char, fixed = TRUE)
    
    #Create a LAD tex file
    file.create(paste(ATLAS_LIST$LAD11CD[z],"_",gsub(" ","_",LAD_Name_No_Non_Char),".tex",sep=''))
    #Open tex file for edits
    fileConn<-file((paste(ATLAS_LIST$LAD11CD[z],"_",gsub(" ","_",LAD_Name_No_Non_Char),".tex",sep='')))
    
    #Get the name of the LAD
    LAD_name <- as.character(ATLAS_LIST$LAD11NM[z])
    
    #Create the header
    header <- paste("\\documentclass[a4paper,10pt]{article}
                    \\pagenumbering{gobble}
                    \\makeatletter
                    \\renewcommand{\\@dotsep}{10000} 
                    \\makeatother
                    \\usepackage{helvet}
                    \\renewcommand{\\familydefault}{\\sfdefault}
                    \\setlength{\\textwidth}{13cm}
                    \\setlength{\\oddsidemargin}{2.5cm}
                    \\setlength{\\evensidemargin}{2.5cm}
                    \\setlength{\\topmargin}{1cm}
                    \\title{",paste("2011 Census Open Atlas (",gsub("'","\\'",LAD_name)," / ", ATLAS_LIST$LAD11CD[z],")",sep=''),"}
                    \\author{Alex D Singleton}
                    \\usepackage[hidelinks]{hyperref}
                    \\usepackage{needspace}
                    \\usepackage{float}
                    \\usepackage[pdftex]{graphicx}
                    \\usepackage[margin=2cm]{geometry}
                    \\usepackage{subfigure}
                    \\usepackage{caption}
                    \\usepackage{graphicx}
                    \\needspace{.25\\textheight}
                    \\begin{document}
                    \\maketitle
                    \\phantomsection
                    \\label{listfigs}
                    \\listoffigures
                    \\clearpage
                    \\graphicspath{{",paste(getwd(),"/",sep=''),"}}",sep="")
  
  tmp_Key_stat_tables <- maps_list[as.character(maps_list$LAD) == as.character(ATLAS_LIST$LAD11CD[z]),]
    
    
  
  #Setup Figure List
  fig_list <- NULL
    
    #Create Lookup Table
    tmp_Key_stat_tables <- merge(tmp_Key_stat_tables,Variable_Desc,by.x="C_Var",by.y="ColumnVariableCode" ,all.x=TRUE)
    tmp_Key_stat_tables <- merge(tmp_Key_stat_tables,Key_stat_tables,by.x="C_Tab",by.y="KS2011_Tab_Code" ,all.x=TRUE)
    
    
    for (v in 1:nrow(tmp_Key_stat_tables)){#loop through variables within table
      
      variable_name <- gsub("-","--",tmp_Key_stat_tables[v,"ColumnVariableDescription"])
      variable_id <- tmp_Key_stat_tables[v,"C_Var"]
      variable_table_id <- tmp_Key_stat_tables[v,"C_Tab"]
      variable_table <- gsub("-","--",tmp_Key_stat_tables[v,"KS2011_Tab_Name"])
      
      map_id <- paste(ATLAS_LIST[z,"LAD11CD"],"_VAR___",tmp_Key_stat_tables[v,"C_Tab"],"___",tmp_Key_stat_tables[v,"C_Var"],sep="")#create the map id
      
      
      assign("content_temp",paste(" 
  \\begin{minipage}{\\textwidth}
  \\begin{figure}[H]
  \\centering
  \\hyperref[listfigs]{\\includegraphics[width=15cm,height=20cm,keepaspectratio]{MAP_",map_id,".pdf}}
  \\end{figure}
  
  \\begin{figure}[H]
   \\includegraphics[width=2cm]{LEG_",map_id,".pdf}
   \\caption{", paste(variable_table," (",variable_name,")",sep=''),"}
   \\end{figure}
   \\noindent \\tiny Variable ID -- ",variable_id,".  \\\\  Contains National Statistics data \\copyright{}  Crown copyright and database right 2014. \\\\ 
  Contains Ordnance Survey data \\copyright{}  Crown copyright and database right 2014.  \\\\  Map created by Alex Singleton www.alex-singleton.com.
                                 \\end{minipage}",sep=""))
        
        
        fig_list <- c(fig_list,content_temp)
        
      
      remove(content_temp)
      
        remove(map_id)
        remove(variable_name)
        remove(variable_id)
        remove(variable_table_id)
        remove(variable_table)
        
        
      }#End variable loop  
  
  #Adds content to the tex file
  
  footer <- "\\end{document}"
  
  content <- as.character(fig_list)
  
  writeLines(c(header,content,footer), fileConn)
  close(fileConn)
    
  #Create LaTex document
  system(paste("pdflatex '",getwd(),"/",ATLAS_LIST$LAD11CD[z],"_",gsub(" ","_",LAD_Name_No_Non_Char),".tex'",sep=''),wait=TRUE,ignore.stdout = TRUE, ignore.stderr = TRUE)
  system(paste("pdflatex '",getwd(),"/",ATLAS_LIST$LAD11CD[z],"_",gsub(" ","_",LAD_Name_No_Non_Char),".tex'",sep=''),wait=TRUE,ignore.stdout = TRUE, ignore.stderr = TRUE)
  
  #Remove junk
  del_ext <- c(".aux",".lof",".log",".out")
  file.remove(paste(ATLAS_LIST$LAD11CD[z],"_",gsub(" ","_",LAD_Name_No_Non_Char),del_ext,sep=''))
  
  #Adds a cover (Uses pdftk - package versions downloaded from http://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/)
  cover_location <- "'/Users/alex/open-atlas/atlas/Cover.pdf'"
  atlas_location <- paste(ATLAS_LIST$LAD11CD[z],"_",gsub(" ","_",LAD_Name_No_Non_Char),".pdf",sep='') 
  final_atlas_location <- paste("'/Volumes/Macintosh HD 2/alex/open-atlas/atlas/",ATLAS_LIST$LAD11CD[z],"_",gsub(" ","_",LAD_Name_No_Non_Char),".pdf'",sep='')
    
  #Cleanup
  system(paste("pdftk",cover_location,atlas_location,"cat output",final_atlas_location),wait = TRUE)
  file.remove(paste(ATLAS_LIST$LAD11CD[z],"_",gsub(" ","_",LAD_Name_No_Non_Char),".tex",sep=''))  
  system(paste("find ",paste("'",getwd(),"'",sep='')," -name '*.pdf' -delete",sep=''),wait = TRUE)
  
  
    
  }#END ATLAS Loop
    
    print(map_count)
    
  }#LAD Loop
