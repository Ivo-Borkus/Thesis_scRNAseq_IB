rmarkdown::render(
    input = paste0("02_scripts/03_phase/02_immune_subset.rmd"),
    output_format = "html_document",
    output_dir = "/scratch_isilon/groups/singlecell/iborkus/Projects/brain_met/02_scripts/knits",
    output_file = paste0("02_immune_subset.html")
)
