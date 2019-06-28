library(ggplot2)
library(cowplot)

# Plot mock correlation plots
theme_set(theme_gray())
p_data <- read.table("/Users/leggettr/Documents/Projects/BAMBI/correlation_plots_R/Mock.txt", header=TRUE, sep="\t")
pdf("/Users/leggettr/Documents/Projects/BAMBI/correlation_plots_R/Mock.pdf", width=15, height=4);
min_plot <- ggplot(p_data, aes(DNAProp,MinBpProp)) +
  geom_point(color="#f8766d") +
  geom_smooth(method = "lm", color="#f8766d") +
  scale_x_continuous(trans='log10', breaks=c(0.01, 0.1, 1, 10, 100), labels=scales::comma) +
  scale_y_continuous(trans='log10', breaks=c(0.01, 0.1, 1, 10, 100), labels=scales::comma) +
  xlab("Expected proportion of DNA") +
  ylab("MinION sequenced proportion") +
  theme(plot.title = element_text(face="bold", size=12, hjust = 0.5), legend.position = "none")
ill_plot <- ggplot(p_data, aes(DNAProp,IllBpProp)) +
  geom_point(color="#00ba38") +
  geom_smooth(method = "lm", color="#00ba38") +
  scale_x_continuous(trans='log10', breaks=c(0.01, 0.1, 1, 10, 100), labels=scales::comma) +
  scale_y_continuous(trans='log10', breaks=c(0.01, 0.1, 1, 10, 100), labels=scales::comma) +
  xlab("Expected proportion of DNA") +
  ylab("Illumina sequenced proportion") +
  theme(plot.title = element_text(face="bold", size=12, hjust = 0.5), legend.position = "none")
all_plot <- ggplot(p_data, aes(MinBpProp,IllBpProp)) +
  geom_point(color="#619cff") +
  geom_smooth(method = "lm", color="#619cff") +
  scale_x_continuous(trans='log10', breaks=c(0.01, 0.1, 1, 10, 100), labels=scales::comma) +
  scale_y_continuous(trans='log10', breaks=c(0.01, 0.1, 1, 10, 100), labels=scales::comma) +
  xlab("MinION propotion") +
  ylab("Illumina proportion") +
  theme(plot.title = element_text(face="bold", size=12, hjust = 0.5), legend.position = "none")
plot_grid(min_plot, ill_plot, all_plot, ncol = 3)
garbage <- dev.off()

# Plot individual sample plots - need to comment as appropriate for correct sample
theme_set(theme_gray())
#p_data <- read.table("/Users/leggettr/Documents/Projects/BAMBI/correlation_plots_R/P205.txt", header=TRUE, sep="\t")
#pdf("/Users/leggettr/Documents/Projects/BAMBI/correlation_plots_R/P205.pdf", width=5, height=3.5);
#p_data <- read.table("/Users/leggettr/Documents/Projects/BAMBI/correlation_plots_R/P49.txt", header=TRUE, sep="\t")
#pdf("/Users/leggettr/Documents/Projects/BAMBI/correlation_plots_R/P49.pdf", width=5, height=3.5);
#p_data <- read.table("/Users/leggettr/Documents/Projects/BAMBI/correlation_plots_R/P8.txt", header=TRUE, sep="\t")
#pdf("/Users/leggettr/Documents/Projects/BAMBI/correlation_plots_R/P8.pdf", width=5, height=3.5);
p_data <- read.table("/Users/leggettr/Documents/Projects/BAMBI/correlation_plots_R/P103M.txt", header=TRUE, sep="\t")
pdf("/Users/leggettr/Documents/Projects/BAMBI/correlation_plots_R/P103M.pdf", width=5, height=3.5);
ggplot(p_data, aes(RELA,RELB)) +
  geom_point() +
  geom_smooth(method = "lm") +
  scale_x_continuous(trans='log10', breaks=c(0.01, 0.1, 1, 10, 100), labels=scales::comma) +
  scale_y_continuous(trans='log10', breaks=c(0.01, 0.1, 1, 10, 100), labels=scales::comma) +
  xlab("Relative abundance at 1hr") +
  ylab("Relative abundance at 6hr") +
  ggtitle("P103M species-level abundance comparison") +
  theme(plot.title = element_text(face="bold", size=12, hjust = 0.5))
garbage <- dev.off()

# P10N Illumina vs Nanopore
p_data <- read.table("/Users/leggettr/Documents/Projects/BAMBI/correlation_plots_R/P10N.txt", header=TRUE, sep="\t")
pdf("/Users/leggettr/Documents/Projects/BAMBI/correlation_plots_R/P10N.pdf", width=5, height=3.5);
ggplot(p_data, aes(IllRel, NanoRel)) +
  geom_point() +
  geom_smooth(method = "lm") +
  scale_x_continuous(trans='log10', breaks=c(0.01, 0.1, 1, 10, 100), labels=scales::comma) +
  scale_y_continuous(trans='log10', breaks=c(0.01, 0.1, 1, 10, 100), labels=scales::comma) +
  xlab("Illumina relative abundance") +
  ylab("Nanopore relative abundance") +
  ggtitle("P10N species-level abundance comparison") +
  theme(plot.title = element_text(face="bold", size=12, hjust = 0.5))
garbage <- dev.off()

# P8 Illumina vs Nanopore
theme_set(theme_gray())
p_data <- read.table("/Users/leggettr/Documents/Projects/BAMBI/correlation_plots_R/P8NanoIll.txt", header=TRUE, sep="\t")
pdf("/Users/leggettr/Documents/Projects/BAMBI/correlation_plots_R/P8NanoIll.pdf", width=5, height=3.5);
ggplot(p_data, aes(IllRel, NanoRel)) +
  geom_point() +
  geom_smooth(method = "lm") +
  scale_x_continuous(trans='log10', breaks=c(0.01, 0.1, 1, 10, 100), labels=scales::comma) +
  scale_y_continuous(trans='log10', breaks=c(0.01, 0.1, 1, 10, 100), labels=scales::comma) +
  xlab("Illumina relative abundance") +
  ylab("Nanopore relative abundance") +
  ggtitle("P8 species-level abundance comparison") +
  theme(plot.title = element_text(face="bold", size=12, hjust = 0.5))
garbage <- dev.off()

# Flongle
p_data <- read.table("/Users/leggettr/Documents/Projects/BAMBI/correlation_plots_R/Flongle.txt", header=TRUE, sep="\t")
pdf("/Users/leggettr/Documents/Projects/BAMBI/correlation_plots_R/Flongle.pdf", width=5, height=3.5);
ggplot(p_data, aes(MinRel, GridRel)) +
  geom_point() +
  geom_smooth(method = "lm") +
  scale_x_continuous(trans='log10', breaks=c(0.01, 0.1, 1, 10, 100), labels=scales::comma) +
  scale_y_continuous(trans='log10', breaks=c(0.01, 0.1, 1, 10, 100), labels=scales::comma) +
  xlab("Flongle/MinION abundance") +
  ylab("Flongle/GridION abundance") +
  ggtitle("Flongle species-level abundance comparison") +
  theme(plot.title = element_text(face="bold", size=12, hjust = 0.5))
garbage <- dev.off()