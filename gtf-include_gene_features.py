#!/usr/bin/env python3

import sys, os, re
from collections import defaultdict
import csv


# Debugging: Adjusting the parsing logic for attributes
def add_gene_and_transcript_rows_debug(input_path, output_path):
    gene_data = defaultdict(lambda: {"start": float("inf"), "end": 0})
    transcript_data = defaultdict(
        lambda: {"start": float("inf"), "end": 0, "gene_id": ""}
    )

    gene_id_to_transcript_ids = defaultdict(set)
    transcript_id_to_exon_rows = defaultdict(list)

    # Parse the GTF file and collect data for genes and transcripts
    with open(input_path, "r") as infile:
        reader = csv.reader(infile, delimiter="\t")
        exon_rows = []

        for row in reader:
            if len(row) < 9 or row[2] != "exon":
                continue  # Skip invalid rows or non-exon features

            chrom, source, feature, start, end, score, strand, frame, attributes = row

            # Safely parse the attributes field
            attributes_dict = {}
            for item in attributes.split(";"):
                if not item.strip():
                    continue
                parts = item.strip().split(" ", 1)
                if len(parts) == 2:
                    key, value = parts
                    attributes_dict[key.strip()] = value.strip('"')

            gene_id = attributes_dict.get("gene_id")
            transcript_id = attributes_dict.get("transcript_id")
            start, end = int(start), int(end)

            # Update gene and transcript bounds
            if gene_id:
                gene_data[gene_id]["start"] = min(gene_data[gene_id]["start"], start)
                gene_data[gene_id]["end"] = max(gene_data[gene_id]["end"], end)
                gene_data[gene_id]["chrom"] = chrom
                gene_data[gene_id]["strand"] = strand

            if transcript_id:
                transcript_data[transcript_id]["start"] = min(
                    transcript_data[transcript_id]["start"], start
                )
                transcript_data[transcript_id]["end"] = max(
                    transcript_data[transcript_id]["end"], end
                )
                transcript_data[transcript_id]["gene_id"] = gene_id
                transcript_data[transcript_id]["chrom"] = chrom
                transcript_data[transcript_id]["strand"] = strand

                gene_id_to_transcript_ids[gene_id].add(transcript_id)
                if "gene_name" in attributes_dict:
                    gene_data[gene_id]["gene_name"] = attributes_dict["gene_name"]

            # exon_rows.append(row)
            transcript_id_to_exon_rows[transcript_id].append(row)

    # Write the updated GTF with new gene and transcript rows
    with open(output_path, "w", newline="") as outfile:
        # Add gene rows
        for gene_id, bounds in gene_data.items():

            gene_name = bounds["gene_name"] if "gene_name" in bounds else gene_id

            print(
                "\t".join(
                    [
                        str(x)
                        for x in [
                            bounds["chrom"],
                            "AddedFeature",
                            "gene",
                            bounds["start"],
                            bounds["end"],
                            ".",
                            bounds["strand"],
                            ".",
                            f'gene_id "{gene_id}"; gene_name "{gene_name}";',
                        ]
                    ]
                ),
                file=outfile,
            )

            for transcript_id in gene_id_to_transcript_ids[gene_id]:
                bounds = transcript_data[transcript_id]

                print(
                    "\t".join(
                        [
                            str(x)
                            for x in [
                                bounds["chrom"],
                                "AddedFeature",
                                "transcript",
                                bounds["start"],
                                bounds["end"],
                                ".",
                                bounds["strand"],
                                ".",
                                f'gene_id "{bounds["gene_id"]}"; transcript_id "{transcript_id}"; gene_name "{gene_name}";',
                            ]
                        ]
                    ),
                    file=outfile,
                )

                exon_rows = transcript_id_to_exon_rows[transcript_id]

                # Add original exon rows
                for row in exon_rows:
                    row[-1] += f' gene_name "{gene_name}";'
                    print("\t".join(row), file=outfile)


usage = "\n\tusage: {} input.gtf output.gtf\n\n".format(sys.argv[0])
if len(sys.argv) < 3:
    exit(usage)

input_gtf = sys.argv[1]
output_gtf = sys.argv[2]

add_gene_and_transcript_rows_debug(input_gtf, output_gtf)
