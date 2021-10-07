
# p-codeml
### Description and Installation
p-codeml is a script for detecting positively selected genes (PSGs) using [CodeML](http://evomics.org/learning/phylogenetics/paml/) under a branch-site model. You can install this repository using the following command:

```$ git clone https://github.com/bsjodin/p-codeml```

You may need to change permissions, which can be done running the following:

```$chmod 755 p-codeml.sh ./src/*.sh ./src/*.R```

### Usage and Options
**Usage:**\
```$ ./p-codeml.sh -i [input_dir] -o [output_dir] -n [threads]```

**Options:**
| Flag | Description |
| --- | --- |
| -i [string] | **Required**; input directory containing PAML formated alignments |
| -o [string] | **Optional**; output directory, default is "output" |
| -n [int] | **Optional**; number of threads/instances to run simultaneously, default is 1 |
  
### Software Requirements
This script requires [PAML](http://evomics.org/learning/phylogenetics/paml/) is installed and in your ```$PATH``` variable. It also requires [R](https://www.r-project.org/) is installed and in your ```$PATH``` variable.

### Input Files and Directory Structure
A minimum of two input files are required:

1) A tree file in Newick format, with the foreground/background branches labeled (see [example_tree.txt](example/tree_labeled.txt)). This must be called `tree_labeled.txt` in order for the script to function correctly.
2) Gene alignments in PAML format (see [example](example/) directory for example inputs). PAML files must have the suffix ".pml" or the program will not run correctly. For multiple genes, it is best to keep these in a seperate directory.

The `p-codeml.sh` script must be in your current working directory and all other scripts must be in a subdirectory called `src`. Input alignment files should be in their own subdirectory, and the labeled tree file must be in your current working directory. The control files also must be in the `src` directory (copying and pasting the `src` directory is the safest practice).

### Overview
The script runs in three steps:

1) First, the script runs the ```generate_ctl.sh``` script in the ```src``` directory which creates the output directory structure and generates all the control files needed to run CodeML. This script uses the `codemlModelA.ctl` and `codemlModelANull.ctl` in the `src` directory as inputs; the parameters in these control files can be edited to best suit your needs.
2) Next, CodeML (`codeml.sh`) is launched in the background, running the number of processes specified by ```-n```. This will run both the Null and Alternative models as well as calculate log-liklihood ratios (LRTs) and associated *p*-values.
3) Lastly, *p*-values are parsed for all genes (`parse_psg.sh`), and R is run to apply a Bonferroni correction to the *p*-values, plotting the distribution for both the uncorrected and corrected values (`pvalue_correct.R`). Genes with *p*<sub>*adjust*</sub>≤0.01 and at least one positively-selected site with a Bayes Empirical Bayes (BEB) probability ≥0.99 are parsed out as PSGs and written to `final_table.txt`.

### Outputs
CodeML results for each gene alignment will be saved in `[output_dir]/[group_id]`. 

LRT and Χ<sup>2</sup> test results will be saved in `[output_dir]/[group_id]/[group_id]_chi2.txt`. 

Corrected *p*-values and histograms will be saved in the current working directory as `pvalues-correct.txt` and `Rplots.pdf`, respectively.

A final table of all PSGs will be output to `final_table.txt` with the following headings:
 - **Group:** ID for the gene alignment file
 - **Alt_lnL:** Log-likelihood score for the alternate model
 - **Null_lnL:** Log-likelihood score for the null model
 - **pvalue:** Uncorrected *p*-value from the LRT test
 - **corrected_pvalue:** *p*-value following Bonferonni correction
 - **#pos_sites:** Number of positively-selected sites with BEB probability ≥0.99
 - **site_names:** Site IDs (integers) of positively-selected sites

### Running individual scripts
Each of the three steps can be run individually, however, all previous scripts must be run first in order to work correctly. For example, the `codeml.sh` script cannot be successfully run without first running `generate_ctl.sh`. 

Before running all scripts, though, you must first generate a file with the names, one per line, and saved to file `fofn.txt`. You can do so with the following command:\
```$ basename -s .pml `ls [input_dir]` > fofn.txt```

Then, the three scripts can be run as follows:

`$ ./src/generate_ctl.sh [input_dir] [output_dir]`\
`$ ./src/codeml.sh fofn.txt [output_dir] | tee codeml.log`\
`$ ./src/parse_psg.sh`

**Note:** Running the `codeml.sh` script in this fashion only submits a single instance. To run multiple, open new terminal windows and re-run the command with a different `fofn.txt` file for each instance (can be renamed; example, `fofn1.txt`).
