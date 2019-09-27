library(plyr)
library(ggplot2)
library(scales)
library(reshape)
library(grid)

scalefactor=3;

samplebasedir = "/Users/leggettr/Documents/Projects/BAMBI/heatmaps"
outputdir = "/Users/leggettr/Documents/Projects/BAMBI/heatmaps"

# Yield plot
#pdf("BAMBI_P8_2D_Local_070317_yield.pdf", width=5, height=3);
#print(ggplot(data=yield_data, aes(x=Hours,y=Reads)) + geom_line(colour="black", size=1) + ylab("Reads analysed") + xlab("Hours since sequencing start"))
#garbage <- dev.off()

plot_heatmap <- function(sample, n_groups, plot_height, plot_height_pdf, plot_width_pdf, heat_limit, heat_breaks, heat_labels)
{
    plot_height = plot_height * scalefactor;

    table_data = read.table(paste(samplebasedir, "/", sample, "/", sample, "_hits_sorted.txt", sep=""), header=TRUE, sep="\t")
    yield_data = read.table(paste(samplebasedir, "/", sample, "/", sample, "_yield.txt", sep=""), header=TRUE, sep="\t")
    time_data = read.table(paste(samplebasedir, "/", sample, "/", "heatmap_timepoints.txt", sep=""), header=TRUE, sep="\t")
    groups = read.table(paste(samplebasedir, "/", sample, "/", "groups.txt", sep=""), sep="\t", header=TRUE)

    all_groups <- c("G1", "G2", "G3", "G4", "G5", "G6", "G7", "G8", "G9", "G10", "G11", "G12", "G13", "G14", "G15", "G16", "G17", "G18", "G19", "G20", "G21", "G22", "G23", "G24", "G25");
    this_groups <- all_groups[1:n_groups];

    data.m = melt(table_data, id.vars = "Reads", measure.vars = this_groups)

    png(paste(outputdir, "/", sample, ".png", sep=""), width=1000 * scalefactor, height=plot_height);
    #pdf(paste(outputdir, "/", sample, ".pdf", sep=""), width=plot_width_pdf, height=plot_height_pdf);

    g1 <- ggplot(data.m, aes(Reads, variable)) + geom_tile(aes(fill = value)) + theme(axis.text.x = element_text(colour = "grey50"))
    g1 <- g1 + scale_fill_gradientn(colours=rev(rainbow(n=30, end=4/6)), limits=c(1, heat_limit), oob=squish, na.value='transparent', name='', breaks = heat_breaks, labels = heat_labels)
    g1 <- g1 + xlab("Number of reads analysed")
    g1 <- g1 + ylab("Group")
    g1 <- g1 + labs(color="Hits")
    g1 <- g1 + scale_y_discrete(labels=groups$Name)
    g1 <- g1 + scale_x_continuous(labels=comma, expand=c(0,0))
    g1 <- g1 + theme(text = element_text(size = 20 * scalefactor))
    g1 <- g1 + guides(fill = guide_colorbar(barheight = 10 * scalefactor, barwidth = 1 * scalefactor))
    g1 <- g1 + theme(plot.margin = unit(c(2 * scalefactor,0,0,0),"cm"))
    g1 <- g1 + theme(axis.title.x = element_text(margin = margin(t = 10 * scalefactor, r = 0, b = 2 * scalefactor, l = 0)))
    g1 <- g1 + theme(axis.title.y = element_text(margin = margin(t = 0, r = 10 * scalefactor, b = 0, l = 10 * scalefactor)))
    g1 <- g1 + theme(legend.margin = margin(0, 16 * scalefactor, 0, 16 * scalefactor))
    g1 <- g1 + theme(axis.ticks.length = unit(0.5, "cm"))

    for (i in 1:length(time_data$Hours))  {
        g1 <- g1 + annotation_custom(grob = textGrob(label = time_data$Hours[i], just = "centre", gp = gpar(cex = 1.5 * scalefactor, col="gray25")),
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

    g1 <- g1 + annotation_custom(grob = textGrob(label = "Hours since sequencing start", just = "centre", gp = gpar(cex = 1.6 * scalefactor, col="black")),
    ymin = n_groups + 1.7,
    ymax = n_groups + 1.7,
    xmin = min(table_data$Reads),
    xmax = max(table_data$Reads))

    g2 <- ggplot_gtable(ggplot_build(g1))
    g2$layout$clip[g2$layout$name == "panel"] <- "off"
    grid.draw(g2)
    garbage <- dev.off()
}

plot_heatmap("BAMBI_1D_19092017", 9, 380, 6.8, 18, 15, c(1, 5, 10, 15), c("1", "5", "10", "15+"))
plot_heatmap("20180112_1634_BAMBI_P205G_1D_12012018", 10, 400, 6, 36, 40, c(1, 10, 20, 30, 40), c("1", "10", "20", "30", "40+"));
plot_heatmap("20180202_1307_BAMBI_P106I_LSQK108_02022018", 5, 300, 4.4, 36, 15, c(1, 5, 10, 15), c("1", "5", "10", "15+"));
plot_heatmap("20180202_1324_BAMBI_P116I_SQK108_02022018", 6, 334, 4.7, 36, 15, c(1, 5, 10, 15), c("1", "5", "10", "15+"));
plot_heatmap("20171220_1133_BAMBI_P103M_400ng_RAD4_20122017", 7, 350, 5, 20, 15, c(1, 5, 10, 15), c("1", "5", "10", "15+"));
plot_heatmap("20180112_1459_BAMBI_P49A_1D_12012018", 4, 270, 3.7, 36, 15, c(1, 5, 10, 15), c("1", "5", "10", "15+"));

