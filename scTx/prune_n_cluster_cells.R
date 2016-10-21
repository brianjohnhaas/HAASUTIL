#!/usr/bin/env Rscript --default-packages=stats,graphics,grDevices,utils,datasets,base,methods

#--default-packages=methods,utils

suppressPackageStartupMessages(library("argparse"))

parser = ArgumentParser()
parser$add_argument("--Rdata", help="Rdata file", required=TRUE)
parser$add_argument("--min_complexity", type="integer", help="min number of genes per cell", required=TRUE)
parser$add_argument("--max_complexity", type="integer", help="max number of genes per cell (remove doublets)", required=TRUE)
parser$add_argument("--min_gene_prevalence", type="integer", help="min number of cells a gene must be expressed in", required=TRUE)

args = parser$parse_args()

pdf_filename = paste(args$Rdata, ".seurat.pdf", sep='')
pdf(pdf_filename)

library("Seurat")

ext = new.env()
load(args$Rdata, verbose=TRUE, envir=ext)

args = parser$parse_args() # reset since over-written



sc = new("seurat", raw.data=ext$log2data)
sc = Setup(sc, project="SingleCell", min.cells=args$min_gene_prevalence, min.genes=args$min_complexity, do.logNormalize = F, total.expr = 1e4)
sc = SubsetData(sc, subset.name="nGene", accept.high=args$max_complexity)

## get variable genes
sc = MeanVarPlot(sc, fxn.x = expMean, fxn.y = logVarDivMean, x.low.cutoff = 0.0125, x.high.cutoff = 3, y.cutoff = 0.5, do.contour = F)

num_var_genes = length(sc@var.genes)
message(sprintf("Number of variable genes: %s", num_var_genes))

sc = PCA(sc, pc.genes = sc@var.genes, do.print = TRUE, pcs.print = 5, genes.print = 5)

sc = ProjectPCA(sc)
PrintPCA(sc, pcs.print = 1:5, genes.print = 5, use.full = TRUE)
PCAPlot(sc, 1, 2)
VizPCA(sc, 1:2)

PCAPlot(sc, 2, 3)
VizPCA(sc, 2:3)

PCHeatmap(sc, pc.use = 1, cells.use = 100, do.balanced = TRUE)
PCHeatmap(sc, pc.use = 2, cells.use = 100, do.balanced = TRUE)
PCHeatmap(sc, pc.use = 3, cells.use = 100, do.balanced = TRUE)

# choose the PCs to use for clustering
PCElbowPlot(sc)

# find clusters
sc <- FindClusters(sc, pc.use = 1:10, resolution = 0.6, print.output = 0, save.SNN = T)

# run TSNE
sc <- RunTSNE(sc, dims.use = 1:10, do.fast = T)

TSNEPlot(sc)


dev.off()
