# RDN-Analiza-Vizualizacija-Podataka-JovanGaric

Analiza faktora koji uticu na srecu stanovnistva u 140 zemalja sveta, zasnovana na World Happiness Report 2024. 
Cilj zadatka je utvrditi koji politicki i ekonomski faktori najvise doprinose sreci jedne zemlje, 
sa prikazom i na poziciju Srbije.

Dataset:

Izvor: Kaggle - World Happiness Report 2024
Broj zemalja: 140 (nakon ciscenja)
Kolone: Ladder.score, Log.GDP.per.capita, Social.support,
Freedom.to.make.life.choices, Generosity, Perceptions.of.corruption, Healthy.life.expectancy

Rezultati:

Srbija se nalazi na 37. mestu sa skorom 6.411. Na scatter plotu BDP vs sreca, 
Srbija se nalazi iznad regresione linije, sto znaci da je srechnija nego sto njen BDP predvidhja.

### Linearna regresija:

Model sa samo BDP-om objasnjava 55% varijanse srece (R^2=0.55)
Model sa svim faktorima objasnjava 79% (R^2=0.79)
Sloboda ima najveci koeficijent (2.02), BDP najmanji (0.47)
RMSE = 0.47

Zakljucak: Sloboda izbora i socijalna podrska predvidjaju srecu bolje od samog BDP-a.

### Stabla odlucivanja

Zemlja se klasifikuje kao "srecna" ili "nesrecna" u odnosu na medijanu skora srece (5.80).
Model postavljamo sa parametrima maxdepth=4, minsplit=10, cp=0.02 da izbegnemo overfitting.

Stablo donosi odluku na osnovu 3 pitanja:
1. Da li je BDP >= 1.5? Ako da, zemlja je srecna.
2. Ako BDP < 1.5, da li je sloboda >= 0.65? Ako ne, nesrecna.
3. Ako sloboda >= 0.65, da li je socijalna podrska >= 1? Ako da, srecna.

Tacnost modela: 78.6%
Srbija je klasifikovana kao srecna zemlja.

Zakljucak: Cak i zemlje sa skromnim BDP-om mogu biti srecne ako imaju
visok nivo slobode i socijalne podrske.

### KNN klasifikacija

KNN (K-nearest neighbors) klasifikuje zemlju na osnovu k najslicnijih zemalja
po svim faktorima. Koristimo k=11 (koren broja opservacija u train skupu).
Pre KNN-a normalizujemo podatke jer je algoritam osetljiv na razlicite skale.

Srbija je klasifikovana kao srecna, okruzena zemljama slicnog profila:
Ceska, Bosna i Herzegovina, Severna Makedonija.