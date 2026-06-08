# World Happiness Report 2024
# Analiza podataka u R-u
# Autor: Jovan Garic

# 1. UCITAVANJE PODATAKA

happiness <- read.csv("data/World-happiness-report-2024.csv")

head(happiness)
str(happiness)
summary(happiness)
nrow(happiness)
colnames(happiness)

# 2. CISCENJE PODATAKA

# provera gde ima NA vrednosti
colSums(is.na(happiness))

# uklanjamo redove sa NA
happiness <- na.omit(happiness)
nrow(happiness)

# pozicija Srbije u datasetu
happiness[happiness$Country.name == "Serbia", ]

# 3. VIZUALIZACIJA

library(ggplot2)

# top 10 najsrecnijih
top10 <- head(happiness, 10)

ggplot(top10, aes(x = reorder(Country.name, Ladder.score), y = Ladder.score)) +
  geom_bar(stat = "identity", fill = "#2196F3") +
  coord_flip() +
  labs(title = "Top 10 najsrecnijih zemalja (2024)", x = "Zemlja", y = "Skor srece") +
  theme_minimal()

ggsave("plots/top10_sreca.png", width = 8, height = 5)

# bottom 10
bottom10 <- tail(happiness, 10)

ggplot(bottom10, aes(x = reorder(Country.name, Ladder.score), y = Ladder.score)) +
  geom_bar(stat = "identity", fill = "#F44336") +
  coord_flip() +
  labs(title = "10 najnesrecnijih zemalja (2024)", x = "Zemlja", y = "Skor srece") +
  theme_minimal()

ggsave("plots/bottom10_sreca.png", width = 8, height = 5)

# veza BDP i srece - Srbija je oznacena crvenom
ggplot(happiness, aes(x = Log.GDP.per.capita, y = Ladder.score)) +
  geom_point(aes(color = Regional.indicator), size = 2) +
  geom_smooth(method = "lm", se = FALSE, color = "black", linetype = "dashed") +
  geom_point(data = happiness[happiness$Country.name == "Serbia", ],
             color = "red", size = 4) +
  geom_text(data = happiness[happiness$Country.name == "Serbia", ],
            aes(label = Country.name), vjust = -1, color = "red", size = 3) +
  labs(title = "Veza izmedju BDP-a i srece (2024)",
       x = "Log BDP po glavi stanovnika",
       y = "Skor srece",
       color = "Region") +
  theme_minimal()

ggsave("plots/bdp_vs_sreca.png", width = 10, height = 6)