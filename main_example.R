## 示例

library(ggplot2)


source("./rfm.R")


vtable <- read_vtable("./example/vlist1.csv")
etable <- read_etable("./example/elist1.csv")
table1 <- init_status_table(vtable, 100)


res <- main_simulate(table1, vtable, etable,
                     update_v_status, 100)


### 可视化每一个 vid 的历史变化趋势
for(ivid in unique(res$vid)){
    p1 <- res %>%
        filter(ivid == vid) %>%
        ggplot() +
        geom_histogram(aes(x = time))
    ggsave(file.path("./img/",
                     paste("fig_vid", ivid, ".png", sep = "")),
           p1)
}


### 可视化每个时间的截面
for(ti in unique(res$time)){
    p1 <- res %>%
        filter(ti == time) %>%
        ggplot() +
        geom_histogram(aes(x = vid))
    ggsave(file.path("./img/",
                     paste("fig_time", ti, ".png", sep = "")),
           p1)
}
