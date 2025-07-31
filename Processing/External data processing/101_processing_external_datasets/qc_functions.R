filters_seurat <- function(seurat_obj) {
    print(seurat_obj)
    minUMI <- 100
    maxUMI <- NA
    minfeat <- 100
    maxfeat <- 10000
    maxmt <- 25

    minUMI <- ifelse(is.na(minUMI), min(seurat_obj@meta.data$nCount_RNA), minUMI)
    maxUMI <- ifelse(is.na(maxUMI), max(seurat_obj@meta.data$nCount_RNA), maxUMI)
    minfeat <- ifelse(is.na(minfeat), min(seurat_obj@meta.data$nFeature_RNA), minfeat)
    maxfeat <- ifelse(is.na(maxfeat), max(seurat_obj@meta.data$nFeature_RNA), maxfeat)
    maxmt <- ifelse(is.na(maxmt), max(seurat_obj@meta.data$percent_mt), maxmt)
    actual_min_UMI <- min(seurat_obj@meta.data$nCount_RNA)
    actual_max_UMI <- max(seurat_obj@meta.data$nCount_RNA)
    actual_min_features <- min(seurat_obj@meta.data$nFeature_RNA)
    actual_max_features <- max(seurat_obj@meta.data$nFeature_RNA)
    actual_max_mito <- max(seurat_obj@meta.data$percent_mt)

    if (minUMI < actual_min_UMI) {
        warning(paste("minUMI is lower than the actual minimum value. Adjusting minUMI to", actual_min_UMI))
        minUMI <- actual_min_UMI
    }


    if (maxUMI > actual_max_UMI) {
        warning(paste("maxUMI is greater than the actual maximum value. Adjusting maxUMI to", actual_max_UMI))
        maxUMI <- actual_max_UMI
    }

    if (minfeat < actual_min_features) {
        warning(paste("minfeat is lower than the actual minimum feature count. Adjusting minFeatures to", actual_min_features))
        minfeat <- actual_min_features
    }


    if (maxfeat > actual_max_features) {
        warning(paste("maxfeat is higher than the actual maximum feature count. Adjusting maxfeat to", actual_max_features))
        maxfeat <- actual_max_features
    }

    if (maxmt > actual_max_mito) {
        warning(paste("maxmt is higher than the actual maximum mitochondrial %. Adjusting maxmt to", actual_max_mito))
        maxmt <- actual_max_mito
    }
    return(list(minUMI, maxUMI, minfeat, maxfeat, maxmt))
}


dataset_colors <- c(
    "Biermann" = "#E41A1C", # Red
    "Gonzalez" = "#377EB8", # Blue
    "Lee"      = "#4DAF4A" # Green
)
QC_plot <- function(seurat_obj, sample_col, n_samp, name, minUMI, maxUMI, minfeat, maxfeat, maxmt) {
    print(seurat_obj)
    print(sample_col)
    print(n_samp)
    print(name)
    qc_count_line <- VlnPlot(seurat_obj,
        features = c("nCount_RNA"),
        log = FALSE,
        group.by = sample_col,
        cols = rep(dataset_colors[[name]], n_samp),
        pt.size = 0
    ) & geom_hline(yintercept = minUMI, color = "red") &
        geom_hline(yintercept = maxUMI, color = "red")
    theme(axis.text.x = element_blank(), plot.title = element_blank())
    # print(qc_count_line)
    qc_feature_line <- VlnPlot(seurat_obj,
        features = c("nFeature_RNA"),
        log = FALSE,
        group.by = sample_col,
        cols = rep(dataset_colors[[name]], n_samp),
        pt.size = 0
    ) + theme(axis.text.x = element_blank(), plot.title = element_blank()) +
        geom_hline(yintercept = minfeat, color = "red") +
        geom_hline(yintercept = maxfeat, color = "red") &
        NoLegend()
    # print(qc_feature_line)
    qc_mt_line <- VlnPlot(seurat_obj,
        features = c("percent_mt"),
        group.by = sample_col,
        log = FALSE,
        cols = rep(dataset_colors[[name]], n_samp),
        pt.size = 0
    ) + theme(axis.text.x = element_blank(), plot.title = element_blank()) +
        geom_hline(yintercept = maxmt, color = "red") &
        NoLegend()
    # print(qc_mt_line)

    hist_count_line <- ggplot(
        data = seurat_obj@meta.data,
        mapping = aes(x = nCount_RNA)
    ) +
        geom_density(fill = dataset_colors[[name]]) +
        labs(title = "Distribution of of UMI count in cells") +
        geom_vline(xintercept = minUMI, color = "red") +
        geom_vline(xintercept = maxUMI, color = "red") +
        theme_minimal() +
        scale_x_log10()
    # print(hist_count_line)

    hist_feat_line <- ggplot(
        data = seurat_obj@meta.data,
        mapping = aes(x = nFeature_RNA)
    ) +
        geom_density(fill = dataset_colors[[name]]) +
        labs(title = "Distribution of unique genes in cells") +
        geom_vline(xintercept = minfeat, color = "red") +
        geom_vline(xintercept = maxfeat, color = "red") +
        theme_minimal() +
        scale_x_log10()
    # print(hist_feat_line)

    hist_mt_line <- ggplot(
        data = seurat_obj@meta.data,
        mapping = aes(x = percent_mt)
    ) +
        geom_density(fill = dataset_colors[[name]]) +
        labs(title = "Distribution of MT percentage in cells") +
        geom_vline(xintercept = maxmt, color = "red") +
        theme_minimal() +
        scale_x_log10()
    # print(hist_mt_line)
    grob_plot <- gridExtra::arrangeGrob(
        hist_count_line, qc_count_line,
        hist_feat_line, qc_feature_line,
        hist_mt_line, qc_mt_line,
        ncol = 2, nrow = 3
    )
    return(grob_plot)
}


scrublet <- function(seurat_obj) {
    count_matrix <- t(as(seurat_obj@assays$RNA$counts, "TsparseMatrix"))
    # print(count_matrix[1:2, 1:3])
    scrr <- scrub_doublets(E_obs = count_matrix, expected_doublet_rate = 0.06, min_counts = 2, min_cells = 3, min_gene_variability_pctl = 85, n_prin_comps = 30)
    scrr <- call_doublets(scrr)
    # plot_doublet_histogram(scrr)
    seurat_obj$doublet.score <- scrr$doublet_scores_obs
    seurat_obj$predicted.doublets <- scrr$predicted_doublets
    # print(FeaturePlot(seurat_obj, features = "doublet.score", cols = c("gray", "red")))
    return(seurat_obj)
}
umi_plot <- function(seurat_obj, sample_col, n_samp, name, minUMI, maxUMI, minfeat, maxfeat, maxmt) {
    umi_v_mt_lines <- ggplot(
        data = seurat_obj@meta.data,
        mapping = aes(x = nCount_RNA, y = percent_mt, fill = sample_col)
    ) +
        geom_point() +
        geom_hline(yintercept = maxmt, color = "red") +
        geom_vline(xintercept = minUMI, color = "red") +
        geom_vline(xintercept = maxUMI, color = "red") +
        scale_x_log10() +
        labs(
            x = "UMI count", y = "Mitochondrial %"
        )



    umi_v_genes_mt_col <- ggplot(
        data = seurat_obj@meta.data,
        mapping = aes(
            x = nCount_RNA, y = nFeature_RNA,
            color = percent_mt,
            size = percent_mt
        )
    ) +
        geom_point() +
        geom_hline(yintercept = minfeat, color = "red") +
        geom_hline(yintercept = maxfeat, color = "red") +
        geom_vline(xintercept = minUMI, color = "red") +
        geom_vline(xintercept = maxUMI, color = "red") +
        scale_x_log10() +
        scale_y_log10() +
        labs(
            x = "UMI count", y = "Unique genes"
        )

    umi_v_genes_doublet_col <- ggplot(
        data = seurat_obj@meta.data,
        mapping = aes(
            x = nCount_RNA, y = nFeature_RNA,
            color = doublet.score,
            size = doublet.score
        )
    ) +
        geom_point() +
        geom_hline(yintercept = minfeat, color = "red") +
        geom_hline(yintercept = maxfeat, color = "red") +
        geom_vline(xintercept = minUMI, color = "red") +
        geom_vline(xintercept = maxUMI, color = "red") +
        scale_x_log10() +
        scale_y_log10() +
        labs(
            x = "UMI count", y = "Unique genes"
        )
    grob_plot <- gridExtra::arrangeGrob(
        umi_v_genes_mt_col + labs(title = paste0("Sample: ", name, " UMI count vs MT percentage")),
        umi_v_genes_doublet_col + labs(title = paste0("Sample: ", name, " UMI count vs unique gene count in cells coloured by scrublet-score")),
        umi_v_mt_lines + labs(title = paste0("Sample: ", name, " UMI count vs unique gene count in cells")),
        ncol = 2, nrow = 2
    )
    return(grob_plot)
}
