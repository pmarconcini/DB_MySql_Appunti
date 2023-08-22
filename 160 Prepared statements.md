# PREPARED STATEMENTS
-----------------------------

MySQL 8.0 permette di "preparare" delle istruzioni lato server; tali istruzioni saranno composte da script completi in cui si trovano dei placeholder (segnaposto) a cui sono destinati i valori ordinati passati come parametri in fase di esecuzione.
Una istruzione preparata persisterà fino alla sua sostituzione (una nuova preparazione), deallocazione o al termine della sessione.

Il numero massimo di prepared statemants simultaneamente disponibili è dato dalla variabile di sistema  max_prepared_stmt_count.

L'istruzione deve essere unica (non può essere una sequanza di istruzioni separate da ";").

I benefici client e server sono molteplici:

- tempi minori per il parsing dell'istruzione ogni volta che è riusata
- Protezione contro attacchi SQL injection

Le fasi previste sono:

- PREPARE - Preparazione dell'istruzione (con eventuale utilizzo dei placeholders)
- EXECUTE - Esecuzione dell'istruzione (con passaggio dei parametri)
- DEALLOCATE - Scarico della memoria

A seguire un esempio con utilizzo diretto e uno utilizzando una variabile userdefined:

    PREPARE stmt1 FROM 'SELECT SQRT(POW(?,2) + POW(?,2)) AS ipotenusa';
    SET @a = 3;
    SET @b = 4;
    EXECUTE stmt1 USING @a, @b;
    -- ==> 5
    DEALLOCATE PREPARE stmt1;


    SET @s = 'SELECT SQRT(POW(?,2) + POW(?,2)) AS ipotenusa';
    PREPARE stmt1 FROM @s;
    SET @a = 3;
    SET @b = 4;
    EXECUTE stmt1 USING @a, @b;
    -- ==> 5
    DEALLOCATE PREPARE stmt1;

Le più frequenti istruzioni eseguibili come prepared statements sono le seguenti:
- ALTER TABLE
- ALTER USER
- ANALYZE TABLE
- CALL
- COMMIT
- {CREATE | DROP} INDEX
- {CREATE | RENAME | DROP} DATABASE
- {CREATE | DROP} TABLE
- {CREATE | RENAME | DROP} USER
- {CREATE | DROP} VIEW
- DELETE
- DO
- FLUSH {TABLE | TABLES | TABLES WITH READ LOCK | HOSTS | PRIVILEGES | LOGS | STATUS | MASTER | SLAVE | USER_RESOURCES}
- GRANT
- INSERT
- KILL
- OPTIMIZE TABLE
- RENAME TABLE
- REPAIR TABLE
- REPLACE
- REVOKE
- SELECT
- SET
- SHOW CREATE {PROCEDURE | FUNCTION | EVENT | TABLE | VIEW}
- TRUNCATE TABLE
- UPDATE


