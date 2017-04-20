#!/usr/bin/env Rscript

suppressPackageStartupMessages(library("argparse"))

parser = ArgumentParser()
parser$add_argument("--matrix", help="Rdata file", required=TRUE)
parser$add_argument("--min_gene_counts", type="integer", help="Filter Cells: min number of genes per cell", required=TRUE)
parser$add_argument("--min_gene_prevalence", type="integer", help="Filter Genes: min number of cells a gene must be expressed in", required=TRUE)
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

# filter based on gene prevalence  (number of cells expressing gene)
gene_prevalence = apply(data, 1, function(x) { sum(x > 0) } )

data = data[gene_prevalence >= args$min_gene_prevalence,]

message("Num genes after gene prevalence filter: ", nrow(data))

# filter cells based on number of genes expressed

genes_expressed_per_cell = apply(data, 2, function(x) { sum(x>0) } )

data = data[,genes_expressed_per_cell >= args$min_gene_counts]

message("Number of cells after applying min gene count: ", ncol(data))


new_matrix_filename = paste0(args$matrix, ".filtered", ".minGPC", args$min_gene_counts, ".minCPG", args$min_gene_prevalence, ".matrix")
write.table(data, file=new_matrix_filename, sep="\t", quote=F)

message("Done, see file:", new_matrix_filename)


