Example data from Shiny reactlog
================================


## Existing reactlog interactive viewer

To create and view the react log for a Shiny application, do the following:

```
library(shiny)
options(shiny.reactlog = TRUE)

# Run the app. Interact with it a bit, and then quit
runApp("01-hello")

# View the react log
showReactLog()
```

This will provide an interactive viewer for the reactlog.


## Data extraction and cleaning

To get the data in a usable JSON format, we'll use the functions defined in `reactlog-utils.R`. There are two functions of note:


* `process_last_reactlog()`: This function gets the reactlog from the previous Shiny application and saves it to two files: a RDS (R format) file, and a JSON file.
* `reset_graph()`: Normally Shiny keeps appending reactlog data each time you run an app and never clears it. This function clears the current reactlog data. (Running this function isn't strictly necessary because `process_last_reactlog()` will only extract data from the last-run application, but it will make data processing more efficient.)

To record data from a very basic application:

```
library(shiny)
options(shiny.reactlog = TRUE)
source("reactlog-utils.R")


reset_graph()
# Interact with the application, then close it
runApp("01-hello")
# Save the data to files
process_last_reactlog(name = "01-hello")
```

The code snippets below will record reactlog data from other example applications from this repository. I have already saved the data in this repository, but you can run the code below if you want to see how the applications work, or if you want to generate your own data set.

A slightly more complicated app:

```
reset_graph()
runApp("063-superzip-example")
process_last_reactlog(name = "063-superzip-example")
```


A simple application which is not reacting as expected:

```
reset_graph()
runApp("not-reacting")
process_last_reactlog(name = "not-reacting")
```


A simple application which is reacting too often:

```
reset_graph()
runApp("too-often")
process_last_reactlog(name = "too-often")
```


Another slightly more complicated app:

```
# Install some packages if needed:
# install.packages(c("shinydashboard", "devtools"))
# devtools::install_github("jcheng5/bubbles")
# devtools::install_github("hadley/shinySignals")
reset_graph()
runApp("087-crandash")
process_last_reactlog(name = "087-crandash")
```

A more complicated app:

```
# Install radiant package if needed:
# install.packages("radiant", repos = "https://radiant-rstats.github.io/minicran/", type = "binary")
reset_graph()
radiant::radiant()
process_last_reactlog(name = "radiant")
```
