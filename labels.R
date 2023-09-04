#RShiny - Run specific bits

#Title of the Dashboard
shiny_title <- "Lake Erie - 2013"

#Example included in git repo
#nosink vs sink
data_dir <- "data"
title_v1 <- "Total Phosphorus, does not sink out"
title_v2 <- "Total Phosphorus, sinks out"
colorby_choices = list( "TP, does not sink out" = "Var1", "TP, sinks out" = "Var2")

#Description of Runs
#nosink vs sink
#data_dir <- "data_nosinkout_vs_sinkout"
#title_v1 <- "Total Phosphorus, does not sink out"
#title_v2 <- "Total Phosphorus, sinks out"
#colorby_choices = list( "TP, does not sink out" = "Var1", "TP, sinks out" = "Var2")

#nosink vs LEEM
#data_dir <- "data_nosinkout_vs_leem"
#title_v1 <- "Total Phosphorus, does not sink out"
#title_v2 <- "Total Phosphorus, LEEM"
#colorby_choices = list( "TP, does not sink out" = "Var1", "TP, LEEM" = "Var2")

#sink vs LEEM
#data_dir <- "data_sinkout_vs_leem"
#title_v1 <- "Total Phosphorus, sinks out"
#title_v2 <- "Total Phosphorus, LEEM"
#colorby_choices = list( "TP, sinks out" = "Var1", "TP, LEEM" = "Var2")