#!/usr/bin/env Rscript

suppressPackageStartupMessages(library("argparse"))

parser = ArgumentParser()
parser$add_argument("--matrix", help="Rdata file", required=TRUE)
parser$add_argument("--min_rowcounts", type="integer", help="max number of genes per cell (remove doublets)", required=TRUE)
parser$add_argument("--min_gene_prevalence", type="integer", help="min number of cells a gene must be expressed in", required=TRUE)
parser$add_argument("--data_start_col_index", type="integer", help="column at which cell counts begin (gene field at column zero)", default=1)


args = parser$parse_args()

data = read.table(file=args$matrix, sep="\t", row.names=1, header=T)

# trim out the metadata columns we dont want.
if (args$data_start_col_index > 1) {
	message("removing columns 1-", args$data_start_col_index)
    x = ncol(data)
    data = data[,args$data_start_col_index:x,]
}

data = data.matrix(data)


message("number of genes at init: ", nrow(data))

# filter based on gene prevalence 
gene_prevalence = apply(data, 1, function(x) { sum(x > 0) } )

data = data[gene_prevalence >= args$min_gene_prevalence,]

message("Num genes after gene prevalence filter: ", nrow(data))

# filter based on min rowcounts
data = data[rowSums(data, na.rm=T) >= args$min_rowcounts,]

message("Num genes after further applying min rowcounts: ", nrow(data))

new_matrix_filename = paste(args$matrix, ".filtered.matrix", sep='')
write.table(data, file=new_matrix_filename, sep="\t", quote=F)

message("Done, see file:", new_matrix_filename)



