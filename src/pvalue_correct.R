#!/usr/bin/env Rscript

pdf(file="pvalue_plots.pdf")

input <- read.delim("pvalues.txt", header=F, sep = " ")
hist(input$V2,main="Uncorrected p-values",xlab="p-value",col="lightgrey")

input$V3 <- p.adjust(input$V2, method="bonferroni", n = length(input$V2))
hist(input$V3,main="Corrected p-values (Bonferroni)",xlab="p-value",col="lightgrey")

write.table(input, file="pvalues-correct.txt",row.names = FALSE, col.names = FALSE,quote = FALSE)
