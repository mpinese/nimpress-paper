run1 = read.table("run1_results.txt", header = TRUE, sep = "\t", stringsAsFactors = FALSE)

library(ggplot2)
library(plyr)
library(svglite)

run1.summary = ddply(run1, .(prefix, method, gts_nsamps, gts_nloci, score_nvars, replicate), function(d) {
    d.mem = d[d$iter == 0,,drop=FALSE]
    d.time = d[d$iter != 0,]

    c(elapsed = median(d.time$elapsed), user = median(d.time$user), sys = median(d.time$sys), mem = d.mem$mem)
    })

library(reshape2)
run1.summary2 = melt(run1.summary, measure.vars = c("elapsed", "user", "sys", "mem"))


ggsave("03_run1_performance.svg", ggplot(run1.summary2[run1.summary2$variable %in% c("elapsed", "mem"),], aes(x = gts_nsamps, y = value, col = method)) + 
    stat_summary(fun.data = function(x) { data.frame(ymin = min(x), y = median(x), ymax = max(x)) }, geom = "errorbar", width = 0.15, lwd = 1) + 
    stat_summary(fun.data = function(x) { data.frame(y = median(x)) }, geom = "line", lwd = 1, alpha = 0.6) + 
    facet_grid(variable ~ score_nvars, scales = "free_y") +
    scale_x_log10() +
    scale_y_log10() +
    theme_bw())


run1.summary3 = ddply(run1.summary, .(prefix, gts_nsamps, gts_nloci, score_nvars, replicate), function(d) {
    elapsed.nimpress = d$elapsed[d$method == "nimpress"]
    mem.nimpress = d$mem[d$method == "nimpress"]
    d$elapsed.rel = d$elapsed / elapsed.nimpress
    d$mem.rel = d$mem / mem.nimpress
    d
})

run1.summary4 = ddply(run1.summary3, .(prefix, method, gts_nsamps, gts_nloci, score_nvars), function(d) {
    c(  elapsed.rel.min = min(d$elapsed.rel), elapsed.rel.med = median(d$elapsed.rel), elapsed.rel.max = max(d$elapsed.rel), 
        mem.rel.min = min(d$mem.rel), mem.rel.med = median(d$mem.rel), mem.rel.max = max(d$mem.rel))
})
run1.summary4 = run1.summary4[run1.summary4$method != "nimpress",]

options(width = 200)
run1.summary4

sessionInfo()

