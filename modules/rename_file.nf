process RENAME_FILE {
    container 'community.wave.seqera.io/library/python:3.13'
    publishDir "${params.outdir}", mode: 'copy', saveAs: { filename -> 
        // Only publish the organized directory structure, not logs
        if (filename.startsWith('PID_')) {
            return filename
        }
        return null
    }
    
    tag "${patient_id}_${sample_id}_${file_type}"
    
    input:
    tuple val(patient_id), val(sample_id), path(downloaded_file), val(dest_path), val(file_type)
    
    output:
    path "PID_${patient_id}/**", emit: organized_files
    path "rename_log.txt", emit: log
    
    script:
    def output_filename = dest_path.split('/').last()
    // Normalize .FASTQ.gz to .fastq.gz if needed
    if (output_filename.endsWith('.FASTQ.gz')) {
        output_filename = output_filename.replaceAll(/\.FASTQ\.gz$/, '.fastq.gz')
    }
    // Build the directory path based on file type
    // For normal_wes: PID_XXX/normal_wes/
    // For tumor files: PID_XXX/tumor_wes/SAMPLE_ID/ or PID_XXX/tumor_rnaseq/SAMPLE_ID/
    def output_subdir = file_type == 'normal_wes' ? 
        "PID_${patient_id}/${file_type}" : 
        "PID_${patient_id}/${file_type}/${sample_id}"
    """
    # Initialize log
    echo "Processing file renaming for ${patient_id}_${sample_id}_${file_type}" > rename_log.txt
    
    # Create output directory structure
    mkdir -p "${output_subdir}"
    
    if [[ -s "${downloaded_file}" ]]; then
        # Copy and rename file
        cp "${downloaded_file}" "${output_subdir}/${output_filename}"
        echo "Organized: ${downloaded_file} -> ${output_subdir}/${output_filename}" >> rename_log.txt
        echo "File size: \$(stat -f%z "${output_subdir}/${output_filename}" 2>/dev/null || stat -c%s "${output_subdir}/${output_filename}" 2>/dev/null)" >> rename_log.txt
    else
        echo "WARNING: No file to process (empty or missing download)" >> rename_log.txt
        # Create placeholder to maintain structure
        touch "${output_subdir}/${output_filename}"
    fi
    """
}
