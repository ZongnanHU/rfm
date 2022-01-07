## 示例

source("./rfm.R")

s <- Sys.time()
for(i in 1:1){
    vlist_path <- file.path("./example",
                            paste("vlist", i, ".csv", sep = ""))
    elist_path <- file.path("./example",
                            paste("elist", i, ".csv", sep = ""))
    outimg_path <- file.path(".", paste("img", i, sep = ""))
    vtable <- read_vtable(vlist_path)
    etable <- read_etable(elist_path)
    table1 <- init_status_table(vtable, 100)
    res <- main_simulate(table1, vtable, etable,
                         update_s_table, 10)
    # plot_simulate(res, outimg_path, all = FALSE)
}
e <- Sys.time()
print(e-s)


s <- Sys.time()
con <- dbConnect(RSQLite::SQLite(), dbname = "./test.sqlite")
dbListTables(con)
if(dbExistsTable(con, "res")){
    dbExecute(con, "DROP TABLE res;")
}
dbWriteTable(con, "res",
             data.frame(aid = integer(0),
                        vid = numeric(0),
                        time = numeric(0),
                        rep = numeric(0)))
for(i in 1:1){
    vlist_path <- file.path("./example",
                            paste("vlist", i, ".csv", sep = ""))
    elist_path <- file.path("./example",
                            paste("elist", i, ".csv", sep = ""))
    vtable <- read_vtable(vlist_path)
    etable <- read_etable(elist_path)
    table1 <- init_status_table(vtable, 100)
    main_simulate_db(con, "res",
                     table1, vtable, etable,
                     update_s_table, times = 10, rep = 10)
}
dbDisconnect(con)
e <- Sys.time()
print(e-s)
