# PDMR Data Download Pipeline

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A520.04.0-23aa62.svg)](https://www.nextflow.io/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)
[![CI](https://github.com/tylergross97/pdmr_data_download/actions/workflows/ci.yml/badge.svg)](https://github.com/tylergross97/pdmr_data_download/actions/workflows/ci.yml)

A Nextflow DSL2 pipeline for automated downloading and organizing of sequencing data from the [NCI Patient-Derived Model Repository (PDMR)](https://pdmr.cancer.gov/).

## 🎯 Overview

This pipeline automates the process of downloading WES (Whole Exome Sequencing) and RNA-seq data from NCI's PDMR database, organizing files into a structured directory hierarchy suitable for downstream bioinformatics analysis.

### ✨ Key Features

- **Automated downloads**: Batch download of WES and RNA-seq FASTQ files
- **Structured organization**: Creates patient/sample directory hierarchy
- **Resume capability**: Continue interrupted downloads with curl's resume feature
- **File validation**: Checks for existing files to avoid re-downloads
- **Flexible naming**: Handles FASTQ extension normalization (.FASTQ.gz → .fastq.gz)
- **Parallel processing**: Downloads multiple files concurrently
- **Container support**: Docker and Singularity for reproducibility

## 🚀 Quick Start

### Prerequisites

- **Nextflow** ≥20.04.0 ([installation guide](https://www.nextflow.io/docs/latest/getstarted.html))
- **Docker** or **Singularity** for containerization
- **Samplesheet** CSV file with download URLs

### Basic Usage

```bash
nextflow run tylergross97/pdmr_data_download \
    --samplesheet samples.csv \
    --base_dir /data/pdmr \
    --outdir results \
    -profile docker
```

## 📥 Input Requirements

### Samplesheet Format

Create a CSV file with the following columns:

| Column | Required | Description |
|--------|----------|-------------|
| `patient_id` | ✅ | Unique patient identifier |
| `sample_id` | ✅ | Sample identifier (e.g., ORIGINATOR, PDX passage) |
| `normal_wes_1` | ❌ | URL to normal WES R1 FASTQ |
| `normal_wes_2` | ❌ | URL to normal WES R2 FASTQ |
| `tumor_wes_1` | ❌ | URL to tumor WES R1 FASTQ |
| `tumor_wes_2` | ❌ | URL to tumor WES R2 FASTQ |
| `tumor_rnaseq_1` | ❌ | URL to tumor RNA-seq R1 FASTQ |
| `tumor_rnaseq_2` | ❌ | URL to tumor RNA-seq R2 FASTQ |

**Example:**

```csv
patient_id,sample_id,normal_wes_1,normal_wes_2,tumor_wes_1,tumor_wes_2,tumor_rnaseq_1,tumor_rnaseq_2
PID001,germline,https://example.com/normal_R1.fastq.gz,https://example.com/normal_R2.fastq.gz,,,
PID001,ORIGINATOR,,,https://example.com/tumor_R1.fastq.gz,https://example.com/tumor_R2.fastq.gz,https://example.com/rna_R1.fastq.gz,https://example.com/rna_R2.fastq.gz
PID001,PDX_P3,,,https://example.com/pdx_R1.fastq.gz,https://example.com/pdx_R2.fastq.gz,,
```

> **Note**: You can leave URL columns empty if data is not available for that sample/data type.

## 📤 Output Structure

The pipeline creates the following directory hierarchy:

```
base_dir/
└── PID_{patient_id}/
    ├── normal_wes/
    │   ├── {filename}_R1.fastq.gz
    │   └── {filename}_R2.fastq.gz
    ├── tumor_wes/
    │   └── {sample_id}/
    │       ├── {filename}_R1.fastq.gz
    │       └── {filename}_R2.fastq.gz
    └── tumor_rnaseq/
        └── {sample_id}/
            ├── {filename}_R1.fastq.gz
            └── {filename}_R2.fastq.gz
```

**Example:**

```
/data/pdmr/
└── PID_PID001/
    ├── normal_wes/
    │   ├── germline_R1.fastq.gz
    │   └── germline_R2.fastq.gz
    ├── tumor_wes/
    │   ├── ORIGINATOR/
    │   │   ├── tumor_R1.fastq.gz
    │   │   └── tumor_R2.fastq.gz
    │   └── PDX_P3/
    │       ├── pdx_R1.fastq.gz
    │       └── pdx_R2.fastq.gz
    └── tumor_rnaseq/
        └── ORIGINATOR/
            ├── rna_R1.fastq.gz
            └── rna_R2.fastq.gz
```

## ⚙️ Parameters

### Required Parameters

| Parameter | Description |
|-----------|-------------|
| `--samplesheet` | Path to CSV samplesheet with download URLs |
| `--base_dir` | Base directory for organized output files |
| `--outdir` | Directory for pipeline outputs and logs |

### Profiles

Choose a container platform:

```bash
# Docker (recommended for local systems)
-profile docker

# Singularity (recommended for HPC)
-profile singularity
```

## 💻 Usage Examples

### Download Data for Multiple Patients

```bash
nextflow run tylergross97/pdmr_data_download \
    --samplesheet pdmr_samples.csv \
    --base_dir /scratch/pdmr_data \
    --outdir pipeline_results \
    -profile docker
```

### Resume Interrupted Downloads

```bash
nextflow run tylergross97/pdmr_data_download \
    --samplesheet pdmr_samples.csv \
    --base_dir /scratch/pdmr_data \
    --outdir pipeline_results \
    -profile docker \
    -resume
```

### HPC with Singularity

```bash
nextflow run tylergross97/pdmr_data_download \
    --samplesheet samples.csv \
    --base_dir /mnt/storage/pdmr \
    --outdir results \
    -profile singularity \
    -resume
```

## 📊 Workflow Details

### Pipeline Steps

1. **PARSE_SAMPLESHEET**: Parses input CSV and creates download task list
2. **DOWNLOAD_FILE**: Downloads files using curl with resume capability
3. **RENAME_FILE**: Moves files to final destination and normalizes extensions

### Workflow Diagram

```mermaid
flowchart LR
    A[Samplesheet CSV] --> B[PARSE_SAMPLESHEET]
    B --> C[DOWNLOAD_FILE]
    C --> D[RENAME_FILE]
    D --> E[Organized Files]
```

## 🧪 Testing

The pipeline includes comprehensive nf-test coverage for all modules.

### Run Tests

```bash
# Install nf-test
curl -fsSL https://code.askimed.com/install/nf-test | bash

# Run all tests
nf-test test
```

## 🐛 Troubleshooting

### Common Issues

**Issue**: Download fails with network error
- **Solution**: Use `-resume` to continue from where it stopped. Curl automatically resumes partial downloads.

**Issue**: "Parameter validation failed" error
- **Solution**: Ensure all three required parameters (`--samplesheet`, `--base_dir`, `--outdir`) are provided

**Issue**: Files already exist but pipeline re-downloads
- **Solution**: The pipeline checks for existing files. Ensure `--base_dir` path matches previous runs.

**Issue**: Permission denied when writing files
- **Solution**: Ensure write permissions for `--base_dir` and `--outdir` directories

### Getting Help

- **Issues**: [GitHub Issues](https://github.com/tylergross97/pdmr_data_download/issues)
- **PDMR Database**: [https://pdmr.cancer.gov/](https://pdmr.cancer.gov/)

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📜 Citation

If you use this pipeline in your research, please cite:

> **Gross, T.** (2025). *PDMR Data Download Pipeline* [Computer software]. https://github.com/tylergross97/pdmr_data_download

### NCI PDMR

Please also acknowledge the NCI Patient-Derived Model Repository:

> National Cancer Institute. *Patient-Derived Model Repository (PDMR)*. https://pdmr.cancer.gov/

## 📄 License

This pipeline is released under the MIT License.

## 👤 Author

**Tyler Gross**
- GitHub: [@tylergross97](https://github.com/tylergross97)

---

**⭐ If you find this pipeline useful, please consider starring the repository!**
