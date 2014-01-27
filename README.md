#2011 Census Open Atlas


##Aim
The code contained in this repository was used to create version two of the [England and Wales 2011 Open Census Atlas](). This uses the bulk census download files from [Nomis](http://www.nomisweb.co.uk/census/2011) alongside boundaries supplied by the [ONS](http://www.ons.gov.uk/ons/guide-method/geography/products/census/spatial/2011/index.html). All of which are open data. 

This script is written in R, and hopefully clear enough in terms of code annotation that it could be replicated. The atlas files are not hosted on github to save on their space, however, are linked to a separate download server.

## External libraries
Towards the end of the script there are two external libraries called from the terminal - these are [PDFCrop](http://users.skynet.be/tools/PDFTools.tgz), which crops the PDF maps and legends to their bounding extent; and [PDFTK](http://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/), which is used to join two PDF files together. The atlases are generated using [LaTex](http://www.latex-project.org/), and as such, this would also be required for the R script to run. This code may not work under windows without adaption, and it has only been tested to run on OSX.

##Atlas Downloads
The atlases are available to download from