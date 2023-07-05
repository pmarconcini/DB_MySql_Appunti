# Character Sets e Collations

  Un character set è un insieme di simboli e di codifica dei caratteri. Una collezione è un insieme di regole di confronto dei caratteri di un character set. 
  MySql permette di specificare il set di caratteri da utilizzare a livello di database in generale, di singolo oggetto o di sessione (quindi l'impatto della scelta è sia a livello di dato che di comunicazione dello stesso). 
  Ad ogni character set corrisponde una collation e le impostazion di default sono rispettivamente utf8mb4 e utf8mb4_0900_ai_ci.

  Il nome di una collation ha un prefisso corrispondente al nome del set associato, una parte centrale descrittiva (generlmente un riferimento geopolitico) e uno o più suffissi che indicano il comportamento:
  - Per gli accenti: _ai > Accent-insensitive o _as >Accent-sensitive
  - Per le lettere dell'alfabeto: _ci > Case-insensitive o _cs > Case-sensitive
  - Per dati binari: _bin

-----------------------------------
## Creazione e modifica degli oggetti

  Per impostare la scelta in fase di creazione del database (o anche in fase di modifica per gli oggetti in esso contenuti) è necessario specificare le parole chiave "CHARACTER SET" o "COLLATE" seguite da uno dei valori specifici disponibili nell'installazione.

    CREATE DATABASE nome_db CHARACTER SET latin1 COLLATE latin1_swedish_ci;
    
    USE nome_db;
    
    SELECT @@character_set_database, @@collation_database;
    -- oppure
    SELECT DEFAULT_CHARACTER_SET_NAME, DEFAULT_COLLATION_NAME
    FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'nome_db';


E' possibile definire dei valori specifici per singola tabella e o singola colonna:

    CREATE TABLE tab
    (
        col1 CHAR(10),
        col2 CHAR(10) CHARACTER SET utf8mb4
    ) CHARACTER SET latin1 COLLATE latin1_bin;

Attenzione: modificare i valori in corso d'opera implica una conversione automatica che potrebbe causare una perdita di dati.

-----------------------------------
## Lettura e scrittura delle impostazioni 
  E' possibile sapere quali sono le impostazioni correnti tramite la query seguente:

    SELECT * FROM performance_schema.session_variables
    WHERE VARIABLE_NAME IN (
      'character_set_client', 'character_set_connection',
      'character_set_results', 'collation_connection'
    ) ORDER BY VARIABLE_NAME;

  Per variare in tempo reale le impostazioni è possibile utilizzare le seguenti istruzioni:
  
    SET character_set_client = charset_name;
    SET character_set_results = charset_name;


-----------------------------------
## Conversione dei dati
  E' possibile eseguire una conversione in una collation diversa direttamente nell'istruzione SQL, sia a livello globale che a livello di singola colonna:

    SELECT col1 FROM tab ORDER BY col1 COLLATE latin1_german2_ci;
    
    SELECT col1 COLLATE latin1_german2_ci AS col1_new FROM tab ORDER BY col1_new;
