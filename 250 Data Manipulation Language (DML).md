# DATA MANIPULATION LANGUAGE (DML)

--------------------------------------------
## INSERT

L’istruzione, utilizzata per inserire dati in una singola tabella, prevede alcune parti necessarie e alcune facoltative:

    INSERT INTO <nome della singola tabella: es. dept> -- =>parte necessaria
    (<elenco dei campi target: es. deptno, dname, loc>) -- => necessaria se non vengono passati valori per tutti i campi e/o in ordine diverso dalla definizione dei campi della tabella
    VALUES -- => parte necessaria eccetto il caso in cui i valori siano ottenuti da una subquery
    (<elenco dei valori/espressioni o subquery di origine>); -- => parte necessaria (l’ordine e il numero dei valori di origine deve coincidere con l’ordine e il numero dei campi target).

NB: è possibile utilizzare l’istruzione con viste e inline view, con i seguenti vincoli:

-	la vista deve fare riferimento a una unica tabella nella clausola FROM
-	la vista deve prendere in considerazione nella clausola SELECT tutti i campi nonnulli della suddetta tabella, ivi compresa quindi la chiave primaria
-	la DML di manipolazione deve intervenire esclusivamente su campi presenti nella clausola SELECT della vista nella loro forma originale (quindi non variati da elaborazioni e/o funzioni)

Per utilizzare l'istruzione INSERT è necessario avere il privilegio INSERT.
Inserire un valore NULL in una colonna definita nonnulla implica una conversione automatica nel valore di default per la tipologia di dato ('' per il testo e 0 per numeri e date).


Nell'esempio seguente le varie forme che può assumere l'istruzione INSERT:

    INSERT INTO dept (deptno, dname, loc) VALUES (50, 'OPERATIONS', 'NEW YORK'); -- tutti i campi, nell'ordine della tabella

    INSERT INTO dept VALUES (60, 'SALES', 'LAS VEGAS'); -- tutti i campi, nell'ordine della tabella
    
    INSERT INTO dept (dname, deptno, loc) VALUES ('SALES', 70, 'MIAMI'); -- tutti i campi, in ordine diverso dalla tabella
    
    INSERT INTO dept (deptno, dname) VALUES (80, 'ONLINE SHOP'); -- solo alcuni campi
    
    INSERT INTO dept -- tramite subquery
    SELECT 80 + @rownum := @rownum + 1 , 'SALES', loc FROM dept d, (SELECT @rownum := 0) r 
       WHERE NOT EXISTS (SELECT 1 FROM dept WHERE loc = d.loc and dname = 'SALES') AND loc IS NOT NULL;

    INSERT INTO dept (deptno, dname, loc) VALUES  -- inserimento multiplo
      (90, 'SALES', 'TURIN'), -- equivale ROW(90, 'SALES', 'TURIN')
      (91, 'SALES', 'FLORENCE'), -- equivale ROW(91, 'SALES', 'FLORENCE')
      (92, 'SALES', 'ROME'); -- equivale ROW(92, 'SALES', 'ROME')

==> 1 row(s) affected	0.000 sec	 
==> 1 row(s) affected	0.000 sec	 
==> 1 row(s) affected	0.000 sec	 
==> 1 row(s) affected	0.000 sec	 
==> 4 row(s) affected	0.000 sec	 
==> 3 row(s) affected	0.000 sec	 


Settare un valore numerico fuori dal range previsto per la colonna di destinazione implica la modifica del dato per portarlo al valore di confine.
Settare un valore testuale con dimensione superiore di quanto previsto per la colonna di destinazione implica il troncamento alla dimensione massima possibile.
Settare una data con un formato errato implica la sostituzione con 0


Se l'inserimento è relativo a una tabella in cui è definita una colonna con AUTO_INCREMENT si può omettere di specificare la colonna e/o il relativo valore: il valore inserito sarà automaticamente calcolato come il valore massimo corrente in tabella +1; indicando invece sia la colonna che il relativo valore si forza MySql ad utilizzare il valore proposto (ovviamente se non viola nessun constraint).
Per sapere quale è l'ultimo id generato (tramite colonna AUTO_INCREMENT) si può utilizzare la funzione LAST_INSERT_ID().
Attenzione! In caso di inserimenti multipli sarà restituito il primo ID dell'inserimento multiplo, non l'ultimo.


E' possibile aggiungere l'opzione IGNORE per bypassare eventuali errori bloccanti, come nel caso della INSERT seguente che causa un errore di chiave duplicata:

    INSERT IGNORE INTO dept (deptno, dname) VALUES (80, 'ONLINE SHOP'); -- chiave già inserita in precedenza

==> 0 row(s) affected, 1 warning(s): 1062 Duplicate entry '80' for key 'dept.PRIMARY'	0.000 sec


E' possibile aggiungere l'opzione ON DUPLICATE KEY UPDATE <colonna1> = <valore1> [,<colonna2> = <valore2> [, ...]]  per fare in modo che non si generi l'errore di chiave duplicata e che lo stesso venga sostituito con l'aggiornamento dei dati del record esistente:

    INSERT INTO dept (deptno, dname) VALUES (80, 'UNDEFINED') ON DUPLICATE KEY UPDATE dname = 'UNDEFINED';

==> 2 row(s) affected	0.016 sec

NB: al momento la console calcola erroneamente il numero di record processati, come si evince dalla risposta



--------------------------------------------
## REPLACE

L'istruzione REPLACE è, in sostanza, una variante della INSERT che ne mantiene tutte le peculiarità ma permette di aggiornare il record nel caso di violazione di chiave duplicata. 
Nell'esempio seguente l'ID 80 è già esistente e quindi viene aggiornata la descrizione (e vengono nullificate le colonne per cui non è disponibile un valore) mentre l'ID 88 non esiste e quindi viene eseguito l'inserimento:

    REPLACE INTO dept (deptno, dname) VALUES (80, 'E-SHOP'), (88, 'E-SHOP');

==> 3 row(s) affected Records: 2  Duplicates: 1  Warnings: 0	0.063 sec

NB: al momento la console calcola erroneamente il numero di record processati, come si evince dalla risposta

 




***************************************************************************************************************************

***************************************************************************************************************************
***************************************************************************************************************************

***************************************************************************************************************************
 


DML - MANIPOLAZIONE: UPDATE
L’istruzione, utilizzata per aggiornare dati in una singola tabella, prevede alcune parti necessarie e alcune facoltative:
•	UPDATE <nome della singola tabella: es. dept> =>parte necessaria. E’ possibile specificare un alias di tabella, spesso necessario in caso di subquery nelle clausole SET e/o WHERE
•	SET <elenco delle valorizzazioni dei campi separate da virgola: es. loc = INITCAP(loc)> => parte necessaria. Le espressioni valide sono tutte quelle utilizzabili nella clausola SELECT. E’ possibile valorizzare contemporaneamente più campi tramite una unica subquery: in questo caso l’elenco dei campi deve essere racchiuso tra parentesi.
•	WHERE  <condizioni> => parte facoltativa. Esattamente come nel caso delle queries di interrogazione permette il filtro dei record. In assenza della clausola WHERE l’aggiornamento riguarderà tutti i record presenti in tabella
Esistono delle forme alternative della clausola WHERE utilizzabili nel codice PL/SQL (CURRENT OF e RETURNING … INTO …) che descriveremo successivamente.
NB: è possibile utilizzare l’istruzione con viste e viste materializzate, con i seguenti vincoli:
•	la vista deve prendere in considerazione nella clausola SELECT tutti i campi della chiave primaria della tabella che si vuole aggiornare
•	la DML di manipolazione deve intervenire esclusivamente su campi presenti nella clausola SELECT della vista nella loro forma originale (quindi non variati da elaborazioni e/o funzioni)
 
5 4 Esempio DML – UPDATE
1.	--#1
2.	UPDATE dept d
3.	SET dname = dname || '*', loc = INITCAP(loc)
4.	WHERE NOT EXISTS (SELECT 1 FROM emp WHERE deptno = d.deptno);
5.	UPDATE dept d
6.	SET loc = UPPER(loc);
7.	COMMIT;    
	 

1.	--#2
2.	UPDATE prova a
3.	SET (t, d) = (SELECT 'Il quadrato di ' || n || ' e'' ' || power(n, 2), sysdate FROM prova WHERE n = a.n);
4.	COMMIT;
	Prima: 		Dopo: 

In maniera simile alla valorizzazione massiva tramite subquery è possibile aggiornare tutti i campi di un record tramite l’utilizzo della funzione VALUE associata anche in questo caso a una subquery; segue un esempio della particolare casistica:
1.	--#3
UPDATE tabella_demo1 p 
2.	SET VALUE(p) = (SELECT VALUE(q) FROM tabella_demo2 q WHERE p.id = q.id)
   WHERE p.id = 10;
Può essere molto utile, per esempio, per il ripristino di dati da una tabella di backup o versionamento.

DML - MANIPOLAZIONE: DELETE E TRUNCATE
L’istruzione DELETE, utilizzata per eliminare dati in una singola tabella, prevede una parte necessaria e una facoltativa:
•	DELETE FROM <nome della singola tabella: es. dept => parte necessaria. E’ possibile specificare un alias di tabella, spesso necessario in caso di subquery nella clausola WHERE
•	WHERE  <condizioni> => parte facoltativa. Esattamente come nel caso delle queries di interrogazione permette il filtro dei record. In assenza della clausola WHERE l’eliminazione riguarderà tutti i record presenti in tabella
Esiste anche in questo caso la forma alternativa RETURNING … INTO … della clausola WHERE utilizzabile nel codice PL/SQL che descriveremo successivamente.
NB: è possibile utilizzare l’istruzione con viste e viste materializzate, con il seguente vincolo:
•	la vista deve prendere in considerazione nella clausola SELECT tutti i campi della chiave primaria della tabella di cui si vuole eliminare dati
 
5 5 Esempio DML – DELETE
1.	DELETE FROM dept d
2.	WHERE deptno > 40;
3.	COMMIT;
	 
Una migliore alternativa per l’eliminazione di tutti i record di una tabella è l’istruzione TRUNCATE che è però considerabile una DDL e, in quanto tale, implica l’esecuzione automatica della COMMIT e l’eliminazione delle versioni precedenti dei dati da parte di Oracle. La TRUNCATE NON può essere utilizzata su tabelle la cui chiave primaria sia parte di vincoli di integrità referenziale attivi.
 
5 6 Esempio DDL – TRUNCATE
1.	TRUNCATE TABLE prova;

DML - MANIPOLAZIONE: MERGE
L’istruzione, utilizzata per combinare operazioni multiple, prevede alcune parti obbligatorie e alcune facoltative:
•	MERGE INTO <nome della singola tabella di destinazione: es. dept> => parte necessaria. E’ la tabella in cui inserire o aggiornare i dati.
•	USING  <tabella o query di origine: es. dept_modificati>. E’ obbligatoria.
•	ON (<condizioni di join>). E’ obbligatoria.
•	WHEN MATCHED THEN UPDATE SET <elenco valorizzazioni> e WHEN NOT MATCHED THEN INSERT (<elenco campi>) VALUES (<elenco espressioni>). E’ obbligatorio che sia presente almeno una delle due forme.
•	La clausola WHEN MATCHED può prevedere anche la clausola WHERE seguita dalle condizioni ed eventualmente, successivamente, la scrittura DELETE WHERE <condizioni> per associare anche l’istruzione di eliminazione; le condizioni di eliminazione vengono verificate DOPO l’aggiornamento e coinvolgono esclusivamente i record aggiornati.
•	È possibile specificare delle condizioni di filtro tramite la clausola WHERE a fine istruzione oppure integrando adeguatamente la clausola di join ON.

 
5 7 Esempio DML – MERGE USING query
1.	MERGE INTO bonus D
2.	   USING (SELECT empno, sal + nvl(comm, 0) tot FROM emp
3.	         ) S
4.	   ON (D.empno = S.empno)
5.	   WHEN MATCHED THEN 
6.	     UPDATE SET D.bonus = D.bonus + S.tot * .01
7.	     DELETE WHERE (D.bonus > 50)
8.	   WHEN NOT MATCHED THEN 
9.	     INSERT (D.empno, D.bonus)
10.	     VALUES (S.empno, S.tot * .01)
11.	   WHERE (S.tot <= 3000);
12.	COMMIT;

	Dopo la prima esecuzione:	   	
	Dopo la seconda esecuzione: 	 


L’esempio seguente è assolutamente equivalente a quello appena visto:
 
5 8 Esempio DML – MERGE USING tabella
1.	MERGE INTO bonus D
2.	   USING emp S
3.	   ON (D.empno = S.empno)
4.	   WHEN MATCHED THEN 
5.	     UPDATE SET D.bonus = D.bonus + (S.sal + nvl(S.comm, 0)) * .01
6.	     DELETE WHERE (D.bonus > 50)
7.	   WHEN NOT MATCHED THEN 
8.	     INSERT (D.empno, D.bonus)
9.	     VALUES (S.empno, (S.sal + nvl(S.comm, 0)) * .01)
10.	   WHERE ((S.sal + nvl(S.comm, 0)) <= 3000);




***************************************************************************************************************************

***************************************************************************************************************************
***************************************************************************************************************************

***************************************************************************************************************************
 

13.2.17 UPDATE Statement
UPDATE is a DML statement that modifies rows in a table.

An UPDATE statement can start with a WITH clause to define common table expressions accessible within the UPDATE. See Section 13.2.20, “WITH (Common Table Expressions)”.

Single-table syntax:

UPDATE [LOW_PRIORITY] [IGNORE] table_reference
    SET assignment_list
    [WHERE where_condition]
    [ORDER BY ...]
    [LIMIT row_count]

value:
    {expr | DEFAULT}

assignment:
    col_name = value

assignment_list:
    assignment [, assignment] ...
Multiple-table syntax:

UPDATE [LOW_PRIORITY] [IGNORE] table_references
    SET assignment_list
    [WHERE where_condition]
For the single-table syntax, the UPDATE statement updates columns of existing rows in the named table with new values. The SET clause indicates which columns to modify and the values they should be given. Each value can be given as an expression, or the keyword DEFAULT to set a column explicitly to its default value. The WHERE clause, if given, specifies the conditions that identify which rows to update. With no WHERE clause, all rows are updated. If the ORDER BY clause is specified, the rows are updated in the order that is specified. The LIMIT clause places a limit on the number of rows that can be updated.

For the multiple-table syntax, UPDATE updates rows in each table named in table_references that satisfy the conditions. Each matching row is updated once, even if it matches the conditions multiple times. For multiple-table syntax, ORDER BY and LIMIT cannot be used.

For partitioned tables, both the single-single and multiple-table forms of this statement support the use of a PARTITION clause as part of a table reference. This option takes a list of one or more partitions or subpartitions (or both). Only the partitions (or subpartitions) listed are checked for matches, and a row that is not in any of these partitions or subpartitions is not updated, whether it satisfies the where_condition or not.

Note
Unlike the case when using PARTITION with an INSERT or REPLACE statement, an otherwise valid UPDATE ... PARTITION statement is considered successful even if no rows in the listed partitions (or subpartitions) match the where_condition.

For more information and examples, see Section 24.5, “Partition Selection”.

where_condition is an expression that evaluates to true for each row to be updated. For expression syntax, see Section 9.5, “Expressions”.

table_references and where_condition are specified as described in Section 13.2.13, “SELECT Statement”.

You need the UPDATE privilege only for columns referenced in an UPDATE that are actually updated. You need only the SELECT privilege for any columns that are read but not modified.

The UPDATE statement supports the following modifiers:

With the LOW_PRIORITY modifier, execution of the UPDATE is delayed until no other clients are reading from the table. This affects only storage engines that use only table-level locking (such as MyISAM, MEMORY, and MERGE).

With the IGNORE modifier, the update statement does not abort even if errors occur during the update. Rows for which duplicate-key conflicts occur on a unique key value are not updated. Rows updated to values that would cause data conversion errors are updated to the closest valid values instead. For more information, see The Effect of IGNORE on Statement Execution.

UPDATE IGNORE statements, including those having an ORDER BY clause, are flagged as unsafe for statement-based replication. (This is because the order in which the rows are updated determines which rows are ignored.) Such statements produce a warning in the error log when using statement-based mode and are written to the binary log using the row-based format when using MIXED mode. (Bug #11758262, Bug #50439) See Section 17.2.1.3, “Determination of Safe and Unsafe Statements in Binary Logging”, for more information.

If you access a column from the table to be updated in an expression, UPDATE uses the current value of the column. For example, the following statement sets col1 to one more than its current value:

UPDATE t1 SET col1 = col1 + 1;
The second assignment in the following statement sets col2 to the current (updated) col1 value, not the original col1 value. The result is that col1 and col2 have the same value. This behavior differs from standard SQL.

UPDATE t1 SET col1 = col1 + 1, col2 = col1;
Single-table UPDATE assignments are generally evaluated from left to right. For multiple-table updates, there is no guarantee that assignments are carried out in any particular order.

If you set a column to the value it currently has, MySQL notices this and does not update it.

If you update a column that has been declared NOT NULL by setting to NULL, an error occurs if strict SQL mode is enabled; otherwise, the column is set to the implicit default value for the column data type and the warning count is incremented. The implicit default value is 0 for numeric types, the empty string ('') for string types, and the “zero” value for date and time types. See Section 11.6, “Data Type Default Values”.

If a generated column is updated explicitly, the only permitted value is DEFAULT. For information about generated columns, see Section 13.1.20.8, “CREATE TABLE and Generated Columns”.

UPDATE returns the number of rows that were actually changed. The mysql_info() C API function returns the number of rows that were matched and updated and the number of warnings that occurred during the UPDATE.

You can use LIMIT row_count to restrict the scope of the UPDATE. A LIMIT clause is a rows-matched restriction. The statement stops as soon as it has found row_count rows that satisfy the WHERE clause, whether or not they actually were changed.

If an UPDATE statement includes an ORDER BY clause, the rows are updated in the order specified by the clause. This can be useful in certain situations that might otherwise result in an error. Suppose that a table t contains a column id that has a unique index. The following statement could fail with a duplicate-key error, depending on the order in which rows are updated:

UPDATE t SET id = id + 1;
For example, if the table contains 1 and 2 in the id column and 1 is updated to 2 before 2 is updated to 3, an error occurs. To avoid this problem, add an ORDER BY clause to cause the rows with larger id values to be updated before those with smaller values:

UPDATE t SET id = id + 1 ORDER BY id DESC;
You can also perform UPDATE operations covering multiple tables. However, you cannot use ORDER BY or LIMIT with a multiple-table UPDATE. The table_references clause lists the tables involved in the join. Its syntax is described in Section 13.2.13.2, “JOIN Clause”. Here is an example:

UPDATE items,month SET items.price=month.price
WHERE items.id=month.id;
The preceding example shows an inner join that uses the comma operator, but multiple-table UPDATE statements can use any type of join permitted in SELECT statements, such as LEFT JOIN.

If you use a multiple-table UPDATE statement involving InnoDB tables for which there are foreign key constraints, the MySQL optimizer might process tables in an order that differs from that of their parent/child relationship. In this case, the statement fails and rolls back. Instead, update a single table and rely on the ON UPDATE capabilities that InnoDB provides to cause the other tables to be modified accordingly. See Section 13.1.20.5, “FOREIGN KEY Constraints”.

You cannot update a table and select directly from the same table in a subquery. You can work around this by using a multi-table update in which one of the tables is derived from the table that you actually wish to update, and referring to the derived table using an alias. Suppose you wish to update a table named items which is defined using the statement shown here:

CREATE TABLE items (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    wholesale DECIMAL(6,2) NOT NULL DEFAULT 0.00,
    retail DECIMAL(6,2) NOT NULL DEFAULT 0.00,
    quantity BIGINT NOT NULL DEFAULT 0
);
To reduce the retail price of any items for which the markup is 30% or greater and of which you have fewer than one hundred in stock, you might try to use an UPDATE statement such as the one following, which uses a subquery in the WHERE clause. As shown here, this statement does not work:

mysql> UPDATE items
     > SET retail = retail * 0.9
     > WHERE id IN
     >     (SELECT id FROM items
     >         WHERE retail / wholesale >= 1.3 AND quantity > 100);
ERROR 1093 (HY000): You can't specify target table 'items' for update in FROM clause
Instead, you can employ a multi-table update in which the subquery is moved into the list of tables to be updated, using an alias to reference it in the outermost WHERE clause, like this:

UPDATE items,
       (SELECT id FROM items
        WHERE id IN
            (SELECT id FROM items
             WHERE retail / wholesale >= 1.3 AND quantity < 100))
        AS discounted
SET items.retail = items.retail * 0.9
WHERE items.id = discounted.id;
Because the optimizer tries by default to merge the derived table discounted into the outermost query block, this works only if you force materialization of the derived table. You can do this by setting the derived_merge flag of the optimizer_switch system variable to off before running the update, or by using the NO_MERGE optimizer hint, as shown here:

UPDATE /*+ NO_MERGE(discounted) */ items,
       (SELECT id FROM items
        WHERE retail / wholesale >= 1.3 AND quantity < 100)
        AS discounted
    SET items.retail = items.retail * 0.9
    WHERE items.id = discounted.id;
The advantage of using the optimizer hint in such a case is that it applies only within the query block where it is used, so that it is not necessary to change the value of optimizer_switch again after executing the UPDATE.

Another possibility is to rewrite the subquery so that it does not use IN or EXISTS, like this:

UPDATE items,
       (SELECT id, retail / wholesale AS markup, quantity FROM items)
       AS discounted
    SET items.retail = items.retail * 0.9
    WHERE discounted.markup >= 1.3
    AND discounted.quantity < 100
    AND items.id = discounted.id;
In this case, the subquery is materialized by default rather than merged, so it is not necessary to disable merging of the derived table.

***********************************************************************************

***********************************************************************************

13.2.2 DELETE Statement
DELETE is a DML statement that removes rows from a table.

A DELETE statement can start with a WITH clause to define common table expressions accessible within the DELETE. See Section 13.2.20, “WITH (Common Table Expressions)”.

Single-Table Syntax
DELETE [LOW_PRIORITY] [QUICK] [IGNORE] FROM tbl_name [[AS] tbl_alias]
    [PARTITION (partition_name [, partition_name] ...)]
    [WHERE where_condition]
    [ORDER BY ...]
    [LIMIT row_count]
The DELETE statement deletes rows from tbl_name and returns the number of deleted rows. To check the number of deleted rows, call the ROW_COUNT() function described in Section 12.15, “Information Functions”.

Main Clauses
The conditions in the optional WHERE clause identify which rows to delete. With no WHERE clause, all rows are deleted.

where_condition is an expression that evaluates to true for each row to be deleted. It is specified as described in Section 13.2.13, “SELECT Statement”.

If the ORDER BY clause is specified, the rows are deleted in the order that is specified. The LIMIT clause places a limit on the number of rows that can be deleted. These clauses apply to single-table deletes, but not multi-table deletes.

Multiple-Table Syntax
DELETE [LOW_PRIORITY] [QUICK] [IGNORE]
    tbl_name[.*] [, tbl_name[.*]] ...
    FROM table_references
    [WHERE where_condition]

DELETE [LOW_PRIORITY] [QUICK] [IGNORE]
    FROM tbl_name[.*] [, tbl_name[.*]] ...
    USING table_references
    [WHERE where_condition]
Privileges
You need the DELETE privilege on a table to delete rows from it. You need only the SELECT privilege for any columns that are only read, such as those named in the WHERE clause.

Performance
When you do not need to know the number of deleted rows, the TRUNCATE TABLE statement is a faster way to empty a table than a DELETE statement with no WHERE clause. Unlike DELETE, TRUNCATE TABLE cannot be used within a transaction or if you have a lock on the table. See Section 13.1.37, “TRUNCATE TABLE Statement” and Section 13.3.6, “LOCK TABLES and UNLOCK TABLES Statements”.

The speed of delete operations may also be affected by factors discussed in Section 8.2.5.3, “Optimizing DELETE Statements”.

To ensure that a given DELETE statement does not take too much time, the MySQL-specific LIMIT row_count clause for DELETE specifies the maximum number of rows to be deleted. If the number of rows to delete is larger than the limit, repeat the DELETE statement until the number of affected rows is less than the LIMIT value.

Subqueries
You cannot delete from a table and select from the same table in a subquery.

Partitioned Table Support
DELETE supports explicit partition selection using the PARTITION clause, which takes a list of the comma-separated names of one or more partitions or subpartitions (or both) from which to select rows to be dropped. Partitions not included in the list are ignored. Given a partitioned table t with a partition named p0, executing the statement DELETE FROM t PARTITION (p0) has the same effect on the table as executing ALTER TABLE t TRUNCATE PARTITION (p0); in both cases, all rows in partition p0 are dropped.

PARTITION can be used along with a WHERE condition, in which case the condition is tested only on rows in the listed partitions. For example, DELETE FROM t PARTITION (p0) WHERE c < 5 deletes rows only from partition p0 for which the condition c < 5 is true; rows in any other partitions are not checked and thus not affected by the DELETE.

The PARTITION clause can also be used in multiple-table DELETE statements. You can use up to one such option per table named in the FROM option.

For more information and examples, see Section 24.5, “Partition Selection”.

Auto-Increment Columns
If you delete the row containing the maximum value for an AUTO_INCREMENT column, the value is not reused for a MyISAM or InnoDB table. If you delete all rows in the table with DELETE FROM tbl_name (without a WHERE clause) in autocommit mode, the sequence starts over for all storage engines except InnoDB and MyISAM. There are some exceptions to this behavior for InnoDB tables, as discussed in Section 15.6.1.6, “AUTO_INCREMENT Handling in InnoDB”.

For MyISAM tables, you can specify an AUTO_INCREMENT secondary column in a multiple-column key. In this case, reuse of values deleted from the top of the sequence occurs even for MyISAM tables. See Section 3.6.9, “Using AUTO_INCREMENT”.

Modifiers
The DELETE statement supports the following modifiers:

If you specify the LOW_PRIORITY modifier, the server delays execution of the DELETE until no other clients are reading from the table. This affects only storage engines that use only table-level locking (such as MyISAM, MEMORY, and MERGE).

For MyISAM tables, if you use the QUICK modifier, the storage engine does not merge index leaves during delete, which may speed up some kinds of delete operations.

The IGNORE modifier causes MySQL to ignore ignorable errors during the process of deleting rows. (Errors encountered during the parsing stage are processed in the usual manner.) Errors that are ignored due to the use of IGNORE are returned as warnings. For more information, see The Effect of IGNORE on Statement Execution.

Order of Deletion
If the DELETE statement includes an ORDER BY clause, rows are deleted in the order specified by the clause. This is useful primarily in conjunction with LIMIT. For example, the following statement finds rows matching the WHERE clause, sorts them by timestamp_column, and deletes the first (oldest) one:

DELETE FROM somelog WHERE user = 'jcole'
ORDER BY timestamp_column LIMIT 1;
ORDER BY also helps to delete rows in an order required to avoid referential integrity violations.

InnoDB Tables
If you are deleting many rows from a large table, you may exceed the lock table size for an InnoDB table. To avoid this problem, or simply to minimize the time that the table remains locked, the following strategy (which does not use DELETE at all) might be helpful:

Select the rows not to be deleted into an empty table that has the same structure as the original table:

INSERT INTO t_copy SELECT * FROM t WHERE ... ;
Use RENAME TABLE to atomically move the original table out of the way and rename the copy to the original name:

RENAME TABLE t TO t_old, t_copy TO t;
Drop the original table:

DROP TABLE t_old;
No other sessions can access the tables involved while RENAME TABLE executes, so the rename operation is not subject to concurrency problems. See Section 13.1.36, “RENAME TABLE Statement”.

MyISAM Tables
In MyISAM tables, deleted rows are maintained in a linked list and subsequent INSERT operations reuse old row positions. To reclaim unused space and reduce file sizes, use the OPTIMIZE TABLE statement or the myisamchk utility to reorganize tables. OPTIMIZE TABLE is easier to use, but myisamchk is faster. See Section 13.7.3.4, “OPTIMIZE TABLE Statement”, and Section 4.6.4, “myisamchk — MyISAM Table-Maintenance Utility”.

The QUICK modifier affects whether index leaves are merged for delete operations. DELETE QUICK is most useful for applications where index values for deleted rows are replaced by similar index values from rows inserted later. In this case, the holes left by deleted values are reused.

DELETE QUICK is not useful when deleted values lead to underfilled index blocks spanning a range of index values for which new inserts occur again. In this case, use of QUICK can lead to wasted space in the index that remains unreclaimed. Here is an example of such a scenario:

Create a table that contains an indexed AUTO_INCREMENT column.

Insert many rows into the table. Each insert results in an index value that is added to the high end of the index.

Delete a block of rows at the low end of the column range using DELETE QUICK.

In this scenario, the index blocks associated with the deleted index values become underfilled but are not merged with other index blocks due to the use of QUICK. They remain underfilled when new inserts occur, because new rows do not have index values in the deleted range. Furthermore, they remain underfilled even if you later use DELETE without QUICK, unless some of the deleted index values happen to lie in index blocks within or adjacent to the underfilled blocks. To reclaim unused index space under these circumstances, use OPTIMIZE TABLE.

If you are going to delete many rows from a table, it might be faster to use DELETE QUICK followed by OPTIMIZE TABLE. This rebuilds the index rather than performing many index block merge operations.

Multi-Table Deletes
You can specify multiple tables in a DELETE statement to delete rows from one or more tables depending on the condition in the WHERE clause. You cannot use ORDER BY or LIMIT in a multiple-table DELETE. The table_references clause lists the tables involved in the join, as described in Section 13.2.13.2, “JOIN Clause”.

For the first multiple-table syntax, only matching rows from the tables listed before the FROM clause are deleted. For the second multiple-table syntax, only matching rows from the tables listed in the FROM clause (before the USING clause) are deleted. The effect is that you can delete rows from many tables at the same time and have additional tables that are used only for searching:

DELETE t1, t2 FROM t1 INNER JOIN t2 INNER JOIN t3
WHERE t1.id=t2.id AND t2.id=t3.id;
Or:

DELETE FROM t1, t2 USING t1 INNER JOIN t2 INNER JOIN t3
WHERE t1.id=t2.id AND t2.id=t3.id;
These statements use all three tables when searching for rows to delete, but delete matching rows only from tables t1 and t2.

The preceding examples use INNER JOIN, but multiple-table DELETE statements can use other types of join permitted in SELECT statements, such as LEFT JOIN. For example, to delete rows that exist in t1 that have no match in t2, use a LEFT JOIN:

DELETE t1 FROM t1 LEFT JOIN t2 ON t1.id=t2.id WHERE t2.id IS NULL;
The syntax permits .* after each tbl_name for compatibility with Access.

If you use a multiple-table DELETE statement involving InnoDB tables for which there are foreign key constraints, the MySQL optimizer might process tables in an order that differs from that of their parent/child relationship. In this case, the statement fails and rolls back. Instead, you should delete from a single table and rely on the ON DELETE capabilities that InnoDB provides to cause the other tables to be modified accordingly.

Note
If you declare an alias for a table, you must use the alias when referring to the table:

DELETE t1 FROM test AS t1, test2 WHERE ...
Table aliases in a multiple-table DELETE should be declared only in the table_references part of the statement. Elsewhere, alias references are permitted but not alias declarations.

Correct:

DELETE a1, a2 FROM t1 AS a1 INNER JOIN t2 AS a2
WHERE a1.id=a2.id;

DELETE FROM a1, a2 USING t1 AS a1 INNER JOIN t2 AS a2
WHERE a1.id=a2.id;
Incorrect:

DELETE t1 AS a1, t2 AS a2 FROM t1 INNER JOIN t2
WHERE a1.id=a2.id;

DELETE FROM t1 AS a1, t2 AS a2 USING t1 INNER JOIN t2
WHERE a1.id=a2.id;
Table aliases are also supported for single-table DELETE statements beginning with MySQL 8.0.16. (Bug #89410,Bug #27455809)



**************************************************************************

**************************************************************************

13.2.12 REPLACE Statement
REPLACE [LOW_PRIORITY | DELAYED]
    [INTO] tbl_name
    [PARTITION (partition_name [, partition_name] ...)]
    [(col_name [, col_name] ...)]
    { {VALUES | VALUE} (value_list) [, (value_list)] ...
      |
      VALUES row_constructor_list
    }

REPLACE [LOW_PRIORITY | DELAYED]
    [INTO] tbl_name
    [PARTITION (partition_name [, partition_name] ...)]
    SET assignment_list

REPLACE [LOW_PRIORITY | DELAYED]
    [INTO] tbl_name
    [PARTITION (partition_name [, partition_name] ...)]
    [(col_name [, col_name] ...)]
    {SELECT ... | TABLE table_name}

value:
    {expr | DEFAULT}

value_list:
    value [, value] ...

row_constructor_list:
    ROW(value_list)[, ROW(value_list)][, ...]

assignment:
    col_name = value

assignment_list:
    assignment [, assignment] ...
REPLACE works exactly like INSERT, except that if an old row in the table has the same value as a new row for a PRIMARY KEY or a UNIQUE index, the old row is deleted before the new row is inserted. See Section 13.2.7, “INSERT Statement”.

REPLACE is a MySQL extension to the SQL standard. It either inserts, or deletes and inserts. For another MySQL extension to standard SQL—that either inserts or updates—see Section 13.2.7.2, “INSERT ... ON DUPLICATE KEY UPDATE Statement”.

DELAYED inserts and replaces were deprecated in MySQL 5.6. In MySQL 8.0, DELAYED is not supported. The server recognizes but ignores the DELAYED keyword, handles the replace as a nondelayed replace, and generates an ER_WARN_LEGACY_SYNTAX_CONVERTED warning: REPLACE DELAYED is no longer supported. The statement was converted to REPLACE. The DELAYED keyword is scheduled for removal in a future release. release.

Note
REPLACE makes sense only if a table has a PRIMARY KEY or UNIQUE index. Otherwise, it becomes equivalent to INSERT, because there is no index to be used to determine whether a new row duplicates another.

Values for all columns are taken from the values specified in the REPLACE statement. Any missing columns are set to their default values, just as happens for INSERT. You cannot refer to values from the current row and use them in the new row. If you use an assignment such as SET col_name = col_name + 1, the reference to the column name on the right hand side is treated as DEFAULT(col_name), so the assignment is equivalent to SET col_name = DEFAULT(col_name) + 1.

In MySQL 8.0.19 and later, you can specify the column values that REPLACE attempts to insert using VALUES ROW().

To use REPLACE, you must have both the INSERT and DELETE privileges for the table.

If a generated column is replaced explicitly, the only permitted value is DEFAULT. For information about generated columns, see Section 13.1.20.8, “CREATE TABLE and Generated Columns”.

REPLACE supports explicit partition selection using the PARTITION clause with a list of comma-separated names of partitions, subpartitions, or both. As with INSERT, if it is not possible to insert the new row into any of these partitions or subpartitions, the REPLACE statement fails with the error Found a row not matching the given partition set. For more information and examples, see Section 24.5, “Partition Selection”.

The REPLACE statement returns a count to indicate the number of rows affected. This is the sum of the rows deleted and inserted. If the count is 1 for a single-row REPLACE, a row was inserted and no rows were deleted. If the count is greater than 1, one or more old rows were deleted before the new row was inserted. It is possible for a single row to replace more than one old row if the table contains multiple unique indexes and the new row duplicates values for different old rows in different unique indexes.

The affected-rows count makes it easy to determine whether REPLACE only added a row or whether it also replaced any rows: Check whether the count is 1 (added) or greater (replaced).

If you are using the C API, the affected-rows count can be obtained using the mysql_affected_rows() function.

You cannot replace into a table and select from the same table in a subquery.

MySQL uses the following algorithm for REPLACE (and LOAD DATA ... REPLACE):

Try to insert the new row into the table

While the insertion fails because a duplicate-key error occurs for a primary key or unique index:

Delete from the table the conflicting row that has the duplicate key value

Try again to insert the new row into the table

It is possible that in the case of a duplicate-key error, a storage engine may perform the REPLACE as an update rather than a delete plus insert, but the semantics are the same. There are no user-visible effects other than a possible difference in how the storage engine increments Handler_xxx status variables.

Because the results of REPLACE ... SELECT statements depend on the ordering of rows from the SELECT and this order cannot always be guaranteed, it is possible when logging these statements for the source and the replica to diverge. For this reason, REPLACE ... SELECT statements are flagged as unsafe for statement-based replication. such statements produce a warning in the error log when using statement-based mode and are written to the binary log using the row-based format when using MIXED mode. See also Section 17.2.1.1, “Advantages and Disadvantages of Statement-Based and Row-Based Replication”.

MySQL 8.0.19 and later supports TABLE as well as SELECT with REPLACE, just as it does with INSERT. See Section 13.2.7.1, “INSERT ... SELECT Statement”, for more information and examples.

When modifying an existing table that is not partitioned to accommodate partitioning, or, when modifying the partitioning of an already partitioned table, you may consider altering the table's primary key (see Section 24.6.1, “Partitioning Keys, Primary Keys, and Unique Keys”). You should be aware that, if you do this, the results of REPLACE statements may be affected, just as they would be if you modified the primary key of a nonpartitioned table. Consider the table created by the following CREATE TABLE statement:

CREATE TABLE test (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  data VARCHAR(64) DEFAULT NULL,
  ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
);
When we create this table and run the statements shown in the mysql client, the result is as follows:

mysql> REPLACE INTO test VALUES (1, 'Old', '2014-08-20 18:47:00');
Query OK, 1 row affected (0.04 sec)

mysql> REPLACE INTO test VALUES (1, 'New', '2014-08-20 18:47:42');
Query OK, 2 rows affected (0.04 sec)

mysql> SELECT * FROM test;
+----+------+---------------------+
| id | data | ts                  |
+----+------+---------------------+
|  1 | New  | 2014-08-20 18:47:42 |
+----+------+---------------------+
1 row in set (0.00 sec)
Now we create a second table almost identical to the first, except that the primary key now covers 2 columns, as shown here (emphasized text):

CREATE TABLE test2 (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  data VARCHAR(64) DEFAULT NULL,
  ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id, ts)
);
When we run on test2 the same two REPLACE statements as we did on the original test table, we obtain a different result:

mysql> REPLACE INTO test2 VALUES (1, 'Old', '2014-08-20 18:47:00');
Query OK, 1 row affected (0.05 sec)

mysql> REPLACE INTO test2 VALUES (1, 'New', '2014-08-20 18:47:42');
Query OK, 1 row affected (0.06 sec)

mysql> SELECT * FROM test2;
+----+------+---------------------+
| id | data | ts                  |
+----+------+---------------------+
|  1 | Old  | 2014-08-20 18:47:00 |
|  1 | New  | 2014-08-20 18:47:42 |
+----+------+---------------------+
2 rows in set (0.00 sec)
This is due to the fact that, when run on test2, both the id and ts column values must match those of an existing row for the row to be replaced; otherwise, a row is inserted.

