#!/usr/bin/env Rscript

args<-commandArgs(TRUE)

if (length(args) == 0) {
   stop("Error, require params: counts.matrix.file");
}

matrix_filename = args[1]

pdf_filename = paste(matrix_filename, '.QCinfo.pdf', sep='')


library(vioplot)


message("Reading matrix")
data = read.table(matrix_filename, header=T, row.names=1)
log2data = log2(data+1)



pdf(pdf_filename)


###############################################################################
##  Complexity per cell:  number of expressed genes per cell (points are cells)

message("computing complexity.per.cell")
complexity.per.cell = apply(log2data, 2, function(x) { sum(x>0) } )

message("Generating complexity.per.cell stripchart")
vioplot(complexity.per.cell)
title('complexity per cell')
stripchart(complexity.per.cell, add = TRUE, vertical = TRUE, method = "jitter", jitter = 0.3, pch = '.')


################################################
## plot counts of genes vs. total reads per cell 

message("plotting genes vs. total reads per cell")
total.reads.per.cell = colSums(data)

plot(complexity.per.cell, total.reads.per.cell, main='gene count vs. total reads per cell', xlab='genes/cell', ylab='reads/cell')



##############################
## plot genes expressed, ordered by abundance
plot(complexity.per.cell[rev(order(complexity.per.cell))], main='genes expressed per cell', xlab='cell by desc count of genes', ylab='num genes expr', log='x')

###############################################################################
##  Gene prevalence:  number of cells expressing each gene.  (points are genes)


message("computing gene.prevalence")
gene.prevalence = apply(log2data, 1, function(x) { sum(x>0) } )


message("Generating gene.prevalence stripchart")
hist(log2(gene.prevalence+1), col='green', xlab='bin log2(num cells)', ylab='num of expr genes', main='hist of num genes expressed by number of cells')


dev.off()


message("Saving data")
rdata_filename = paste(matrix_filename, '.QCinfo.Rdata', sep='')
save(list=ls(all=TRUE), file=rdata_filename)



