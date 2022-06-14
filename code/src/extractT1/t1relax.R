library(tidyverse)
library(gridExtra)

# TO DO
# - [ ] plot single subj plots
# - [ ] plot nb voxels
#



path <- '~/Desktop/Data/MP2RAGE_T1_layers/outputs/derivatives/cpp_spm-roi'

# load the tsv file per each subject
pilot001 <- read.table(paste(path,
                             'sub-pilot001/ses-001/anat',
                             'sub-pilot001_ses-001_acq-r0p375_label-V1_desc-T1relaxation.tsv', sep = '/'),
                       header = T,
                       na.strings = 'NaN')

pilot004 <- read.table(paste(path,
                             'sub-pilot004/ses-001/anat',
                             'sub-pilot004_ses-001_acq-r0p375_label-V1_T1relaxation.tsv', sep = '/'),
                       header = T,
                       na.strings = 'NaN')

pilot005 <- read.table(paste(path,
                             'sub-pilot005/ses-001/anat',
                             'sub-pilot005_ses-001_acq-r0p375_label-V1_T1relaxation.tsv', sep = '/'),
                       header = T,
                       na.strings = 'NaN')


# make it tidy and clean
pilot001_tidy <- pilot001 %>%
  gather(layer, t1relaxation, na.rm = TRUE, convert = TRUE) %>%
  filter(t1relaxation != 'n/a') %>%
  filter(t1relaxation > 0) %>%
  mutate(subID = rep('pilot001', length(t1relaxation))) %>%
  mutate(t1relaxation = as.numeric(t1relaxation))

pilot004_tidy <- pilot004 %>%
  gather(layer, t1relaxation, na.rm = TRUE, convert = TRUE) %>%
  filter(t1relaxation != 'n/a') %>%
  filter(t1relaxation > 0) %>%
  mutate(subID = rep('pilot004', length(t1relaxation))) %>%
  mutate(t1relaxation = as.numeric(t1relaxation))

pilot005_tidy <- pilot005 %>%
  gather(layer, t1relaxation, na.rm = TRUE, convert = TRUE) %>%
  filter(t1relaxation != 'n/a') %>%
  filter(t1relaxation > 0) %>%
  mutate(subID = rep('pilot005', length(t1relaxation))) %>%
  mutate(t1relaxation = as.numeric(t1relaxation))

# bind all the the datasets

subjAll_tidy <- rbind(pilot001_tidy, pilot004_tidy, pilot005_tidy)

# compute mean, sd and se by subjects and layers
t1relaxTableSubj <- subjAll_tidy %>%
  group_by(subID, layer) %>%
  summarize(mean = mean(t1relaxation),
            sd = sd(t1relaxation),
            n = n(),
            se = sd / sqrt(n),
            .groups = 'keep')

# compute group wise mean, sd and se by layers
t1relaxTableGroup <- subjAll_tidy %>%
  group_by(layer) %>%
  summarize(mean_group = mean(t1relaxation),
            sd_group = sd(t1relaxation),
            n = n(),
            se_group = sd_group / sqrt(n),
            .groups = 'keep')

# plot group wise results
ggplot() +
  # geom_boxplot(data = t1relaxTableGroup,
  #             aes(x = mean_group,
  #                 y = layer)) +
  geom_jitter(data = t1relaxTableSubj,
             aes(x = mean,
                 y = layer,
                 shape = subID),
             color = '#23b6b7',
             size = 3,
             height = 0.4,
             width = 0,
             alpha = .8) +
  geom_errorbarh(data = t1relaxTableGroup,
                 aes(x = mean_group,
                     y = layer,
                     xmin = mean_group - sd_group,
                     xmax = mean_group + sd_group,
                     height = 0),
                 color = '#b74823') +
  geom_point(data = t1relaxTableGroup,
             aes(x = mean_group,
                 y = layer),
             color = '#b74823',
             size = 6.5,
             shape = 18,
             alpha = .95) +
  theme_classic() +
  scale_y_discrete(limits=c("layer_1", "layer_2", "layer_3", "layer_4", "layer_5", "layer_6"),
                     labels = c("VI", "V", "IV", "III", "II", "I")) +
  annotate("text", x = 1.28, y = 6.5, label = "CSF", color = 'darkgray') +
  annotate("text", x = 1.28, y = 0.5, label = "WM", color = 'darkgray') +
  labs(x="T1 relaxation (sec)", y="Layers") +
  # ggtitle("sub-pilot005") +
  theme(
    text=element_text(size=14),
    axis.line = element_line(size = 0.6),
    axis.text.x = element_text(size=12,colour="black",
                               angle = 0,
                               vjust = .5,
                               hjust = 0.5),
    axis.text.y = element_text(size=12,
                               colour='black'),
    legend.title=element_blank()) +
  coord_cartesian(xlim = c(min(t1relaxTableSubj$mean) - 0.2,
                           max(t1relaxTableSubj$mean) + 0.4),
                  clip = 'off')

ggsave('t1Relaxation.jpeg',
       device="jpeg",
       units="in",
       width=5.54,
       height=4.54,
       dpi=300)



library(ggridges)

# plot single subject resutls
ggplot() +
  # geom_boxplot(data = t1relaxTableGroup,
  #             aes(x = mean_group,
  #                 y = layer)) +
  # geom_density_ridges(data = subset(subjAll_tidy, subID == 'pilot005'),
  #             aes(x = t1relaxation,
  #                 fill = layer),
  #             color = '#23b6b7',
  #             size = 3,
  #             alpha = .8) +
  geom_density_ridges(data = subset(subjAll_tidy, subID == 'pilot005'),
                      aes(x = t1relaxation,
                          y = layer,
                          fill = layer),
                      color = "black",
                      size = .4,
                      alpha = .5,
                      show.legend = F) +
  scale_fill_manual(values = c("#0e4949",
                               "#1c9292",
                               "#23b6b7",
                               "#4fc5c5",
                               "#91dbdb",
                               "#bde9e9")) +
  theme_classic() +
  scale_y_discrete(limits=c("layer_1", "layer_2", "layer_3", "layer_4", "layer_5", "layer_6"),
                   labels = c("VI", "V", "IV", "III", "II", "I")) +
  annotate("text", x = 1.28, y = 6.5, label = "CSF", color = 'darkgray') +
  annotate("text", x = 1.28, y = 0.5, label = "WM", color = 'darkgray') +
  labs(x="T1 relaxation (sec)", y="Layers") +
  ggtitle("sub-pilot005") +
  theme(
    text=element_text(size=14),
    axis.line = element_line(size = 0.6),
    axis.text.x = element_text(size=12,colour="black",
                               angle = 0,
                               vjust = .5,
                               hjust = 0.5),
    axis.text.y = element_text(size=12,
                               colour='black'),
    legend.title=element_blank()) +
  theme_ridges(grid = FALSE, center_axis_labels = TRUE)

ggsave('t1Relaxation_dist.jpeg',
       device="jpeg",
       units="in",
       width=5.54,
       height=4.54,
       dpi=300)
