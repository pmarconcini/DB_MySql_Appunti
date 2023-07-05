# Informazioni su dabases e oggetti
  - L'istruzione SHOW DATABASES elenca i database gestiti sul server
  - La funzione DATABASE() ==> restituisce il nome del database corrente (restituisce NULL se non è selezionato alcun database)
  - La funzione VERSION() ==> restituisce la versione del DBMS
  - L'istruzione SHOW TABLES ==> restituisce l'elenco delle tabelle del database corrente
  - L'istruzione DESCRIBE <tabella> ==> restituisce nome, tipo, nonnullità, indici ed eventuale contatore della tabella
  - L'istruzione SHOW CREATE TABLE <tabella> ==> produce lo script per la creazione della tabella
  - L'istruzione SHOW INDEX FROM <tabella> ==> restituisce informazioni sugli eventuali indici della tabella
  - L'istruzione SHOW CHARACTER SET elenca i character set disponibili (dato recuperabile anche dalla tabella INFORMATION_SCHEMA.CHARACTER_SETS)
  - L'istruzione SHOW CHARACTER SET elenca le collations disponibili (una o più per character set; dato recuperabile anche dalla tabella INFORMATION_SCHEMA.COLLATIONS)
 

  Molte delle informazioni sono recuperabili direttamente dalle variabili di sistema (ie. @@version restituisce lo stesso dato di VERSION()), trattate nel capitolo seguente.

  Le variabili di sistema più frequentemente utilizzate sono le seguenti:

		select @@auto_increment_increment, @@auto_increment_offset, @@autocommit, @@basedir, @@character_set_database,
       @@character_set_results, @@collation_database, @@connect_timeout, @@datadir, @@event_scheduler,
       @@foreign_key_checks, @@log_error, @@sql_mode, @@sql_safe_updates, @@sql_warnings,
       @@time_zone, @@timestamp, @@tmpdir, @@unique_checks, @@version, @@wait_timeout;

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/82326bc8-536c-4b3e-bef5-a80528988dfc)
==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/9769d24e-1f89-44f9-af54-d541688505da)
==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/0fb3fe9c-0d90-4d6e-bb17-25f276187fca)
