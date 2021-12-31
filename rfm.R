## Resource Flow Model
##
##
## 1. 数据读取
##
## 该模型需要读入两张表
##
##   - 节点表格：包含网络的节点信息
##   - 边表格：包含网络的边信息
##
## 节点表格必须有一个 vid 字段，用于标识节点；边表格必须有 from、to
## 以及 dis 属性，分别用于表示边的开始、结束以及边的阻力。除去必要字
## 段外，两个表格可以包含其它字段。
##
## 读入节点表格与边表格分别使用函数 read_vtable 与 read_etable。默认
## 情况下程序认为边是无向的，会读取过程中会自动将边处理成有向的。若
## 原始文件中边便是有向的，read_etable 的 to_arc 参数为 FALSE。
##
## 原始数据的示例文件可参考 example 文件夹。
##
##
## 2. 数据结构
##
## 程序核心数据结构是三个数据框：
##
##   - 节点信息数据框
##   - 边信息数据框
##   - 状态数据框
##
## 节点信息数据框与边信息数据框直接由函数 read_vtable 与 read_etable
## 读取，状态数据框由 init_status_table 函数生成，update_s_table 函数
## 会读入三个数据框并一个节点更新函数 up_func，生成新的状态数据框。
##
##
## 3. 核心函数
##
## 整个算法的核心在于节点更新函数函数，该函数读入节点标识 vid（表示某
## 一个主体为于改节点）与节点数据信息、边数据信息与状态数据框，得到该
## 主体可能会前往的下一个节点。
##
## update_s_table 函数将节点更新函数应用于整个状态表，以生成下一个状
## 态表。



library(dplyr)
library(ggplot2)



## 读取节点
read_vtable <- function(csvfile){
    vtable <- read.csv(csvfile)
    stopifnot("vid" %in% colnames(vtable))
    return(vtable)
}


## 获取某个节点的某个属性
v_attr <- function(vtable, vid, field){
    stopifnot(vid %in% vtable$vid)
    stopifnot(field %in% names(vtable))
    return(vtable[vtable$vid == vid, field])
}


## 调换两个字符串
exchage_name <- function(nam, n1, n2){
    stopifnot(all(c(n1, n2) %in% nam))
    p <- 1:length(nam)
    n1p <- which(nam == n1)
    n2p <- which(nam == n2)
    p[n1p] <- n2p[1]
    p[n2p] <- n1p[1]
    return(nam[p])
}


## 读取列表清单
read_etable <- function(csvfile, to_arc = TRUE){
    elist <- read.csv(csvfile)
    stopifnot(all(c("from", "to", "dis") %in% colnames(elist)))
    if(to_arc){
        elist2 <- elist
        colnames(elist2) <- exchage_name(
            colnames(elist), "from", "to")
        return(bind_rows(elist, elist2))
    } else {
        return(elist)
    }
}


## 获取边的阻力
e_dis <- function(from, to, etable){
    return(etable$dis[etable$from == from & etable$to == to])
}


## 给每个节点安排一定数量的
init_status_table <- function(vtable, anum){
    vids <- vtable$vid
    if(length(anum) == 1){
        anum <- rep(anum, length(vids))
    } else {
        stopifnot(length(vids) == length(anum))
    }
    vids = rep(vids, anum)
    return(data.frame(
        aid = 1:length(vids),
        vid = vids,
        time = 1))
}


## 计算节点 vid 中的主体个数
count_agent <- function(vid, s_table){
    return(sum((s_table$vid == vid)))
}


## 获取邻域
neigbor <- function(vid, etable){
    return(etable$to[etable$from == vid])
}


##------------------------------------------------------------------
## 算法核心


## 计算 vid1 对 vid2 的引力
cal_attraction <- function(vid1, vid2, vtable, etable, s_table){
    c1 <- count_agent(v1, s_table)
    c2 <- count_agent(v2, s_table)
    dis <- e_dis(vid1, vid2, etable)
    return(1/(dis*dis))
}


## 状态更新函数
update_v_status <- function(vid, vtable, etable, s_table, ua = 0.3){
    nei <- neigbor(vid, etable)
    if(length(nei) == 0) {
        return(vid)
    } else if (length(nei) == 1){
        to_vid <- nei
    } else {
        prob <- sapply(nei, function(x) {
            cal_attraction(x, vid, vtable, etable, s_table)})
        to_vid <- sample(nei, 1, prob = prob/sum(prob)) # 轮盘赌
    }
    res <- sample(c(vid, to_vid), 1, prob = c(0.95, 0.05))
    if(sample(c(TRUE, FALSE),1,prob=c(ua, 1 - ua))){
        return(update_v_status(to_vid, vtable,
                               etable, s_table, ua*0.6))
    }
    return(res)
}


## 更新表格
update_s_table <- function(s_table,
                           vtable,
                           etable,
                           up_func = update_v_status){
    time <- s_table[1,3] + 1
    res <- t(sapply(1:nrow(s_table), function(row){
        c(s_table$aid[row],
          up_func(s_table$vid[row], vtable, etable, s_table),
          time)}))
    res <- as.data.frame(res)
    colnames(res) <- colnames(s_table)
    return(res)
}


## 控制模拟
main_simulate <- function(init_table,
                          vtable,
                          etable,
                          up_func = update_v_status,
                          times = 1000){
    res <- list()
    res[[1]] <- init_table
    for(time in 2:(times + 1)){
        res[[time]] <- update_s_table(res[[time-1]], vtable, etable,
                                      up_func)
        cat(time, "\n")
    }
    return(bind_rows(res))
}


##------------------------------------------------------------------
## 模拟结果输出


## 将 main_simulate 生成的结果输出
plot_simulate <- function(simulate_res, outdir, all = FALSE){
    if(all){
        ivids <- unique(simulate_res$vid)
        tis <- unique(simulate_res$time)
    } else {
        ivids <- simulate_res$vid[length(simulate_res$vid)]
        tis <- simulate_res$ti[length(simulate_res$time)]
    }
    for(ivid in ivids){
        p1 <- simulate_res %>%
            filter(ivid == vid) %>%
            ggplot() +
            geom_histogram(aes(x = time))
        ggsave(file.path(outdir,
                         paste("fig_vid", ivid, ".png", sep = "")),
               p1)
    }
    for(ti in tis){
        p1 <- simulate_res %>%
            filter(ti == time) %>%
            ggplot() +
            geom_histogram(aes(x = vid)) +
            scale_x_continuous(breaks= sort(ivids))
        ggsave(file.path(outdir,
                         paste("fig_time", ti, ".png", sep = "")),
               p1)
    }
}
