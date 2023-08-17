# Convenzioni e regole di scrittura
-----------------------------------
## Testi e caratteri speciali
  I testi sono racchiusi tra apici singoli o doppi. Sequenze ti testi espliciti sono automaticamente concatenati:
  
    select 'a string' c1, "another string" c2, 'a' ' ' 'string' c3;
    
  ==>  
  |c1|c2|c3|
  |--|--|--|
  |a string|another string|a string|
  
  nb: se è abilitato il parametro ANSI_QUOTES è utilizzabile solo l'apice singolo per l'identificazione del testo (mentre il doppio apice è sempre utilizzabile come identificatore).

  E' possibile specificare il set di caratteri da applicare a un testo anteponendo il formato (i 3 esempi seguenti sono equivalenti):
    
      SELECT N'aeiouèéùòàì' c1, n'aeiouèéùòàì' c2, _utf8'aeiouèéùòàì' c3;

  ==> 
  |c1|c2|c3|
  |--|--|--|
  |aeiouèéùòàì|aeiouèéùòàì|aeiouèéùòàì|
  
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

-----------------------------------
## Numeri e date
  Il separatore decimale è il punto. 
  I numeri in MySql possono essere esatti (tipi INTEGER e DECIMAL e derivati) o approssimati (FLOAT e DOUBLE e sinonimi). Numeri presentati con la notazione scientifica sono approssimati.

  Le date e gli orari possono essere rappresentati (e autoconvertiti) in vari formati testuali: 'YYYY-MM-DD', 'YYYYMMDD', 'YYYY-MM-DD HH:MI:SS', 'YYYYMMDDHHMISS'.
  E' possibile forzare la conversione anteponendo il formato voluto:

    select DATE '19750607' c1, DATE '1975-06-07' c2, TIME '192800' c3, TIME '19:28:00' c4, 
    TIMESTAMP '19750607192800' c5, TIMESTAMP '1975-06-07 19:28:00' c6;

  ==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/edd40c63-d412-4ebf-953e-52d494d7a3a4)

  nb: i caratteri di separazione possono essere diversi da quelli indicati così come l'anno può essere espresso in 2 byte
  
  Con DATETIME e TIMESTAMP è possibile specificare anche la parte decimale dei secondi (fino a 6 decimali di precisione).
  Specificando l'anno in 2 byte MySql presume che con valori 70-99 ci si riferisca al range 1970-1999 e con valori 00-69 al range 2000-2069.

  Nel caso in cui un testo debba essere convertito in orario MySql procede secondo la seguente regola: 2 byte > SS, 4 byte MISS, 6 byte > HHMISS

-----------------------------------
## Booleani e valore nullo
  I valori booleani sono TRUE e FALSE, NON sono case sensitive e corrispondono rispettivamente ai valori 1 e 0.

  Il valore nullo corrisponde alla parola NULL, non case sensitive, ed è diverso dal testo nullo (doppio apice singolo o doppio apice doppio senza testo racchiuso). 
  MySql tratta la stringa nulla come testo e non come valore nullo. 
  Nell'esempio seguente in c1 si nota come il NULL non sia neanche confrontabile con il testo nullo (causando la propagazione del NULL) mentre in c3 si nota come la funzione coalesce (che cerca considera il primo valore non nullo nell'elenco) NON sostituisce il testo nullo con la "x":
  
    SELECT NULL = '' c1, coalesce(NULL, '') = '' c2, coalesce(NULL, 'x') = coalesce('', 'x') c3;

  ==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/7826b97d-0017-4759-9b4b-1ce6d3576652)

-----------------------------------
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

-----------------------------------
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

  ==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/07163213-e93a-45b7-8c30-0f0725f17fe4)

  nb: per tutte le unità di misura disponibili si rimanda alla documentazione ufficiale

  L'intervallo è utilizzabile anche nelle espressioni per aggiungere o sottrarre un dato periodo da una data o come fonte di dati:

    SELECT '2018-12-31 23:59:59' + INTERVAL 1 SECOND c1, 
       INTERVAL 1 DAY + '2018-12-31' c2,
       '2025-01-01' - INTERVAL 1 SECOND c3, 
       EXTRACT(YEAR FROM '2019-07-02') c4, 
       EXTRACT(YEAR_MONTH FROM '2019-07-02 01:02:03') c5;

  ==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/27ff4a71-6a72-4103-b744-1322c1644f1a)
  
  Attenzione alla conversione del dato della quantità; è sempre preferibile eseguire un CAST:

    SELECT  CAST(6/4 AS DECIMAL(3,1)) c1,-- 1 ora e 30 minuti
  		6/4 c2,
  		DATE_ADD('1970-01-01 12:00:00', INTERVAL CAST(6/4 AS DECIMAL(3,1)) HOUR_MINUTE) c3,
  		DATE_ADD('1970-01-01 12:00:00', INTERVAL '6/4' HOUR_MINUTE) c4, -- 6 ore 3 4 minuti
  		DATE_ADD('1970-01-01 12:00:00', INTERVAL 6/4 HOUR_MINUTE) c5;-- 1 ora e 5000 minuti

  ==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/bc6a6e79-760d-4b96-b7f9-c1ae389a6459)

-----------------------------------
## Commenti
  Sono disponibili varie tipologie di commento, come da esempio seguente:

		SELECT 1+0 ris    # Commento fino a fine linea
		UNION 
		SELECT 1+1  -- Commento fino a fine linea
		UNION 
		SELECT 1 /* Commento in linea */ + 2
		UNION 
		SELECT 1+		/* Commento
		multilinea */		3;

 ==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/2015383b-b535-4711-9c60-e6d0ea3d1cd0)

  Nel caso in cui i commenti siano parte del codice di procedure e funzioni vengono memorizzati anch'essi.

  Esiste poi un ulteriore tipo di commenti simile al commento "in linea" che permette di indicare delle direttive in fase di esecuzione degli script e che NON viene memorizzato. La scrittura è /*! Codice MySQL */, come nell'esempio seguente in cui la creazione della tabella è vincolata alla versione minima del DBMS:

	CREATE TABLE tab (a INT, KEY (a)) /*!80024 KEY_BLOCK_SIZE=1024 */;

-----------------------------------
## Riferimenti ad oggetti
La scrittura standard per riferirsi ad una colonna di una tabella (o di una vista) è <nome_database>.<nome_tabella>.<nome_colonna>, ma si può omettere il riferimento al database per le tabelle del database locale. 
La stessa logica va considerata per riferirsi agli altri tipi di oggetti (procedure, funzioni e trigger): <nome_database>.<nome_oggetto>, con la possibilità di omettere il riferimento al database per gli oggetti locali.
  
