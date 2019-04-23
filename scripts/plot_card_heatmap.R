library(plyr)
library(ggplot2)
library(scales)
library(reshape)
library(grid)

sample = "BAMBI_1D_19092017";
n_groups = 15
plot_height = 556;
plot_height_pdf = 6.8;
plot_width_pdf = 18;
#36

#sample = "20180112_1634_BAMBI_P205G_1D_12012018";
#n_groups = 12
#plot_height = 476;
#plot_height_pdf = 6;
#plot_width_pdf = 36;

#sample="20180202_1307_BAMBI_P106I_LSQK108_02022018";
#n_groups=7
#plot_height=350
#plot_height_pdf = 4.4;
#plot_width_pdf = 36;

#sample="20180202_1324_BAMBI_P116I_SQK108_02022018";
#n_groups=8
#plot_height=360
#plot_height_pdf = 4.7;
#plot_width_pdf = 36;

#sample="20171220_1133_BAMBI_P103M_400ng_RAD4_20122017"
#n_groups=9
#plot_height=400
#plot_height_pdf = 5;
#plot_width_pdf = 20;

#sample="20180112_1459_BAMBI_P49A_1D_12012018";
#n_groups=5
#plot_height=280
#plot_height_pdf = 3.7;
#plot_width_pdf = 36;

table_data = read.table(paste(sample, "/", sample, "_hits_sorted.txt", sep=""), header=TRUE, sep="\t")
yield_data = read.table(paste(sample, "/", sample, "_yield.txt", sep=""), header=TRUE, sep="\t")
time_data = read.table(paste(sample, "/", "heatmap_timepoints.txt", sep=""), header=TRUE, sep="\t")
groups = read.table(paste(sample, "/", "groups.txt", sep=""), sep="\t", header=TRUE)

#data.m = melt(table_data, id.vars = "Reads", measure.vars = c("G1", "G2", "G3", "G4", "G5", "G6", "G7", "G8", "G9", "G10", "G11", "G12", "G13", "G14", "G15", "G16", "G17", "G18", "G19", "G20", "G21", "G22", "G23", "G24", "G25"))
data.m = melt(table_data, id.vars = "Reads", measure.vars = c("G1", "G2", "G3", "G4", "G5", "G6", "G7", "G8", "G9", "G10", "G11", "G12", "G13", "G14", "G15"))

#data.m = melt(table_data, id.vars = "Reads", measure.vars = c("G1", "G2", "G3", "G4", "G5", "G6", "G7", "G8", "G9", "G10", "G11", "G12"))
#data.m = melt(table_data, id.vars = "Reads", measure.vars = c("G1", "G2", "G3", "G4", "G5", "G6", "G7"))
#data.m = melt(table_data, id.vars = "Reads", measure.vars = c("G1", "G2", "G3", "G4", "G5", "G6", "G7", "G8"))
#data.m = melt(table_data, id.vars = "Reads", measure.vars = c("G1", "G2", "G3", "G4", "G5", "G6", "G7", "G8", "G9"))
#data.m = melt(table_data, id.vars = "Reads", measure.vars = c("G1", "G2", "G3", "G4", "G5"))


png(paste(sample, ".png", sep=""), width=1400, height=plot_height);
#pdf(paste(sample, ".pdf", sep=""), width=plot_width_pdf, height=plot_height_pdf);
g1 <- ggplot(data.m, aes(Reads, variable)) + geom_tile(aes(fill = value)) + theme(axis.text.x = element_text(angle = 270, hjust = 0, colour = "grey50")) + scale_fill_gradientn(colours=rev(rainbow(n=30, end=4/6)), limits=c(1, 51), oob=squish, na.value='transparent', name='Hits', breaks = c(1, 10, 20, 30, 40)) + xlab("Number of reads analysed") + ylab("Group") + labs(color="Hits") + scale_y_discrete(labels=groups$Name) + scale_x_continuous(labels=comma, expand=c(0,0)) + theme(text = element_text(size = 24))+ guides(fill = guide_colorbar(barheight = 10)) + theme(plot.margin=unit(c(2,0,0,0),"cm"))

for (i in 1:length(time_data$Hours))  {
    g1 <- g1 + annotation_custom(grob = textGrob(label = time_data$Hours[i], just = "centre", gp = gpar(cex = 1.5, col="gray25")),
                                 ymin = n_groups + 1.1,
                                 ymax = n_groups + 1.1,
                                 xmin = time_data$Reads[i],
                                 xmax = time_data$Reads[i])
    g1 <- g1 + annotation_custom(grob = linesGrob(x = unit(c(0, 5), "npc"),
    gp=gpar(col= "gray25")),
    xmin = time_data$Reads[i],
    xmax = time_data$Reads[i],
    ymin = (n_groups + 1) - 0.40,
    ymax = (n_groups + 1) - 0.3)
}

g1 <- g1 + annotation_custom(grob = textGrob(label = "Hours since sequencing start", just = "centre", gp = gpar(cex = 2, col="black")),
ymin = n_groups + 2.2,
ymax = n_groups + 2.2,
xmin = min(table_data$Reads),
xmax = max(table_data$Reads))
g2 <- ggplot_gtable(ggplot_build(g1))
g2$layout$clip[g2$layout$name == "panel"] <- "off"
grid.draw(g2)
garbage <- dev.off()

# Yield plot
#pdf("BAMBI_P8_2D_Local_070317_yield.pdf", width=5, height=3);
#print(ggplot(data=yield_data, aes(x=Hours,y=Reads)) + geom_line(colour="black", size=1) + ylab("Reads analysed") + xlab("Hours since sequencing start"))
#garbage <- dev.off()
