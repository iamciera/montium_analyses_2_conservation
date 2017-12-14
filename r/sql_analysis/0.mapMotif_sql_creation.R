## mapMotif_sql_creation.R

## libraries
library(RSQLite)
library(tidyverse)
library(dbplyr)
library(dplyr)
library(DBI)
library(data.table)


# This takes about 5 min
# There is no hunchback though, I have to go back and make hunchback with a smaller threshold level or somethingç
TFBS_df_0 <- fread("../../data/outputs/map_motif_output/all_motifs/map_motif_testoutput_everymotif.csv", sep = "\t", header = FALSE)



# So not to have to read in again
TFBS_df <- TFBS_df_0
head(TFBS_df)
TFBS_df <- TFBS_df[,-1]

colnames(TFBS_df) <- c("position", "score",	"seq_len",	"species", "raw_position",	"strand",	"align_position",	"alignment_file", "motif_file")

## as.factor species
TFBS_df$species <- as.factor(TFBS_df$species)


## Retrieve species
## Takes about > 8 min
## Bleh, this is taking forever!!! Like 30 min.

TFBS_df <- TFBS_df %>% 
  separate(species, 
           c("A", "B", "C", "D", "E", "F", "G"), 
           sep = "\\|", extra = "merge", 
           fill = "left") %>%
  select(., -c(A:E, G))

colnames(TFBS_df)[4] <- "species"

## Clean up alignment file notation
TFBS_df$alignment_file <- gsub("output_", "", TFBS_df$alignment_file) 
TFBS_df$alignment_file <- gsub(".fa", "", TFBS_df$alignment_file)

## Clean up motif_file
TFBS_df$motif_file <- gsub(".fm", "", TFBS_df$motif_file)

## Make prettier for graphs ahead of time
TFBS_df$strand <- gsub("positive", "+ strand", TFBS_df$strand, perl = TRUE)
TFBS_df$strand <- gsub("negative", "- strand", TFBS_df$strand, perl = TRUE)

## Check
head(TFBS_df)
dim(TFBS_df)
str(TFBS_df)

###########################
#### Make SQL database
############################

## Make the database for alignmentKeys
con_db <- DBI::dbConnect(RSQLite::SQLite(), "../data/sql/TFBS_cons_DB.sqlite")
dbWriteTable(con_db, name = "motifMap", value = transform(TFBS_df), row.names = FALSE, append = TRUE)

## List Tables
dbListTables(con_db)

## Disconnect
dbDisconnect(con_db)


# ##### Test
# con_db <- DBI::dbConnect(RSQLite::SQLite(), "../data/sql/TFBS_cons_DB.sqlite")
# head(TFBS_df)
# nrow(subset(TFBS_df, species == "MEMB002A" & motif_file == "bcd_FlyReg")) #213804
# 
# motifMap_SQL <- tbl(con_db, "motifMap") 
# 
# subset_after <- motifMap_SQL %>%
#   filter(species == "MEMB002A") %>%
#   filter(motif_file == "bcd_FlyReg") %>%
#   collect()
# 
# nrow(subset_after) #213804
