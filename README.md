# DB_MySql_Appunti
  Introduzione a MySql, sql e procedurale

#Links e risorse utili
## Documentazione ufficiale
  https://dev.mysql.com/doc/refman/8.0/en/

## Databases di esempio
  ### Employees
  https://dev.mysql.com/doc/employee/en/employees-installation.html
  https://github.com/datacharmer/test_db

  ### Sakila
  https://dev.mysql.com/doc/sakila/en/
  
  ### Scott (Oracle like)
  https://github.com/pmarconcini/DB_MySql_Appunti/blob/master/MySql_DB_scott_oracle_like.sql

# Convenzioni e regole di scrittura
## Testi e caratteri speciali
  I testi sono racchiusi tra apici singoli o doppi. Sequenze ti testi espliciti sono automaticamente concatenati:
  
    select 'a string' c1, "another string" c2, 'a' ' ' 'string' c3;
    
  ==>![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/953a338c-a62a-49e6-999f-4cc1f0da16be)

  nb: se è abilitato il parametro ANSI_QUOTES è utilizzabile solo l'apice singolo per l'identificazione del testo (mentre il doppio apice è sempre utilizzabile come identificatore).

  E' possibile specificare il set di caratteri da applicare a un testo anteponendo il formato (i 3 esempi seguenti sono equivalenti):
    
      SELECT N'aeiouèéùòàì' c1, n'aeiouèéùòàì' c2, _utf8'aeiouèéùòàì' c3;

  ==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/7bed6f38-723e-4d49-aa00-4378bcc92dc3)

  Il backslash (\) è il carattere di escape di una serie di caratteri:
  - \'	Apice singolo (ma anche due apici singoli se l'identificatore di testo è un apice singolo)
  - \"	Apice doppio (ma anche due apici doppi se l'identificatore di testo è un apice doppio)
  - \b	Backspace
  - \n	Nuova linea
  - \r	Return carriage
  - \t	Tab
  - \\	Backslash
  - \%	Percentuale
  - \_	Underscore

## Numeri e date
  Il separatore decimale è il punto. 
  I numeri in MySql possono essere esatti (tipi INTEGER e DECIMAL e derivati) o approssimati (FLOAT e DOUBLE e sinonimi). Numeri presentati con la notazione scientifica sono approssimati.

  Le date e gli orari possono essere rappresentati (e autoconvertiti) in vari formati testuali: 'YYYY-MM-DD', 'YYYYMMDD', 'YYYY-MM-DD HH:MI:SS', 'YYYYMMDDHHMISS'.
  E' possibile forzare la conversione anteponendo il formato voluto:

    select DATE '19750607' c1, DATE '1975-06-07' c2, TIME '192800' c3, TIME '19:28:00' c4, 
    TIMESTAMP '19750607192800' c5, TIMESTAMP '1975-06-07 19:28:00' c6;

  ==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/b8121c38-04cc-42f5-8101-d2c224f339f7)

  nb: i caratteri di separazione possono essere diversi da quelli indicati così come l'anno può essere espresso in 2 byte
  
  Con DATETIME e TIMESTAMP è possibile specificare anche la parte decimale dei secondi (fino a 6 decimali di precisione).
  Specificando l'anno in 2 byte MySql presume che con valori 70-99 ci si riferisca al range 1970-1999 e con valori 00-69 al range 2000-2069.

  Nel caso in cui un testo debba essere convertito in orario MySql procede secondo la seguente regola: 2 byte > SS, 4 byte MISS, 6 byte > HHMISS

## Booleani e valore nullo
  I valori booleani sono TRUE e FALSE, NON sono case sensitive e corrispondono rispettivamente ai valori 1 e 0.

  Il valore nullo corrisponde alla parola NULL, non case sensitive, ed è diverso dal testo nullo (doppio apice singolo o doppio apice doppio senza testo racchiuso). 
  MySql tratta la stringa nulla come testo e non come valore nullo. 
  Nell'esempio seguente in c1 si nota come il NULL non sia neanche confrontabile con il testo nullo (causando la propagazione del NULL) mentre in c3 si nota come la funzione coalesce (che cerca considera il primo valore non nullo nell'elenco) NON sostituisce il testo nullo con la "x":
  
    SELECT NULL = '' c1, coalesce(NULL, '') = '' c2, coalesce(NULL, 'x') = coalesce('', 'x') c3;

  ==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/2f3c7a6f-7b90-4d5d-83c5-239054e2bfdb)

## Naming convention
  Esistono un buon numero di regole per la naming convention degli oggetti:
  - L'identificativo può non essere quotato, ma deve esserlo se nel nome sono presenti caratteri speciali (in questo caso sarà sempre necessario quotare l'identificativo
  - I nomi sono automaticamnete conveertiti in Unicode (UTF-8)
  - L'identificativo può iniziare con un numero, ma solo se quotato
  - Il carattere per quotare è il backtick (`). Se il parametro ANSI_QUOTES è abilitato si può usare anche il doppio apice
  - L'identificativo deve essere unico per database
  - La lunghezza massima dei nomi è 64 byte in quasi tutti i casi
  - Gli identificativi sono non case sensitivi ma è buona prassi utilizzare sempre nomi lower case per non generare conflitti di compatibilità in un eventuale cambio di sistema operativo
  - Non è possibile utilizzare una parola chiave o una parola riservata come identificativo (l'elenco aggiornato è reperibile nella documentazione ufficiale)

## Intervalli temporali
  In alcune funzioni o attività è possibile indicare come parametro un intervallo temporale specificando la parola chiave INTERVAL seguita dalla quantità e da una unità di misura tra quelle esposte nell'esempio seguente:

    SELECT  DATE_ADD('2018-05-01',INTERVAL 1 DAY) c1, 
		DATE_SUB('2018-05-01',INTERVAL 1 YEAR) c2, 
        DATE_ADD('2020-12-31 23:59:59', INTERVAL 1 SECOND) c3, 
        DATE_ADD('2018-12-31 23:59:59', INTERVAL 1 DAY) c4, 
        DATE_ADD('2100-12-31 23:59:59', INTERVAL '1:1' MINUTE_SECOND) c5, 
        DATE_SUB('2025-01-01 00:00:00', INTERVAL '1 1:1:1' DAY_SECOND) c6,
        DATE_ADD('1900-01-01 00:00:00', INTERVAL '-1 10' DAY_HOUR) c7,
        DATE_SUB('1998-01-02', INTERVAL 31 DAY) c8,
        DATE_ADD('1992-12-31 23:59:59.000002', INTERVAL '1.999999' SECOND_MICROSECOND) c9;

  ==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/3224239b-7968-499a-9ca6-0745f852450a)

  nb: per tutte le unità di misura disponibili si rimanda alla documentazione ufficiale

  L'intervallo è utilizzabile anche nelle espressioni per aggiungere o sottrarre un dato periodo da una data o come fonte di dati:

    SELECT '2018-12-31 23:59:59' + INTERVAL 1 SECOND c1, 
       INTERVAL 1 DAY + '2018-12-31' c2,
       '2025-01-01' - INTERVAL 1 SECOND c3, 
       EXTRACT(YEAR FROM '2019-07-02') c4, 
       EXTRACT(YEAR_MONTH FROM '2019-07-02 01:02:03') c5;

  ==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/e492d6a2-3785-4a63-9749-23e9240ac285)
  
  Attenzione alla conversione del dato della quantità; è sempre preferibile eseguire un CAST:

    SELECT  CAST(6/4 AS DECIMAL(3,1)) c1,-- 1 ora e 30 minuti
  		6/4 c2,
  		DATE_ADD('1970-01-01 12:00:00', INTERVAL CAST(6/4 AS DECIMAL(3,1)) HOUR_MINUTE) c3,
  		DATE_ADD('1970-01-01 12:00:00', INTERVAL '6/4' HOUR_MINUTE) c4, -- 6 ore 3 4 minuti
  		DATE_ADD('1970-01-01 12:00:00', INTERVAL 6/4 HOUR_MINUTE) c5;-- 1 ora e 5000 minuti

  ==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/6eabc55f-393b-4499-8b65-1bd53d608ea3)
  



@WORK:
https://dev.mysql.com/doc/refman/8.0/en/query-attributes.html


*****************************************************************

# Informazioni su dabases e tabelle
  - L'istruzione SHOW DATABASES elenca i database gestiti sul server
  - La funzione DATABASE() ==> restituisce il nome del database corrente (restituisce NULL se non è selezionato alcun database)
  - L'istruzione SHOW TABLES ==> restituisce l'elenco delle tabelle del database corrente
  - L'istruzione DESCRIBE <tabella> ==> restituisce nome, tipo, nonnullità, indici ed eventuale contatore della tabella
  - L'istruzione SHOW CREATE TABLE <tabella> ==> produce lo script per la creazione della tabella
  - L'istruzione SHOW INDEX FROM <tabella> ==> restituisce informazioni sugli eventuali indici della tabella

# Variabili
## Variabili User-defined
  Sono variabili che permettono la memorizzazione di dati senza la necessità di utilizzare un metodo di storage. 
  Per esempio la query seguente memorizza il salario minimo e il salario massimo ottenuti direttamente da una query:
    SELECT @min_sal:=MIN(sal),@max_sal:=MAX(sal) FROM emp;

  ==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/c7b155cf-2f5a-4c6e-bb9b-3632a0ab04c1)

    SELECT * FROM emp WHERE sal=@min_sal OR sal=@max_sal;

  ==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/70fc494c-745b-4a14-83c7-07eadf5130f4)

  E' possibile valorizzare le variabili user defined anche tramite l'istruzione SET, sai come istruzione in uno script che all'interno del codice degli oggetti:

    SET @var_name = expr [, @var_name = expr] ...

  
# Tipi di dati
## AUTO_INCREMENT
  AUTO_INCREMENT è un attributo di colonna utilizzabile per generare un identificativo numerico unico incrementale per ogni nuovo record di una tabella. 
  Il comportamento varia a seconda del motore utilizzato per la specifica colonna.
  
  Con *motore INNO_DB* l'identificativo è unico a livello di tabella e la colonna DEVE essere la prima della chiave primaria.
  L'intero proposto è, come impostazione predefinita, quello successivo al massimo presente in tabella.
  E' possibile passare in maniera esplicita un valore per la colonna e, nel caso in cui siano proposti il valore 0 o il valore NULL, MySql genera comunque un nuovo ID autoincrementato.
  NB: nel caso in cui sia abilitata la modalità NO_AUTO_VALUE_ON_ZERO è mantenuto un eventuale 0 proposto.

    DROP TABLE IF EXISTS animals;

    CREATE TABLE animals (
    id MEDIUMINT NOT NULL AUTO_INCREMENT,
    name CHAR(30) NOT NULL,
    primary key (id)
    );

    INSERT INTO animals (name) VALUES
    ('dog'),('cat'),('penguin'),
    ('lax'),('whale'),('ostrich');
    INSERT INTO animals (id,name) VALUES(0,'groundhog');
    INSERT INTO animals (id,name) VALUES(NULL,'squirrel');
    INSERT INTO animals (id,name) VALUES(100,'rabbit');
    INSERT INTO animals (id,name) VALUES(NULL,'mouse');
    INSERT INTO animals (name) VALUES ('bull');

    SELECT * FROM animals;

  ==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/c5868d89-4eda-4b94-9422-26730757ef29)

  Nell'esempio seguente il penultimo inserimento produce l'ID 101 poichè l'autoincremento è sempre rispetto al massimo valore in tabella.
  E' possibile comunque indicare un valore di partenza tramite l'istruzione seguente:

      ALTER TABLE <tabella> AUTO_INCREMENT = <valore iniziale>;

  E' possibile sapere l'ultimo ID prodotto nella sessione corrente tramite la funzioen LAST_INSERT_ID(). 
    Attenzione! In caso di inserimento multiplo il dato restituito è l'ID del primo record inserito, non dell'ultimo. 

  E' preferibile utilizzare il tipo di dato numerico minimo sufficiente per la quantità di record prevista, specificando l'attributo UNSIGNED per ridurre lo spazio utilizzato. 


  Con *motore MyISAM* la colonna autoincrementata NON deve necessariamente essere la prima della chiave primaria e l'incremento è relativo al gruppo di colonne che la precedono nella definizione della chiave stessa.
  
    DROP TABLE IF EXISTS animals;

    CREATE TABLE animals (
    grp ENUM('fish','mammal','bird') NOT NULL,
    id MEDIUMINT NOT NULL AUTO_INCREMENT,
    name CHAR(30) NOT NULL,
    PRIMARY KEY (grp,id)
    ) ENGINE=MyISAM;

    INSERT INTO animals (grp,name) VALUES
    ('mammal','dog'),('mammal','cat'),
    ('bird','penguin'),('fish','lax'),('mammal','whale'),
    ('bird','ostrich');

    SELECT * FROM animals ORDER BY grp,id;
    Which returns:

  ==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/827e3bc3-55a0-4459-8742-ff814d3e7695)


# Ottimizzazione del database
  Documentazione ufficiale: 
  https://dev.mysql.com/doc/refman/8.0/en/optimization.html

  I fattori più importanti da considerare sono:
  - Tabelle sono strutturate correttamente e tipi di dato corretti ed adeguati per dimensione. Per database transazionali meglio molte tabelle piccole, per OLAP meglio poche tabelle con molte colonne.
  - Inidici sono corretti per le queries richieste
  - Il motore impostato per ogni singola tabella è quello più adatto
  - Dimensione adeguata delle varie aree di memoria

## Ottimizzazione delle istruzioni SQL
  Considerazioni generali:
  - Per velocizzare una query il primo passo è verificare la correttezza degli indici coinvolti (soprattutto sui criteri di filtro della clausola WHERE).
  - Si può utilizzare l'istruzione EXPLAIN per determinare gli indici utilizzati in una SELECT
  - Si deve minimizzare il numero di accessi "full scan" alle tabelle
  - Per aggiornare le statistiche e migliorare l'ottimizzazione utilizzare l'istruzione ANALYZE TABLE periodicamente
  - Adeguare le dimensioni e le proprietà delle varie aree di memoria destinate al caching
  - Rivedere la gestione della concorrenza se altre sessioni impattano sull'esecuzione di una istruzione
   
### Clausola WHERE
  nb: le indicazioni valgono sia per l'utilizzo in una istruzione SELECT che nelle istruzioni DELETE e UPDATE.
  - Sono preferibili operazioni aritmetiche anche a scapito della leggibilità
  - Rimuovere le parentesi non necessarie
  - Rimuovere le condizioni costanti
  - Con MyIsam la funzione COUNT(*) applicata ad una tabella senza condizioni nella calusola WHERE ricava i dati direttamente dalle informazioni di sistema, senza necessità di full scan
  - Le "constant tables" sono lette prima delle altre. Sono: tabelle vuote, tabelle con una riga, tabelle filtrate sulla PK o su UK
  - Se tutti i campi riferiti nelle clausole ORDER BY e GROUP BY sono nella stessa tabella è preferibile prtire da essa nella query
  - Se tutti i campi necessari sono presenti in un indice MySql utilizzerà direttamente l'indice come sorgente

### EXPLAIN (@TODO)
  https://dev.mysql.com/doc/refman/8.0/en/using-explain.html

### Buffer e cache (@TODO)
  https://dev.mysql.com/doc/refman/8.0/en/buffering-caching.html

### Concorrenza
  https://dev.mysql.com/doc/refman/8.0/en/locking-issues.html


  
   
