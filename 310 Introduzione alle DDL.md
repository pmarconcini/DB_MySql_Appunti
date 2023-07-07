# Introduzione alle DDL

DDL è l'acronimo di Data Definition Language, cioè l'insieme di istruzioni che permettono di creare, modificare ed eliminare gli oggetti memorizzati all'interno del database, il database stesso o alcune delle componenti che lo costituiscono.
La trattazione dell'argomento è finalizzata all'utilizzo da parte di uno sviluppatore DB e quindi risultano esclusi gli argomenti di interesse specifico dei DBA (DataBase Administrator).

Per una trattazione completa si rimanda alla documentazione ufficiale:
https://dev.mysql.com/doc/refman/8.0/en/sql-data-definition-statements.html

In MySql le istruzioni DDL sono "atomiche", a differenza di quanto accade in altri RDBMS in cui sono "transazionali"; all'atto pratico questo significa che le istruzioni DDL possono essere utilizzate direttamente all'interno del codice.
Attenzione: le istruzioni DDL causano un'azione di salvataggio (COMMIT) implicito, ma NON l'avvio di una nuova transazione.

Nell'esempio seguente la creazione della tabella t_1 causa il salvataggio della riga con valore 2, ma non avviando una nuova transazione l'operazione di annullamento (rollback) non ha effetto e la riga con valore 3 è mantenuta; senza l'istruzione di creazione della tabella entrambi i record sarebbero stati annullati.

    create table t_0 (n integer);
    DELIMITER $$
    CREATE PROCEDURE p_prova()
    BEGIN
        truncate table t_0; -- DDL
    	insert into t_0 (n) values (1);
    	**start transaction;**
    	**insert into t_0 (n) values (2);**
        **create table t_1 (id int);** -- DDL > commit implicito e SENZA nuovo avvio transazione
    	**insert into t_0 (n) values (3);**
        **rollback;**
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

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/aa89ca13-8951-4220-9428-2b00160a8044)

