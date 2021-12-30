library(igraph)

example1 <- graph.data.frame(
    read.csv("./elist1.csv")[,c("from", "to", "dis")],
    directed = FALSE,
    vertices = read.csv("./vlist1.csv")[,c("vid", "value")])
plot(example1)


example2 <- graph.data.frame(
    read.csv("./elist2.csv")[,c("from", "to", "dis")],
    directed = FALSE,
    vertices = read.csv("./vlist2.csv")[,c("vid", "value")])
plot(example2)



example3 <- graph.data.frame(
    read.csv("./elist3.csv")[,c("from", "to", "dis")],
    directed = FALSE,
    vertices = read.csv("./vlist3.csv")[,c("vid", "value")])
plot(example3)


example4 <- graph.data.frame(
    read.csv("./elist4.csv")[,c("from", "to", "dis")],
    directed = FALSE,
    vertices = read.csv("./vlist4.csv")[,c("vid", "value")])
plot(example4)


example5 <- graph.data.frame(
    read.csv("./elist5.csv")[,c("from", "to", "dis")],
    directed = FALSE,
    vertices = read.csv("./vlist5.csv")[,c("vid", "value")])
plot(example5)


example6 <- graph.data.frame(
    read.csv("./elist6.csv")[,c("from", "to", "dis")],
    directed = FALSE,
    vertices = read.csv("./vlist6.csv")[,c("vid", "value")])
plot(example6)
