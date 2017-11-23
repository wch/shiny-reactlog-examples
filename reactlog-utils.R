library(dplyr)
library(tidyr)
library(jsonlite)

# Process the reactlog for one session
process_reactlog_one <- function(dat) {
  # Find id-label mapping
  label_map <- dat %>%
    select(id, label) %>%
    filter(!is.na(label))
  
  if (any(duplicated(label_map$id))) {
    stop("More than one label for id: ",
      paste(unique(label_map$id[duplicated(label_map$id)]), collapse = ", ")
    )
  }

  # Fill in labels
  dat <- dat %>%
    select(-label) %>%
    left_join(label_map, by = "id") %>%
    mutate(id = ifelse(is.na(label), id, label))

  # Some entries of dependsOn will have an id number. Replace with the label.
  dat <- dat %>%
    left_join(label_map, by = c("dependsOn" = "id"), suffix = c("", ".y")) %>%
    mutate(dependsOn = ifelse(is.na(label.y), dependsOn, label.y)) %>%
    select(-label.y)


  dat <- dat %>%
    select(session, time, action, id, value, dependsOn, type) %>%
    mutate(time = (time - min(time)) * 1000)
  
  dat$action[dat$action == "depId"]  <- "dep"
  dat$action[dat$action == "ctx"]    <- "new"
  dat$type[dat$type == "observable"] <- "reactive"

  dat
}

# * dat: reactlog data list.
# * name: Name used for the output file.
process_last_reactlog <- function(dat = shiny:::.graphStack$as_list(), name = NULL) {
  # A little data fixup: Sometimes the session is NULL, when the action is
  # "exit". In this case, we'll just fill it in with the previous value.
  lastsession <- ""
  for (i in seq_along(dat)) {
    if (is.null(dat[[i]]$session)) {
      dat[[i]]$session <- lastsession
    } else {
      lastsession <- dat[[i]]$session
    }
  }

  # Keep only the rows from the last session
  keep_rows <- vapply(dat, function(row) {
    return(row$session == lastsession)
  }, TRUE)
  
  dat <- dat[keep_rows]
  
  # Convert from d3-format nested lists to data frame
  dat <- lapply(dat, function(row) {
    row$srcref <- NULL
    row$srcfile <- NULL

    as.data.frame(row, stringsAsFactors = FALSE)
  })
  dat <- bind_rows(dat)
  dat$prevId[dat$prevId == ""] <- NA

  # Process data from the session
  dat <- process_reactlog_one(dat)

  if (is.null(name))
    name <- lastsession

  # Save to RDS and JSON
  saveRDS(dat, sprintf("reactlog-%s.rds", name))
  json <- jsonlite::toJSON(dat, digits = 2, pretty = TRUE)
  write(json, sprintf("reactlog-%s.json", name))
  invisible(dat)
}

# This resets the reactlog graph data in Shiny. It's not strictly necessary,
# since process_last_reactlog() extracts the data for the most recent session,
# but it is more efficient to reset the data.
reset_graph <- function() {
  gs <- shiny:::.graphStack
  gs$initialize()
  gs$private$count <- 0L
}
