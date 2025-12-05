.AM
.ds CH \ 
.ds CF \ 
.TL
Incrementele vertaling voor SUMMER
.FS *
Dit verslag beschrijft de achtergrond en het verloop van het project waaraan
ik gewerkt heb tijdens mijn stageperiode van februari\ '84 tot juli\ '84 op
het Centrum voor Wiskunde en Informatica te Amsterdam.
.FE
.sp
Saco Bekius
.sp
Centrum voor Wiskunde en Informatica, Amsterdam
.br
Hogere Informatica Opleiding,
.br
I.H.B.O. "de Maere", Enschede
.sp 16
.SH
samenvatting
.PP
Om implementatie van de taal SUMMER beter bruikbaar te maken bestaat
behoefte aan een effici\*:entere wijze van vertaling van vooral grote
programma's. Hiertoe worden twee mechanismen voor modulaire vertaling
vergeleken,
.UL afzonderlijke
en
.UL incrementele
vertaling. Incrementele
vertaling blijkt, gezien de situatie, het meest geschikt en is aan de
bestaande compiler toegevoegd. Hiervoor is een stapsgewijze
werkmethode gekozen, die per stap beschreven en ge\*:evalueerd wordt.
.bp
.ds RF %
.ds RH Inleiding
.NH
Inleiding
.NH 2
Doel van het project
.PP
De taal SUMMER [1] is een flexibele programmeertaal die ontworpen is voor
toepassingen op het gebied van patroonherkenning en string-manipulatie.
Het huidige SUMMER systeem bestaat uit een vertaler die SUMMER programma's
naar SAM (SUMMER ABSTRACT MACHINE) code vertaalt en een interpretator voor
deze SAM code. Daar de SUMMER vertaler zelf met behulp van dit systeem
ge\*:implementeerd is, kost het vertaalproces vrij veel tijd.
.KS
.sp 24
.TS
center;
r l.
1,3	SUMMER respectivelijk SAM code programma
2	Vertaler voor SUMMER naar SAM code
4	Interpretator voor SAM code ge\*:implementeerd in M code
5	Een willekeurige machine
.TE
.ce
figuur 1, t-diagram van het SUMMER systeem
.KE
.PP
Het doel van dit stageproject is het vertaalproces te versnellen. Dit is
in principe mogelijk door:
.IP 1)
een snellere machine (M) te kiezen.
.IP 2)
een effici\*:entere, eventueel hardware, SAM te ontwikkelen.
.IP 3)
de vertaler met behulp van een effici\*:entere taal dan SUMMER te
implementeren.
.IP 4)
de vertaalstrategie zodanig te wijzigen dat reeds vertaalde en goedbevonden
modulen niet hervertaald hoeven te worden als een ander moduul gewijzigd wordt.
.PP
Omdat 1) buiten mijn bereik ligt en er aan 2) al gewerkt is vallen deze af.
Een effici\*:entere implementatie van de vertaler is een re\*:ele
mogelijkheid, omdat de gemaakte vertaalslag relatief simpel is. De doel
taal, SAM code, is namelijk speciaal voor SUMMER ontwikkeld. De keuze van
alternatief 1) 2) of 3) betekent echter dat er een deel van de implementatie van
het SUMMER systeem opnieuw geformuleerd zal worden. Dergelijke
optimalisaties brengen doorgaans alleen een procentuele winst met zich mee:
als een programma dat kwa omvang een factor groter is
aangeboden wordt, zullen dezelfde problemen de kop weer op steken.
.PP
Het veranderen van de vertaaltaktiek, alternatief 4), verkleint daarentegen
de orde van het probleem. Doorgaans betekent dit een kleine winst voor
kleine problemen en een grote winst waar het om grote problemen gaat. Deze
vertaaltaktiek wordt doorgaans modulaire vertaling genoemd.
Het toevoegen van het
mechanisme aan het SUMMER systeem heeft geen invloed op de taal, maar
wijzigt alleen de implementatie ervan.
.NH 2
Realiseerbaarheid
.IP \  35
\ \ \ \ \ De keuze van modulaire vertaling voor SUMMER houdt in dat het bestaande
systeem gewijzigd moet worden, wat alleen realistisch als de organisatie
ervan dit toelaat.
.sp
\ \ \ \ \ Tijdens de ontwikkeling van de vertaler is geen rekening gehouden met een
eventuele toevoeging van een dergelijk mechanisme. Wel is de
organisatie van het systeem doorzichtig (figuur\ 2). De PARSER is met behulp van een
parsergenerator (PGEN [2]) ge\*:implementeerd. Hierin zijn heel goed de
verbanden tussen de taal SUMMER en de bouw van de PARSETREE te vinden.  De
knopen van de PARSETREE bestaan uit objecten die met taal-elementen
overeenkomen. Op het hoogste niveau bestaat deze uit een lijst met
declaraties. Codegeneratie vindt plaats door voor iedere knoop de
bijbehorende SAM code te genereren.
.LP
\ \ \ \ \ \ figuur\ 2, het twee pass
.br
\ \ \ \ \ \ \ \ \ \ vertaalproces
.ds RH \ 
.bp
.NH
Modulaire vertaling
.ds RH Modulaire\ vertaling
.NH 2
Wat is modulaire vertaling?
.PP
Modulaire vertaling berust op het principe dat niet alle begrippen die in
een programma-module gebruikt worden ook in dezelfde module gedefinieerd 
moeten zijn. Hoe dit gerealiseerd kan worden hangt sterk
af van het karakter van de betreffende programmeertaal.
.PP
Het is vrij eenvoudig om aan een taal die helemaal geen
typechecking kent (b.v. assembler) een mechanisme toe te voegen
om een aantal namen globaal over alle source-modulen geldig te maken. Zo
kennen de meeste assemblers een commando om een label globaal te
declareren. De linkage-editor zorgt er voor dat de
verschillende, nog niet complete objectmodulen, tot \*`e\*`en executeerbare
file aan elkaar gesmeed worden.
.PP
Vaak wordt er bij het implementeren van modulaire vertaling gebruik
gemaakt van het modulair vertaalmechanisme van de onderliggende assembler.
Waar tijdens de vertaling al informatie nodig is over een bepaald extern
gedefinieerd taal-element, wordt deze vaak als extra informatie aan het
oorspronkelijke programma toegevoegd. Hiervoor zijn ad-hoc toevoegingen
aan de taal nodig zoals in het volgende (in een Pascal-dialect geschreven)
voorbeeld blijkt.
.DS
program someprimes(output);
var i: integer;
function isaprime(n: integer): boolean;
  extern;
begin
for i := 1 to maxint do
  if isaprime(i)
  then
    writeln(output, i)
end.
.DE
Het is in Pascal regel dat alle begrippen voor hun gebruik
gedeclareerd moeten zijn. Daar "isaprime" elders gedefinieerd is,
wordt hier wel de header gegeven, maar inplaats van de bodie een aanwijzing
(de toevoeging aan Pascal) dat deze elders staat.
.PP
Deze voor Pascal gebruikte vorm van modulaire vertaling blijkt in de
praktijk nogal zwak en onbevredigend te zijn. Wie garandeert dat de header
van "isaprime" er inderdaad zo uit ziet?
Dergelijke verbanden moeten op een later tijdstip gecontroleerd
worden, of er moet tijdens het vertalen informatie over aanwezig zijn.
.PP
In modulaire vertaling spelen globale taal-elementen een belangrijke rol. De
verzameling globale taal-elementen noem ik
.UL omgeving.
Met
betrekking tot deze omgeving spelen de volgende constructies een rol:
.IP 1)
omgeving-bepalende taal-elementen, dit zijn bijvoorbeeld declaraties
van globale variabelen en procedures.
.IP 2)
omgeving-afhankelijke taal-elementen, dit zijn bijvoorbeeld referenties naar
globale variabelen en procedures.
.PP
Het verband tussen deze twee kan zowel door de linkage-editor 
als door de vertaler opgelost worden. Deze twee technieken noem ik
respectivelijk
.UL afzonderlijke-
en
.B
incrementele vertaling.
.R
.NH 2
Afzonderlijke vertaling
.PP
De situatie waarin het verband tussen omgeving-afhankelijke
en omgeving-bepalende taal-elementen door de linkage-editor opgelost wordt,
noem ik
.B
afzonderlijke vertaling.
.R
Er is in dat geval in
de object-module, naast de
gebruikelijke code, informatie aanwezig over de symbolische verbanden die de
vertaler niet op kon lossen, en de omgeving-bepalende taal-elementen in die
programma-module. Na vertaling van een module kunnen dergelijke verbanden
met behulp van de linkage-editor alsnog opgelost worden.
.PP
In het geval van afzonderlijke vertaling wordt het voorbeeld programma
"someprimes":
.DS
program someprimes(output);
var i: integer;
begin
for i := 1 to maxint do
  if isaprime(i)
  then
    write(output, i)
end.
.DE
.PP
Er is in dit geval geen declaratie voor de header van "isaprime" nodig.
De object-module bevat echter
als een van de nog niet opgeloste omgeving-afhankelijke symbolen een entry
voor "isaprime": dit moet een boolean functie met een integer parameter zijn.
Zou "isaprime" nu de volgende (foutieve) header hebben:
.DS
function isaprime(n: real): boolean;
.DE
dan zal de linkage-editor een melding geven over het niet overeenkomen van het
type van de variabele "i" met het parameter type van "isaprime".
.PP
Het voordeel van deze methode is dat de objectmodulen in verschillende
omgevingen toegepast kunnen worden.
Nadelen zijn, dat foutmeldingen op een later tijdstip
kunnen verschijnen en dat de linkage-editor programmeertaal afhankelijk is.
.NH 2 
Incrementele vertaling 
.PP
Een tweede vorm van modulaire vertaling is
.B
incrementele vertaling,
.R
hierbij worden alle verbanden tussen omgeving-afhankelijke en
omgeving-bepalende taal-elementen door de vertaler opgelost.
De consequentie daarvan is dat
alle omgeving bepalende informatie bij de vertaler bekend moet zijn. Dat kan
gerealiseerd worden door:
.IP 1)
De vertaler de symbooltabel, en vector indeling uit de vorige vertaalsessie
als uitgangspunt te geven.
.IP 2)
De vertaler beschrijvingen van de niet te vertalen modulen aan te bieden.
.PP
Bij het toepassen van alleen 2) is er geen volledige incrementele vertaling
mogelijk. Als de omgeving veranderd is moeten alle modulen vertaald worden
om de juiste verbanden te garanderen, zoals in 5.1 en 10.2 zal blijken.
Ik ga er vanuit dat de taal over een mechanisme beschikt
om aan te geven hoe een
programma over verschillende files verspreid is. Een dergelijk mechanisme
noem ik, net als in SUMMER, include-mechanisme.
Het is verstandig om in de
grammaticale formulering van het include-statement af te dwingen dat er
per file een
afgerond geheel staat. Is dit namelijk niet het geval, dan kan het
moeilijk worden om te bepalen hoe de object-code over de modulen verspreid
moet worden.
.PP
Zo zou het programma "someprimes" (in een ander Pascal-dialect)
als volgt geschreven kunnen worden: 
.DS
program someprimes(output); 
var i: integer; 
include 'isaprime.p'; 
begin 
for i := 1 to maxint do
  if isaprime(i) 
  then 
    writeln(output, i) 
end.  
.DE
.PP
Incrementele vertaling wil nu zeggen dat alleen die programma-modulen
vertaald worden die sinds de vorige sessie gewijzigd zijn. Een wijziging kan
het gevolg zijn van een verandering van een deel van het programma, of een
zijeffect daarvan. 
Stel dat "someprimes" veranderd is na de laatste
vertaalsessie. Dan moet er alleen voor deze module een nieuw object-moduul
gegenereerd worden. Maar als  de header definitie van "isaprime" veranderd
is (er kan een parameter toegevoegd zijn), is wijziging en
hervertaling van "someprimes" nodig.
.PP
Om voor "someprimes" tot een correcte vertaling te komen is het nodig dat
de header van "isaprime" bekend is. Bij incrementele vertaling wordt de vertaler zodanig
be\*:invloed dat het net is of de hele source-module vertaald is. Er is al een
object-module uit de vorige sessie en de header-definitie van "isaprime" staat
in de symbooltabel, door de omgevingsbeschrijving van "isaprime.p" gelezen te
hebben of deze uit de symbooltabel van de vorige vertaalsessie te betrekken.
.PP
Doordat de vertaler alle programma-modulen aangeboden krijgt kunnen alle
taal-afhankelijke problemen tijdens het vertalen opgelost worden. De
gegenereerde objectmodulen kunnen vervolgens door een standaard
linkage-editor verwerkt worden.
.PP
Het hangt af van de implementatie wat op een gegeven moment de zijeffecten
van het veranderen van een
declaratie zijn. Als in het volgende voorbeeld:
.DS
program tweeplustwee(output);
include 'declaratie.p';
begin
writeln(output, twee + twee)
end.
.DE
de include file "declaratie.p";
.DS
function twee: integer;
begin twee := 2 end;
.DE
verandert in:
.DS
function twee: real;
begin twee := 2.0 end;
.DE
Zal afhankelijk van het feit of:
.IP 1)
de vertaler ziet dat er goedkoper een integer opteloperatie gebruikt kan
worden,
.IP 2)
de doeltaal in het midden laat of het hier om een integer dan wel real
optelling gaat,
.IP 3)
een andere denkbare reden,
.LP
de vertaling van "tweeplustwee" verschillend zijn.
.ds RH Modulaire\ vertaling\ voor\ SUMMER
.NH 
Modulaire vertaling voor SUMMER 
.NH 2 
Omgeving-bepalende taal-elementen 
.PP
In SUMMER zijn een aantal taal-elementen aan te wijzen die de omgeving
vormen; taal-elementen die daar aan refereren maken een module
omgeving-afhankelijk. Een taal-element kan vanwege eigenschappen van de taal
omgeving-bepalend zijn maar ook vanwege de implementatie die ervoor
gebruikt is.
.PP
Omgeving-bepalende taal-elementen, die uit de definitie van SUMMER
voortvloeien, zijn:
.IP 1)
Globale constanten en hun waarden. 
.IP 2)
Globale variabelen.  
.IP 3)
Globale operator, klasse en proceduredeclaraties.
.IP 4)
Bij de klassen behorende velden.
.IP 5)
Include-statement's.
.PP
Omgeving-bepalende taal-elementen, die voortvloeien uit de implementatie,
zijn:
.IP 1)
String constanten: deze worden tijdens het vertalen in een tabel opgeslagen
waar ze een paar vormen bestaande uit een label en de stringwaarde.
In deze tabel staan niet alleen de in
de programmatekst gebruikte strings, maar ook de namen van identifiers en de
stringwaarden van real constanten.
.IP 2)
Verborgen globale variabelen: deze worden gegenereerd tijdens de vertaling
van case- en for-expressies buiten procedure-bodies.
.IP 3)
Initialisaties van globale variabelen: tijdens vertaling wordt de code voor
het initialiseren van  case-tabellen en globale variabelen opgespaard. Deze
worden uitgevoerd v\*'o\*'or de aanvang van de executie van het feitelijke
programma. Dit wordt bereikt
door ze voor de bodie van het hoofd programma te plaatsen.
.IP 4)
Fetch- en store-associaties voor de klasse velden. Deze zijn omgeving
bepalend omdat ook hiervoor tijdens vertaling de code opgespaard wordt en
ze voor de procedure declaraties in een SAM programma gedeclareerd worden.
.NH 2 
Organisatie van de SAM
.PP
Wat de omgeving betreft heeft de vertaling van een SUMMER programma een
initialisatie voor de datastructuur van de SAM als resultaat. Om globale
variabelen, procedures en velden te bereiken worden een aantal vectoren
(figuur\ 3) gebruikt. De betekenis daarvan is alsvolgt:
.KF
.sp 27
.ce
figuur 3, datastructuur SAM
.sp 1
.KE
.IP
.B classsizes:
voor elke in het SUMMER programma gedefinieerde klasse een getal wat
aangeeft hoeveel geheugen er voor een object van deze klasse gealloceerd moet
worden.
.IP
.B fieldswitches: 
een rij integers ter lengte van het aantal in het SUMMER
programma gedeclareerde klassen. De waarde van de integers is -1 als het
veld voor die klasse niet gedefinieerd is. In het geval ze wel gedefinieerd is,
wordt er een offset naar de acces procedure gegeven.  
.IP 
.B fields: 
in SAM instructies voor veldselectie wordt geen gebruik van
de veldlabels gemaakt, maar van een offset in deze vector. Op die
betreffende plaats staat het label van een field-switch.
.IP
.B globals: 
SAM instructies die gebruik maken van globale variabelen en
procedures bevatten geen concrete adressen, maar offsets in deze
vector.
.PP
Een SAM programma bestaat uit een aantal procedure-bodies. De procedure met
het label "the-program" wordt als eerste aan de evaluator van de SAM
aangeboden. Deze procedure begint met code om de globale
variabelen te initialiseren.
.PP
De string constanten worden als laatste in een SAM code programma
gedeclareerd. Deze declaraties bestaan uit paren bestaande uit een label en
een stringwaarde. De pointers naar strings in figuur\ 3 zijn referenties
aan deze labels.
.PP
De velden class-sizes, class-names, field-switches, field-vector, globals,
global-names en string-table vormen de omgeving voor procedure-bodies. Een
verandering in de omgeving komt neer op een verandering in een van deze
vectoren. Het gevolg daarvan is dat de referenties vanuit procedure-bodies
aan de context ook aangepast moeten worden. Andersom geldt niet dat een
verandering van een procedure-bodie een verandering in de omgeving teweegbrengt.
.NH 2
Opbouw van de SAM vectoren door de vertaler
.PP
De zes SAM vectoren uit figuur\ 3 zijn terug te brengen tot de volgende drie:
.IP 1)
De velden-vector met voor elk veld een pointer naar de "field-swich" en een
naar de naam ervan.
.IP 2)
De globalen-vector met voor elke globale variabele of procedure
een pointer naar het gerelateerde
object en een naar de naam ervan.
.IP 3)
De klasse-velden met voor elke klasse de hoeveelheid geheugen die
gealloceerd moet worden en een pointer naar de naam ervan.
.PP
Voor elk van deze vectoren wordt er in de vertaler een tabel bijgehouden.
Als er een nieuw symbool in een tabel geplaatst wordt krijgt dat als index
de eerst volgende vrije lokatie in de betreffende vector
.NH 2 
Keuze van type modulaire vertaling 
.PP
De keuze tussen afzonderlijke vertaling en incrementele vertaling zal het
meest be\*:invloed worden door het gemak waarmee deze twee mechanismen te
implementeren zijn, en hoe goed ze in te passen zijn in de huidige
implementatie. Ik heb niet als doel om in \*`e\*`en slag een perfect
systeem te implementeren, maar doe het liever stapsgewijs waarbij ik in
iedere volgende stap gebruik maak van de resultaten uit de vorige.
.PP
Keuze voor afzonderlijke vertaling maakt het nodig om voor afhandeling
van de globale symbolen een speciale linkage-editor te implementeren. Deze
moet uit de informatie in de vertaalde files een vectorindeling berekenen
en daarna alle referenties daaraan oplossen. Daarnaast moet de vertaler zodanig
veranderd worden dat alle referenties aan de omgeving-velden symbolisch zijn.
Dit zal al met al een vrij grote hoeveelheid werk kosten waarin moeilijk
fasen aan te geven zijn die een op zich werkbaar geheel opleveren.
.PP
Incrementele vertaling is gezien de situatie wel geschikt voor SUMMER omdat
de taal over een include-statement op declaratieniveau beschikt en de
omgeving-bepalende informatie (zoals we in 5.2 zullen zien) in SUMMER uit te
drukken blijkt te zijn. Hierdoor hoeven we in eerste instantie weinig aan de
bestaande vertaler te veranderen. In een later stadium kan er naar een vorm
gezocht worden om de vectorindeling op basis van de voorlaatste vertaalsessie
te berekenen.
Hierdoor wordt het zijeffect van een omgevingsverandering terug gebracht
en het uiteindelijke systeem efficienter.
.ds RH \ 
.NH
Gevolgde werkwijze
.ds RH Gevolgde\ werkwijze
.PP
Een project is doorgaans op twee manieren uit te voeren. Je kunt eerst een
uitgebreid ontwerp maken wat daarna (eventueel in fasen) uitgevoerd wordt.
Voordeel van deze methode is dat (als je voldoende kennis over het onderwerp
hebt) de kans op dubbel werk klein is.
.PP
Vanwege mijn gebrekkige kennis van SUMMER en de implementatie heb ik voor
een andere methode gekozen. Het is de bedoeling om een aantal
stappen in de richting van incrementele vertaling te doen. Of een volgende fase
uitgevoerd zal worden hangt af van een schatting van het nuttig effect 
en de hoeveelheid werk.
.PP
In het volgende deel zijn de doorlopen fasen beschreven. Ze bestaan uit een
doel, verslag van ontwerp en implementatie en een evaluatie. Het ideaalbeeld dat tijdens het project nagestreefd zal worden bestaat uit:
.KF
.sp 24
.QP
figuur\ 4, in deze figuur is het verband tussen de hoeveelheid vertaalde
tekst en de vertaaltijd te zien. De onderbroken lijn geeft dit aan voor de
huidige vertaler, hoe klein de verandering in een programma tekst ook is,
alles moet hervertaald worden. De andere lijn geeft het verband bij
een ideale vorm van incrementele vertaling aan.
.sp
.KE
.IP 1)
Een lineair verband tussen de tijd die nodig is voor het vertalen en de
hoeveelheid gewijzigde tekst, waarbij de overhead nul is. (figuur\ 4)
.IP 2)
Dat een verandering van een declaratie een minimaal zijeffect heeft.
.IP 3)
Dat het zijeffect van een verandering van een declaratie volledig bepaald
kan worden.
.PP
Om iets te kunnen zeggen over de vorderingen die een bepaalde fase oplevert
zal ik voor iedere fase metingen aan een benchmark verrichten. Deze
bestaat uit de ongeveer 5500 regels source-code van de al bestaande vertaler, die over aan
aantal files verdeeld is. Ik ben vooral ge\*:interesseerd in de overhead die
er is bij het vertalen van alle files en de tijd die het kost om de complete
omgevingsbeschrijving in te lezen.
.PP
In de evaluatie van een stap die een grote tijdswinst opgeleverd heeft zal
ik het verband tussen het percentage vertaalde tekst en de vertaaltijd
grafisch weergeven. Daar het moeilijk is om dit verband
exact te bepalen bouw ik
de grafieken met behulp van twee meetpunten. De een is het punt
waarbij er geen veranderde programma-modulen aangeboden worden, dit noem ik
de
.UL nulvertaling.
Het andere punt wordt gemeten bij
.B
totale vertaling,
.R
dat wil zeggen dat alle programma-modulen vertaald zijn. De grafieken hebben
enkel een illustratieve waarde.
.PP
Omdat elke stap zijn eigen SUMMER vertaler oplevert geef ik elke nieuwe
vertaler de naam "sep", gevolgd door het nummer van de stap. Zo zal de
vertaler van de eerste stap "sep1" heten, de huidige vertaler heet
"sumc".
.bp
.SH
Bijlage A
.ds RH Bijlage\ A
.PP
Deze bijlage beschrijft de SUMMER klasse FILTER voor de
omgevingsbeschrijvingengenerator uit 5.3. De SUMMER grammatica met de
commando's om het filter te besturen is niet gegeven.
.DS L
class FILTER(output)
begin

      fetch copieer_SUMMER, copieer_commentaar,
        vorige_toestand, put;

      proc copieer_SUMMMER()
      (
        vorige_toestanden.append(huidige_toestand);
        case huidige_toestand of
          copieer_als_SUMMER:
            huidige_toestand := copieer_als_SUMMER,
          copieer_als_commentaar:
            output.sluit_commentaar;
            huidige_toestand := copieer_als_SUMMER,
          copieer_niet:
            huidige_toestand := copieer_als_SUMMER
        esac
      ); # copieer_SUMMMER #

.DE
.DS L
      proc copieer_commentaar()
      (
        vorige_toestanden.append(huidige_toestand);
        case huidige_toestand of
          copieer_als_SUMMER:
            huidige_toestand := copieer_als_SUMMER,
          copieer_als_commentaar:
            huidige_toestand := copieer_als_commentaar,
          copieer_niet:
            output.open_commentaar;
            huidige_toestand := copieer_als_commentaar
        esac
      ); # copieer_commentaar #

.DE
.DS L
      proc vorige_toestand()
      (
        case huidige_toestand of
          copieer_als_SUMMER:
            huidige_toetstand := vorige_toestanden.delete,
          copieer_als_commentaar:
            output.sluit_commentaar;
            huidige_toetstand := vorige_toestanden.delete
        esac
      ); # vorige_toestand #

.DE
.DS L
      proc put()
      (
        if huidige_toestand ~= copieer_niet
        then
          output.copieer_symbool;
        fi
      ); # put #

end FILTER;
.DE
.ds RH \ 
.bp
.SH
Bijlage B
.ds RH Bijlage\ B
.PP
Deze bijlage beschrijft de SUMMER procedure die nagaat of de omgeving
veranderd is door de declaratie van "nieuw_element". Hiertoe wordt het er
volgens de volgorde van declaraties bijbehorende oude omgevingsbeschrijvend
object opgezocht en worden de twee vergeleken.
.DS L
proc de_omgeving_veranderd_door(nieuw_element)
(
  var oud_element := volgend_element_uit_omgeving_beschrijving;
  if type(oud_element) = type(nieuw_element) fails
  then
    freturn
  else
    case type(nieuw_element) of
      variabele_beschrijving:
      constante_beschrijving: 
        return(oud_element.naam =~ nieuw_element.naam),
      procedure_beschrijving:
      operator_beschrijving:
        return(oud_element.naam =~ nieuw_element.naam |
             oud_element.aantal_parameters =~
             nieuw_element.aantal_parameters),
      klasse_beschrijving:
        return(oud_element.naam =~ nieuw_element.naam |
             oud_element.velden =~
               nieuw_element.velden |
             oud_element.associaties =~ nieuw_element.associaties)
    esac
  fi
);
.DE
.ds RH \ 
.NH
Stap 1: Extern genereren van de omgevingsbeschrijvingen
.ds RH Stap\ 1:\ Extern\ genereren\ van\ de\ omgevingsbeschrijvingen
.NH 2
Doel
.PP
In de eerste stap naar incrementele vertaling van SUMMER wordt de omgeving als
een constant gegeven beschouwd. Tijdens een incrementele vertaalsessie wordt
de nieuwe omgevingsbeschrijving met de oude veregeleken. Blijkt dat er een
verandering in de omgeving plaatsgevonden heeft, dan moet alle SAM code
opnieuw gegenereerd worden om de juiste verbanden tussen
omgeving-afhankelijke en omgeving-bapalende taal-elementen
te garanderen.
.PP
De omgeving wordt in SUMMER beschreven zodat in de vertaler alleen de routines
voor het herkennen van en genereren van code voor include-statements veranderd
hoeven te worden.
.PP
Ten bate van de linkage-editor, die de SAM code files samen met de
interpretator tot een executeerbaar programma maakt, is het nodig een aantal
labels globaal te declareren.
.NH 2
Inhoud van de omgevingsbeschrijvingen
.PP
In de omgevingsbeschrijving moeten alle in 3.1 genoemde taal-elementen
opgenomen worden, daarnaast moet hij volledig aan de SUMMER grammatica
voldoen. Dit is te bereiken door de bodies van procedures en
initialisaties van globale variabelen en klassen weg te laten.
.PP
In de huidige implementatie behoren echter de initialisaties van globale
variabelen, string-constanten en de verborgen globale variabelen ook tot de
omgeving. Door deze worden twee tabellen bepaald: de
stringtabel en de globale initialisaties.
Omdat code voor deze taal-elementen alleen tijdens totale vertaalsessies
gegenereerd wordt en er geen referenties naar bestaan, hoeven de
omgevingsbeschrijvingen hiervoor niet geparsed te worden. Dit komt goed uit,
want ze kunnen nu als commentaar opgenomen worden, wat overal tussen de
SUMMER symbolen in een programma geplaatst mag worden. Verandering van deze
omgevingsbepalende taal-elementen kan nu nog wel gedetecteerd worden.
.PP
Van de verborgen variabelen behandel ik in deze fase alleen de
case-expressies. Deze worden in hun geheel uit de source overgenomen en
gescheiden door dyadische-operatoren. For-expressies blijken vrijwel
niet buiten procedure-bodies gebruikt te worden, en laat ik vanwege de 
problemen die ze met zich mee brengen voorlopig buiten beschouwing.
.NH 2
De generator voor omgevingsbeschrijvingen
.PP
In eerste instantie is de generator voor de omgevingsbeschrijvingen een
tweede programma naast de vertaler. Dit programma heeft als taak de omgeving die
een bepaalde SUMMER module bepaald in SUMMER te beschrijven.  Het is als het
ware een filter dat op basis van de grammatica voor elk symbool beslist of
het in de omgevingsbeschrijving hoort of niet. Er zijn drie acties op een
symbool mogelijk:
.IP 1)
als SUMMER in de omgevingsbeschrijving plaatsen;
.IP 2)
als commentaar in de omgevingsbeschrijving plaatsen;
.IP 3)
niet in de omgevingsbeschrijving plaatsen;
.LP
Zo onderneemt de generator voor het volgende SUMMER programma:
.DS
program hello()
  put('Hello world')
.DE
de acties:
.TS
center, box;
c c
l c.
symbool	gerelateerde actie
_
"program"	1
"hello"	1
"("	1
")"	1
"put"	3
"("	3
"'Hello world'"	2
")"	3
.TE
wat als omgevingsbeschrijving:
.DS
program hello()#'Hello world'#
.DE
oplevert.
.PP
Als implementatie heb ik voor een klasse FILTER
gekozen die door de parser bestuurd
wordt. De parser biedt het filter elk gelezen symbool aan, en geeft
commando's om het in de juiste toestand te zetten. De acties van het filter
worden op basis van de toestand ondernomen. De implementatie van de
generator voor omgevingsbeschrijvingen is in bijlage A te vinden.
.NH 2
Veranderingen aan de vertaler
.PP
De vertaler moet voor het lezen van een programma-module beslissen of de
omgevingsbeschrijving danwel de source-module gelezen wordt. Lezen (en vertalen)
van de source-module is nodig als:
.IP 1)
Het bekend is dat een van de modulen zodanig veranderd is dat de omgeving voor
de anderen gewijzigd is.
.IP 2)
Als de object-module ouder is dan de bijbehorende source-module.
.PP
Tijdens een incrementele vertaalsessie moet er gecontroleerd 
worden of de omgeving veranderd is
door na het lezen van een source module
de oude omgevingsbeschrijving met de nieuwe te
vergelijken. Blijken deze verschillend te zijn, dan moeten
alle source-modulen vertaald worden. Hiertoe wordt deze vertaalsessie
gestopt en wordt er \*'e\*'en gestart waarbij alle modulen vertaald worden.
.PP
De vertaalde include-files bevatten alleen procedure-bodies. Alle
omgeving-bepalende SAM code wordt opgeslagen bij de code voor de
"hoofd-module", dit is de source-module die correspondeert met
de wortel van de hierarchie van include-files. De "hoofd-module" wordt alleen
bij volledige vertaling gegenereerd. De consequentie hiervan is, dat
voor deze module geen incrementele vertaling mogelijk is.
.NH 2
Evaluatie
.PP
Doordat er nog veel taal-elementen deeluitmaken van de omgeving is het
rendement van de incrementele vertaling laag, er wordt vaak een totale
vertaalsessie gestart. Een tweede, hiermee samenhangend, nadeel is dat
de omgevingsbeschrijvingen nogal groot zijn en dat de besparing die
het lezen van omgevingsbeschrijvingen met zich mee brengt nogal klein is,
in vergelijking tot het lezen van de hele source-teksten.
.KF
.sp 38
.ce
figuur 5, resultaat van de eerste stap
.KE
.PP
De tijden die uit de metingen aan de benchmark kwamen zijn enigzinds
bedroevend. De overhead veroorzaakt door het voor een tweede maal parsen
van de teksten
ten bate van de samenvattingen blijkt nogal groot te zijn (zie tabel\ 1 en
figuur\ 5). In het figuur en de tabel zijn naast de resultaten van "sep1"
die van "sumc", de oude vertaler, opgenomen.
De nieuwe vertaler die deze stap opgeleverd heeft blijkt bij totale vertaling
een overhead van
ongeveer 90 seconden op de oude te hebben. Voor een deel kan dit een gevolg
van de subprocessen die de nieuwe vertaler start zijn, maar dat lijkt mij
niet een dekkend argument. Er moet nog ergens oponthoud veroorzaakt worden,
waar dat is ga ik niet nader onderzoeken.
.PP
De namen boven de lijnen in de grafiek geven aan welk
programma verantwoordelijk is voor het direct onderliggende deel van de
tijd. Zo is duidelijk te zien dat de generator voor de omgevingsbechrijvingen
een gote overhead met zich mee brengt.
.KS
.TS
center;
c s
l r.
Vertaaltijden met behulp van "sumc"

vertaler	679 sec
assembler	81 sec
linkage-editor	10 sec
totaal	769 sec


.TE
.KE
.KS
.TS
center;
c s
c s
l r.
Vertaaltijden met behulp van "sep1"
als 100% van de tekst vertaald is

vertaler	769 sec
generatie samenvattingen	414 sec
assembler	79 sec
linkage-editor	14 sec
totaal	1277 sec


.TE
.KE
.KS
.TS
center;
c s
c s
l r.
Vertaaltijden met behulp van "sep1"
als 0% van de tekst vertaald is

vertaler	224 sec
generatie samenvattingen	0 sec
assembler	0 sec
linkage-editor	14 sec
totaal	238 sec
.TE
.KE
.ce
tabel 1
.PP
In de komende fasen wil ik mij vooral op de volgende twee punten
toeleggen. Ten eerste zal het aantal omgeving-bepalende taal-elementen
teruggebracht moeten worden. Hierbij denk ik vooral aan die taal-elementen
die vanwege de implementatie omgeving-bepalend zijn.
.PP
Ten tweede blijkt uit metingen aan het parsen (zonder verdere acties) dat
een groot deel van de overhead, veroorzaakt door het genereren van de
samenvattingen teruggedrongen kan worden. Het blijkt bijvoorbeeld 324
seconden te kosten om
de hele benchmark alleen te parsen. Dit werk wordt in de huidige versie twee
maal gedaan. Door het genereren van samenvatingen in de parser te
integreren kan dit grotendeels bespaard worden.
.ds RH \ 
.NH 1
Stap 2: Verminderen van het aantal omgeving-bepalende taal-elementen
.ds RH Stap\ 2:\ Verminderen van het aantal omgeving-bepalende taal-elementen
.NH 2
Doel
.PP
Het doel van deze tweede stap naar incrementele vertaling is het kleiner
maken van het aantal omgeving-bepalende taal-elementen. De meeste
zijn omgeving-bepalend omdat ze iets over de globale
verbanden in het programma zeggen. Omdat ik de vertaler deze verbanden op
wil laten lossen kunnen ze niet uit de omgevingsbeschrijving verwijderd
worden. Voor de volgende taal-elementen geldt dat niet of in mindere mate:
.IP 1)
string constanten en alles wat daarmee samenhangt.
.IP 2)
initialisaties van globale variabelen.
.IP 3)
verborgen variabelen.
.IP 4)
fetch- en store-associaties voor klasse velden
.PP
Hiervan komen 1) en 2) voor deze stap in aanmerking. De verborgen variabelen
niet omdat ze kwa aard sterk met de globale veriabelen overeenkomen.
Hierover meer in sectie 10.4. De veld informatie moet in de omgevingsbeschrijving
staan, omdat de code die hier mee overeenkomt omgevingbeschrijvend is. Zou
ik hierin wijzigingen toestaan, dan kan het vergelijken van een oude en een
nieuwe omgevingsbeschrijvig niet meer op een zo simpele wijze gedaan worden.
.PP
Een tweede verbetering die ik in deze fase aan zal brengen is het isoleren
van de code voor het initialiseren van de datastructuur van de SAM.
Door dit in een aparte object-module op te
slaan is voor alle source-modulen incrementele vertaling mogelijk.
.NH 2
Structuur van globale initialisaties
.PP
De code voor globale initialisaties vertoont een geneste structuur; de
initialisatie code voor source-module "source-i", die source-module "source-j"
omvat, wordt onderbroken door de initialisatie-code van source-module
"source-j".
Een dergelijke structuur is ook te bereiken door aan iedere module een
initialisatie-procedure toe te voegen.  De initialisatie-procedure van
source-module "source-i" heeft op de plaats waar eerst de initialisatie-code
voor source-module "source-j" stond een aanroep van de bij die source-module
horende initialisatie procedure.
.NH 2
Opdelen van de stringtabel
.PP
Het opdelen van de stringtabel is gerealiseerd door \*'e\*'en stringtabel per
object-module te genereren. De generatie van een stringtabel gebeurt verder
net als in de oude SUMMER vertaler.
.NH 2
Herindeling SAM code
.PP
De herindeling van de SAM code komt er op neer dat voor de omgeving en
voor elke module een code file gegenereerd wordt. De file die de
omgevingbeschrijft wordt alleen bij volledige vertaling gegenereerd.
.NH 2
Verandering omgevingsbeschrijving
.PP
De omgevingsbeschrijvingen-generator moet aangepast worden omdat er taal-elementen uit de omgeving verdwenen zijn. Voor het samenvatten van de
verborgen variabelen (case-expressies) heb ik het nul-karakter gekozen, een
kleine uitbreiding van SUMMER, die alleen tijdens het parsen van
samenvattingen geldig is. Het herkennen van het nul-karakter gebeurt in de
scanner:
.DS
if een_nul-karakter & 
  deze_source_is_een_omgevingsbeschrijving
then
  declareer_een_verborgen_variabele
else
  ERROR
fi;
.DE
.NH 2
Evaluatie
.PP
Het kleiner zijn van de omgevingsbeschrijvingen heeft een tweeledig gevolg.
Ten eerste is de kans dat er totale vertaling plaats moet vinden afgenomen.
Ik schat dat de eerste versie in ongeveer 75 procent van de gevallen
overging tot hervertaling, terwijl dit nu onder de 50 ligt. De mogelijke
afwijkingen van de schattingen zijn groot omdat er weinig meetgegevens zijn.
Na een maand meten kwam ik voor deze versie tot:
.TS
center;
l c.
totale vertaling	22 maal
incrementele vertaling	18 maal
.TE
.ce
tabel 2
.PP
Ten tweede is het vertaalproces versneld, doordat de omgevingsbeschrijvingen
kleiner geworden zijn. Ze zijn nu ongeveer half \*`a een derde maal zo groot als die van de
vorige versie. Het effect hiervan is dat het lezen van de
omgevingsbeschrijvingen ongeveer drie maal zo snel geworden is. De
nulvertaling, waarbij alleen ongewijzigde teksten vertaald worden, duurde
eerst 238 seconden nu zijn dat er nog 83.
.ds RH \ 
.NH 1
Stap 3: Generatie van omgevingsbeschrijvingen door de vertaler
.ds RH Stap\ 3:\ Generatie\ van\ omgevingsbeschrijvingen\ door\ de\ vertaler
.NH 2
Doel
.PP
In deze derde stap naar incrementele vertaling voor SUMMER, wil ik het
genereren van samenvattingen door de vertaler laten doen. Voordeel hiervan
is dat een tekst die vertaald wordt niet twee maar \*`e\*`en maal geparsed
moet worden. Bij de evaluatie in 5.5 bleek hoeveel deze optimalisatie kan
besparen.
.NH 2
Realisatie
.PP
Deze optimalisatie bestaat uit het toevoegen van de code van de
samenvattingen-generator aan de vertaler. Om tijdens het parsen van een
omgevingsbeschrijving geen tweede te genereren, heb ik voor die situatie
een klasse NULLFILTER gedefinieerd. Deze herdefinieert de klasse FILTER
waarbij alle acties tot nul-acties gereduceerd zijn.
.NH 2
For-expressies
.PP
De verborgen variabelen die voor for-expressie buiten procedure-bodies
gegenereerd worden konden tot nu toe niet in een omgevingsbeschrijving
geplaatst worden, omdat de generator hierover geen informatie heeft. Daar de
vertaler dat wel heeft kunnen de for-expressies nu altijd op correcte wijze
afgehandeld worden, door de omgevingsbeschrijving voor een verborgen
variabele tijdens de declaratie daarvan te genereren.
.NH 2
Evaluatie
.PP
Deze stap heeft tot het gewenste resultaat geleid. De overhead veroorzaakt
door het genereren van de omgevingsbeschrijvingen is nu nog 90 seconden,
iets minder dan ik in 5.5 verwacht had, aangenomen dat de onverklaarde
overhead uit de vorige fase nog bestaat.
Hoe de tijden nu verdeeld zijn is
in tabel\ 3 en figuur\ 6
te zien. De vertaler kan nu nog versneld worden door de
omgevingsbeschrijvingen binair op te slaan.
.KF
.sp 31
.QP
figuur\ 6, de resultaten van sep3, de onderbrokenlijn geeft het resultaat
van "sumc", de oude vertaler, weer.
.KE
.KS
.TS
center;
c s
c s
l r.
Vertaaltijden met behulp van "sep3"
als 100% van de tekst vertaald is

vertaler	848 sec
assembler	82 sec
likage-editor	11 sec
totaal	941 sec


.TE
.KE
.KS
.TS
center;
c s
c s
l r.
Vertaaltijden met behulp van "sep3"
als 0% van de tekst vertaald is

vertaler	72 sec
assembler	0 sec
linkage-editor	11 sec
totaal	83 sec
.TE
.KE
.ce
tabel 3
.sp
.ds RH \ 
.NH
Stap 4: Een binair gerepresenteerde omgeving
.ds RH Stap\ 4:\ Een\ binair\ gerepresenteerde\ omgeving
.NH 2
Doel
.PP
Het doel van deze vierde stap naar incrementele vertaling is het lezen van
omgevingsbeschrijvingen te versnellen door deze als binair gerepresenteerde
objecten op te slaan. In de nu bereikte situatie worden deze taalobjecten in
SUMMER beschreven wat als nadeel heeft dat de parser ze steeds moet
samenstellen. Door ze binair op te slaan kan de vertaalslag steeds
achterwege blijven wat zeker een besparing op zal leveren.
Problemen die zich voordoen zijn:
.IP 1)
Hoe worden de omgevingsbeschrijving ge\*:interpreteerd.
.IP 2)
Hoe wordt, tijdens incrementele vertaling, de nieuw gegenereerde omgevingsbeschrijving met de oude vergeleken.
.NH 2
Omgevingsbeschrijving op basis van objecten
.PP
Nu de beschrijving van de omgeving uit een aantal objecten, in plaats van een
beschrijving daarvan, bestaat moet de parser uitgebreid worden met een
mogelijkheid om deze objecten te interpreteren. Daarvoor is er voor een
object, naast beschrijvende velden, een interpretatie procedure gedefinieerd.
.PP
Zo had de declaratie:
.DS
var totaal := 0;
.DE
de omgevingsbeschrijving:
.DS
var totaal;
.DE
en is deze als object:
.DS
variabele beschrijving:
  naam          => "totaal"
  interpretatie => Declareer een variabele "totaal"
.DE
.PP
Het evalueren van de interpretatie procedures wordt door de scanner verzorgd:
.DS
proc lees_karakter()
if een_SUMMER_tekst
then
  return(volgend_karakter)
else
  while volgend_omgevingbeschrijvend_object
  do
    interpreteer_het_object;
    if type(object) = 'include_beschrijving'
    then
      return('')
    fi;
  od
  return(einde_file)
fi;
.DE
.PP
Omdat de nesting van programma-modulen in de vertaler op een stack afgebeeld
is, is er niet voor twee wederzijds recursieve procedures gekozen waarvan de
\*'e\*'en SUMMER teksten leest en de ander omgevingsbeschrijvingen
interpreteert. Het bleek eenvoudiger om de interpretatie
aan de lees routine, die met een source-module gerelateerd is, over te
laten. Deze wordt "onderbroken" als er een source-module op de stack
geplaatst is om te bepalen of dat een omgevingsbeschrijving of een SUMMER
tekst is.
.NH 2
Het vergelijken van omgevingsbeschrijvingen
.PP
De tijdens incrementele vertaling gegenereerde omgeving-beschrijvende
objecten moeten met de overeenkomstige objecten uit de re\*:ele omgevingsbeschrijving vergeleken worden, om in het geval dat er een verandering
geconstateerd wordt een totale hervertaling te starten. Het is nu goed
mogelijk om de vergelijking op elk moment uit te voeren dat er een element gegenereerd wordt
te doen, zodat een omgevingsverandering in een zo vroeg mogelijk stadium
ontdekt wordt. Het algoritme voor het toevoegen van een omgevingbeschrijvend
element is:
.DS
proc voeg_omgevingsbeschrijvend_element_toe(element)
if dit_is_een_incrementele_vertaalsessie
then
  if de_omgeving_is_veranderd_door(element)
  then
    stop_sessie_en_start_totale_vertaling
  fi
else
  voeg_het_element_toe;
fi;
.DE
.PP
Het algoritme voor het vergelijken van een nieuw met een oud object is in
bijlage B te vinden.
.NH 2
Evaluatie
.PP
Het binair representeren van de omgevingsbeschrijvingen heeft de vertaler
sneller gemaakt, zoals verwacht werd. Vreemd is echter dat uit de
meetgegevens blijkt dat deze vertaler ("sep4") in alle gevallen
sneller is dan de
oude vertaler ("sumc"). In het geval van totale vertaling is het verschil
ongeveer 15 seconden, wat enerzijds
door een meetfout veroorzaakt kan zijn en anderzijds door het feit dat
bepaalde tabellen in de vertaler verkleint zijn doordat deze opgesplitst
zijn.
.PP
Naast de totale vertaling is ook de nul vertaling versneld, dit is een
direct gevolg van het binair representeren van de omgevingsbeschrijvingen. In
tabel\ 4 en figuur\ 7 heb ik de meetgegevens voor "sep4" weergegeven.
.KF
.sp 26
.QP
figuur 7, het resultaat van "sep4", de onderbrokenlijn geeft het resultaat
van "sumc" weer.
.KE
.KS
.TS
center;
c s
c s
l r.
Vertaaltijden met behulp van "sep4"
als 100% van de tekst vertaald is

vertaler	663 sec
assembler	82 sec
linkage-editor	14 sec
totaal	759 sec


.TE
.KE
.KS
.TS
center;
c s
c s
l r.
Vertaaltijden met behulp van "sep4"
als 0% van de tekst vertaald is

vertaler	47 sec
assembler	0 sec
linkage-editor	14 sec
totaal	61 sec
.TE
.ce
tabel 4
.KE
.PP
Doordat de omgeving nu met behulp van objecten, en niet meer als een tekst
die objecten beschrijft, gerepresenteerd is, is het mogelijk een oude en
nieuwe omgevingsbeschrijving wat selectiever te vergelijken. In de volgende
stap wil ik daar gebruik van maken.
.ds RH \ 
.NH
Stap 5: Variatie in de velden
.ds RH Stap\ 5:\ Variatie\ in\ de\ velden
.NH 2
Doel
.PP
Het doel van deze vijfde stap naar incrementele vertaling is, door variatie
toe te staan in de veld definitie van een klasse,
het rendement van het mechanisme te verhogen. Dit is mogelijk doordat de
SAM instructie voor de selectie van elk type veld hetzelfde is. Tijdens
executie van het programma wordt er met behulp van de field-swich bepaald of
selectie voor een bepaalde klasse plaats mag vinden, en welke procedure er
feitelijk uitgevoerd moet worden.
.PP
Het toestaan van wijzigingen in de veld definities betekent dat de
field-swiches per vertaalsessie gegenereerd moeten worden. Problemen die
zich voor doen zijn:
.IP 1)
Een veld moet altijd de zelfde index toegewezen krijgen.
.IP 2)
Wat wordt er gedaan als de definitie van een veldsymbool helemaal niet meer
voorkomt.
.NH 2
Toekennen lokaties
.PP
Het toekennen van lokaties is gerealiseerd op basis van de verdeling in de
vorige vertaalsessie. Hiervoor wordt een veldlokatietabel bijgehouden,
die voor elk veld de index in de field-vector bevat. Het toekennen gaat
volgens het volgende algoritme:
.DS
proc alloceer_field-vector_index(naam)
(
  if field-vector_indices[naam] = undefined
  then
    field-vector_indices[naam] := 
      field-vector_indices.volgende_vrije_lokatie
  fi;
  return(field-vector_indices[naam])
);
.DE
.PP
Bij het starten van een totale vertaling wordt de tabel "field-vector_indices"
als leeg ge\*:initializeerd.
.NH 2
Verdwenen velddefinities
.PP
Een ongebruikte lokatie mag niet voor een ander veld in gebruik genomen
worden, omdat niet bekend is of er nog een selectie van een veld dat ermee
overeen kwam bestaat. Nu zijn er, als blijkt dat een veld niet meer
gedefinieerd is, de volgende mogelijkheden:
.IP 1)
Beschouw het verdwijnen van de definitie als een omgevingsverandering en
start een totale vertaalsessie. Na afloop van die vertaling blijkt dan of dat
veld nog geselecteerd wordt.
.IP 2)
Beschouw het veld als gedefinieerd, maar niet als geassocieerd met een
klasse. De gebruiker kan hierop geattendeerd worden.
.PP
De tweede benadering past het beste bij het karakter van
incrementele vertaling
.NH 2
Generatie veld- en klasse-vectoren
.PP
De omgevingbeschrijvende SAM code file moet gesplitst worden in \*'e\*'en
voor de globalen-vectoren en \*'e\*'en voor de klasse- en veld-vectoren. De
eerste zal alleen bij totale vertaling gegenereerd worden, SAM code voor de
klasse- en veld-vectoren moet gegenereerd worden als van een klasse de
velddefinitie veranderd is. De verandering moet ook in de omgevingsbeschrijving
doorgevoerd
worden, omdat anders bij een volgende regeneratie van de klasse- en
veld-vectoren voor die klasse de oude situtatie weer gerecostrueerd kan
worden.
.NH 2
Evaluatie
.PP
Aan deze verbetering zijn geen metingen verricht vanwege tijdsgebrek. Ik ben
er echter van overtuigt dat het hier om een verbetering gaat. In ruil voor
een rendementsverhoging is in de gevallen dat nieuwe klasse- en
veld-vectoren gegenereerd moeten worden de vertaler iets langer bezig en er
is een assembleer sessie nodig. Daar deze twee activiteiten ook bij totale
vertaling plaatsvinden en daar een fractie van de tijd op zich nemen, mag
dit geen naam hebben.
.ds RH \ 
.NH
Stap 6: Aanzet tot incrementele vertaling voor SUMMER
.ds RH Stap\ 6:\ Aanzet\ tot\ incrementele\ vertaling\ voor\ SUMMER
.NH 2
Doel
.PP
Het tot nu toe verrichtte werk heeft geleid tot een effici\*:entere vertaler
voor SUMMER die gebaseerd is op incrementele vertaling. In deze stap wil ik
verkennen in hoeverre de vertaler nog niet aan de eisen van incrementele
vertaling voldoet en een aanzet geven tot de oplossing van eventuele
problemen. Dit hoofdstuk kan dan ook gezien worden als een aanzet tot een
vertaler voor
SUMMER die in alle situaties gebruik van een incrementele vertaaltaktiek
maakt.
.NH 2
Probleemgebieden
.PP
Bij incrementele vertaling moet een programma-module vertaald worden als:
.IP 1)
er voor de source-module geen (jongere) object-module bestaat.
.IP 2)
de betekenis van een source-module veranderd is door een verandering van een
declaratie in een andere source-module.
.PP
De nieuwe SUMMER vertaler voldoet niet aan dit criterium. Na
een verandering van een declaratie die deel uitmaakt van de omgeving moeten
alle modulen vertaald worden omdat:
.IP 1)
de wijziging van de volgorde van declaraties heeft meestal als zijeffect dat
alle volgende declaraties veranderd lijken. Dit is een gevolg van
sequenti\*:ele opbouw van de globalen vector. Als er een declaratie mist,
dan hebben alle volgende globalen een index 1 lager
dan in de voorgaande vertaalsessie.
.IP 2)
er niet bekend is in welke modulen een bepaald symbool gebruikt wordt.
.PP
Door gebruik te maken van dergelijke informatie zou het vertaalproces
alsvolgt, kunnen lopen:
.DS
lees source-modulen waarvan de object-modulen
  ouder zijn of niet bestaan;
los nog niet gedefinieerde symbolen op, 
  op basis van de oude symbooltabel;
lees source-modulen waarin referenties naar
  begrippen staan waarvan bekend is dat hun
  declaraties veranderd zijn;
genereer code voor alle gelezen source-modulen;
.DE
.PP
In dit proces wordt geen rekening gehouden met volgorde afhankelijkheid
die SUMMER kent. Dit komt nog aan bod in 10.5.
.NH 2
De oude symbooltabel
.PP
Bij deze versie van incrementele vertaling zal als omgevingsbeschrijving
gebruik gemaakt worden van de symbooltabel uit de voorgaande vertaalsessie.
Deze zal ik verder oude symbooltabel noemen, de symbooltabel
die tijdens een incrementele vertaalsessie aangemaakt wordt noem ik de
nieuwe.
Als na vertalen van de
source-modulen
blijkt dat er nog symbolen zijn die niet gedeclareerd zijn, dan worden die met
behulp van de oude symbooltabel opgelost. Daarbij gelden de volgende
regels:
.IP 1)
Alle symbolen die in niet gelezen modulen gedeclareerd worden, worden als
gedefinieerd beschouwd.
.IP 2)
De declaratie ven een symbool mag veranderd worden of verdwijnen als de module
waar de oude declaratie plaatsvond gelezen is.
.IP 3)
Er mag altijd een declaratie voor een nieuw symbool toegevoegd worden.
.PP
Na het vergelijken van de oude en nieuwe symbooltabel worden eerst
de niet meer gebruikte lokaties in de vectoren verzameld om deze vervolgens aan nieuwe
declaraties toe te kennen.
.NH 2
Cross-reference informatie
.PP
Om het werken met twee symbooltabellen, als in de vorige paragraaf geschetst
werd, uit te kunnen voeren is het nodig dat bekend is in welke module een
symbool gedeclareerd is en waar ernaar gerefereerd wordt.
.PP
De referenties aan een symbool worden in een vector bijgehouden
met voor elke module een bit of het symbool daar voorkomt. De index
van een "1" bit is, net als bij variabelen en fields, een offset
in de modulen vector.
.PP
Het invullen van de referentie vectoren vindt tijdens codegeneratie plaats.
Voor die tijd worden alle referenties
met betrekking tot de modulen waarvoor code gegenereerd zal worden op "0"
gezet, om niet meer geldende referenties te niet te doen.
.NH 2
Volgorde afhankelijkheden
.PP
SUMMER kent drie vormen van volgorde afhankelijkheid:
.IP 1)
Een constante moet gedeclareerd zijn voordat deze gebruikt kan worden.
.IP 2)
Een klasse moet gedeclareerd zijn voordat deze in een subklasse definitie
voor mag komen.
.IP 3)
Het include-statement, wat de hierarchie van de source-modulen beschrijft.
.PP
Controle op de eerste twee regels is mogelijk door voor deze taal-elementen
in de cross-reference informatie (absolute) regelnummers op te nemen.
Deze moeten voor de plaats van definitie steeds
groter zijn dan voor die van van het eerste gebruik. Om het eerste gebruik
te kennen nadat de plaats daarvan gewijzigd is, moet van elke module
bekend zijn waar in dat module een volgorde afhankelijk taal-element voor het eerst
gebruikt wordt. Het include-statement kan niet op deze wijze opgelost
worden, omdat dit en fysieke volgorde beschrijft.
.PP
Het is dan ook beter om de volgorde afhankelijke taal-elementen als van ouds
in een omgevingsbeschrijving op te nemen.
Voor een referentie aan een
constante betekent dit dat de naam opgenomen wordt, voor een constante
declaratie de naam en de niet ge\*:evalueerde waarde, voor een klasse de
subklasse declaratie en de veld informatie,
en voor een include-statement de naam van de module
waar het om gaat.
.NH 2
Afhandeling constante declaraties
.PP
Bij een constante declaratie in een omgevingsbeschrijving wordt de niet
ge\*:evalueerde waarde opgenomen om te kunnen zien of deze door een
zijeffect gewijzigd is. Als dit in de tweede leessessie van de vertaler
gedaan zou worden, zou ook dan kunnen blijken dat er een constante
declaratie vanwege een zijeffect gewijzigd is. Om dergelijke iteraties te
vermijden wordt tijdens iedere vertaalsessie de initialisatie expressie van
een constante ge\*:evalueerd en de constante gedeclareerd.
.NH 2
Afhandeling subklassen
.PP
In SUMMER worden de velden van een klasse waarvoor een super klasse bestaat
voor een deel door die super klasse bepaald. Dit heeft, volgens het tweede
kriterium voor hervertaling, als gevolg dat als de veld-definitie van een
klasse veranderd alle subklassen daarvan hervertaald moeten worden.
.PP
Dit zou inderdaad het geval zijn als de field-switches in de bij de klasse
declaratie horende
object-module opgeslagen waren. Nu is dat niet het geval, maar zijn de
field-switches als omgeving-beschrijvende code opgeslagen (zie 3.2). Om wel
de goede "fieldswitches" te genereren, moet de veld informatie van een
klasse in de omgevingsbeschrijving staan en moet er voor elke subklasse in
een omgevingsbeschrijving een superklasse expansie plaatsvinden.
.NH 2
Bepalen en lezen van te hervertalen modulen
.PP
Nadat de kwa tekst gewijzigde source-modulen gelezen zijn moeten de
zijeffecten van deze wijzigingen onderzocht worden en op basis daarvan
eventueel enkele source-modulen hervertaald worden. Een programma-module die
nog niet vertaald is moet hervertaald worden als hierin referenties staan naar
declaraties die gewijzigd zijn.
.PP
Tijdens de tweede leessessie van de vertaler zijn er de volgende problemen:
.IP 1)
Alle symbolen die gedeclareerd worden zijn in feite al gedeclareerd.
.IP 2)
Include-statement's hebben niet meer als gevolg dat er een nieuwe source-module
gelezen moet worden.
.IP 3)
De formulering van de grammatica staat niet toe dat er hervertaling
plaatsvindt.
.PP
De problemen 1) en 2) zijn eenvoudig op te lossen door betreffende acties op
basis van de toestand van de vertaler te nemen. Om 3) op te lossen, is een
wijziging van de formulering van de SUMMER grammatica mogelijk:
.DS
<summmer_programma> ::=
  ( <declaratie> ...
  | <include_file> ...
  | 'eof_include' ...
  | 'eof_veranderde_modulen'
    /bepaal_te_hervertalen_modulen/ )*.
.DE
Het stop symbool voor een <summer_programma> wordt door de scanner
gegenereerd als alle source-modulen die hervertaald moeten worden geparsed
zijn.
.ds RH \ 
.NH
Slot
.ds RH Slot
.PP
Na vijf stappen in de richting van incrementele vertaling voor SUMMER gedaan
te hebben is er een vertaler ontstaan die deze taktiek onder de volgende
voorwaarden toepast:
.IP 1)
Dat aan een symbool altijd het zelfde type declaratie gerelateerd is.
.IP 2)
De hierarchie van programma-modulen ongewijzigd blijft.
.IP 3)
Als de waarden van globale constanten niet gewijzigd worden.
.IP 4)
Dat het aantal parameters van de verschillende klassen en globale procedures
niet wijzigd.
.PP
Bij totale vertaling vertoond de nieuwe vertalergeen overhead om de oude,
een onverwacht maar bevredigend resultaat.
.PP
In stap\ 6 staat beschreven hoe de vertaler ge\*:optimaliseerd kan worden om,
als niet aan bovenstaande voorwaarden voldaan is, zo weinig mogelijk te
hervertalen. Tot nu toe wordt er in dergelijke situaties een tottale vertaal
sessie gestart.
.PP
Dan wil ik Paul Klint bedanken voor de hulp bij het tot staan komen van dit
verslag en Arthur Veen voor de idee\*:en en aanmoediging om het project op
deze manier op te zetten.
.bp
.SH
Literatuur:
.IP [1]
P. Klint,
.B
From SPRING to SUMMER,
.R
Matematisch centrum, Amsterdam (1982)
.IP [2]
G. Florijn & G. Rolf,
.B
PGEN - a general purpose parser generator,
.R
Matematisch centrum, Amsterdam (1981)
