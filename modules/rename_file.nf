process RENAME_FILE {
    container 'python:3.13'
    publishDir "${params.outdir}", mode: 'copy', pattern: 'output/**'
    
    tag "${patient_id}_${sample_id}_${file_type}"
    
    input:
    tuple val(patient_id), val(sample_id), path(downloaded_file), val(dest_path), val(file_type)
    
    output:
    tuple val(patient_id), val(sample_id), val(file_type), path("output/*"), emit: renamed_files
    path "rename_log.txt", emit: log
    
    script:
    def output_filename = dest_path.split('/').last()
    // Normalize .FASTQ.gz to .fastq.gz if needed
    if (output_filename.endsWith('.FASTQ.gz')) {
        output_filename = output_filename.replaceAll(/\.FASTQ\.gz$/, '.fastq.gz')
    }
    def output_subdir = "PID_${patient_id}/${file_type}/${sample_id}"
    """
    # Initialize log
    echo "Processing file renaming for ${patient_id}_${sample_id}_${file_type}" > rename_log.txt
    
    # Create output directory structure
    mkdir -p output/${output_subdir}
    
    if [[ -s "${downloaded_file}" ]]; then
        # Copy and rename file
        cp "${downloaded_file}" "output/${output_subdir}/${output_filename}"
        echo "Renamed: ${downloaded_file} -> ${output_filename}" >> rename_log.txt
        echo "Output path: ${output_subdir}/${output_filename}" >> rename_log.txt
    else
        echo "No file to process (empty or missing download)" >> rename_log.txt
        # Create placeholder
        touch "output/${output_subdir}/${output_filename}"
    fi
    """
}
