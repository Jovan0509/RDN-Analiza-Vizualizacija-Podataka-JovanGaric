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

# provera za NA vr

colSums(is.na(happiness))

# cisti NA vr

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
  labs(title = "Top 10 Najsrecnijih Zemalja (2024)", x = "Zemlja", y = "Skor Srece") +
  theme_minimal()

ggsave("plots/top10_sreca.png", width = 8, height = 5)

# bottom 10 najsrecnijih aka top 10 unhappiest
bottom10 <- tail(happiness, 10)

ggplot(bottom10, aes(x = reorder(Country.name, Ladder.score), y = Ladder.score)) +
  geom_bar(stat = "identity", fill = "#F44336") +
  coord_flip() +
  labs(title = "Top 10 Najnesrecnijih Zemalja (2024)", x = "Zemlja", y = "Skor Srece") +
  theme_minimal()

ggsave("plots/bottom10_sreca.png", width = 8, height = 5)

# BDP Sreca veza, sa Srbijom point
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

# 4. LINEARNA REGRESIJA

library(caret)

# korelaciona matrica aka koji features imaju veze sa srecom

cor_matrix <- cor(happiness[, c("Ladder.score", "Log.GDP.per.capita", 
                                "Social.support", "Healthy.life.expectancy",
                                "Freedom.to.make.life.choices", "Generosity",
                                "Perceptions.of.corruption")])
print(cor_matrix)

# TR/TS 80/20 
set.seed(42)
train_index <- createDataPartition(happiness$Ladder.score, p = 0.8, list = FALSE)
train_data <- happiness[train_index, ]
test_data <- happiness[-train_index, ]

# Model 1 sa samo BDP-om
model1 <- lm(Ladder.score ~ Log.GDP.per.capita, data = train_data)
summary(model1)

# Model 2 sa svim features i kor. matrice
model2 <- lm(Ladder.score ~ Log.GDP.per.capita + Social.support + 
               Healthy.life.expectancy + Freedom.to.make.life.choices + 
               Generosity + Perceptions.of.corruption, data = train_data)
summary(model2)

# R2 poredjenja

cat("Model 1 R2 (samo BDP):", summary(model1)$r.squared, "\n")
cat("Model 2 R2 (svi faktori):", summary(model2)$r.squared, "\n")

# Model2 poredjenje na test skupu

predictions <- predict(model2, test_data)
rmse <- sqrt(mean((predictions - test_data$Ladder.score)^2))
cat("RMSE na test skupu:", rmse, "\n")

# grafik za predvidjene vs stvarne vrednosti

test_data$predicted <- predictions

ggplot(test_data, aes(x = predicted, y = Ladder.score)) +
  geom_point(color = "#2196F3", size = 2) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "black") +
  geom_point(data = test_data[test_data$Country.name == "Serbia", ],
             color = "red", size = 4) +
  geom_text(data = test_data[test_data$Country.name == "Serbia", ],
            aes(label = Country.name), vjust = -1, color = "red", size = 3) +
  labs(title = "Predvidjene vs. Stvarne Vrednosti Srece",
       x = "Predvidjeni skor",
       y = "Stvarni skor") +
  theme_minimal()

ggsave("plots/regresija_predikcija.png", width = 8, height = 6)