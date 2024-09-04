# Annot

Annot is a bioinformatics pipeline designed to streamline the annotation of Variant Call Format (VCF) files with the VEP (Variant Effect Predictor). It employs the Snakemake workflow manager to efficiently process and integrate diverse annotations, empowering researchers to gain deeper insights into genetic variation.

## Features

* **Comprehensive Annotation:** Annot integrates a wide range of annotations, including:
        * Population frequencies (gnomAD)
        * Predicted protein impact (LoFtee)
        * Pathogenicity scores (REVEL, CADD)
        * Disease associations (DisGeNET)
        * Splice site alterations (SpliceAI)
        * RNA annotations (RNACENTRAL)
       
* **Efficient Processing:** Utilizes optimized tools like 'bcftools' and 'tabix', along with parallelization, for efficient variant filtering and indexing.
* **Flexible Configuration:** Easily adaptable to different datasets and annotation requirements through a YAML configuration file.
* **Reproducibility:** The Snakemake workflow ensures consistent and traceable execution of the pipeline.

## Getting Started

### Clone the repository:

```bash

    git clone https://github.com/your-username/annot.git
    cd annot
```
### Install dependencies:
 
Ensure you have the following software installed:

* Snakemake
* bcftools
* tabix
* VEP (Variant Effect Predictor)
* Other dependencies specified in the environment.yml file.

### Prepare your data:

* Organize your VCF files in a suitable directory structure.
* Create a config.yml file specifying the paths to your VCFs, reference genome, annotation databases, and other relevant parameters.

### Run the pipeline:

```bash
snakemake --cores <number_of_cores>

```

## Configuration

Customize the pipeline's behavior using the config.yml file. Refer to the provided example configuration for guidance.
Contributing

Contributions are welcome! Please follow the standard GitHub fork-and-pull-request workflow.

## License

This project is licensed under the MIT License.

## Contact

For questions or support, please open an issue on the GitHub repository.
Acknowledgments

    The Variant Effect Predictor (VEP) team for their invaluable tool.
    The developers of the various annotation databases integrated into Annot.
