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

# 5. STABLA ODLUCIVANJA

library(rpart)
library(rpart.plot)

# pravimo binarnu varijablu, ili srecna ili nesrecna
# granica je medijana skora srece

medijana <- median(happiness$Ladder.score)

happiness$srecna <- ifelse(happiness$Ladder.score >= medijana, "srecna", "nesrecna")
happiness$srecna <- as.factor(happiness$srecna)

cat("Medijana Skora Srece:", medijana, "\n")
cat("Srbija je:", as.character(happiness[happiness$Country.name == "Serbia", "srecna"]), "\n")

# tr/ts split

set.seed(42) 
train_index2 <- createDataPartition(happiness$srecna, p = 0.8, list = FALSE)

train_data2 <- happiness[train_index2, ]
test_data2 <- happiness[-train_index2, ]

# stablo odlucivanja

stablo <- rpart(srecna ~ Log.GDP.per.capita + Social.support +
                   Healthy.life.expectancy + Freedom.to.make.life.choices +
                   Generosity + Perceptions.of.corruption,
                 data = train_data2, method = "class",
                 control = rpart.control(maxdepth = 4, minsplit = 10, cp = 0.02))

# vizualizacija stabla
rpart.plot(stablo, type = 4, extra = 101, 
           main = "Stablo odlucivanja - srecne vs nesrecne zemlje")


png("plots/stablo_odlucivanja.png", width = 1200, height = 800)
rpart.plot(stablo, type = 4, extra = 101,
           main = "Stablo odlucivanja - srecne vs nesrecne zemlje")
dev.off()

# test na test skupu

predikcije2 <- predict(stablo, test_data2, type = "class")
konfuziona_matrica <- table(Stvarno = test_data2$srecna, Predvidjeno = predikcije2)
print(konfuziona_matrica)

# tacnost modela
tacnost <- sum(diag(konfuziona_matrica)) / sum(konfuziona_matrica)

cat("Tacnost stabla odlucivanja:", round(tacnost * 100, 1), "%\n")


# 6. KNN KLASIFIKACIJA

library(class)

# uzimamo samo numericke kolone za KNN

knn_kolone <- c("Log.GDP.per.capita", "Social.support", 
                "Healthy.life.expectancy", "Freedom.to.make.life.choices",
                "Generosity", "Perceptions.of.corruption")

# normalizacija podataka obvzn jer KNN je osetljiv na razlicite skale

normalize <- function(x) {
  return((x - min(x)) / (max(x) - min(x)))
}

happiness_norm <- as.data.frame(lapply(happiness[, knn_kolone], normalize))

happiness_norm$srecna <- happiness$srecna
happiness_norm$Country.name <- happiness$Country.name

# tr/ts split
set.seed(42)
train_index3 <- createDataPartition(happiness_norm$srecna, p = 0.8, list = FALSE)
train_knn <- happiness_norm[train_index3, knn_kolone]
test_knn <- happiness_norm[-train_index3, knn_kolone]
train_labels <- happiness_norm[train_index3, "srecna"]
test_labels <- happiness_norm[-train_index3, "srecna"]

# k = koren broja opservacija, standardno pravilo

k <- round(sqrt(nrow(train_knn)))
cat("Koristimo k =", k, "\n")

# KNN model
knn_predikcije <- knn(train_knn, test_knn, train_labels, k = k)

# tacnost

knn_matrica <- table(Stvarno = test_labels, Predvidjeno = knn_predikcije)
print(knn_matrica)

knn_tacnost <- sum(diag(knn_matrica)) / sum(knn_matrica)
cat("Tacnost KNN modela:", round(knn_tacnost * 100, 1), "%\n")

# gde spada Srbija po KNN?

srbija_norm <- happiness_norm[happiness_norm$Country.name == "Serbia", knn_kolone]
srbija_knn <- knn(train_knn, srbija_norm, train_labels, k = k)
cat("KNN klasifikacija Srbije:", as.character(srbija_knn), "\n")

# vizualizacija KNN - klasifikacija po regionima
happiness_norm$region <- happiness$Regional.indicator
happiness_norm$ladder <- happiness$Ladder.score
happiness_norm$gdp <- happiness$Log.GDP.per.capita

# dodajemo KNN predikciju za sve zemlje
knn_sve <- knn(train_knn, happiness_norm[, knn_kolone], train_labels, k = k)
happiness_norm$knn_klasa <- knn_sve

ggplot(happiness_norm, aes(x = gdp, y = ladder, color = region)) +
  geom_point(size = 2) +
  geom_point(data = happiness_norm[happiness_norm$Country.name == "Serbia", ],
             color = "red", size = 5) +
  geom_text(data = happiness_norm[happiness_norm$Country.name == "Serbia", ],
            aes(label = Country.name), vjust = -1, color = "red", size = 3) +
  labs(title = "KNN klasifikacija zemalja po regionima",
       x = "Log BDP po glavi stanovnika",
       y = "Skor srece",
       color = "Region") +
  theme_minimal()

ggsave("plots/knn_regioni.png", width = 10, height = 6)



# 7. K-MEANS KLASTEROVANJE


# uzimamo iste normalizovane kolone
set.seed(42)
kmeans_model <- kmeans(happiness_norm[, knn_kolone], centers = 4, nstart = 25)

happiness_norm$klaster <- as.factor(kmeans_model$cluster)
happiness$klaster <- as.factor(kmeans_model$cluster)

# koji klaster je Srbija?

srbija_klaster <- happiness_norm[happiness_norm$Country.name == "Serbia", "klaster"]
cat("Srbija pripada klasteru:", as.character(srbija_klaster), "\n")

# koje zemlje su u istom klasteru kao Srbija?

isti_klaster <- happiness[happiness$klaster == srbija_klaster, "Country.name"]
cat("Zemlje u istom klasteru kao Srbija:\n")
print(isti_klaster)

# vizualizacija klastera

ggplot(happiness_norm, aes(x = gdp, y = ladder, color = klaster)) +
  geom_point(size = 2) +
  geom_point(data = happiness_norm[happiness_norm$Country.name == "Serbia", ],
             color = "red", size = 5) +
  geom_text(data = happiness_norm[happiness_norm$Country.name == "Serbia", ],
            aes(label = Country.name), vjust = -1, color = "red", size = 3) +
  labs(title = "K-means klasterovanje zemalja (k=4)",
       x = "Log BDP po glavi stanovnika",
       y = "Skor srece",
       color = "Klaster") +
  theme_minimal()

ggsave("plots/kmeans_klasteri.png", width = 10, height = 6)



# 8. ANSAMBL - kombinujemo linearna regresija + stablo + KNN



# linearna regresija predikcija za sve zemlje

reg_predikcije <- predict(model2, happiness)
reg_klasa <- ifelse(reg_predikcije >= medijana, "srecna", "nesrecna")

# stablo predikcija za sve zemlje

stablo_klasa <- as.character(predict(stablo, happiness, type = "class"))

# KNN predikcija za sve zemlje

knn_klasa_sve <- as.character(knn(train_knn, happiness_norm[, knn_kolone], train_labels, k = k))

# glasanje - ako 2 od 3 modela kazu "srecna", rezultat je "srecna"

ansambl <- data.frame(
  Country = happiness$Country.name,
  Regresija = reg_klasa,
  Stablo = stablo_klasa,
  KNN = knn_klasa_sve
)

ansambl$glasovi_srecna <- rowSums(ansambl[, c("Regresija", "Stablo", "KNN")] == "srecna")
ansambl$rezultat <- ifelse(ansambl$glasovi_srecna >= 2, "srecna", "nesrecna")

# tacnost ansambla
ansambl$stvarno <- as.character(happiness$srecna)
tacnost_ansambl <- mean(ansambl$rezultat == ansambl$stvarno)

cat("Tacnost ansambla:", round(tacnost_ansambl * 100, 1), "%\n")

# gde je Srbija?

cat("Ansambl klasifikacija Srbije:", 
    ansambl[ansambl$Country == "Serbia", "rezultat"], "\n")

# koliko modela se slaze za Srbiju?

print(ansambl[ansambl$Country == "Serbia", ])
