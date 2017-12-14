### Creating SQL database for mostConserved

## libraries
library(RSQLite)
library(tidyverse)
library(dbplyr)
library(dplyr)
library(DBI)



#####################
## Most Conserved
####################

## PhastCons - most conserved
## "","seqname","src","feature","start","end","score","strand","attribute","alignment"
most_conserved <- read.csv("../data/outputs/mostConserved/output_all_mostConserved.csv")
colnames(most_conserved) <- c("","seqname","src","feature","start","end","score","strand","attribute","alignment_file")

## Alignment file
most_conserved$alignment_file <- gsub(".fa", "", most_conserved$alignment_file)
most_conserved$alignment_file <- gsub("output_", "", most_conserved$alignment_file) 

## Keep only columns we need
most_conserved <- most_conserved[,c(5,6,7,10)]


#######################
## Query alignment keys 
#######################

con <- DBI::dbConnect(RSQLite::SQLite(), "../data/sql/alignmentKeys.sqlite")

## Peaks into alignment keys
alignmentKeys <- tbl(con, "alignmentKeys")
head(alignmentKeys, n = 10)

## Subset based on species
MEMB002A_key <- alignmentKeys %>%
  filter(species == "MEMB002A") %>%
  collect()

dbDisconnect(con)

head(MEMB002A_key)
MEMB002A_key <- MEMB002A_key %>%
                  select(-species)


########################
### Merging
#########################

colnames(MEMB002A_key)[2] <- "start"

start_merged <- merge(most_conserved, MEMB002A_key, by = c("alignment_file", "start"))
colnames(start_merged)[5] <- "align_start"

colnames(MEMB002A_key)[2] <- "end"

most_conserved_align <- merge(start_merged, MEMB002A_key, by = c("alignment_file", "end"))
colnames(most_conserved_align)[6] <- "align_end"

head(most_conserved_align)

###########################
#### Make SQL database
############################

## Make the database for alignmentKeys

con_db <- DBI::dbConnect(RSQLite::SQLite(), "../data/sql/TFBS_cons_DB.sqlite")

## List all the tables in the database
dbListTables(con_db)

dbWriteTable(con_db, name = "mostConserved", value = transform(most_conserved_align), row.names = FALSE, append = TRUE)

## List all the tables in the database
dbListTables(con_db)

# ## Test Database
# 
consScore_SQL <- tbl(most_conserved, "mostConserved")


# head(consScore_SQL, n = 10)
# 
# ## Subset based on species
# VT0003_after <- consScore_SQL %>%
#   filter(alignment_file == "VT0003") %>%
#   collect()
# 
# dim(VT0003_after) ## 2177
# 
# 
# ### Compared with 
# VT0003_before <- cons_score_key %>% 
#   filter(alignment_file == "VT0003")
# 
# dim(VT0003_after) ## 2177





