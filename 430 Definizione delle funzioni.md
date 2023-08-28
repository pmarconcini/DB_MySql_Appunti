# Definizione delle funzioni
--------------------------------------

## ESECUZIONE
Una funzione  è un blocco di codice (un insieme ordinato di istruzioni) memorizzato direttamente nel database che restituisce sempre e solo un risultato del tipo di dato previsto e rieseguibile più volte. La funzione può essere utilizzata direttametne nelle query e nelle istruzioni SQL, ma mai da sola: il valore ottenuto deve essere infatti parte dell'output o utilizzato per valorizzare variabili o in espressioni. Le funzioni possono prevedere uno o più parametri rigorosamente con direzione IN:

    [...]
    SELECT <nome_funzione> ( [ <parametro> [, ... ]] ) [...];
    SET <variabile> = <nome_funzione> ( [ <parametro> [, ... ]] ) [...];
    [...]
    
    [...]
    SELECT <nome_funzione>() [...];
    SET <variabile> = <nome_funzione> () [...];
    [...]

L'eventuale elenco di parametri è indicato, per numero, singola tipologia, ordine e direzione, nella firma della funzione assieme al tipo di dato del valore restituito che è a sua volta stabilita al momento della creazione dell'oggetto.
Le tipologie (dei parametri e della risposta) ammesse sono le stesse già viste nella definizione delle colonne delle tabelle e delle variabili.
L'unica direzione ammessa per i parametri delle funzioni è IN e non è necessario specificare l'opzione.
L'elaborazione di una funzione DEVE sempre concludersi con l'istruzione RETURN <espressione>; (quindi deve sempre esserci almeno un RETURN nel codice).

Nell'esempio seguente è richiamata una funzione con un parametro direttamente nella clausola SELECT:

    DELIMITER $$
    CREATE FUNCTION test (param INT)
    RETURNS INT
    DETERMINISTIC
    BEGIN
    	DECLARE ris INT;
      SELECT param * param INTO ris;
      RETURN ris;
    END 
    $$
    DELIMITER ;
    SELECT test(10);

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/18001dbf-83ff-4df6-b914-b004ca96172a)



--------------------------------------
## DEFINIZIONE DELLA FUNZIONE

--------------------------------------
### PRIVILEGI

Per poter creare una funzione è necessasrio avere il privilegio CREATE ROUTINE, per modificarla o eliminarla è necessario avere il privilegio ALTER ROUTINE e per utilizzarla è necessario il privilegio EXECUTE (questi ultimi due sono garantito automaticamente al creatore di una funzione).


--------------------------------------
### INFORMAZIONI

Per ottenere informazioni sulle stored functions è possibile eseguire ricerche nella tabella ROUTINES del database INFORMATION_SCHEMA.
Per vedere la definizione di una funzione è possibile utilizzare l'istruzione SHOW CREATE FUNCTION <nome_funzione>.
Per vedere lo stato di tutte le funzioni è possibile utilizzare l'istruzione SHOW FUNCTION STATUS.


--------------------------------------
### FIRMA e CORPO

Ogni stored function contiene un corpo che consiste di istruzioni (le strutture ed i costrutti visti nel capitolo precedente) separati dal carattere ";", motivo per cui è necessario definire il set di caratteri di delimitazione prima dello script di creazione/modifica/eliminazione.

La logica dei blocchi e la visibilità all'interno del codice è stata già esaminata in un capitolo precedente e si rimanda quindi a quello. 
L'unico aspetto che si aggiunge a quanto detto è la definizione della firma che prevede un nome univoco a livello di database e tipo oggetto, un eventuale elenco ordinato di parametri, ognuno dei quali costituito da nome univoco a livello di elenco dei parametri e tipologia di dato e l'indicazione del tip odi dato del valore restituito.
La visibilità dei parametri è ovviamente tutta la funzione.

All'interno delle funzione:
- si può fare riferimento direttamente a variabili di sessione (va considerata sempre l'inizializzazione delle stesse)
- NON si può utilizzare SELECT senza valorizzazione di variabili (quindi senza clausola INTO) come output in forma di recordset (quindi l'unico output DEVE essere il valore nel formato specificato nella firma)


--------------------------------------
## CREATE

Il template per cer creare una funzione è il seguente:

    CREATE [DEFINER = user] FUNCTION [IF NOT EXISTS] <nome_funzione> ( [ <parametro> <tipo_dato> [,...] ])    RETURNS <tipo_dato>
    [ { COMMENT 'descrizione della funzione'  | [NOT] DETERMINISTIC  | { CONTAINS SQL | NO SQL | READS SQL DATA | MODIFIES SQL DATA }
        | SQL SECURITY { DEFINER | INVOKER } } ] 
    <corpo_della_funzione>;

Il nome della funzione NON può essere una parola chiave o il nome di una routine di sistema.
La funzione viene creata nel database in uso. Per creare la funzione in un database diverso è necessario specificare il nome nella forma <nome_database>.<nome_funzione> (ed avere i necessari privilegi).

Se viene utilizzata l'opzione DEFINER  nella creazione della funzione saranno considerati i privilegi dell'utente indicato, altrimenti sono considerati quelli dell'utente creatore.

L'opzione IF NOT EXISTS evita l'errore che occorre quando si cerca di creare un oggetto con un nome già in uso.

L'opzione COMMENT permette di specificare una descrizione per la funzione (l'informazione è visibile con SHOW CREATE PROCEDURE).

L'opzione DETERMINISTIC indica che la funzione a pari parametri in ingresso produrrà sempre lo stesso risultato; l'opzione predefinita è NOT DETERMINISTIC.

L'opzione CONTAINS SQL indica che la funzione NON legge dati, NO SQL che la funzione NON contiene istruzioni, READS SQL DATA indica che sono presenti istruzioni di sola lettura dati e MODIFIES SQL DATA indica la presenza di istruzioni di modifica dei dati..

L'opzione SQL SECURITY permette di stabilire se in fase di elaborazione devono essere considerati i privilegi del creatore (DEFINER) o dell'esecutore (INVOKER, opzione predefinita).



--------------------------------------
## ALTER

L'istruzione ALTER permette di variare alcune caratteristiche di una funzione esistente, secondo il seguente template:

    ALTER FUNCTION <nome_funzione> { COMMENT 'Descrizione della funzione' | { CONTAINS SQL | NO SQL | READS SQL DATA | MODIFIES SQL DATA } | SQL SECURITY { DEFINER | INVOKER } } ;
    
Per la descrizione delle opzioni si rimanda al paragrafo CREATE.

E' necessario il privilegio ALTER ROUTINE.



--------------------------------------
## DROP

L'istruzione DROP permette di eliminare una funzione esistente, secondo il seguente template:

    DROP FUNCTION [IF EXISTS] <nome_funzione> ;

L'opzione IF EXISTS permette di evitare l'errore che si verifica cercando di eliminare un oggetto che non esiste.

E' necessario il privilegio ALTER ROUTINE.
