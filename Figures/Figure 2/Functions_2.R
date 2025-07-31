volcano_plotting <- function(marker_list, ident.1 = "", ident.2 = "", p_stat = "p_val") {
    marker_list$genes <- row.names(marker_list)
    marker_list$diffexpressed <- "NO"
    marker_list$diffexpressed[marker_list$avg_log2FC > 1.5 & marker_list[[p_stat]] < 0.05] <- "UP"
    marker_list$diffexpressed[marker_list$avg_log2FC < -1.5 & marker_list[[p_stat]] < 0.05] <- "DOWN"
    marker_list$diffexpressed[marker_list$avg_log2FC > 1.5 & marker_list[[p_stat]] < 0.05] <- "UP"
    marker_list$diffexpressed[marker_list$avg_log2FC < -1.5 & marker_list[[p_stat]] < 0.05] <- "DOWN"
    # marker_list$delabel <- NA
    # marker_list$delabel[marker_list$diffexpressed != "NO"] <- row.names(marker_list)[marker_list$diffexpressed != "NO"]
    marker_list$delabel <- NA
    marker_list$delabel[marker_list$diffexpressed != "NO"] <- row.names(marker_list)[marker_list$diffexpressed != "NO"]
    marker_list %>%
        arrange(desc(avg_log2FC)) %>%
        dplyr::select(avg_log2FC) %>%
        head(, n = 15) %>%
        row.names() -> labels_1
    marker_list %>%
        arrange(avg_log2FC) %>%
        dplyr::select(avg_log2FC) %>%
        head(, n = 15) %>%
        row.names() -> labels_2
    labels <- c(labels_1, labels_2)
    marker_list$delabel <- NA
    marker_list$delabel[marker_list$genes %in% labels] <- marker_list$genes[marker_list$genes %in% labels]
    min_above <- min(marker_list[[p_stat]][marker_list[[p_stat]] > 0])
    marker_list[[p_stat]] <- ifelse(marker_list[[p_stat]] == 0, min_above, marker_list[[p_stat]])
    volcano_plot <- ggplot(data = marker_list, aes(x = avg_log2FC, y = -log10(!!sym(p_stat)), col = diffexpressed, label = delabel)) +
        geom_point() +
        geom_text_repel(max.overlaps = Inf) +
        scale_color_manual(values = c("blue", "black", "red")) +
        geom_vline(xintercept = c(-1.5, 1.5), col = "red") +
        geom_hline(yintercept = -log10(0.05), col = "red") & labs(title = paste0("Comparing: ", ident.1, " versus the ", ident.2))
    return(volcano_plot)
}


# library(writexl)
excel_sheet <- function(markers, output_dir, name) {
    library(writexl)
    print(paste0("Output will be put in: ", output_dir, name, ".xlsx"))
    if (file.exists(output_dir)) {
        markers %>%
            arrange(cluster, desc(avg_log2FC)) %>% # Arrange within each cluster
            group_by(cluster) %>%
            select(cluster, pct.1, pct.2, p_val, p_val_adj, avg_log2FC, gene) %>%
            group_split() %>% # Split into list by 'cluster'
            setNames(unique(markers$cluster)) %>% # Name list elements
            writexl::write_xlsx(paste0(output_dir, name, ".xlsx"))
    } else {
        stop("Directory does not exist")
    }
}
# output_excel <- "03_processing/14_phase_7/data/regress_excel/"
extract_ranks <- function(marker_list, cut_off_fc = 1.5, cut_off_p = 0.05, n = NULL, kegg = NULL) {
    marker_list$genes <- row.names(marker_list)
    marker_list %>%
        filter(p_val_adj < cut_off_p) %>%
        arrange(desc((avg_log2FC))) %>%
        filter(abs(avg_log2FC) > cut_off_fc) %>%
        dplyr::select(avg_log2FC) -> fold_change
    fold_change %>% arrange(desc(abs(avg_log2FC))) -> inter
    if (!is.null(n)) {
        inter$genes <- row.names(inter)
        fold_change <- inter[1:n, ]
        ranks <- fold_change$avg_log2FC
        names(ranks) <- row.names(fold_change)
        ranks <- sort(ranks, decreasing = TRUE)
    } else {
        ranks <- fold_change$avg_log2FC
        names(ranks) <- row.names(fold_change)
    }

    if (!is.null(kegg)) {
        print("doing Kegg list")
        ids <- bitr(names(ranks), fromType = "SYMBOL", toType = "ENTREZID", OrgDb = organism)
        dedup_ids <- ids[!duplicated(ids[c("SYMBOL")]), ]
        fold_change$X <- row.names(fold_change)
        # print(fold_change$X %>% head())
        # print(dedup_ids$SYMBOL %>% head())

        df2 <- fold_change[fold_change$X %in% dedup_ids$SYMBOL, ]
        df2$Y <- dedup_ids$ENTREZID
        # print(df2 %>% head())

        kegg_gene_list <- df2$avg_log2FC
        names(kegg_gene_list) <- df2$Y
        kegg_gene_list <- na.omit(kegg_gene_list)
        kegg_gene_list <- sort(kegg_gene_list, decreasing = TRUE)
        return(kegg_gene_list)
    } else {
        return(ranks)
    }
}


plot_gsea_pathways <- function(fgseaRes_obj, pathways_fgsea, rank_list, number = 10) {
    topPathwaysUp <- fgseaRes_obj[ES > 0][head(order(pval), n = number), pathway]
    topPathwaysDown <- fgseaRes_obj[ES < 0][head(order(pval), n = number), pathway]
    topPathways <- c(topPathwaysUp, rev(topPathwaysDown))
    plot(plotGseaTable(pathways_fgsea[topPathways], rank_list, fgseaRes_obj,
        gseaParam = 0.5
    ))
}
