# Definizione delle procedure

--------------------------------------
## CALL

Una procedura è un blocco di codice (un insieme ordinato di istruzioni) memorizzato direttamente nel database e rieseguibile più volte. L'istruzione per eseguire la procedura (detta anche "chiamata") è CALL e lo script può variare come segue a seconda che la procedura chiamata preveda l'utilizzo di uno o più parametri:

    CALL <nome_procedura> ( [ <parametro> [, ... ]] ) ;

    CALL <nome_procedura> [()] ;

L'eventuale elenco di parametri è indicato, per numero, singola tipologia, ordine e direzione, nella firma della procedura che è a sua volta stabilita al momento della creazione dell'oggetto.
Le tipologie ammesse sono le stesse già viste nella definizione delle colonne delle tabelle e delle variabili.
La direzione indica se il parametro si aspetta un valore al momento della "chiamata" e/o è utilizzato per restituire un valore al termine positivo dell'elaborazione ed i valori possibili, indicati prima del nome del parametro, sono IN, INOUT e OUT. Se omessa, la direzione predefinita è IN.

Nell'esempio seguente è richiamata una procedura con 3 parametri con le tre modalità di direzione:

    DELIMITER $$
    CREATE PROCEDURE test (OUT ver_param VARCHAR(25), INOUT incr_param INT, INOUT delta_param INT)
    BEGIN
        SELECT VERSION() INTO ver_param;
        SET incr_param = incr_param + delta_param;
    END 
    $$
    DELIMITER ;
    SET @delta = 10; SET @increment = 1;
    CALL test(@version, @increment, @delta);
    SELECT @version, @increment, @delta;
        
==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/7cd4748e-dc92-4d53-9fd2-1d12f7bce9de)


La stessa procedura è eseguibile anche tramite prepared statemet (v. capitolo dedicato):

    SET @delta = 10; SET @increment = 1;
    PREPARE ps FROM 'CALL test(?, ?, ?)';
    EXECUTE ps USING @version, @increment, @delta;
    SELECT @version, @increment, @delta;



--------------------------------------
## DEFINIZIONE DELLA PROCEDURA

--------------------------------------
### PRIVILEGI

Per poter creare una procedura è necessasrio avere il privilegio CREATE ROUTINE, per modificarla o eliminarla è necessario avere il privilegio ALTER ROUTINE e per eseguirla è necessario il privilegio EXECUTE (questi ultimi due sono garantito automaticamente al creatore di una procedura).


--------------------------------------
### INFORMAZIONI

Per ottenere informazioni sulle stored procedure è possibile eseguire ricerche nella tabella ROUTINES del database INFORMATION_SCHEMA.
Per vedere la definizione di una procedura è possibile utilizzare l'istruzione SHOW CREATE PROCEDURE <nome_procedura>.
Per vedere lo stato di tutte le procedure è possibile utilizzare l'istruzione SHOW PROCEDURE STATUS.


--------------------------------------
### FIRMA e CORPO

Ogni stored procedure contiene un corpo che consiste di istruzioni (le strutture ed i costrutti visti nel capitolo precedente) separati dal carattere ";", motivo per cui è necessario definire il set di caratteri di delimitazione prima dello script di creazione/modifica/eliminazione.

La logica dei blocchi e la visibilità all'interno del codice è stata già esaminata nel capitolo precedente e si rimanda quindi a quello. 
L'unico aspetto che si aggiunge a quanto detto è la definizione della firma che prevede un nome univoco a livello di database e un eventuale elenco ordinato di parametri, ognuno dei quali costituito da direzione, nome univoco a livello di elenco dei parametri e tipologia di dato.
La visibilità dei parametri è ovviamente tutta la procedura.

All'interno delle procedure si può anche:
- fare riferimento direttamente a variabili di sessione (va considerata sempre l'inizializzazione delle stesse)
- una o più SELECT senza valorizzazione di variabili (quindi senza clausola INTO) come output in forma di recordset (quindi senza necessità di passare da un parametro con direzione OUT o INOUT)


--------------------------------------
## CREATE

Il template per cer creare una procedura è il seguente:

    CREATE [DEFINER = user] PROCEDURE [IF NOT EXISTS] <nome_procedura> ( [ [ IN | OUT | INOUT ] <parametro> <tipo_dato> [,...] ])
    [ { COMMENT 'descrizione della procedura'  | [NOT] DETERMINISTIC  | { CONTAINS SQL | NO SQL | READS SQL DATA | MODIFIES SQL DATA }
        | SQL SECURITY { DEFINER | INVOKER } } ] 
    <corpo_della_procedura>;

Il nome della procedura NON può essere una parola chiave o il nome di una routine di sistema.
La procedura viene creata nel database in uso. Per creare la procedura in un database diverso è necessario specificare il nome nella forma <nome_database>.<nome_procedura> (ed avere i necessari privilegi).

Se viene utilizzata l'opzione DEFINER  nella creazione della procedura saranno considerati i privilegi dell'utente indicato, altrimenti sono considerati quelli dell'utente creatore.

L'opzione IF NOT EXISTS evita l'errore che occorre quando si cerca di creare un oggetto con un nome già in uso.

L'opzione COMMENT permette di specificare una descrizione per la procedura (l'informazione è visibile con SHOW CREATE PROCEDURE).

L'opzione DETERMINISTIC indica che la procedura a pari parametri in ingresso produrrà sempre lo stesso risultato; l'opzione predefinita è NOT DETERMINISTIC.

L'opzione CONTAINS SQL indica che la procedura NON legge dati, NO SQL che la procedura NON contiene istruzioni, READS SQL DATA indica che sono presenti istruzioni di sola lettura dati e MODIFIES SQL DATA indica la presenza di istruzioni di modifica dei dati..

L'opzione SQL SECURITY permette di stabilire se in fase di elaborazione devono essere considerati i privilegi del creatore (DEFINER) o dell'esecutore (INVOKER, opzione predefinita).



--------------------------------------
## ALTER

L'istruzione ALTER permette di variare alcune caratteristiche di una procedura esistente, secondo il seguente template:

    ALTER PROCEDURE <nome_procedura> { COMMENT 'Descrizione della procedura' | { CONTAINS SQL | NO SQL | READS SQL DATA | MODIFIES SQL DATA } | SQL SECURITY { DEFINER | INVOKER } } ;
    
Per la descrizione delle opzioni si rimanda al paragrafo CREATE.

E' necessario il privilegio ALTER ROUTINE.



--------------------------------------
## DROP

L'istruzione DROP permette di eliminare una procedura esistente, secondo il seguente template:

    DROP PROCEDURE [IF EXISTS] <nome_procedura> ;

L'opzione IF EXISTS permette di evitare l'errore che si verifica cercando di eliminare un oggetto che non esiste.

E' necessario il privilegio ALTER ROUTINE.

