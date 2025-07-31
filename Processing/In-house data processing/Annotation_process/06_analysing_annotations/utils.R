group1 <- c("Bad-Quality", "Doublets")
group2 <- c("Tnaive_b1", "Texh_CD8_b", "Tnaive_b2", "Proliferating_CD8_1b", "Tregs_b", "Proliferating_CD8_2b", "Teff_CD8_b")
group3 <- c("Proliferating_CD8_1a", "Tnaive", "Texterm_CD8", "Th_cells", "Teff_exh_CD8", "Teff_CD8", "Proliferating_CD4", "Tem_CD8", "Tregs_memory", "Proliferating_CD8_2a", "Tregs_CCR8", "GD_NKT_CD8", "Proliferating_CD8_gd", "NK", "IFN_response", "Tactive")
group4 <- c("Monocytes", "Macrophages", "Neutrophils", "Macrophage_OTOA", "CD1CA+_A", "Monocytic_MDSCs", "Microglia", "pDCs", "Macrophage_SPP1", "cDC1", "mregDCs")
group5 <- c("PlasmaCells", "Bcells")


cols1 <- c("#2c2c2c", "#595959")
cols2 <- c("#006400", "#1b5e20", "#004d00", "#2e7d32", "#33691e", "#1a472a", "#0b3d02")
cols3 <- c("#7fc97f", "#a6d854", "#66c2a5", "#b2df8a", "#8bc34a", "#aed581", "#9ccc65", "#c5e1a5", "#76c893", "#cdeac0", "#80cbc4", "#c1f0dc", "#a5d6a7", "#b9fbc0", "#dcedc1", "#d0f0c0")
cols4 <- c("#e67e22", "#f39c12", "#ff9800", "#ffa726", "#fb8c00", "#ef6c00", "#f57c00", "#ffb74d", "#ff8f00", "#ff7043", "#ffcc80")
cols5 <- c("#4a90e2", "#005b96")

color_panel_1 <- c(
    setNames(cols1, group1),
    setNames(cols2, group2),
    setNames(cols3, group3),
    setNames(cols4, group4),
    setNames(cols5, group5)
)
barplot(rep(1, length(color_panel_1)), col = color_panel_1, names.arg = names(color_panel_1), las = 2)
### OLD
####
# This file contains instructions to determine

# seurat_obj@meta.data$ann_lvl_2 %>% levels()
# pal.cluster(alphabet2(), n = 3,main="alphabet2")
# pal.cluster()




palette_lvl_1 <- c(
    "#4a90e2", # Lymphoid - softened blue
    "#f39c12", # Myeloid - softened orange
    "#2c2c2c" # Other - dark gray (distinct)
)

palette_lvl_2 <- c(
    "#43a843", # Tcells - green
    "#A8E6A1", # NK - deeper blue
    "#7fb3d5", # Bcells - softened blue

    "#f39c12", # Macrophage - softened orange
    "#f5a623", # Microglia - light orange
    "#e67e22", # Monocyte - burnt orange
    "#f7c85b", # Neutrophil - very light orange
    "#e74c3c", # DC - soft red/orange
    "#2c2c2c" # Other - dark gray (distinct)
)

palette_lvl_3 <- c(
    "#43a843", # Tcells - green
    "#2E8B57", # CD8 - softened blue
    "#66FF66", # CD4 - light blue
    "#4CAF50", # Treg - very light blue
    "#A8E6A1", # NK - same darker blue
    "#7fb3d5", # Bcells - same light blue
    "#d5e1f1", # Plasmacells - pale blue
    "#f39c12", # Macrophage - same as above
    "#f5a623", # Microglia - same
    "#e67e22", # Monocyte - same
    "#f7c85b", # Neutrophil - same
    "#e74c3c", # DC - same
    "#2c2c2c" # Other - same dark gray
)
