### Creating SQL Data Base out of alignment keys

## libraries
require("RSQLite")
library(RSQLite)
library(tidyverse)

## First try with just one
## Takes ~5min
alignmentKeys1 <-  read.csv("../data/outputs/alignment_keys/raw_to_alignment_key_outputoutput_all.csv", sep = "\t", header = TRUE, fileEncoding = "latin1", stringsAsFactors = FALSE)
alignmentKeys <- alignmentKeys1 ## So I don't have to load again

alignmentKeys <- alignmentKeys[,-1]
head(alignmentKeys)


alignmentKeys <- alignmentKeys %>% 
  separate(species, 
           c("A", "B", "C", "D", "E", "F", "G"), 
           sep = "\\|", extra = "merge", 
           fill = "left") %>%
  select(., -c(A:E, G))

colnames(alignmentKeys)[3] <- "species"

## Clean up alignment file notation
alignmentKeys$alignment_file <- gsub("output_", "", alignmentKeys$alignment_file) 
alignmentKeys$alignment_file <- gsub(".fa", "", alignmentKeys$alignment_file)

## Check
head(alignmentKeys)
colnames(alignmentKeys)
str(alignmentKeys)

## Make align and raw numeric
alignmentKeys$align_position <- as.numeric(alignmentKeys$align_position)
alignmentKeys$raw_position <- as.numeric(alignmentKeys$raw_position)

## Make the database
con <- dbConnect(SQLite(), "../data/sql/alignmentKeys.sqlite")
dbWriteTable(con, name = "alignmentKeys", value = transform(alignmentKeys), row.names = FALSE, append = TRUE)
dbDisconnect(con)

## Test Database

con <- dbConnect(SQLite(), "../data/sql/alignmentKeys.sqlite")

## Query.  Get only the align_position results
sql1 <- paste("SELECT alignmentKeys.align_position FROM alignmentKeys", sep = "")

## Run SQL query
results <- dbGetQuery(con, sql1) 
dbDisconnect(con)

## Sanity Check
dbrowcount <- aggregate(align_position ~ align_position, data = results, FUN = length)
csvrowcount <- nrow(alignmentKeys)

dbrowcount
csvrowcount


## Resources
## http://www.starkingdom.co.uk/creating-an-sqlite-database-with-r/
## http://www.datacarpentry.org/R-ecology-lesson/05-r-and-databases.html
## https://cran.r-project.org/web/packages/RSQLite/vignettes/RSQLite.html
