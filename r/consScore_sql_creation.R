### Creating SQL Data Base out of alignment keys

## libraries
library(RSQLite)
library(tidyverse)
library(dbplyr)
library(dplyr)

#################################
## PhastCons score per alignment
################################

## Read in and clean up PhastCons scores.

cons_scores_0 <- read.csv("../data/outputs/consScore2/output_VT_all_consScore.csv")

cons_scores <- cons_scores_0
colnames(cons_scores) <- c("","coord","post.prob","alignment")

cons_scores <- cons_scores[,-1]
colnames(cons_scores)[1] <- "raw_MEMB002A_pos"
cons_scores$raw_MEMB002A_pos <- as.numeric(cons_scores$raw_MEMB002A_pos)

colnames(cons_scores)[3] <- "alignment_file"
cons_scores$alignment_file <- gsub(".fa", "", cons_scores$alignment_file)
cons_scores$alignment_file <- gsub("output_", "", cons_scores$alignment_file) 

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

head(MEMB002A_key)

########################
### Merging
#########################

## Turn into tibble
cons_scores <- as_data_frame(cons_scores)

### Alignmnet Keys For merging
levels(as.factor(MEMB002A_key$alignment_file))

colnames(MEMB002A_key)[2] <- "raw_MEMB002A_pos"

## Merge the two files
cons_score_key <- full_join(cons_scores, MEMB002A_key, by = c("alignment_file", "raw_MEMB002A_pos"))

cons_score_key <- cons_score_key %>% 
    select(-species)

###########################
#### Make SQL database
############################

## Make the database for alignmentKeys
con_db <- dbConnect(SQLite(), "../data/sql/consScore.sqlite")
dbWriteTable(con_db, name = "consScore", value = transform(cons_score_key), row.names = FALSE, append = TRUE)
dbDisconnect(con_db)

# ## Test Database
# con_db <- DBI::dbConnect(RSQLite::SQLite(), "../data/sql/consScore.sqlite")
# 
# consScore_SQL <- tbl(con_db, "consScore")
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

## Resources
## http://www.starkingdom.co.uk/creating-an-sqlite-database-with-r/
## http://www.datacarpentry.org/R-ecology-lesson/05-r-and-databases.html
## https://cran.r-project.org/web/packages/RSQLite/vignettes/RSQLite.html