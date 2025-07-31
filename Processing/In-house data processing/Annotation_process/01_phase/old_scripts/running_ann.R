# rmarkdown::render(
#     input = paste0("02_scripts/002_integration_analysis.rmd"),
#     output_format = "html_document",
#     output_dir = "/scratch_isilon/groups/singlecell/iborkus/Projects/brain_met/02_scripts/knits",
#     output_file = paste0("002_integration_analysis.html")
# )


# rmarkdown::render(
#     input = paste0("02_scripts/002_immune_compartment_annotation.rmd"),
#     output_format = "html_document",
#     output_dir = "/scratch_isilon/groups/singlecell/iborkus/Projects/brain_met/02_scripts/knits",
#     output_file = paste0("002_immune_compartment_annotation.html")
# )
# rmarkdown::render(
#     input = paste0("02_scripts/02_phase/03_immune_compartment_annotation.rmd"),
#     output_format = "html_document",
#     output_dir = "/scratch_isilon/groups/singlecell/iborkus/Projects/brain_met/02_scripts/knits",
#     output_file = paste0("03_immune_compartment_annotation.html")
# )

# rmarkdown::render(
#     input = paste0("02_scripts/02_phase/04_naming_compartments.rmd"),
#     output_format = "html_document",
#     output_dir = "/scratch_isilon/groups/singlecell/iborkus/Projects/brain_met/02_scripts/knits",
#     output_file = paste0("04_naming_compartments.html")
# )
rmarkdown::render(
    input = paste0("02_scripts/02_phase/Immune/01_general_annotation.rmd"),
    output_format = "html_document",
    output_dir = "/scratch_isilon/groups/singlecell/iborkus/Projects/brain_met/02_scripts/knits",
    output_file = paste0("knits/03_phase/Immune/01_general_annotation.html")
)
