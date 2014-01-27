#2011 Census Open Atlas


##Aim
The code contained in this repository was used to create version two of the [England and Wales 2011 Open Census Atlas](http://www.alex-singleton.com/r/2014/02/05/2011-census-open-atlas-project-version-two/). This uses the bulk census download files from [Nomis](http://www.nomisweb.co.uk/census/2011) alongside boundaries supplied by the [ONS](http://www.ons.gov.uk/ons/guide-method/geography/products/census/spatial/2011/index.html). All of which are open data.

This script is written in [R](http://www.r-project.org/), and hopefully clear enough that it could be replicated. The atlas files are not hosted on github, however, are linked to a separate download server.

## External libraries
Towards the end of the script there are two external libraries called from the terminal - these are [PDFCrop](http://users.skynet.be/tools/PDFTools.tgz), which crops the PDF maps and legends to their bounding extent; and [PDFTK](http://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/), which is used to join PDF files together. The atlases are generated using [LaTex](http://www.latex-project.org/), and as such, this would also be required for the R script to run. This code may not work under windows without adaption, and it has only been tested to run on OSX.

##Atlas Downloads
The atlases are available to download here: [http://www.alex-singleton.com/Open-Atlas/](http://www.alex-singleton.com/Open-Atlas/)