# Definizione dei trigger
-------------------------------

## ESECUZIONE
-------------------------------
Un trigger è un oggetto del database associato a una tabella che si attiva quando si verificano specifici eventi relativi alla stessa tabella. 
Gli eventi possono essere le tre DML e l'effetto è l'elaborazione del codice memorizzato nel trigger stesso per ogni riga processata.
Altro comportamento definibile è il momento di esecuzione, che può avvenire prima o dopo della modifica causata dalla DML.


--------------------------------------
## DEFINIZIONE DEL TRIGGER

--------------------------------------
### PRIVILEGI

Per poter creare, modificare o eliminare un trigger è necessario avere il privilegio TRIGGER sulla tabella associata; l'elaborazione è automatica è dipende dai privilegi dell'utente sulle tabelle coinvolte e non sull'oggetto stesso (in mancanza di privilegi la DML è stoppata e il trigger non è elaborato).


--------------------------------------
### INFORMAZIONI

Per ottenere informazioni sui trigger è possibile eseguire ricerche nella tabella ROUTINES del database INFORMATION_SCHEMA.
Per vedere la definizione di un trigger è possibile utilizzare l'istruzione SHOW CREATE TRIGGER <nome_trigger>.
Per vedere lo stato di tutte i trigger è possibile utilizzare l'istruzione SHOW TRIGGER STATUS.


--------------------------------------
### FIRMA e CORPO

La firma deve comprendere un nome univoco per tipo di oggetto a livello di database e sono necessari i riferimenti alla tabella, al tipo di DML e al momento dell'elaborazione; generalmente il nome è parlante e contiene riferimenti a tutte queste informazioni.
E' possibile definre più trigger per una unica tabella, anche relativi allo stesso evento ed alle stesse modalità di esecuzione. E' possibile definire l'ordine di esecuzione tramite le opzioni FOLLOWS e PRECEDES; se non specificate l'ordine corrisponde a quello di creazione.

Il body può contenere tutte le istruzioni viste fino ad ora, con alcune limitazioni ed alcune peculiarità in più:

- ci si può riferire al nuovo valore (se disponibile) di una colonna con NEW.<nome_colonna> e, se il trigger è elaborato prima della DML, nell'elaborazione è possibile aggiornarne il valore
- ci si può riferire al vecchio valore (se disponibile) di una colonna con OLD.<nome_colonna>
- non è possibile eseguire stored procedures che restituiscono dataset o che utilizzano all'interno SQL dinamico
- non è possibile gestire esplicitamente la transazione (v. capitolo sul linguaggio TCL) perchè dipendono dalla gestione dell'istruzione scatenante
- non è possibile associare un trigger a una tabella temporanea o a una vista
- l'ordine di elaborazione è "trigger prima" (BEFORE), DML e "trigger dopo" (AFTER): in caso di errore in uno dei tre step MySQL annulla l'istruzione e non procede con eventuali step successivi. Ciò significa che con un database transazionale (InnoDB per esempio) è annullato l'intero processo mentre con un database NON transazionale (come MyISAM) le attività già completate persistono e vanno eventualmente annullate con una gestione ad hoc

Nell'esempio seguente sono creati tutti i trigger relativi alla tabella "prova" per correggere o completare dati, eseguire il log del dato modificato nella tabella "prova_log" e conteggiare le DML eseguite:

    TRUNCATE TABLE PROVA;
    
    DROP TRIGGER IF EXISTS trg_prova_bi;
    DROP TRIGGER IF EXISTS trg_prova_bu;
    DROP TRIGGER IF EXISTS trg_prova_bd;
    DROP TRIGGER IF EXISTS trg_prova_ai;
    DROP TRIGGER IF EXISTS trg_prova_au;
    DROP TRIGGER IF EXISTS trg_prova_ad;
    DROP TABLE IF EXISTS prova_log;
    
    CREATE TABLE prova_log AS SELECT 'X' DML, x.* FROM prova x;
    
    DELIMITER $$
    
    CREATE TRIGGER trg_prova_bi 
    BEFORE INSERT ON prova FOR EACH ROW
    BEGIN
    	IF NEW.d IS NULL THEN 
    		SET NEW.d = CURRENT_TIMESTAMP(); 
    	END IF;
        INSERT INTO prova_log VALUES ('I', NEW.n, NEW.t, NEW.d);
    END
    $$
    
    CREATE TRIGGER trg_prova_bu 
    BEFORE UPDATE ON prova FOR EACH ROW
    BEGIN
    	IF NEW.d IS NULL OR NEW.d <> OLD.d THEN 
    		SET NEW.d = CURRENT_TIMESTAMP(); 
    	END IF;
        INSERT INTO prova_log VALUES ('U', NEW.n, NEW.t, NEW.d);
    END
    $$
    
    CREATE TRIGGER trg_prova_bd 
    BEFORE DELETE ON prova FOR EACH ROW
    BEGIN
        INSERT INTO prova_log VALUES ('D', OLD.n, OLD.t, OLD.d);
    END
    $$
    
    CREATE TRIGGER trg_prova_ai 
    AFTER INSERT ON prova FOR EACH ROW
    BEGIN
    	SET @dml = @dml +1;
    END
    $$
    
    CREATE TRIGGER trg_prova_au 
    AFTER UPDATE ON prova FOR EACH ROW
    BEGIN
    	SET @dml = @dml +1;
    END
    $$
    
    CREATE TRIGGER trg_prova_ad
    AFTER DELETE ON prova FOR EACH ROW
    BEGIN
    	SET @dml = @dml +1;
    END
    $$
    
    DELIMITER ;
    
    SET sql_safe_updates=0;
    SET @dml = 0;
    INSERT INTO PROVA (n, t) VALUES (1, 'primo');
    INSERT INTO PROVA (n, t) VALUES (2, 'secondo');
    INSERT INTO PROVA (n, t) VALUES (3, 'terzo');
    INSERT INTO PROVA (n, t) VALUES (4, 'quarto');
    UPDATE PROVA SET t = concat(t, ' --> ', n) WHERE n <= 2;
    UPDATE PROVA SET t = 'nuovo testo' WHERE n = 3;
    DELETE FROM PROVA WHERE n < 3;
    DELETE FROM PROVA WHERE n = 4;
    SET sql_safe_updates=1;
    
    SELECT 'corrente' tabella, @dml dml, p.* FROM prova p union SELECT 'log', p.* from prova_log p;

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/919a489d-91b6-4eac-a029-9c61fc331121)


--------------------------------------
## CREATE

Il template per cer creare un trigger è il seguente:

    CREATE [DEFINER = user] TRIGGER [IF NOT EXISTS] <nome_trigger> 
      { BEFORE | AFTER } { INSERT | UPDATE | DELETE } ON <nome_tabella> FOR EACH ROW
        [ { FOLLOWS | PRECEDES } <altro_nome_trigger> ]
        <body>;

Se viene utilizzata l'opzione DEFINER  nella creazione del trigger saranno considerati i privilegi dell'utente indicato, altrimenti sono considerati quelli dell'utente creatore.

L'opzione IF NOT EXISTS evita l'errore che occorre quando si cerca di creare un oggetto con un nome già in uso.

CREATE TRIGGER richiede il privilegio TRIGGER sulla tabella associata. 

L'opzione obbligatoria BEFORE o AFTER indica se il codice del BODY deve essere eseguito PRIMA o DOPO la DML scatenante.

L'opzione obbligatoria INSERT o UPDATE o DELETE  indica quale tipo di DML fa scattare il trigger.

FOR EACH ROW indica che il trigger sarà elaborato per ogni riga della DML (al momento non esiste una alternativa, a differenza di quanto accade per esempio in Oracle)

L'opzione facoltativa FOLLOWS o PRECEDES permette di definire l'ordine di esecuzione dei trigger: ovviamente il riferimento deve essere a un trigger in competizione e quindi con analoghe caratteristiche temporali e di tipologia di DML. Se l'opzione è omessa l'ordine di esecuzione corrisponde con l'ordine di creazione dei trigger.

Attenzione: foreign keys aggiornate a cascata NON causano l'esecuzione di trigger.



--------------------------------------
## ALTER

Non esiste una istruzione per modificare un trigger: è necessario eliminare e ricreare l'oggetto.



--------------------------------------
## DROP

L'istruzione DROP permette di eliminare un trigger esistente, secondo il seguente template:

    DROP TRIGGER [IF EXISTS] <nome_trigger> ;

L'opzione IF EXISTS permette di evitare l'errore che si verifica cercando di eliminare un oggetto che non esiste.

E' necessario il privilegio TRIGGER sulla tabella associata.
