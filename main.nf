#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

def validateParams() {
    def errors = []
    if (!params.samplesheet) {
        errors << "ERROR: Please provide --samplesheet parameter"
    }
    if (!params.base_dir) {
        errors << "ERROR: Please provide --base_dir parameter"
    }
    if (!params.outdir) {
        errors << "ERROR: Please provide --outdir parameter"
    }
}

include { PARSE_SAMPLESHEET } from './modules/parse_samplesheet.nf'
include { DOWNLOAD_FILE } from './modules/download_file.nf'
include { RENAME_FILE } from './modules/rename_file.nf'

workflow {
   validateParams()

   //Create channels
   input_samplesheet = Channel.fromPath(params.samplesheet)

   PARSE_SAMPLESHEET(input_samplesheet)

   // Convert CSV to channel of download tasks
   download_tasks_ch = PARSE_SAMPLESHEET.out.tasks
        .splitCsv(header: true)
        .filter { row -> row.url && row.url != 'null' && row.url != '' }
        .map { row -> 
            [row.patient_id, row.sample_id, row.url, row.dest_path, row.file_type]
        }
    
   DOWNLOAD_FILE(download_tasks_ch)

   RENAME_FILE(DOWNLOAD_FILE.out.downloaded) 
}