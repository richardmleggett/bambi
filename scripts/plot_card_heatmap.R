library(plyr)
library(ggplot2)
library(scales)
library(reshape)
library(grid)

table_data = read.table("nanook_reporter_files/BAMBI_P8_2D_Local_070317_hits.txt", header=TRUE, sep="\t")
yield_data = read.table("nanook_reporter_files/BAMBI_P8_2D_Local_070317_yield.txt", header=TRUE, sep="\t")
time_data = read.table("nanook_reporter_files/heatmap_timepoints.txt", header=TRUE, sep="\t")
groups = read.table("nanook_reporter_files/groups.txt", sep="\t", header=TRUE)

data.m = melt(table_data,  id.vars = "Reads", measure.vars = c("G1", "G2", "G3", "G4", "G5", "G6", "G7", "G8", "G9", "G10", "G11", "G12", "G13"))

png("BAMBI_P8_2D_Local_070317_hits.png", width=1800, height=600);
g1 <- ggplot(data.m, aes(Reads, variable)) + geom_tile(aes(fill = value)) + theme(axis.text.x = element_text(angle = 270, hjust = 0, colour = "grey50")) + scale_fill_gradientn(colours=rev(rainbow(n=30, end=4/6)), limits=c(1, 11), oob=squish, na.value='transparent', name='Hits', breaks = c(1, 5, 10)) + xlab("Number of reads analysed") + ylab("Group") + labs(color="Hits") + scale_y_discrete(labels=groups$Name) + scale_x_continuous(expand=c(0,0)) + theme(text = element_text(size = 24))+ guides(fill = guide_colorbar(barheight = 10)) + theme(plot.margin=unit(c(2,0,0,0),"cm"))

for (i in 1:length(time_data$Hours))  {
    g1 <- g1 + annotation_custom(grob = textGrob(label = time_data$Hours[i], just = "centre", gp = gpar(cex = 1.5, col="gray25")),
                                 ymin = 14,
                                 ymax = 14,
                                 xmin = time_data$Reads[i],
                                 xmax = time_data$Reads[i])
    g1 <- g1 + annotation_custom(grob = linesGrob(x = unit(c(0, 5), "npc"),
    gp=gpar(col= "gray25")),
    xmin = time_data$Reads[i],
    xmax = time_data$Reads[i],
    ymin = 13.65,
    ymax = 13.7)
}

g1 <- g1 + annotation_custom(grob = textGrob(label = "Hours since sequencing start", just = "centre", gp = gpar(cex = 2, col="black")),
ymin = 14.7,
ymax = 14.7,
xmin = min(yield_data$Reads),
xmax = max(yield_data$Reads))
g2 <- ggplot_gtable(ggplot_build(g1))
g2$layout$clip[g2$layout$name == "panel"] <- "off"
grid.draw(g2)
garbage <- dev.off()

# Yield plot
#pdf("BAMBI_P8_2D_Local_070317_yield.pdf", width=5, height=3);
#print(ggplot(data=yield_data, aes(x=Hours,y=Reads)) + geom_line(colour="black", size=1) + ylab("Reads analysed") + xlab("Hours since sequencing start"))
#garbage <- dev.off()
