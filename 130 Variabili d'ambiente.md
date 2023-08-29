# Variabili d'ambiente
-----------------------------------

## Variabili di sistema
  L'elenco e la modalità di gestione sono disponibili nelal documentazione ufficiale: 
  https://dev.mysql.com/doc/refman/8.0/en/server-system-variable-reference.html

  - Sono le variabili di configurazione e possono essere in parte modificate in tempo reale (sono quelle con scope "session" o "both"). 
  - Sono identificate dal prefisso "@@" nelle query e nel codice.
  - Per vedere i valori delle variabili globali è possibile utilizzare l'istruzione SHOW GLOBAL VARIABLES [LIKE '%<testo>%'];
  - Per vedere i valori delle variabili di sessione è possibile utilizzare l'istruzione SHOW [SESSION] VARIABLES [LIKE '%<testo>%']; o tramite query. 
  - La visibilità di una eventuale variazione dipende dall'indicazione (SESSION o GLOBAL) usata nell'istruzione SET di valorizzazione.
  
        SET GLOBAL generated_random_password_length = 10; -- valore iniziale 20
        SET SESSION generated_random_password_length = 15; -- valore iniziale 20
        SHOW GLOBAL VARIABLES LIKE '%generated_random_password_length%';
        SHOW SESSION VARIABLES LIKE '%generated_random_password_length%';
        SHOW VARIABLES like '%generated_random_password_length%';
        select @@generated_random_password_length AS generated_random_password_length;

-----------------------------------

## Variabili User-defined (o di sessione)
  - Sono variabili che permettono la memorizzazione di dati senza la necessità di utilizzare un metodo di storage. 
  - Sono identificate dal prefisso "@".
  - La persistenza del dato è legata alla sessione, quindi all'avvio di ogni nuova sessione è necessario (eventualmente) inizializzare i dati.
  
  Per esempio la query seguente memorizza il salario minimo e il salario massimo ottenuti direttamente da una query:
  
    SELECT @min_sal:=MIN(sal),@max_sal:=MAX(sal) FROM emp;

  ==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/c7b155cf-2f5a-4c6e-bb9b-3632a0ab04c1)

    SELECT * FROM emp WHERE sal=@min_sal OR sal=@max_sal;

  ==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/70fc494c-745b-4a14-83c7-07eadf5130f4)

  E' possibile valorizzare le variabili user defined anche tramite l'istruzione SET, sia come istruzione in uno script che all'interno del codice degli oggetti:

    SET @var_name = expr [, @var_name = expr] ...


-----------------------------------

## SQL MODE

In MySQL è possibile settare delle variabili per variare il comportamento del server, il suo supporto della sintassi SQL ed il comportamento nella validazione dei dati; queste impostazioni sono detti "SQL modes".

E' possibile impostare la modalità all'avvio del server intervenendo nello script o nel file di configurazione, ma anche impostare la modalità "a caldo" globalmente o per la singola sessione:

	SET GLOBAL sql_mode = 'modo';
	SET SESSION sql_mode = 'modo';

Con modo che è composto da uno o più tra i seguenti valori (senza spazi e con virgola a separare): ONLY_FULL_GROUP_BY, STRICT_TRANS_TABLES, NO_ZERO_IN_DATE, NO_ZERO_DATE, ERROR_FOR_DIVISION_BY_ZERO, NO_ENGINE_SUBSTITUTION

Per settare l'impostazione a livello globale è necessario avere il privilegio SYSTEM_VARIABLES_ADMIN.

Per sapere le attuali impostazioni:

	SELECT @@GLOBAL.sql_mode, @@SESSION.sql_mode;


Strict SQL Mode (o STRICT MODE) è una modalità che costringe MySQL ad una interpretazione restrittiva dei dati e degli script DML e DDL, evitando di applicare alcune correzioni (ad esempio l'inserimento di 0 in un campo numerico obbligatorio senza dafault e non specificato). Non esiste un valore specifico perchè è sostanzialmente la summa delle opzioni STRICT_ALL_TABLES e STRICT_TRANS_TABLES


I più importanti SQL Modes sono:

- ANSI: per una verifica più stringente della sintassi per conformarsi agli standard
- STRICT_TRANS_TABLES: interruzione delle istruzioni in caso di errori in DML in una tabella transazionale
- ALLOW_INVALID_DATES: non viene eseguita la validazione completa delle date (solo giorni e mesi)
- ERROR_FOR_DIVISION_BY_ZERO: una divisione per 0 produce un warning o un errore (dipende se attivo anche "STRICT MODE")
- IGNORE_SPACE: permette l'inserimento di spazi tra il nome delle funzioni e le parentesi
- NO_AUTO_VALUE_ON_ZERO: un eventuale AUTO_INCREMENT mantiene un valore 0 proposto invece di calcolare l'ID successivo
- NO_ZERO_DATE: l'inserimento del valore '0000-00-00' come data causa un warning o un errore (dipende se attivo anche "STRICT MODE")
- ONLY_FULL_GROUP_BY: rifiuta una eventuale query con un campo in HAVING o ORDER BY e non presente in GROUP BY
- STRICT_ALL_TABLES: abilita la "STRICT MODE" per tutte le tabelle


