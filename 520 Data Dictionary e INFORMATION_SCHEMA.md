# Data Dictionary e INFORMATION_SCHEMA

INFORMATION_SCHEMA è un database gestito da MySQL contentente tutti i metadati dei database presenti nel server (database, definizioni degli oggetti, privilegi, etc). L'insieme di queste informazioni è spesso chiamato "data dictionary".

--------------------------------
## INFORMATION_SCHEMA

Le informazioni sono distribuite in tabelle read-only gestite autonmamente dal server MySQL a cui sono associate le viste a cui l'utente può accedere in lettura e su cui non è quindi possibile intervenire nè con DML, nè associando dei trigger.

E' possibile recuperare le informazioni direttamente dalle tabelle tramite una query standard su INFORMATION_SCHEMA.<oggetti> o utilizzando il set di istruzioni SHOW <oggetti>: una SELECT offre più possibilità perchè espone più dati e sono utilizzabili tutte le caratteristiche di SQL, mentre con SHOW è possibile applicare esclusivaente la condizione di filtro LIKE, come da template a seguire:

    SHOW <oggetti> [ LIKE '%%' ];

I dati ottenuti sono spesso legati ai privilegi dell'utente che vi accede: quando l'utente NON ha un privilegio richiesto per il dato esso è trasformato automaticamente in NULL.


--------------------------------
### Catalogo

Per l'elenco completo delle viste e dei dati esposti si rimanda alla [documentazione ufficiale](https://dev.mysql.com/doc/refman/8.0/en/information-schema-general-table-reference.html).

A seguire le viste consultabili di maggior importanza, consultabili con le istruzioni viste in precedenza (as esempio SELECT * FROM INFORMATION_SCHEMA.TABLES; o SHOW TABLES;):

- CHARACTER_SETS > set di caratteri disponibili
- COLLATIONS	> set di collezioni disponibili per ogni character set
- COLUMN_PRIVILEGES	> privilegi definiti su singole colonne
- COLUMNS	> colonne di tutte le tabelle
- ENABLED_ROLES	> ruoli abilitati per la sessione corrente
- EVENTS	> eventi
- PARAMETERS	> parametri delle stored procedure e stored function
- PARTITIONS	> partizioni di tabella
- PROCESSLIST	> processi correnti
- REFERENTIAL_CONSTRAINTS	> foreign key
- ROUTINES	> stored routines
- SCHEMA_PRIVILEGES	> privilegi per schema
- SCHEMATA	> Informazioni sullo schema
- STATISTICS	> statistiche degli indici di tabella
- TABLE_CONSTRAINTS	> Constraints di tabella
- TABLE_PRIVILEGES	> privilegi di tabella
- TABLES	> tabella
- TABLESPACES	> tablespace
- TRIGGERS	> triggers
- USER_PRIVILEGES	> privilegi degli utenti
- VIEWS	> viste
