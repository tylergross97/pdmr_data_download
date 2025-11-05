process RENAME_FILE {
    publishDir params.outdir, mode: 'copy'
    
    tag "${patient_id}_${sample_id}"
    
    input:
    tuple val(patient_id), val(sample_id), path(downloaded_file), val(dest_path), val(file_type)
    
    output:
    path "final_file", emit: final_file
    
    script:
    """
    # Initialize log
    echo "Processing file renaming for ${patient_id}_${sample_id}" > rename_log.txt
    
    # Move file to final destination
    mkdir -p "\$(dirname "${dest_path}")"
    
    if [[ -s "${downloaded_file}" ]]; then
        cp "${downloaded_file}" "${dest_path}"
        echo "Moved: ${downloaded_file} -> ${dest_path}" >> rename_log.txt
        
        # Handle file extension normalization for specific samples
        if [[ "${sample_id}" == "germline" && "${file_type}" == "normal_wes" ]]; then
            echo "Normalizing file extensions for germline in patient ${patient_id}" >> rename_log.txt
            
            # Check if file has .FASTQ.gz extension and rename to .fastq.gz
            if [[ "${dest_path}" == *.FASTQ.gz ]]; then
                new_path="\${dest_path%.FASTQ.gz}.fastq.gz"
                mv "${dest_path}" "\$new_path"
                echo "Renamed: ${dest_path} -> \$new_path" >> rename_log.txt
            fi
            
        elif [[ "${sample_id}" == "ORIGINATOR" && ("${file_type}" == "tumor_wes" || "${file_type}" == "tumor_rnaseq") ]]; then
            echo "Normalizing file extensions for ORIGINATOR in patient ${patient_id}" >> rename_log.txt
            
            # Check if file has .FASTQ.gz extension and rename to .fastq.gz
            if [[ "${dest_path}" == *.FASTQ.gz ]]; then
                new_path="\${dest_path%.FASTQ.gz}.fastq.gz"
                mv "${dest_path}" "\$new_path"
                echo "Renamed: ${dest_path} -> \$new_path" >> rename_log.txt
            fi
        fi
    else
        echo "No file to process (empty or missing download)" >> rename_log.txt
    fi
    
    # Create a final file marker
    echo "Processed ${patient_id}_${sample_id}_${file_type}" > final_file
    """
}