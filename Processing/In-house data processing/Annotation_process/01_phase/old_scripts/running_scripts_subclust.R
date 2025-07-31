rmarkdown::render(
    input = paste0("02_scripts/lineage_annotation/per_sample/sample_1.rmd"),
    output_format = "html_document",
    output_dir = "/scratch_isilon/groups/singlecell/iborkus/Projects/brain_met/02_scripts/knits/lineage_annotation",
    params = list(
        sample = "105086-009-002",
        fullname = "Lung_BrM23-24",
        minUMI = 500,
        maxUMI = NA,
        minfeat = 300,
        maxfeat = 10000,
        maxmt = 20,
        res = "0.1",
        load = TRUE,
        new = FALSE
    ), output_file = paste0("sample_105086-009-002_lineages.html")
)
rmarkdown::render(
    input = paste0("02_scripts/lineage_annotation/per_sample/sample_2.rmd"),
    output_format = "html_document",
    output_dir = "/scratch_isilon/groups/singlecell/iborkus/Projects/brain_met/02_scripts/knits/lineage_annotation",
    params = list(
        sample = "105086-009-003",
        fullname = "Colon_BrM23-25",
        minUMI = 500,
        maxUMI = NA,
        minfeat = 300,
        maxfeat = 10000,
        maxmt = 25,
        res = "0.3",
        load = TRUE,
        new = FALSE
    ), output_file = paste0("sample_105086-009-003_lineages.html")
)
rmarkdown::render(
    input = paste0("02_scripts/lineage_annotation/per_sample/sample_3.rmd"),
    output_format = "html_document",
    output_dir = "/scratch_isilon/groups/singlecell/iborkus/Projects/brain_met/02_scripts/knits/lineage_annotation",
    params = list(
        sample = "105086-009-005",
        fullname = "Colon_BrM24-03",
        minUMI = 100,
        maxUMI = NA,
        minfeat = 100,
        maxfeat = 10000,
        maxmt = 20,
        res = "0.5",
        load = TRUE,
        new = FALSE
    ), output_file = paste0("sample_105086-009-005_lineages.html")
)
rmarkdown::render(
    input = paste0("02_scripts/lineage_annotation/per_sample/sample_4.rmd"),
    output_format = "html_document",
    output_dir = "/scratch_isilon/groups/singlecell/iborkus/Projects/brain_met/02_scripts/knits/lineage_annotation",
    params = list(
        sample = "105086-009-009",
        fullname = "Lung_BrM24-08",
        minUMI = 500,
        maxUMI = NA,
        minfeat = 300,
        maxfeat = 10000,
        maxmt = 25,
        res = "0.05",
        load = TRUE,
        new = FALSE
    ), output_file = paste0("sample_105086-009-009_lineages.html")
)
rmarkdown::render(
    input = paste0("02_scripts/lineage_annotation/per_sample/sample_5.rmd"),
    output_format = "html_document",
    output_dir = "/scratch_isilon/groups/singlecell/iborkus/Projects/brain_met/02_scripts/knits/lineage_annotation",
    params = list(
        sample = "105946-002-002",
        fullname = "Mel_BrM23-17",
        minUMI = 500,
        maxUMI = NA,
        minfeat = 300,
        maxfeat = 10000,
        maxmt = 20,
        res = "0.05",
        load = TRUE,
        new = FALSE
    ), output_file = paste0("sample_105946-002-002_lineages.html")
)
rmarkdown::render(
    input = paste0("02_scripts/lineage_annotation/per_sample/sample_6.rmd"),
    output_format = "html_document",
    output_dir = "/scratch_isilon/groups/singlecell/iborkus/Projects/brain_met/02_scripts/knits/lineage_annotation",
    params = list(
        sample = "105946-002-003",
        fullname = "Mel_BrM23-18-1",
        minUMI = 500,
        maxUMI = NA,
        minfeat = 300,
        maxfeat = 10000,
        maxmt = 20,
        res = "0.01",
        load = TRUE,
        new = FALSE
    ), output_file = paste0("sample_105946-002-003_lineages.html")
)

rmarkdown::render(
    input = paste0("02_scripts/lineage_annotation/per_sample/sample_7.rmd"),
    output_format = "html_document",
    output_dir = "/scratch_isilon/groups/singlecell/iborkus/Projects/brain_met/02_scripts/knits/lineage_annotation",
    params = list(
        sample = "105946-002-004",
        fullname = "Mel_BrM23-18-2",
        minUMI = 500,
        maxUMI = NA,
        minfeat = 300,
        maxfeat = 10000,
        maxmt = 20,
        res = "0.05",
        load = TRUE,
        new = FALSE
    ), output_file = paste0("sample_105946-002-004_lineages.html")
)
rmarkdown::render(
    input = paste0("02_scripts/lineage_annotation/per_sample/sample_8.rmd"),
    output_format = "html_document",
    output_dir = "/scratch_isilon/groups/singlecell/iborkus/Projects/brain_met/02_scripts/knits/lineage_annotation",
    params = list(
        sample = "105946-002-005",
        fullname = "Mel_BrM24-01",
        minUMI = 500,
        maxUMI = NA,
        minfeat = 300,
        maxfeat = 10000,
        maxmt = 20,
        res = "0.05",
        load = TRUE,
        new = FALSE
    ), output_file = paste0("sample_105946-002-005_lineages.html")
)
