.hc |
.ds LH SAMENVATTING
.ds RH SAMENVATTING
.bp
.DS C
\fBSAMENVATTING\fP
.DE
.sp 1
.PP
Geschreven tekst vormt een essentieel element in onze cultuur
en het wekt dan ook geen verbazing dat verschillende technische
hulpmiddelen uitgevonden zijn om het produceren van geschreven
tekst te vereenvoudigen.
Potlood en papier, de schrijfmachine en de zetmachine zijn
voorbeelden van dergelijke uitvindingen.
.PP
Als voortzetting van deze lijn van ontwikkeling worden computers tegenwoordig
gebruikt om het produceren van geschreven tekst te vereenvoudigen.
Geautomatiseerde tekstverwerkende systemen
(van `word processors' voor het schrijven en redigeren van eenvoudige
teksten tot volledig geautomatiseerde systemen voor het drukken
van kranten en boeken)
dringen momenteel door in allerlei gebieden waar het geschreven woord
het voornaamste communicatiemiddel is.
.PP
Historisch gezien is de ontwikkeling van computers altijd in hoge
mate bepaald door de behoefte om veel en snel te kunnen rekenen.
Dit heeft zijn weerslag gevonden in het ontwerp van de meeste
computers en programmeertalen.
Door het toenemend gebruik van computers voor tekstverwerking en
voor de oplossing van andere, niet numerieke, problemen
raken de oorspronkelijke, hoofdzakelijk op rekenen gerichte
ontwerpen verouderd.
.PP
Dit proefschrift is gewijd aan de programmeertaalaspecten
van geautomatiseerde tekstverwerking en
in het bijzonder aan het ontwerp en de
implementatie van `stringmanipulatietalen'.
Dit zijn programmeertalen die gebruikt kunnen worden bij
het bouwen van tekstverwerkende systemen.
Onder stringmanipulatie wordt hier verstaan het
inspecteren of wijzigen van rijen `symbolen'.
In het geval van tekstverwer|king zal men 
als symbolen kiezen de letters, cijfers en leestekens
waaruit een te behandelen tekst bestaat.
Men kan ook andere basissymbolen kiezen om anderssoortige problemen
op te lossen.
.PP
Een min of meer chronologisch overzicht wordt
gegeven van pogingen om enkele problemen die zich
in bestaande stringmanipulatietalen voordoen op te lossen.
Het beschreven onderzoek omvat allereerst twee exercities
op het gebied van het ontwerp van toepassingsgerichte programmeertalen.
Dit heeft geleid tot het ontwerp van de talen \s-2SPRING\s0 en \s-2SUMMER\s0.
De lessen die geleerd zijn bij het ontwerp en het gebruik van \s-2SPRING\s0
zijn verwerkt in het ontwerp van \s-2SUMMER\s0.
Het beschreven onderzoek omvat verder een exercitie op het gebied van het formeel
defini\*:eren van de betekenis (`semantiek') van programmeertalen.
Definitie en implementatie van de programmeertaal \s-2SUMMER\s0
vormen tenslotte het feitelijke eindproduct van dit onderzoek.
.PP
Dit proefschrift bestaat uit twee delen.
Deel I volgt de ontwikkeling van het onderzoek op de voet en bestaat uit
de hoofdstukken 1 t/m 7.
Deel II vormt het eindprodukt van het onderzoek
en bestaat uit hoofdstukken 8 t/m 12.
De inhoud wordt hieronder kort samengevat.
.PP
Hoofdstuk 1 is een inleiding op het onderwerp en geeft de noodzakelijke
motivering en achtergrond voor de studie van stringmanipulatietalen.
.PP
Hoofdstuk 2 schetst de programmeertaal \s-2SPRING\s0,
een eerste poging tot het ontwerpen van een stringmanipulatietaal.
S\s-2PRING\s0 is een nogal omvangrijke programmeertaal die
een groot aantal ingebouwde operaties bevat om problemen op het gebied van
tekstverwerking op te lossen.
In dit hoofdstuk wordt gewezen op een aantal ongewenste eigenschappen
van deze taal die voortkomen uit ogenschijnlijk logische ontwerpkeuzen.
Veel van de problemen en vragen die in het eerste hoofdstuk aan de orde
komen werden tijdens dit onderzoek als zodanig onderkend.
.PP
Hoofdstuk 3 is gewijd aan algemene ontwerpoverwegingen voor
stringmanipulatietalen en aan een vergelijking van de werking
van `patroonherkennings'-modellen.
Patroonherkenning is een methode die dient om vast te stellen
of een tekst bepaalde eigenschappen heeft,
zoals `is korter dan 83 tekens', of `bevat het woord ``heks'''.
Bij deze vergelijking wordt aandacht besteed aan verschillende
vormen van neveneffecten die kunnen optreden tijdens
een patroonherkenningsoperatie.
Als resultaat van deze analyse wordt een nieuw
patroonherkenningsmodel gepresenteerd dat een elegante besturing
van het al dan niet ongedaan maken van neveneffecten mogelijk maakt.
.PP
In hoofdstuk 4 wordt een overzicht gegeven van de programmeertaal \s-2SUMMER\s0,
een tweede poging tot het ontwerpen van een stringmanipulatietaal.
S\s-2UMMER\s0 is een vrij `kleine' programmeertaal
die bestaat uit een relatief kleine kern
van primitieven voor
tekstverwerking, naast een uitbreidingsmechanisme
om toepassingsgerichte operaties te defini\*:eren.
.PP
In hoofdstuk 5 staat de vraag centraal hoe de semantiek van
een programmeertaal op dusdanige wijze formeel beschreven kan worden
dat zowel de ontwerpers als de implementatoren en gebruikers van een taal,
met succes van een dergelijke formele beschrijving gebruik kunnen maken.
In dit hoofdstuk wordt een verbeterde methode voor de operationele definitie
van de semantiek van programmeertalen ontwikkeld
en wordt de toepassing daarvan bij het defini\*:eren van \s-2SUMMER\s0 ge\*:illustreerd.
.PP
In hoofdstuk 6 wordt de implementatie van \s-2SUMMER\s0 beschreven.
.PP
Hoofdstuk 7 besluit het eerste deel van dit proefschrift
door de resultaten van het onderzoek samen te vatten
en door enkele richtingen voor voortgezet onderzoek aan te geven.
.PP
Deel II is gewijd aan de definitie van de programmeertaal \s-2SUMMER\s0.
Het bevat zowel een informele als een formele definitie
van de taal en geeft enkele uitgewerkte voorbeelden.
.PP
In hoofdstuk 8 worden de techniek en de notatie uiteengezet
die in de definitie gebruikt worden.
De feitelijke definitie-methode krijgt hierbij veel aandacht.
.PP
Hoofdstuk 9 bevat een semi-formele definitie van een `kern' van
\s-2SUMMER\s0.
Deze kern is een klein deel van de taal dat voldoende is om de rest van
\s-2SUMMER\s0 in te beschrijven.
De definitie van iedere taalconstructie bestaat
uit een beschrijving van zijn vorm,
een informele en formele definitie van zijn betekenis, en voorbeelden.
.PP
In hoofdstuk 10 wordt de kern van \s-2SUMMER\s0 uitgebreid met een aantal
nuttige datatypen met bijbehorende operaties,
zoals re\*:ele getallen, arrays, associatieve geheugens,
databestanden, enzovoorts.
.PP
Een aantal volledige, geannoteerde, \s-2SUMMER\s0 programma's
wordt in hoofdstuk 11 gepresenteerd.
.PP
Hoofdstuk 12 bevat tenslotte een overzicht van de syntax van \s-2SUMMER\s0.
.PP
Lezers die alleen een globale indruk van de taal \s-2SUMMER\s0
willen krijgen kunnen zich beperken tot hoofdstuk 4.
Lezers die niet ge\*:interesseerd zijn in de formele definitie
kunnen hoofdstuk 8 overslaan
(met uitzondering van de paragrafen 8.1 en 8.2),
evenals alle paragrafen van hoofdstuk 9 met als titel `semantics'.
