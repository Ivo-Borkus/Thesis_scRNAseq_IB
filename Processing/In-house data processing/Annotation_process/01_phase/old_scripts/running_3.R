rmarkdown::render(
    input = paste0("02_scripts/02_phase/04_naming_compartments.rmd"),
    output_format = "html_document",
    output_dir = "/scratch_isilon/groups/singlecell/iborkus/Projects/brain_met/02_scripts/knits",
    output_file = paste0("04_naming_compartments.html")
)
