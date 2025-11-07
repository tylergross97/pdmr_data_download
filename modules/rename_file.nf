process RENAME_FILE {
    container 'docker://python:3.14'
    publishDir params.outdir, mode: 'copy'
    
    tag "${patient_id}_${sample_id}"
    
    input:
    tuple val(patient_id), val(sample_id), path(downloaded_file), val(dest_path), val(file_type)
    
    output:
    path "final_file", emit: final_file
    
    script:
    """
    # Store the destination path in a shell variable
    DEST_PATH="${dest_path}"
    
    # Initialize log
    echo "Processing file renaming for ${patient_id}_${sample_id}" > rename_log.txt
    
    # Move file to final destination
    mkdir -p "\$(dirname "\$DEST_PATH")"
    
    if [[ -s "${downloaded_file}" ]]; then
        cp "${downloaded_file}" "\$DEST_PATH"
        echo "Moved: ${downloaded_file} -> \$DEST_PATH" >> rename_log.txt
        
        # Handle file extension normalization for specific samples
        if [[ ("${sample_id}" == "ORIGINATOR" && ("${file_type}" == "tumor_wes" || "${file_type}" == "tumor_rnaseq")) || ("${sample_id}" == "germline" && "${file_type}" == "normal_wes") ]]; then
            echo "Normalizing file extensions for ${sample_id} sample in patient ${patient_id}" >> rename_log.txt
            
            # Check if file has .FASTQ.gz extension and rename to .fastq.gz
            if [[ "\$DEST_PATH" == *.FASTQ.gz ]]; then
                new_path="\${DEST_PATH%.FASTQ.gz}.fastq.gz"
                mv "\$DEST_PATH" "\$new_path"
                echo "Renamed: \$DEST_PATH -> \$new_path" >> rename_log.txt
            fi
        fi
    else
        echo "No file to process (empty or missing download)" >> rename_log.txt
    fi
    
    # Create a final file marker
    echo "Processed ${patient_id}_${sample_id}_${file_type}" > final_file
    """
}
