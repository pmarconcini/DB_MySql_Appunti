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

## Variabili User-defined
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

  
