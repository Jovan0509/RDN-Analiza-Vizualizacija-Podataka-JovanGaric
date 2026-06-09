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

Eksploracija
Srbija se nalazi na 37. mestu sa skorom 6.411. Na scatter plotu BDP vs sreca, 
Srbija se nalazi iznad regresione linije, sto znaci da je srechnija nego sto njen BDP predvidhja.

Linearna regresija:

Model sa samo BDP-om objasnjava 55% varijanse srece (R^2=0.55)
Model sa svim faktorima objasnjava 79% (R^2=0.79)
Sloboda ima najveci koeficijent (2.02), BDP najmanji (0.47)
RMSE = 0.47

Zakljucak: Sloboda izbora i socijalna podrska predvidjaju srecu bolje od samog BDP-a.