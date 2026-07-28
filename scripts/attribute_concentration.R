# Attentional narrowing across attributes, by block of 5 trials.
#
# Produces the continuous analogue of Munoz Delaveau (2025) Figure C.1: instead of
# categorising each participant x block by which attributes crossed 25% of dwell time,
# we compute how many attributes were *effectively* consulted.
#
#   p_a  = share of value-cell dwell time on attribute a  (a = Cost, Time, Comfort, CO2)
#   H    = -sum p_a log p_a                                (0 .. log 4)
#   eff  = exp(H)                                          (1 .. 4)
#
# eff = 4 means dwell time was spread evenly over all four attributes; eff = 1 means it
# went entirely to one. Note that the 25% threshold in Figure C.1 is exactly the uniform
# point for four attributes, so this measure is that plot without the hard cutoff.

library(dplyr)
library(ggplot2)
library(patchwork)

BLOCK_SIZE   <- 5
N_TRAIN_TRIAL <- 100
LAST_TRAIN_BLOCK <- N_TRAIN_TRIAL / BLOCK_SIZE   # 20

# ---------------------------------------------------------------------------
# Input: one row per participant x trial x ROI.
# Expected columns: participant, trial, roi_type ("value" | "attr_label" | "alt_label"),
#                   attribute ("Cost" | "Time" | "Comfort" | "CO2"), dwell_s
# Value cells only: including the attribute labels would mix value inspection with the
# re-localisation search that follows each permutation.
# ---------------------------------------------------------------------------
gaze <- readRDS("data/gaze_roi_long.rds")   # <- point at the current pipeline output

conc <- gaze %>%
  filter(roi_type == "value") %>%
  mutate(block = (trial - 1) %/% BLOCK_SIZE + 1) %>%
  group_by(participant, block, attribute) %>%
  summarise(dwell = sum(dwell_s), .groups = "drop_last") %>%
  group_by(participant, block) %>%
  mutate(p = dwell / sum(dwell)) %>%
  summarise(
    H    = -sum(ifelse(p > 0, p * log(p), 0)),
    eff  = exp(H),        # effective number of attributes attended
    top1 = max(p),        # robustness: share on the single most-attended attribute
    total_dwell = sum(dwell),
    .groups = "drop"
  ) %>%
  # blocks with almost no usable gaze would otherwise produce unstable shares
  mutate(across(c(H, eff, top1), ~ ifelse(total_dwell < 0.5, NA_real_, .)))

# Order rows by training-phase concentration so the structure is visible.
# Display only -- do not treat this ordering as an analysis.
ord <- conc %>%
  filter(block <= LAST_TRAIN_BLOCK) %>%
  group_by(participant) %>%
  summarise(m = mean(eff, na.rm = TRUE)) %>%
  arrange(m) %>%
  pull(participant)

conc <- conc %>% mutate(participant = factor(participant, levels = ord))

# ---- heatmap --------------------------------------------------------------
p_tiles <- ggplot(conc, aes(block, participant, fill = eff)) +
  geom_tile(colour = NA) +
  geom_vline(xintercept = LAST_TRAIN_BLOCK + 0.5, colour = "white", linewidth = 0.7) +
  scale_fill_viridis_c(
    option = "magma", direction = -1, limits = c(1, 4),
    breaks = 1:4, na.value = "grey92",
    name = "Effective no.\nof attributes"
  ) +
  scale_x_continuous(expand = c(0, 0), breaks = seq(5, 30, 5)) +
  scale_y_discrete(expand = c(0, 0)) +
  labs(x = NULL, y = "Participant") +
  theme_minimal(base_size = 10) +
  theme(
    panel.grid  = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank()
  )

# ---- marginal mean --------------------------------------------------------
summ <- conc %>%
  filter(!is.na(eff)) %>%
  group_by(block) %>%
  summarise(m = mean(eff), se = sd(eff) / sqrt(n()), .groups = "drop")

p_mean <- ggplot(summ, aes(block, m)) +
  geom_vline(xintercept = LAST_TRAIN_BLOCK + 0.5, linetype = 2, colour = "grey40") +
  geom_ribbon(aes(ymin = m - se, ymax = m + se), fill = "grey80") +
  geom_line(linewidth = 0.7) +
  scale_x_continuous(expand = c(0, 0), breaks = seq(5, 30, 5)) +
  labs(x = "Block (5 trials)", y = "Mean") +
  theme_minimal(base_size = 10) +
  theme(panel.grid.minor = element_blank())

p_tiles / p_mean + plot_layout(heights = c(4, 1))

ggsave("fig/attribute_concentration.png", width = 7, height = 6, dpi = 300)

# ---- the numbers to quote in the text -------------------------------------
conc %>%
  mutate(phase = ifelse(block <= LAST_TRAIN_BLOCK, "training", "disrupted")) %>%
  group_by(phase) %>%
  summarise(across(c(eff, top1), list(m = ~mean(., na.rm = TRUE),
                                      sd = ~sd(., na.rm = TRUE))))

# Early vs late training, and late training vs first disrupted blocks.
conc %>%
  filter(block %in% c(1:2, 19:20, 21:22)) %>%
  mutate(window = case_when(block <= 2  ~ "early_train",
                            block <= 20 ~ "late_train",
                            TRUE        ~ "post_disruption")) %>%
  group_by(window) %>%
  summarise(eff = mean(eff, na.rm = TRUE), n = n())
