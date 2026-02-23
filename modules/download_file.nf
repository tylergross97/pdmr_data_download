process DOWNLOAD_FILE {
    container 'community.wave.seqera.io/library/curl:8.17.0--03c37328f7dd882d'
    publishDir params.outdir, mode:'copy'
    
    tag "${patient_id}_${sample_id}_${file_type}"
    
    input:
    tuple val(patient_id), val(sample_id), val(url), val(dest_path), val(file_type)
    
    output:
    tuple val(patient_id), val(sample_id), path("${filename}"), val(dest_path), val(file_type), emit: downloaded
    path "download_log.txt", emit: log
    
    script:
    filename = dest_path.split('/').last()
    """
    # Create log file
    echo "Processing: ${patient_id}, ${sample_id}, ${file_type}" > download_log.txt
    
    # Check if URL is provided
    if [[ -n "${url}" && "${url}" != "null" ]]; then
        # Check if file already exists at destination
        if aws s3 ls "${dest_path}" 2>/dev/null; then
            echo "SKIPPED (already exists): ${dest_path}" >> download_log.txt
            # Create empty placeholder file
            touch "${filename}"
        else
            echo "Downloading ${url} -> ${filename}" >> download_log.txt
            
            # Download with curl (resume capability and follow redirects)
            if curl -L -C - -o "${filename}" "${url}"; then
                echo "SUCCESS: Downloaded ${filename}" >> download_log.txt
            else
                echo "FAILED: ${url}" >> download_log.txt
                exit 1
            fi
        fi
    else
        echo "SKIPPED (no URL provided): ${dest_path}" >> download_log.txt
        touch "${filename}"
    fi
    """
}