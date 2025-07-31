library(Seurat)
library(here)
library(dplyr)
library(ggplot2)
library(readr)
library(purrr)
library(tibble)
library(tidyr)
# library(paletteer)
library(ggrepel)
library(gridExtra)
library(DoubletFinder)
library(clustree)
library(knitr)
library(rscrublet)
library(Matrix)
library(patchwork)
library(harmony)
library(lisi)

nejm_colors <- paletteer::paletteer_d(
    "ggsci::default_nejm", length(levels(as.factor(meta_data$sample_fullname)))
)
primary_colors <- c("#66c2a5", "#fc8d62", "#8da0cb", "#e78ac3")
primary_colors_sample <- c("#66c2a5", "#fc8d62", "#fc8d62", "#8da0cb", "#e78ac3", "#e78ac3", "#e78ac3", "#e78ac3")
primary <- c("CUP", "Colon", "Colon", "Lung", "Melanoma", "Melanoma", "Melanoma", "Melanoma")
primary_sample <- c("CUP", "Colon_1", "Colon_2", "Lung", "Melanoma_1_sorted", "Melanoma_2_sorted", "Melanoma_2_unsorted", "Melanoma_3_unsorted")



merge_list_seurat <- function(seurat_list) {
    meta_data <- read.csv(here("03_processing/01_QC/data/meta_data.csv"))
    sample_ids <- meta_data$sample_fullname
    seurat_obj_list <- map(sample_ids, function(id) {
        index <- match(id, sample_ids)
        seurat_obj <- seurat_list[[index]]
        seurat_obj$sample <- id
        seurat_obj
    })
    names(seurat_obj_list) <- sample_ids
    seurat_obj <- merge(seurat_obj_list[[1]],
        y = seurat_obj_list[2:length(seurat_obj_list)],
        add.cell.ids = sample_ids
    )
    return(seurat_obj)
}
umap_sample <- function(seurat_obj, reduction_name, title_name) {
    umap_by_sample <- DimPlot(
        object = seurat_obj,
        reduction = reduction_name,
        group.by = "sample",
        pt.size = 0.1,
        label = F, cols = nejm_colors
    ) & theme(plot.title = element_text(size = 10)) &
        NoAxes() & labs(title = title_name)
}
umap_feature_vec <- c(
    "PTPRC", # Immune
    "TOP2A", "MKI67", "STMN1", # Proliferative
    ## Lymphoid
    "CD3D", "CD3E", # T cells
    "CD4", "CD8A", "CD8B", # distinction between 4 and 8
    "FOXP3", "IL2RA", # T regs
    "TOX", # Tfh cell
    "NCAM1", "KLRF1", # NK cells
    "MS4A1", "CD79A", # B cells
    # "TCL1A", # Naive B cells
    # "BANK1", "BLK", # Memory/ activated B cells
    "SDC1", "PRDM1", # Plasma cells
    ## Myeloid
    "S100A8", "CD14", # Monocytes
    "CD163", "CD68", # Macrophage markers
    "P2RY12", "SLC2A5", # microglia
    "IL3RA", # pDCs
    "CD1C", # DCs
    "MAG", "MLANA" # other cells
)

Running_plots <- function(seurat_obj, reduction_name) {
    PCA_elbow <- ElbowPlot(seurat_obj, reduction = paste0("pca_", reduction_name))
    Genes_influence_PCA <- VizDimLoadings(seurat_obj,
        dims = 1:5, reduction = paste0("pca_", reduction_name), nfeatures = 15
    )
    ggsave(PCA_elbow, filename = paste0(output_figs, reduction_name, "_PCA_elbow.png"))
    ggsave(Genes_influence_PCA, filename = paste0(output_figs, reduction_name, "_PCA_loadings.png"))


    resolution_columns <- grep("^RNA_snn_res\\.",
        colnames(seurat_obj@meta.data),
        value = TRUE
    )

    umap_resolution_combined <- DimPlot(
        object = seurat_obj,
        reduction = paste0("umap.", reduction_name),
        group.by = resolution_columns,
        pt.size = 0.1,
        label = TRUE
    ) & NoLegend() &
        theme(plot.title = element_text(size = 10)) &
        NoAxes() # & labs(title = paste0("Data: ", reduction_name, " plot of resolutions "))
    ggsave(umap_resolution_combined, file = paste0(output_figs, reduction_name, "_umap_res.png"))


    features <- FeaturePlot(seurat_obj,
        features = umap_feature_vec,
        reduction = paste0("umap.", reduction_name),
        ncol = 3, order = TRUE
    ) & NoAxes() # & labs(title = paste0("Data: ", reduction_name, " plot of features "))
    ggsave(features, file = paste0(output_figs, reduction_name, "_Umap_features.png"), width = 18, height = 20)


    umap_by_sample <- DimPlot(
        object = seurat_obj,
        reduction = paste0("umap.", reduction_name),
        group.by = "sample",
        pt.size = 0.5,
        label = F, cols = nejm_colors
    ) & theme(plot.title = element_text(size = 10)) &
        NoAxes() & labs(title = paste0("Data: ", reduction_name, " plot of samples"))
    ggsave(umap_by_sample, file = paste0(output_figs, reduction_name, "_Umap_sample.png"), height = 20, width = 20)

    # umap_by_primary <- DimPlot(
    #     object = seurat_obj,
    #     reduction = paste0("umap.", reduction_name),
    #     group.by = "primary",
    #     pt.size = 0.1,
    #     label = F, cols = primary_colors,
    # ) & theme(plot.title = element_text(size = 10)) &
    #     NoAxes() & labs(title = paste0("Data: ", reduction_name, " plot of primary"))
    # ggsave(umap_by_primary, file = paste0(output_figs, reduction_name, "_Umap_primary.png"), height = 20, width = 20)

    umap_by_sample_primary <- DimPlot(
        object = seurat_obj,
        reduction = paste0("umap.", reduction_name),
        group.by = "sample",
        pt.size = 0.5,
        label = F, cols = primary_colors_sample,
    ) & theme(plot.title = element_text(size = 10)) &
        NoAxes() & labs(title = paste0("Data: ", reduction_name, " plot of sample/primary"))
    ggsave(umap_by_sample_primary, file = paste0(output_figs, reduction_name, "_Umap_sample_primary.png"), height = 20, width = 20)


    umap_by_annotation <- DimPlot(
        object = seurat_obj,
        reduction = paste0("umap.", reduction_name),
        group.by = "general_annotation",
        pt.size = 0.1,
        label = T,
    ) & theme(plot.title = element_text(size = 10)) &
        NoAxes() & labs(title = paste0("Data: ", reduction_name, " plot of annotation"))
    ggsave(umap_by_annotation, file = paste0(output_figs, reduction_name, "_Umap_annotation.png"), height = 20, width = 20)

    if (reduction_name == "merged_subset_immune") {
        print("This is the immune subset")
        umap_by_annotation <- DimPlot(
            object = seurat_obj,
            reduction = paste0("umap.", reduction_name),
            group.by = "specific_annotation_immune",
            pt.size = 0.1,
            label = T,
        ) & theme(plot.title = element_text(size = 10)) & labs(title = paste0("Data: ", reduction_name, " plot of specific immune annotation")) & NoAxes()
        ggsave(umap_by_annotation, file = paste0(output_figs, reduction_name, "_Umap_specific_annotation.png"), height = 20, width = 20)
    } else {
        print("this is not an immune subset")
        print(reduction_name)
    }
}




Running_plots_post_harmony <- function(seurat_obj, reduction_name) {
    PCA_elbow <- ElbowPlot(seurat_obj, reduction = paste0("pca_", reduction_name), ndims = 50)
    Genes_influence_PCA <- VizDimLoadings(seurat_obj,
        dims = 1:5, reduction = paste0("pca_", reduction_name), nfeatures = 15
    )
    PCA_elbow
    Genes_influence_PCA
    ggsave(PCA_elbow, filename = paste0(output_figs, reduction_name, "_PCA_elbow.png"), width = 10, height = 10)
    ggsave(Genes_influence_PCA, filename = paste0(output_figs, reduction_name, "_PCA_loadings.png"), width = 20, height = 20)


    resolution_columns <- grep("^RNA_snn_res\\.",
        colnames(seurat_obj@meta.data),
        value = TRUE
    )
    umap_resolution_combined <- DimPlot(
        object = seurat_obj,
        reduction = paste0("umap.harmony.", reduction_name),
        group.by = resolution_columns,
        pt.size = 0.1,
        label = TRUE
    ) & NoLegend() &
        theme(plot.title = element_text(size = 10)) &
        NoAxes() # & labs(title = paste0("Data: ", reduction_name, " plot of resolutions "))
    print(umap_resolution_combined)
    ggsave(umap_resolution_combined, file = paste0(output_figs, reduction_name, "_harmony_res.png"))


    features <- FeaturePlot(seurat_obj,
        features = umap_feature_vec,
        reduction = paste0("umap.harmony.", reduction_name),
        ncol = 3, order = TRUE
    ) & NoAxes() # & labs(title = paste0("Data: ", reduction_name, " plot of features "))
    print(features)
    ggsave(features, file = paste0(output_figs, reduction_name, "_harmony_features.png"), width = 18, height = 20)


    umap_by_sample <- DimPlot(
        object = seurat_obj,
        reduction = paste0("umap.harmony.", reduction_name),
        group.by = "sample",
        pt.size = 0.1,
        label = F, cols = nejm_colors
    ) & theme(plot.title = element_text(size = 10)) &
        NoAxes() & labs(title = paste0("Data: ", reduction_name, " plot of samples"))
    print(umap_by_sample)
    ggsave(umap_by_sample, file = paste0(output_figs, reduction_name, "_harmony_samples.png"), height = 20, width = 20)
    # umap_by_sample_primary <- DimPlot(
    #     object = seurat_obj,
    #     reduction = paste0("umap.harmony.", reduction_name),
    #     group.by = "sample",
    #     pt.size = 0.1,
    #     label = F, cols = primary_colors_sample,
    # ) & theme(plot.title = element_text(size = 10)) &
    #     NoAxes() & labs(title = paste0("Data: ", reduction_name, " plot of sample/primary"))
    # ggsave(umap_by_sample_primary, file = paste0(output_figs, reduction_name, "_harmony_samples_primary.png"), height = 20, width = 20)
    print(DimPlot(
        object = seurat_obj,
        reduction = paste0("umap.harmony.", reduction_name),
        group.by = "specific_annotation_immune",
        pt.size = 0.1,
        label = T,
    ) & theme(plot.title = element_text(size = 10)))
    if (reduction_name == "merged_subset_immune") {
        print("This is the immune subset")
        umap_by_annotation <- DimPlot(
            object = seurat_obj,
            reduction = paste0("umap.harmony.", reduction_name),
            group.by = "specific_annotation_immune",
            pt.size = 0.1,
            label = T,
        ) & theme(plot.title = element_text(size = 10)) & labs(title = paste0("Data: ", reduction_name, " plot of specific immune annotation")) & NoAxes()
        ggsave(umap_by_annotation, file = paste0(output_figs, reduction_name, "_harmony_specific_annotation.png"), height = 20, width = 20)
    } else {
        print("this is not an immune subset")
        print(reduction_name)
    }
}
