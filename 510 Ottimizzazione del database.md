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
