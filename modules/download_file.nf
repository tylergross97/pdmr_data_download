process DOWNLOAD_FILE {
    container 'community.wave.seqera.io/library/curl:8.17.0--03c37328f7dd882d'
    publishDir params.outdir, mode:'copy'
    
    tag "${patient_id}_${sample_id}_${file_type}"
    
    input:
    tuple val(patient_id), val(sample_id), val(url), val(dest_path), val(file_type)
    
    output:
    tuple val(patient_id), val(sample_id), path("downloaded_file"), val(dest_path), val(file_type), emit: downloaded
    path "download_log.txt", emit: log
    
    script:
    def filename = dest_path.split('/').last()
    """
    # Create log file
    echo "Processing: ${patient_id}, ${sample_id}, ${file_type}" > download_log.txt
    
    # Check if URL is provided
    if [[ -n "${url}" && "${url}" != "null" ]]; then
        # Create destination directory structure
        mkdir -p "\$(dirname "${dest_path}")"
        
        # Check if file already exists
        if [[ -f "${dest_path}" ]]; then
            echo "SKIPPED (already exists): ${dest_path}" >> download_log.txt
            # Create a symlink to the existing file for consistency
            ln -s "${dest_path}" downloaded_file
        else
            echo "Downloading ${url} -> ${dest_path}" >> download_log.txt
            
            # Download with curl (resume capability and follow redirects)
            if curl -L -C - -o downloaded_file "${url}"; then
                echo "SUCCESS: ${dest_path}" >> download_log.txt
            else
                echo "FAILED: ${dest_path}" >> download_log.txt
                exit 1
            fi
        fi
    else
        echo "SKIPPED (no URL provided): ${dest_path}" >> download_log.txt
        touch downloaded_file
    fi
    """
}