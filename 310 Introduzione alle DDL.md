# Introduzione alle DDL

DDL è l'acronimo di Data Definition Language, cioè l'insieme di istruzioni che permettono di creare, modificare ed eliminare gli oggetti memorizzati all'interno del database, il database stesso o alcune delle componenti che lo costituiscono.
La trattazione dell'argomento è finalizzata all'utilizzo da parte di uno sviluppatore DB e quindi risultano esclusi gli argomenti di interesse specifico dei DBA (DataBase Administrator).

Per una trattazione completa si rimanda alla documentazione ufficiale:
https://dev.mysql.com/doc/refman/8.0/en/sql-data-definition-statements.html

In MySql le istruzioni DDL sono "atomiche", a differenza di quanto accade in altri RDBMS in cui sono "transazionali"; all'atto pratico questo significa che le istruzioni DDL possono essere utilizzate direttamente all'interno del codice.
Attenzione: le istruzioni DDL causano un'azione di salvataggio (COMMIT) implicito, ma NON l'avvio di una nuova transazione.

Nell'esempio seguente la creazione della tabella t_1 causa il salvataggio della riga con valore 2, ma non avviando una nuova transazione l'operazione di annullamento (rollback) non ha effetto e la riga con valore 3 è mantenuta; senza l'istruzione di creazione della tabella entrambi i record sarebbero stati annullati.

    drop table if exists t_1, t_0;
    create table t_0 (n integer);
    DELIMITER $$
    CREATE PROCEDURE p_prova()
    BEGIN
        truncate table t_0; -- DDL
    	insert into t_0 (n) values (1);
    	start transaction;
    	insert into t_0 (n) values (2);
        create table t_1 (id int); -- DDL > commit implicito e SENZA nuovo avvio transazione
    	insert into t_0 (n) values (3);
        rollback;
    	start transaction;
    	insert into t_0 (n) values (4);
        rollback;
    	insert into t_0 (n) values (5);
        commit;
        drop table if exists t_1; -- DDL
        select * from t_0;
    END$$
    DELIMITER ;
    call p_prova();

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/840aa0ed-bbf9-45fc-8607-f8616230f384)


Le DDL possono contenere o meno istruzioni complesse; in queste lezioni saranno esaminati prima gli oggetti che NON prevedono utilizzo di codice nella creazione (database, tabelle, viste e indici) e poi, dopo aver esplicato le strutture complesse ed i costrutti disponibili, quelli che ne prevedono l'utilizzo all'interno (procedure, funzioni, triggers ed eventi, in una definizione semplice gli "stored programs").

Per convenzione nel mondo MySQL per "stored routines" si inte esclusivamente le procedure (Stored procedure) e le funzioni (Stored function).
Per "stored programs", come detto, si intende triggers ed eventi in aggiunta alle "stored routines".
Per "stored objects" si intende l'insieme degli oggetti senza codice e degli "stored programs".

Ogni oggetto ha delle istruzioni di creazione (CREATE), modifica (ALTER) ed eliminazione (DROP) con caratteristiche ed opzioni peculiari, che saranno affrontate negli specifici capitoli.
