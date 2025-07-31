QC_plot <- function(seurat_obj, sample_col, n_samp = NULL, name = NULL, minUMI = NULL, maxUMI = NULL, minfeat = NULL, maxfeat = NULL, maxmt = NULL) {
    print(seurat_obj)
    print(sample_col)
    # print(n_samp)
    qc_count_line <- VlnPlot(seurat_obj,
        features = c("nCount_RNA"),
        log = FALSE,
        group.by = sample_col,
        # cols = rep(dataset_colors[[name]], n_samp),
        pt.size = 0
    ) + # & geom_hline(yintercept = minUMI, color = "red") &
        #   geom_hline(yintercept = maxUMI, color = "red")
        theme(axis.text.x = element_blank(), plot.title = element_blank())
    # print(qc_count_line)
    qc_feature_line <- VlnPlot(seurat_obj,
        features = c("nFeature_RNA"),
        log = FALSE,
        group.by = sample_col,
        # cols = rep(dataset_colors[[name]], n_samp),
        pt.size = 0
    ) + theme(axis.text.x = element_blank(), plot.title = element_blank()) +
        # geom_hline(yintercept = minfeat, color = "red") +
        # geom_hline(yintercept = maxfeat, color = "red") &
        NoLegend()
    # print(qc_feature_line)
    qc_mt_line <- VlnPlot(seurat_obj,
        features = c("percent_mt"),
        group.by = sample_col,
        log = FALSE,
        # cols = rep(dataset_colors[[name]], n_samp),
        pt.size = 0
    ) + theme(axis.text.x = element_blank(), plot.title = element_blank()) +
        # geom_hline(yintercept = maxmt, color = "red") &
        NoLegend()
    # print(qc_mt_line)

    hist_count_line <- ggplot(
        data = seurat_obj@meta.data,
        mapping = aes(x = nCount_RNA)
    ) +
        geom_density(fill = "skyblue") +
        labs(title = "Distribution of of UMI count in cells") +
        # geom_vline(xintercept = minUMI, color = "red") +
        # geom_vline(xintercept = maxUMI, color = "red") +
        theme_minimal() +
        scale_x_log10()
    # print(hist_count_line)

    hist_feat_line <- ggplot(
        data = seurat_obj@meta.data,
        mapping = aes(x = nFeature_RNA)
    ) +
        geom_density(fill = "skyblue") +
        labs(title = "Distribution of unique genes in cells") +
        # geom_vline(xintercept = minfeat, color = "red") +
        # geom_vline(xintercept = maxfeat, color = "red") +
        theme_minimal() +
        scale_x_log10()
    # print(hist_feat_line)

    hist_mt_line <- ggplot(
        data = seurat_obj@meta.data,
        mapping = aes(x = percent_mt)
    ) +
        geom_density(fill = "skyblue") +
        labs(title = "Distribution of MT percentage in cells") +
        # geom_vline(xintercept = maxmt, color = "red") +
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
