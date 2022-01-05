## 示例

source("./rfm.R")


for(i in 1:12){
    vlist_path <- file.path("./example",
                            paste("vlist", i, ".csv", sep = ""))
    elist_path <- file.path("./example",
                            paste("elist", i, ".csv", sep = ""))
    outimg_path <- file.path(".", paste("img", i, sep = ""))
    vtable <- read_vtable(vlist_path)
    etable <- read_etable(elist_path)
    table1 <- init_status_table(vtable, 800)
    res <- main_simulate(table1, vtable, etable,
                         update_v_status, 500)
    plot_simulate(res, outimg_path, all = FALSE)
}
