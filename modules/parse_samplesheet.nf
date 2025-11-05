process PARSE_SAMPLESHEET {
    conda "bioconda::python=3.9"
        
    input:
    path samplesheet
    
    output:
    path "download_tasks.csv", emit: tasks
    
    script:
    """
    #!/usr/bin/env python3
    import csv
    
    with open('${samplesheet}', 'r') as infile, open('download_tasks.csv', 'w', newline='') as outfile:
        reader = csv.DictReader(infile)
        writer = csv.writer(outfile)
        
        # Write header
        writer.writerow(['patient_id', 'sample_id', 'url', 'dest_path', 'file_type'])
        
        for row in reader:
            patient_id = row['patient_id']
            sample_id = row['sample_id']
            base_dir = '${params.base_dir}'
            
            # Normal WES files
            if row.get('normal_wes_1'):
                dest = f"{base_dir}/PID_{patient_id}/normal_wes/{row['normal_wes_1'].split('/')[-1]}"
                writer.writerow([patient_id, sample_id, row['normal_wes_1'], dest, 'normal_wes'])
            
            if row.get('normal_wes_2'):
                dest = f"{base_dir}/PID_{patient_id}/normal_wes/{row['normal_wes_2'].split('/')[-1]}"
                writer.writerow([patient_id, sample_id, row['normal_wes_2'], dest, 'normal_wes'])
            
            # Tumor WES files
            if row.get('tumor_wes_1'):
                dest = f"{base_dir}/PID_{patient_id}/tumor_wes/{sample_id}/{row['tumor_wes_1'].split('/')[-1]}"
                writer.writerow([patient_id, sample_id, row['tumor_wes_1'], dest, 'tumor_wes'])
            
            if row.get('tumor_wes_2'):
                dest = f"{base_dir}/PID_{patient_id}/tumor_wes/{sample_id}/{row['tumor_wes_2'].split('/')[-1]}"
                writer.writerow([patient_id, sample_id, row['tumor_wes_2'], dest, 'tumor_wes'])
            
            # Tumor RNA-seq files
            if row.get('tumor_rnaseq_1'):
                dest = f"{base_dir}/PID_{patient_id}/tumor_rnaseq/{sample_id}/{row['tumor_rnaseq_1'].split('/')[-1]}"
                writer.writerow([patient_id, sample_id, row['tumor_rnaseq_1'], dest, 'tumor_rnaseq'])
            
            if row.get('tumor_rnaseq_2'):
                dest = f"{base_dir}/PID_{patient_id}/tumor_rnaseq/{sample_id}/{row['tumor_rnaseq_2'].split('/')[-1]}"
                writer.writerow([patient_id, sample_id, row['tumor_rnaseq_2'], dest, 'tumor_rnaseq'])
    """
}