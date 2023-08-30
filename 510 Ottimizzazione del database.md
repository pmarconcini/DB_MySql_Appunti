# Ottimizzazione del database
  Documentazione ufficiale: 
  https://dev.mysql.com/doc/refman/8.0/en/optimization.html

  I fattori più importanti da considerare sono:
  - Tabelle sono strutturate correttamente e tipi di dato corretti ed adeguati per dimensione. Per database transazionali meglio molte tabelle piccole, per OLAP meglio poche tabelle con molte colonne.
  - Inidici sono corretti per le queries richieste
  - Il motore impostato per ogni singola tabella è quello più adatto
  - Dimensione adeguata delle varie aree di memoria

-----------------------------------
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


-----------------------------------
## Utilizzo del PERFORMANCE_SCHEMA

Per una trattazione completa si rimanda alla [documentazione ufficiale](https://dev.mysql.com/doc/refman/8.0/en/performance-schema.html).

Il PERFORMANCE_SCHEMA è un database a cui si può accedere per monitorare le performance tramite tabelle gestite autonomamente da MySQL; in particolare il monitoraggio è relativo alle attività del server e delle loro tempistiche.Sono disponibili sia i dati correnti che i dati storici e aggregati.
Attivare il PERFORMANCE_SCHEMA non causa variazioni nel comportamento generale del server, nè impatta sulle fnzionalità, neanche in caso di problemi o errori interni al servizio.

Il servizio è abilitato come scelta predefinita in fase di installazione e lo stato è impostabile da file di configurazione (performance_schema=ON)

Per visualizzare lo stato:

    SHOW VARIABLES LIKE 'performance_schema';


Per conoscere le tabelle disponibili:

    SHOW TABLES FROM performance_schema;

    
Non tutte le funzioni sono abilitate di default ed è possibile intervenire direttamente in tabella:

    SELECT NAME, ENABLED, TIMED FROM performance_schema.setup_instruments;
    UPDATE performance_schema.setup_instruments SET ENABLED = 'YES', TIMED = 'YES';

    SELECT * FROM performance_schema.setup_consumers;
    UPDATE performance_schema.setup_consumers SET ENABLED = 'YES';


Attivati i servizi, per conoscere le attività correnti e storiche (10000 azioni) del database:

    SELECT * FROM performance_schema.events_waits_current;
    
    SELECT EVENT_ID, EVENT_NAME, TIMER_WAIT FROM performance_schema.events_waits_history WHERE THREAD_ID = 13 ORDER BY EVENT_ID;

    SELECT EVENT_NAME, COUNT_STAR FROM performance_schema.events_waits_summary_global_by_event_name ORDER BY COUNT_STAR DESC LIMIT 10;



