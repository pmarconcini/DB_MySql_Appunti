# Data query language (DQL)

--------------------------------
## Struttra della query standard

L'istruzione SELECT permette di ricavare un set di dati composti da 0 o più righe i cui valori sono strutturati in una o più colonne ed è, quindi, l'elemento centrale di SQL.
L'origine dei valori è abitualmente una tabella o una vista, ma possono essere ricavati anche da operazioni, funzioni e costanti; ci si riferisce genericamente all'origine del dato col termine espressione.

In MySql l'unica clausola obbligatoria tra quelle previste dagli standard ANSI è proprio SELECT, mentre le altre sono facoltative e seguono le regole ufficiali per quanto riguarda presenza e dipendenze.

La forma standard di una query è la seguente (l'indentazione è utilizzata per evidenziare le dipendenze):

    SELECT [ALL | DISTINCT ] <elenco espressioni>]
    [INTO {<elenco variabili>] | OUTFILE 'nome_file' | DUMPFILE 'nome_file'}
        [FROM <elenco tabelle>
            [WHERE <serie di condizioni>]
            [GROUP BY <elenco espressioni> [WITH ROLLUP]]
                [HAVING <serie di condizioni>]
            [ORDER BY <elenco espressioni [ASC | DESC]> [WITH ROLLUP]]
            [LIMIT {[offset,] row_count | row_count OFFSET offset}]
            [FOR {UPDATE | SHARE}
                [OF <elenco tabelle>]
                [NOWAIT | SKIP LOCKED]
            ]
        ]

---------------------------------
### La clausola SELECT, le espressioni e gli alias di colonna e tabella

Nell'esempio seguente sono rappresentate le tipiche situazioni legate alla clausola SELECT: valorizzazione del dato tramite espressioni e utilizzo degli alias per nominare le colonne dell'output e per risolvere eventuali ambiguità nei riferimenti alle tabelle.

        SELECT
            current_date() AS data,      /* ⇒ esposto valore non derivato dalla tabella */
            i.deptno,                 /* ⇒ è necessario specificare l'alias di tabella perché il nome di colonna è presente in entrambe le tabelle coinvolte */
            i.empno,                  /* ⇒ nome della colonna mantenuta, valore del campo non variato */
            i.ename Nome,             /* ⇒ alias di colonna considerato comunque maiuscolo, valore del campo non variato*/
            UCASE(i.ename) "Nome Dip",  /* ⇒ alias di colonna come specificato tra virgolette, valore del campo variato (funzione) */
            i.ename || i.empno,  /* ⇒ alias corrispondente al calcolo (da evitare perché causa l'allargamento della colonna in output, valore variato (concatenamento) */
            (i.sal * 14 + comm) * (1 - 0.40) netto_annuo,  /* ⇒ operazioni secondo le regole dell'algebra */
            (select count(*) from emp) tot_dip, /* ⇒ valore ottenuto da una subquery */
            d.* /* ⇒ l'asterisco indica di considerare tutti i campi della tabella (o vista) */
        FROM emp i, dept d
        WHERE i.deptno = d.deptno AND i.job     = 'SALESMAN';

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/1af18d4f-f37b-40ca-b779-866d9278fcd3)
        

Questi sono i concetti fondamentali ricavabili:
- Colonna data: è esposto valore non derivato dalla tabella traite una funzione (ma la logica è la stessa anche con un valore assoluto)
- Colonna data: la parola chiave (opzionale) AS precede il nome specificato per la colonna; il nome deve essere unico nella query
- Colonna deptno: il valore è ricavato da tabella e non modificato
- Colonna deptno: è necessario specificare l'alias di tabella  "i." perché il nome di colonna è presente in entrambe le tabelle coinvolte (disambiguazione)
- Colonna deptno: se non viene specificato un alias di colonna il nome della stessa coinciderà con l'espressione (causa un errore nella creazione di una vista)
- Colonna Nome: viene specificato un nome di colonna ma senza utilizzare la parola chiave AS; il nome NON è case sensitive e quindi ci si potrà riferire ad esso con qualsiasi forma del testo "nome"
- Colonna Nome Dip: viene utilizzata una funzione su un valore ricavato da tabella
- Colonna Nome Dip: Viene specificato un nome di colonna tra doppi apici, rendendo lo stesso case sensitive e quindi ci si potrà riferire allo stesso SOLO con il riferimento "Nome Dip" (è l'unico modo per specificare degli spazi in un nome di colonna)
- Colonna netto_annuo: utilizzo di operazioni algebriche secondo le abituali regole della matematica
- Colonna tot_dip: valore ottenuto da una sub-query annidata; la sub-query deve restituire zero o un valore
- Colonne successive: sono ricavate dal riferimento <alias di tabella>.* che significa esporre tutte le colonne di una data tabella (da evitare nella creazione di viste per non violare l'unicità del nome)


L'opzione facoltativa DISTINCT permette di considerare nel risultato della query le righe duplicate una sola volta; l'opzione ALL è la scelta predefinita ed indica di consderare anche i duplicati:

    SELECT job FROM emp WHERE deptno = 30;
    SELECT ALL job FROM emp WHERE deptno = 30;
    SELECT DISTINCT job FROM emp WHERE deptno = 30;

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/2d7b8bbf-d9a7-4dba-9712-d9a39d5a6076)

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/32f970bd-d754-44ac-838c-c2ea7d80dcf4)

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/56bfbe43-f2dd-49da-98ff-1896ffb2c68e)

L'opzione DISTINCT può impattare anche sensibilmente sulle performance.


La clausola facoltativa INTO è necessaria per utilizzare i dati ottenuti per valorizzare variabili o file e sarà esaminata in un capitolo successivo.


------------------------------------------
### La clausola FROM

La clausola FROM è destinata ad indicare le origini dei dati (tabelle, viste, sub-query) ed è opzionale ed ometterla equivale a utilizzare la tabella fittizia monoriga di sistema DUAL; non avendo essa alcuna colonna predefinita, in assenza di clausola FROM si potrà fare uso solamente di espressioni che non fanno riferimento ad alcuna colonna; in sostanza in MySql le istruzioni "SELECT 1 + 1;" e "SELECT 1 + 1 FROM DUAL;" sono analoghe.

E' possibile specificare per ogni tabella un alias (nome locale), purchè univoco per il livello di query; l'utilizzo dell'alias è necessario in caso di utilizzo ripetuto di una tabella o vista (come vedremo a proposito delle self-join) e nel caso di sub-query; in assenza di alias di tabella la "disambiguazione" avviene specificando l'intero nome della tabella nella forma <tabella>.<campo>.
La parola chiave AS è opzionale anche nella definizione dell'alias di tabella.

Nell'esempio seguente possiamo osservare:
- Quando non c'è ambiguità nell'origine del dato non serve l'alias (ma è vivamente consigliato): i campi ename, loc, job e sal_medio sono presenti solo una volta nelle tabelle coinvolte e nella sub-query
- Quando non è specificato l'alia di tabella è necessario specificare anche il nome della tabella per fare riferimento ad una colonna: emp.deptno nella clausola WHERE
    
        SELECT 	ename, d.deptno, loc, sal - sal_medio delta
        FROM emp, dept d, (SELECT avg(sal) sal_medio FROM emp) AS m
        WHERE emp.deptno = d.deptno AND job     = 'SALESMAN';

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/296ada12-bf67-4a90-aed5-65cb2d15e25a)


------------------------------------------
### La clausola WHERE

La clausola opzionale WHERE ha il duplice scopo di filtrare i singoli record e di indicare la relazione tra tabelle (ma in questo caso vedremo una scrittura alternativa nel paragrafo dedicato alle join). Le espressioni utilizzate a tale scopo sono tipicamente costituite da due valori intervallati da un operatore di confronto, ma sono comunque presenti alcune eccezioni.
I valori possono essere dati presenti nel record, elaborazione degli stessi, costanti o risultati di subquery.

Queste le peculiarità:
- La relazione tra tabelle prevede tipicamente una condizione per ogni colonna coinvolta unite dall'operatore AND.
- Le espressioni sono logicamente legate tra loro dagli operatori AND e OR e dall’uso delle parentesi tonde secondo la logica applicata in matematica.
- In assenza di parentesi l’operatore AND è considerato prima dell’operatore OR.
- L’operatore NOT nega la verifica dell’espressione (attenzione, le espressioni “a = 1” e “NOT a = 1” NON sono complementari perchè entrambe escludono i casi in cui “a” è nullo).
- L’operatore di confronto IN è abitualmente utilizzato con elenchi definiti e statici di valori semplici (costituiti da una singola colonna).
- L'operatore BETWEEN permette di verificare la presenza in un intervallo di cui sono indicati i due estremi (che sono compresi) separati dall'operatore AND
- Per verificare la nullità (o nonnullità) di un dato è necessario utilizzare l'operatore IS NULL (o NOT IS NULL) che restituisce un valore booleano; attenzione a non confondere il "non valore" (NULL) con un testo a lunghezza nulla ('').
- L'operatore LIKE permette di confrontare testi utilizzando i caratteri jolly "*" (qualsiasi quantità di qualsiasi carattere) e "_" (un carattere qualsiasi).

NB: Gli operatori di confronto IN, ALL, ANY, SOME, EXISTS saranno affrontati nel paragrafo destinato alle subqueries. In tutti questi casi il confronto avviene con un elenco (anche vuoto) di dati ed è possibile considerare più colonne.

Nell'esempio seguente gli elementi fondamentali sono:
- La relazione tra tabelle: e.deptno = d.deptno
- l'operatore OR per definire due condizioni alternative prevale sull'operatore AND grazie alle parentesi
- l'operatore BETWEEN per indicare un range
- l'operatore IN per indicare un elenco di valori ammissibili o non (NOT) ammissibili
- l'operatore IS NULL per verificare l'esistenza di un dato
- l'operatore LIKE per confrontare un testo con un pattern
    
        SELECT 	e.ename, e.job, e.deptno, e.sal, e.comm, d.loc
        FROM emp e, dept d
        WHERE e.deptno = d.deptno 
        AND (e.sal BETWEEN 1000 AND 2000 OR e.comm IS NOT NULL)
        AND d.loc IN ('CHICAGO', 'NEW YORK')
        AND NOT e.job IN ('PRESIDENT')
        AND e.job LIKE '%E%';

  ==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/23e8222f-b56d-4881-80cd-ba4691765157)


------------------------------------------
### La clausola ORDER BY

La clausola opzionale ORDER BY permette di stabilire l’ordine di esposizione dei record elencando i criteri per priorità; i criteri seguono le stesse regole dell’esposizione nella clausola SELECT e quindi possono essere valori presenti campi, elaborazioni di essi, sub-queries, gli alias utilizzati o la posizione della colonne nella SELECT e, per ognuno, è possibile stabilire la cardinalità aggiungendo la sigla ASC (valore predefinito e quindi in genere omesso) per l’ordine crescente o DESC per l’ordine decrescente, secondo la logica del dato stesso (alfabetico per i testi, dimensioni per i numeri e temporale per le date)
In assenza di clausola ORDER BY i dati sono esposti nell'ordine di recupero ed il processo di ordinamento può impattare anche sensibilmente sulle performance.
Nel caso in cui siano eseguiti dei raggruppamenti secondo le modalità specificate nei paragrafi seguenti, nella clausola ORDER BY possono essere specificati solo i raggruppamenti stessi (o loro elaborazioni). 


Nell'esempio seguente i dati sono ordinati per commissione decrescente (con gestione dei nulli), per lavoro, per salario (con riferimento alla posizione) decrescente e per nome (con riferimento all'alias di colonna):

    SELECT 	e.ename AS nome, e.job, e.sal, e.comm
    FROM emp e
    ORDER BY coalesce(comm,0) DESC, job, 3 DESC, nome;

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/e141732b-a32f-4a1e-96d2-4dff4239154f)


------------------------------------------
### Le clausole GROUP BY e HAVING

Tramite la clausola opzionale GROUP BY è possibile aggregare record, al solito secondo il valore presente nei campi o elaborazioni dello stesso, stabilendo l’ordine logico di aggregazione. In presenza di raggruppamenti nella clausola SELECT è possibile fare riferimento esclusivamente agli stessi criteri di aggregazione utilizzati nella GROUP BY e/o a eventuali valori ottenuti da funzioni aggregate. Discorso analogo per la clausola ORDER BY, ma senza vincoli nell’ordine di utilizzo.

La clausola opzionale HAVING può essere presente solo in presenza della clausola GROUP BY ed è una clausola di filtro dei raggruppamenti; ne consegue che in essa si possono usare esclusivamente funzioni aggregate applicate ai criteri di raggruppamento o i criteri di raggruppamento stessi e gli operatori logici e di confronto già visti nel caso della clausola WHERE.

La clausola LIMIT (che vedremo successivamente) è considerata DOPO la eventuale clausola HAVING.

Nell'esempio seguente:
- le espressioni utilizzate nella clausola SELECT sono tutte presenti nella clausola GROUP BY o il risultato di una funzione (nei casi esposti sono sempre funzioni aggregate perchè sono applicate a tutti i record dei singoli gruppi prodotti)
- nella clausola HAVING tutte le condizioni sono riferite ad espressioni contenenti funzioni aggregate, perchè il filtro è a livello di intero gruppo

        SELECT d.loc,
        	CASE i.job WHEN 'PRESIDENT' THEN 'Capi' 
                       WHEN 'MANAGER' THEN 'Capi' ELSE 'Schiavi' END ruolo,
        	AVG(i.sal) F1,         -- media del gruppo
         	COUNT(d.loc) F2,         -- conteggio dei record con valore per gruppo
         	COUNT(*) F3,         -- conteggio dei record per gruppo
        	COUNT(i.sal) F4,         -- conteggio dei record con valore per gruppo
        	MAX(i.sal) F5,         -- massimo
        	MIN(i.sal) F6,         -- minimo
        	SUM(i.sal) F7         -- sommatoria
        FROM emp i RIGHT JOIN dept d ON i.deptno = d.deptno 
        GROUP BY d.loc ,
         		CASE i.job WHEN 'PRESIDENT' THEN 'Capi' 
                            WHEN 'MANAGER' THEN 'Capi' ELSE 'Schiavi' END
        HAVING MAX(coalesce(i.sal,0)) < 5000 and COUNT(i.sal) BETWEEN 0 AND 4
              AND d.loc NOT IN ('DALLAS')
        ORDER BY ruolo, AVG(i.sal) DESC, d.loc;

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/ad7e2139-ff93-452a-b6a2-81d8c8ee907d)


------------------------------------------
### La clausola LIMIT

La clausola opzionale LIMIT permette di filtrare i dati a valle di tutte le altre clausole per esporne una quota parte ed è processata a valle delle altre clausole di limitazione (WHERE e HAVING) e, in particolare, permette di stabilire il numero di record da mantenere e quanti record iniziali saltare (è un parametro opzionale).

A differenza di quanto accade con le altre clausole con LIMIT è possibile far riferimento alle variabili di sessione ("@nome_variabile"), alle variabili locali negli stored programs (procedure, funzioni e triggers) e, come vedremo più avanti, ai placeholder nei prepared statement.

Per compatibilità con altri RDBMS è possibile utilizzare anche la scrittura con la parola chiave OFFSET

Nell'esempio seguente, nell'ordine:
- Omesso il parametro indicante i record da saltare
- Utilizzati entrambi i parametri (salto e quantità)
- Forzato al valore massimo il parametro quantità per considerare "tutti gli altri record"
- Il secondo caso riproposto con prepared statement
- Il secondo caso con l'uso di OFFSET

        SELECT 	ename, sal FROM emp ORDER BY sal DESC LIMIT 3; -- i 3 impiegati più pagati
        
        SELECT 	ename, sal FROM emp ORDER BY sal DESC LIMIT 2, 3; -- i 3 impiegati più pagati saltando i primi due
        
        SELECT 	ename, sal FROM emp ORDER BY sal DESC LIMIT 12, 9999999999999999; -- tutti a partire dal tredicesimo
        
        SET @skip=2; SET @numrows=3;
        PREPARE STMT FROM 'SELECT 	ename, sal FROM emp ORDER BY sal DESC LIMIT  ?, ?';
        EXECUTE STMT USING @skip, @numrows;
        
        SELECT 	ename, sal FROM emp ORDER BY sal DESC LIMIT 3 OFFSET 2; -- i 3 impiegati più pagati saltando i primi due

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/f81717a1-38d4-4f5d-986f-613950df750c)
  
==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/4aba4b63-eb68-4fa8-8629-ef8d48ba1192)
  
==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/6d955bd1-82d7-4cd6-bc29-cc32f137ab8b)
  
==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/6df7eed2-18e4-463b-9cc5-0e28e32b3246)
  
==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/dca0d1e4-fcf8-4978-b876-63bb952a0938)
  

------------------------------------------
### Le clausole FOR UPDATE e FOR SHARE

La clausola opzionale FOR UPDATE permette di inibire l'accesso ad altre sessioni ad una o più tabelle utilizzate nella query fino al termine dell'esecuzione della stessa.
La clausola opzionale alternativa FOR SHARE permette di inibire l'accesso in modifica ad altre sessioni ad una o più tabelle utilizzate nella query fino al termine dell'esecuzione della stessa.
Con le opzioni NOWAIT e SKIP LOCKED è possibile stabilire se una eventuale DML in conflitto deve andare in errore o se devono essere escluse dalla stessa i record bloccati.

Per esempio, supponendo l'utilizzo degli script seguenti in 2 sessione parallele A e B, considerando l'utilizzo della funzione SLEEP(1) per rallentare l'esecuzione di un secondo per record e l'esecuzione da parte di A immediatamente prima di B, si ricava che:
- Se A esegue lo script #1 (in 14 secondi), qualunque script lanciato da B durerà 28 secondi (14 + 14)
- Se A esegue lo script #2 (in 14 secondi), se B lancia lo script #1 dovrà attendere e l'esecuzione durerà 28 secondi (14 + 14) mentre negli altri casi l'esecuzione sarà immediata (14 secondi)
- Se A esegue lo script #3 (in 14 secondi), qualunque script lanciato da B durerà 14 secondi perchè NON dovrà attendere

        -- #1
        SELECT 	ename, sal, SLEEP(1) FROM emp FOR UPDATE OF emp;
        
        -- #2
        SELECT 	ename, sal, SLEEP(1) FROM emp FOR SHARE OF emp;
        
        -- #3
        SELECT 	ename, sal, SLEEP(1) FROM emp;




*********************************************************************

*********************************************************************




13.2.13.1 SELECT ... INTO Statement
The SELECT ... INTO form of SELECT enables a query result to be stored in variables or written to a file:

SELECT ... INTO var_list selects column values and stores them into variables.

SELECT ... INTO OUTFILE writes the selected rows to a file. Column and line terminators can be specified to produce a specific output format.

SELECT ... INTO DUMPFILE writes a single row to a file without any formatting.

A given SELECT statement can contain at most one INTO clause, although as shown by the SELECT syntax description (see Section 13.2.13, “SELECT Statement”), the INTO can appear in different positions:

Before FROM. Example:

SELECT * INTO @myvar FROM t1;
Before a trailing locking clause. Example:

SELECT * FROM t1 INTO @myvar FOR UPDATE;
At the end of the SELECT. Example:

SELECT * FROM t1 FOR UPDATE INTO @myvar;
The INTO position at the end of the statement is supported as of MySQL 8.0.20, and is the preferred position. The position before a locking clause is deprecated as of MySQL 8.0.20; expect support for it to be removed in a future version of MySQL. In other words, INTO after FROM but not at the end of the SELECT produces a warning.

An INTO clause should not be used in a nested SELECT because such a SELECT must return its result to the outer context. There are also constraints on the use of INTO within UNION statements; see Section 13.2.18, “UNION Clause”.

For the INTO var_list variant:

var_list names a list of one or more variables, each of which can be a user-defined variable, stored procedure or function parameter, or stored program local variable. (Within a prepared SELECT ... INTO var_list statement, only user-defined variables are permitted; see Section 13.6.4.2, “Local Variable Scope and Resolution”.)

The selected values are assigned to the variables. The number of variables must match the number of columns. The query should return a single row. If the query returns no rows, a warning with error code 1329 occurs (No data), and the variable values remain unchanged. If the query returns multiple rows, error 1172 occurs (Result consisted of more than one row). If it is possible that the statement may retrieve multiple rows, you can use LIMIT 1 to limit the result set to a single row.

SELECT id, data INTO @x, @y FROM test.t1 LIMIT 1;
INTO var_list can also be used with a TABLE statement, subject to these restrictions:

The number of variables must match the number of columns in the table.

If the table contains more than one row, you must use LIMIT 1 to limit the result set to a single row. LIMIT 1 must precede the INTO keyword.

An example of such a statement is shown here:

TABLE employees ORDER BY lname DESC LIMIT 1
    INTO @id, @fname, @lname, @hired, @separated, @job_code, @store_id;
You can also select values from a VALUES statement that generates a single row into a set of user variables. In this case, you must employ a table alias, and you must assign each value from the value list to a variable. Each of the two statements shown here is equivalent to SET @x=2, @y=4, @z=8:

SELECT * FROM (VALUES ROW(2,4,8)) AS t INTO @x,@y,@z;

SELECT * FROM (VALUES ROW(2,4,8)) AS t(a,b,c) INTO @x,@y,@z;
User variable names are not case-sensitive. See Section 9.4, “User-Defined Variables”.

The SELECT ... INTO OUTFILE 'file_name' form of SELECT writes the selected rows to a file. The file is created on the server host, so you must have the FILE privilege to use this syntax. file_name cannot be an existing file, which among other things prevents files such as /etc/passwd and database tables from being modified. The character_set_filesystem system variable controls the interpretation of the file name.

The SELECT ... INTO OUTFILE statement is intended to enable dumping a table to a text file on the server host. To create the resulting file on some other host, SELECT ... INTO OUTFILE normally is unsuitable because there is no way to write a path to the file relative to the server host file system, unless the location of the file on the remote host can be accessed using a network-mapped path on the server host file system.

Alternatively, if the MySQL client software is installed on the remote host, you can use a client command such as mysql -e "SELECT ..." > file_name to generate the file on that host.

SELECT ... INTO OUTFILE is the complement of LOAD DATA. Column values are written converted to the character set specified in the CHARACTER SET clause. If no such clause is present, values are dumped using the binary character set. In effect, there is no character set conversion. If a result set contains columns in several character sets, so is the output data file, and it may not be possible to reload the file correctly.

The syntax for the export_options part of the statement consists of the same FIELDS and LINES clauses that are used with the LOAD DATA statement. For information about the FIELDS and LINES clauses, including their default values and permissible values, see Section 13.2.9, “LOAD DATA Statement”.

FIELDS ESCAPED BY controls how to write special characters. If the FIELDS ESCAPED BY character is not empty, it is used when necessary to avoid ambiguity as a prefix that precedes following characters on output:

The FIELDS ESCAPED BY character

The FIELDS [OPTIONALLY] ENCLOSED BY character

The first character of the FIELDS TERMINATED BY and LINES TERMINATED BY values

ASCII NUL (the zero-valued byte; what is actually written following the escape character is ASCII 0, not a zero-valued byte)

The FIELDS TERMINATED BY, ENCLOSED BY, ESCAPED BY, or LINES TERMINATED BY characters must be escaped so that you can read the file back in reliably. ASCII NUL is escaped to make it easier to view with some pagers.

The resulting file need not conform to SQL syntax, so nothing else need be escaped.

If the FIELDS ESCAPED BY character is empty, no characters are escaped and NULL is output as NULL, not \N. It is probably not a good idea to specify an empty escape character, particularly if field values in your data contain any of the characters in the list just given.

INTO OUTFILE can also be used with a TABLE statement when you want to dump all columns of a table into a text file. In this case, the ordering and number of rows can be controlled using ORDER BY and LIMIT; these clauses must precede INTO OUTFILE. TABLE ... INTO OUTFILE supports the same export_options as does SELECT ... INTO OUTFILE, and it is subject to the same restrictions on writing to the file system. An example of such a statement is shown here:

TABLE employees ORDER BY lname LIMIT 1000
    INTO OUTFILE '/tmp/employee_data_1.txt'
    FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"', ESCAPED BY '\'
    LINES TERMINATED BY '\n';
You can also use SELECT ... INTO OUTFILE with a VALUES statement to write values directly into a file. An example is shown here:

SELECT * FROM (VALUES ROW(1,2,3),ROW(4,5,6),ROW(7,8,9)) AS t
    INTO OUTFILE '/tmp/select-values.txt';
You must use a table alias; column aliases are also supported, and can optionally be used to write values only from desired columns. You can also use any or all of the export options supported by SELECT ... INTO OUTFILE to format the output to the file.

Here is an example that produces a file in the comma-separated values (CSV) format used by many programs:

SELECT a,b,a+b INTO OUTFILE '/tmp/result.txt'
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  FROM test_table;
If you use INTO DUMPFILE instead of INTO OUTFILE, MySQL writes only one row into the file, without any column or line termination and without performing any escape processing. This is useful for selecting a BLOB value and storing it in a file.

TABLE also supports INTO DUMPFILE. If the table contains more than one row, you must also use LIMIT 1 to limit the output to a single row. INTO DUMPFILE can also be used with SELECT * FROM (VALUES ROW()[, ...]) AS table_alias [LIMIT 1]. See Section 13.2.19, “VALUES Statement”.

Note
Any file created by INTO OUTFILE or INTO DUMPFILE is owned by the operating system user under whose account mysqld runs. (You should never run mysqld as root for this and other reasons.) As of MySQL 8.0.17, the umask for file creation is 0640; you must have sufficient access privileges to manipulate the file contents. Prior to MySQL 8.0.17, the umask is 0666 and the file is writable by all users on the server host.

If the secure_file_priv system variable is set to a nonempty directory name, the file to be written must be located in that directory.

In the context of SELECT ... INTO statements that occur as part of events executed by the Event Scheduler, diagnostics messages (not only errors, but also warnings) are written to the error log, and, on Windows, to the application event log. For additional information, see Section 25.4.5, “Event Scheduler Status”.

As of MySQL 8.0.22, support is provided for periodic synchronization of output files written to by SELECT INTO OUTFILE and SELECT INTO DUMPFILE, enabled by setting the select_into_disk_sync server system variable introduced in that version. Output buffer size and optional delay can be set using, respectively, select_into_buffer_size and select_into_disk_sync_delay. For more information, see the descriptions of these system variables.


*******************************************************************************

*******************************************************************************

13.2.3 DO Statement
DO expr [, expr] ...
DO executes the expressions but does not return any results. In most respects, DO is shorthand for SELECT expr, ..., but has the advantage that it is slightly faster when you do not care about the result.

DO is useful primarily with functions that have side effects, such as RELEASE_LOCK().

Example: This SELECT statement pauses, but also produces a result set:

mysql> SELECT SLEEP(5);
+----------+
| SLEEP(5) |
+----------+
|        0 |
+----------+
1 row in set (5.02 sec)
DO, on the other hand, pauses without producing a result set.:

mysql> DO SLEEP(5);
Query OK, 0 rows affected (4.99 sec)
This could be useful, for example in a stored function or trigger, which prohibit statements that produce result sets.

DO only executes expressions. It cannot be used in all cases where SELECT can be used. For example, DO id FROM t1 is invalid because it references a table.


***************************************************************

****************************************************************

13.2.16 TABLE Statement
TABLE is a DML statement introduced in MySQL 8.0.19 which returns rows and columns of the named table.

TABLE table_name [ORDER BY column_name] [LIMIT number [OFFSET number]]
The TABLE statement in some ways acts like SELECT. Given the existence of a table named t, the following two statements produce identical output:

TABLE t;

SELECT * FROM t;
You can order and limit the number of rows produced by TABLE using ORDER BY and LIMIT clauses, respectively. These function identically to the same clauses when used with SELECT (including an optional OFFSET clause with LIMIT), as you can see here:

mysql> TABLE t;
+----+----+
| a  | b  |
+----+----+
|  1 |  2 |
|  6 |  7 |
|  9 |  5 |
| 10 | -4 |
| 11 | -1 |
| 13 |  3 |
| 14 |  6 |
+----+----+
7 rows in set (0.00 sec)

mysql> TABLE t ORDER BY b;
+----+----+
| a  | b  |
+----+----+
| 10 | -4 |
| 11 | -1 |
|  1 |  2 |
| 13 |  3 |
|  9 |  5 |
| 14 |  6 |
|  6 |  7 |
+----+----+
7 rows in set (0.00 sec)

mysql> TABLE t LIMIT 3;
+---+---+
| a | b |
+---+---+
| 1 | 2 |
| 6 | 7 |
| 9 | 5 |
+---+---+
3 rows in set (0.00 sec)

mysql> TABLE t ORDER BY b LIMIT 3;
+----+----+
| a  | b  |
+----+----+
| 10 | -4 |
| 11 | -1 |
|  1 |  2 |
+----+----+
3 rows in set (0.00 sec)

mysql> TABLE t ORDER BY b LIMIT 3 OFFSET 2;
+----+----+
| a  | b  |
+----+----+
|  1 |  2 |
| 13 |  3 |
|  9 |  5 |
+----+----+
3 rows in set (0.00 sec)
TABLE differs from SELECT in two key respects:

TABLE always displays all columns of the table.

Exception: The output of TABLE does not include invisible columns. See Section 13.1.20.10, “Invisible Columns”.

TABLE does not allow for any arbitrary filtering of rows; that is, TABLE does not support any WHERE clause.

For limiting which table columns are returned, filtering rows beyond what can be accomplished using ORDER BY and LIMIT, or both, use SELECT.

TABLE can be used with temporary tables.

TABLE can also be used in place of SELECT in a number of other constructs, including those listed here:

With set operators such as UNION, as shown here:

mysql> TABLE t1;
+---+----+
| a | b  |
+---+----+
| 2 | 10 |
| 5 |  3 |
| 7 |  8 |
+---+----+
3 rows in set (0.00 sec)

mysql> TABLE t2;
+---+---+
| a | b |
+---+---+
| 1 | 2 |
| 3 | 4 |
| 6 | 7 |
+---+---+
3 rows in set (0.00 sec)

mysql> TABLE t1 UNION TABLE t2;
+---+----+
| a | b  |
+---+----+
| 2 | 10 |
| 5 |  3 |
| 7 |  8 |
| 1 |  2 |
| 3 |  4 |
| 6 |  7 |
+---+----+
6 rows in set (0.00 sec)
The UNION just shown is equivalent to the following statement:

mysql> SELECT * FROM t1 UNION SELECT * FROM t2;
+---+----+
| a | b  |
+---+----+
| 2 | 10 |
| 5 |  3 |
| 7 |  8 |
| 1 |  2 |
| 3 |  4 |
| 6 |  7 |
+---+----+
6 rows in set (0.00 sec)
TABLE can also be used together in set operations with SELECT statements, VALUES statements, or both. See Section 13.2.18, “UNION Clause”, Section 13.2.4, “EXCEPT Clause”, and Section 13.2.8, “INTERSECT Clause”, for more information and examples. See also Section 13.2.14, “Set Operations with UNION, INTERSECT, and EXCEPT”.

With INTO to populate user variables, and with INTO OUTFILE or INTO DUMPFILE to write table data to a file. See Section 13.2.13.1, “SELECT ... INTO Statement”, for more specific information and examples.

In many cases where you can employ subqueries. Given any table t1 with a column named a, and a second table t2 having a single column, statements such as the following are possible:

SELECT * FROM t1 WHERE a IN (TABLE t2);
Assuming that the single column of table t1 is named x, the preceding is equivalent to each of the statements shown here (and produces exactly the same result in either case):

SELECT * FROM t1 WHERE a IN (SELECT x FROM t2);

SELECT * FROM t1 WHERE a IN (SELECT * FROM t2);
See Section 13.2.15, “Subqueries”, for more information.

With INSERT and REPLACE statements, where you would otherwise use SELECT *. See Section 13.2.7.1, “INSERT ... SELECT Statement”, for more information and examples.

TABLE can also be used in many cases in place of the SELECT in CREATE TABLE ... SELECT or CREATE VIEW ... SELECT. See the descriptions of these statements for more information and examples.

**********************************************************

**********************************************************

13.2.14 Set Operations with UNION, INTERSECT, and EXCEPT
Result Set Column Names and Data Types

Set Operations with TABLE and VALUES Statements

Set Operations using DISTINCT and ALL

Set Operations with ORDER BY and LIMIT

Limitations of Set Operations

SQL set operations combine the results of multiple query blocks into a single result. A query block, sometimes also known as a simple table, is any SQL statement that returns a result set, such as SELECT. MySQL 8.0 (8.0.19 and later) also supports TABLE and VALUES statements. See the individual descriptions of these statements elsewhere in this chapter for additional information.

The SQL standard defines the following three set operations:

UNION: Combine all results from two query blocks into a single result, omitting any duplicates.

INTERSECT: Combine only those rows which the results of two query blocks have in common, omitting any duplicates.

EXCEPT: For two query blocks A and B, return all results from A which are not also present in B, omitting any duplicates.

(Some database systems, such as Oracle, use MINUS for the name of this operator. This is not supported in MySQL.)

MySQL has long supported UNION; MySQL 8.0 adds support for INTERSECT and EXCEPT (MySQL 8.0.31 and later).

Each of these set operators supports an ALL modifier. When the ALL keyword follows a set operator, this causes duplicates to be included in the result. See the following sections covering the individual operators for more information and examples.

All three set operators also support a DISTINCT keyword, which suppresses duplicates in the result. Since this is the default behavior for set operators, it is usually not necessary to specify DISTINCT explicitly.

In general, query blocks and set operations can be combined in any number and order. A greatly simplified representation is shown here:

query_block [set_op query_block] [set_op query_block] ...

query_block:
    SELECT | TABLE | VALUES

set_op:
    UNION | INTERSECT | EXCEPT
This can be represented more accurately, and in greater detail, like this:

query_expression:
  [with_clause] /* WITH clause */ 
  query_expression_body
  [order_by_clause] [limit_clause] [into_clause]

query_expression_body:
    query_term
 |  query_expression_body UNION [ALL | DISTINCT] query_term
 |  query_expression_body EXCEPT [ALL | DISTINCT] query_term

query_term:
    query_primary
 |  query_term INTERSECT [ALL | DISTINCT] query_primary

query_primary:
    query_block
 |  '(' query_expression_body [order_by_clause] [limit_clause] [into_clause] ')'

query_block:   /* also known as a simple table */
    query_specification                     /* SELECT statement */
 |  table_value_constructor                 /* VALUES statement */
 |  explicit_table                          /* TABLE statement  */
You should be aware that INTERSECT is evaluated before UNION or EXCEPT. This means that, for example, TABLE x UNION TABLE y INTERSECT TABLE z is always evaluated as TABLE x UNION (TABLE y INTERSECT TABLE z). See Section 13.2.8, “INTERSECT Clause”, for more information.

In addition, you should keep in mind that, while the UNION and INTERSECT set operators are commutative (ordering is not significant), EXCEPT is not (order of operands affects the outcome). In other words, all of the following statements are true:

TABLE x UNION TABLE y and TABLE y UNION TABLE x produce the same result, although the ordering of the rows may differ. You can force them to be the same using ORDER BY; see ORDER BY and LIMIT in Unions.

TABLE x INTERSECT TABLE y and TABLE y INTERSECT TABLE x return the same result.

TABLE x EXCEPT TABLE y and TABLE y EXCEPT TABLE x do not yield the same result. See Section 13.2.4, “EXCEPT Clause”, for an example.

More information and examples can be found in the sections that follow.

Result Set Column Names and Data Types
The column names for the result of a set operation are taken from the column names of the first query block. Example:

mysql> CREATE TABLE t1 (x INT, y INT);
Query OK, 0 rows affected (0.04 sec)

mysql> INSERT INTO t1 VALUES ROW(4,-2), ROW(5,9);
Query OK, 2 rows affected (0.00 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> CREATE TABLE t2 (a INT, b INT);
Query OK, 0 rows affected (0.04 sec)

mysql> INSERT INTO t2 VALUES ROW(1,2), ROW(3,4);
Query OK, 2 rows affected (0.01 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> TABLE t1 UNION TABLE t2;
+------+------+
| x    | y    |
+------+------+
|    4 |   -2 |
|    5 |    9 |
|    1 |    2 |
|    3 |    4 |
+------+------+
4 rows in set (0.00 sec)

mysql> TABLE t2 UNION TABLE t1;
+------+------+
| a    | b    |
+------+------+
|    1 |    2 |
|    3 |    4 |
|    4 |   -2 |
|    5 |    9 |
+------+------+
4 rows in set (0.00 sec)
This is true for UNION, EXCEPT, and INTERSECT queries.

Selected columns listed in corresponding positions of each query block should have the same data type. For example, the first column selected by the first statement should have the same type as the first column selected by the other statements. If the data types of corresponding result columns do not match, the types and lengths of the columns in the result take into account the values retrieved by all of the query blocks. For example, the column length in the result set is not constrained to the length of the value from the first statement, as shown here:

mysql> SELECT REPEAT('a',1) UNION SELECT REPEAT('b',20);
+----------------------+
| REPEAT('a',1)        |
+----------------------+
| a                    |
| bbbbbbbbbbbbbbbbbbbb |
+----------------------+
Set Operations with TABLE and VALUES Statements
Beginning with MySQL 8.0.19, you can also use a TABLE statement or VALUES statement wherever you can employ the equivalent SELECT statement. Assume that tables t1 and t2 are created and populated as shown here:

CREATE TABLE t1 (x INT, y INT);
INSERT INTO t1 VALUES ROW(4,-2),ROW(5,9);

CREATE TABLE t2 (a INT, b INT);
INSERT INTO t2 VALUES ROW(1,2),ROW(3,4);
The preceding being the case, and disregarding the column names in the output of the queries beginning with VALUES, all of the following UNION queries yield the same result:

SELECT * FROM t1 UNION SELECT * FROM t2;
TABLE t1 UNION SELECT * FROM t2;
VALUES ROW(4,-2), ROW(5,9) UNION SELECT * FROM t2;
SELECT * FROM t1 UNION TABLE t2;
TABLE t1 UNION TABLE t2;
VALUES ROW(4,-2), ROW(5,9) UNION TABLE t2;
SELECT * FROM t1 UNION VALUES ROW(4,-2),ROW(5,9);
TABLE t1 UNION VALUES ROW(4,-2),ROW(5,9);
VALUES ROW(4,-2), ROW(5,9) UNION VALUES ROW(4,-2),ROW(5,9);
To force the column names to be the same, wrap the query block on the left-hand side in a SELECT statement, and use aliases, like this:

mysql> SELECT * FROM (TABLE t2) AS t(x,y) UNION TABLE t1;
+------+------+
| x    | y    |
+------+------+
|    1 |    2 |
|    3 |    4 |
|    4 |   -2 |
|    5 |    9 |
+------+------+
4 rows in set (0.00 sec)
Set Operations using DISTINCT and ALL
By default, duplicate rows are removed from results of set operations. The optional DISTINCT keyword has the same effect but makes it explicit. With the optional ALL keyword, duplicate-row removal does not occur and the result includes all matching rows from all queries in the union.

You can mix ALL and DISTINCT in the same query. Mixed types are treated such that a set operation using DISTINCT overrides any such operation using ALL to its left. A DISTINCT set can be produced explicitly by using DISTINCT with UNION, INTERSECT, or EXCEPT, or implicitly by using the set operations with no following DISTINCT or ALL keyword.

In MySQL 8.0.19 and later, set operations work the same way when one or more TABLE statements, VALUES statements, or both, are used to generate the set.

Set Operations with ORDER BY and LIMIT
To apply an ORDER BY or LIMIT clause to an individual query block used as part of a union, intersection, or other set operation, parenthesize the query block, placing the clause inside the parentheses, like this:

(SELECT a FROM t1 WHERE a=10 AND b=1 ORDER BY a LIMIT 10)
UNION
(SELECT a FROM t2 WHERE a=11 AND b=2 ORDER BY a LIMIT 10);

(TABLE t1 ORDER BY x LIMIT 10) 
INTERSECT 
(TABLE t2 ORDER BY a LIMIT 10);
Use of ORDER BY for individual query blocks or statements implies nothing about the order in which the rows appear in the final result because the rows produced by a set operation are by default unordered. Therefore, ORDER BY in this context typically is used in conjunction with LIMIT, to determine the subset of the selected rows to retrieve, even though it does not necessarily affect the order of those rows in the final result. If ORDER BY appears without LIMIT within a query block, it is optimized away because it has no effect in any case.

To use an ORDER BY or LIMIT clause to sort or limit the entire result of a set operation, place the ORDER BY or LIMIT after the last statement:

SELECT a FROM t1
EXCEPT
SELECT a FROM t2 WHERE a=11 AND b=2
ORDER BY a LIMIT 10;

TABLE t1
UNION 
TABLE t2
ORDER BY a LIMIT 10;
If one or more individual statements make use of ORDER BY, LIMIT, or both, and, in addition, you wish to apply an ORDER BY, LIMIT, or both to the entire result, then each such individual statement must be enclosed in parentheses.

(SELECT a FROM t1 WHERE a=10 AND b=1)
EXCEPT
(SELECT a FROM t2 WHERE a=11 AND b=2)
ORDER BY a LIMIT 10;

(TABLE t1 ORDER BY a LIMIT 10) 
UNION 
TABLE t2 
ORDER BY a LIMIT 10;
A statement with no ORDER BY or LIMIT clause does need to be parenthesized; replacing TABLE t2 with (TABLE t2) in the second statement of the two just shown does not alter the result of the UNION.

You can also use ORDER BY and LIMIT with VALUES statements in set operations, as shown in this example using the mysql client:

mysql> VALUES ROW(4,-2), ROW(5,9), ROW(-1,3) 
    -> UNION 
    -> VALUES ROW(1,2), ROW(3,4), ROW(-1,3) 
    -> ORDER BY column_0 DESC LIMIT 3;
+----------+----------+
| column_0 | column_1 |
+----------+----------+
|        5 |        9 |
|        4 |       -2 |
|        3 |        4 |
+----------+----------+
3 rows in set (0.00 sec)
(You should keep in mind that neither TABLE statements nor VALUES statements accept a WHERE clause.)

This kind of ORDER BY cannot use column references that include a table name (that is, names in tbl_name.col_name format). Instead, provide a column alias in the first query block, and refer to the alias in the ORDER BY clause. (You can also refer to the column in the ORDER BY clause using its column position, but such use of column positions is deprecated, and thus subject to eventual removal in a future MySQL release.)

If a column to be sorted is aliased, the ORDER BY clause must refer to the alias, not the column name. The first of the following statements is permitted, but the second fails with an Unknown column 'a' in 'order clause' error:

(SELECT a AS b FROM t) UNION (SELECT ...) ORDER BY b;
(SELECT a AS b FROM t) UNION (SELECT ...) ORDER BY a;
To cause rows in a UNION result to consist of the sets of rows retrieved by each query block one after the other, select an additional column in each query block to use as a sort column and add an ORDER BY clause that sorts on that column following the last query block:

(SELECT 1 AS sort_col, col1a, col1b, ... FROM t1)
UNION
(SELECT 2, col2a, col2b, ... FROM t2) ORDER BY sort_col;
To maintain sort order within individual results, add a secondary column to the ORDER BY clause:

(SELECT 1 AS sort_col, col1a, col1b, ... FROM t1)
UNION
(SELECT 2, col2a, col2b, ... FROM t2) ORDER BY sort_col, col1a;
Use of an additional column also enables you to determine which query block each row comes from. Extra columns can provide other identifying information as well, such as a string that indicates a table name.

Limitations of Set Operations
Set operations in MySQL are subject to some limitations, which are described in the next few paragraphs.

Set operations including SELECT statements have the following limitations:

HIGH_PRIORITY in the first SELECT has no effect. HIGH_PRIORITY in any subsequent SELECT produces a syntax error.

Only the last SELECT statement can use an INTO clause. However, the entire UNION result is written to the INTO output destination.

As of MySQL 8.0.20, these two UNION variants containing INTO are deprecated; you should expect support for them to be removed in a future version of MySQL:

In the trailing query block of a query expression, use of INTO before FROM produces a warning. Example:

... UNION SELECT * INTO OUTFILE 'file_name' FROM table_name;
In a parenthesized trailing block of a query expression, use of INTO (regardless of its position relative to FROM) produces a warning. Example:

... UNION (SELECT * INTO OUTFILE 'file_name' FROM table_name);
Those variants are deprecated because they are confusing, as if they collect information from the named table rather than the entire query expression (the UNION).

Set operations with an aggregate function in an ORDER BY clause are rejected with ER_AGGREGATE_ORDER_FOR_UNION. Although the error name might suggest that this is exclusive to UNION queries, the preceding is also true for EXCEPT and INTERSECT queries, as shown here:

mysql> TABLE t1 INTERSECT TABLE t2 ORDER BY MAX(x);
ERROR 3028 (HY000): Expression #1 of ORDER BY contains aggregate function and applies to a UNION, EXCEPT or INTERSECT
A locking clause (such as FOR UPDATE or LOCK IN SHARE MODE) applies to the query block it follows. This means that, in a SELECT statement used with set operations, a locking clause can be used only if the query block and locking clause are enclosed in parentheses.

****************************************************************

****************************************************************

13.2.18 UNION Clause
query_expression_body UNION [ALL | DISTINCT] query_block
    [UNION [ALL | DISTINCT] query_expression_body]
    [...]

query_expression_body:
    See Section 13.2.14, “Set Operations with UNION, INTERSECT, and EXCEPT”
UNION combines the result from multiple query blocks into a single result set. This example uses SELECT statements:

mysql> SELECT 1, 2;
+---+---+
| 1 | 2 |
+---+---+
| 1 | 2 |
+---+---+
mysql> SELECT 'a', 'b';
+---+---+
| a | b |
+---+---+
| a | b |
+---+---+
mysql> SELECT 1, 2 UNION SELECT 'a', 'b';
+---+---+
| 1 | 2 |
+---+---+
| 1 | 2 |
| a | b |
+---+---+
UNION Handing in MySQL 8.0 Compared to MySQL 5.7
In MySQL 8.0, the parser rules for SELECT and UNION were refactored to be more consistent (the same SELECT syntax applies uniformly in each such context) and reduce duplication. Compared to MySQL 5.7, several user-visible effects resulted from this work, which may require rewriting of certain statements:

NATURAL JOIN permits an optional INNER keyword (NATURAL INNER JOIN), in compliance with standard SQL.

Right-deep joins without parentheses are permitted (for example, ... JOIN ... JOIN ... ON ... ON), in compliance with standard SQL.

STRAIGHT_JOIN now permits a USING clause, similar to other inner joins.

The parser accepts parentheses around query expressions. For example, (SELECT ... UNION SELECT ...) is permitted. See also Section 13.2.11, “Parenthesized Query Expressions”.

The parser better conforms to the documented permitted placement of the SQL_CACHE and SQL_NO_CACHE query modifiers.

Left-hand nesting of unions, previously permitted only in subqueries, is now permitted in top-level statements. For example, this statement is now accepted as valid:

(SELECT 1 UNION SELECT 1) UNION SELECT 1;
Locking clauses (FOR UPDATE, LOCK IN SHARE MODE) are allowed only in non-UNION queries. This means that parentheses must be used for SELECT statements containing locking clauses. This statement is no longer accepted as valid:

SELECT 1 FOR UPDATE UNION SELECT 1 FOR UPDATE;
Instead, write the statement like this:

(SELECT 1 FOR UPDATE) UNION (SELECT 1 FOR UPDATE);

*********************************************************************************

*********************************************************************************

13.2.4 EXCEPT Clause
query_expression_body EXCEPT [ALL | DISTINCT] query_expression_body
    [EXCEPT [ALL | DISTINCT] query_expression_body]
    [...]

query_expression_body:
    See Section 13.2.14, “Set Operations with UNION, INTERSECT, and EXCEPT”
EXCEPT limits the result from the first query block to those rows which are (also) not found in the second. As with UNION and INTERSECT, either query block can make use of any of SELECT, TABLE, or VALUES. An example using the tables a, b, and c defined in Section 13.2.8, “INTERSECT Clause”, is shown here:

mysql> TABLE a EXCEPT TABLE b;
+------+------+
| m    | n    |
+------+------+
|    2 |    3 |
+------+------+
1 row in set (0.00 sec)

mysql> TABLE a EXCEPT TABLE c;
+------+------+
| m    | n    |
+------+------+
|    1 |    2 |
|    2 |    3 |
+------+------+
2 rows in set (0.00 sec)

mysql> TABLE b EXCEPT TABLE c;
+------+------+
| m    | n    |
+------+------+
|    1 |    2 |
+------+------+
1 row in set (0.00 sec)
As with UNION and INTERSECT, if neither DISTINCT nor ALL is specified, the default is DISTINCT.

DISTINCT removes duplicates found on either side of the relation, as shown here:

mysql> TABLE c EXCEPT DISTINCT TABLE a;
+------+------+
| m    | n    |
+------+------+
|    1 |    3 |
+------+------+
1 row in set (0.00 sec)

mysql> TABLE c EXCEPT ALL TABLE a;
+------+------+
| m    | n    |
+------+------+
|    1 |    3 |
|    1 |    3 |
+------+------+
2 rows in set (0.00 sec)
(The first statement has the same effect as TABLE c EXCEPT TABLE a.)

Unlike UNION or INTERSECT, EXCEPT is not commutative—that is, the result depends on the order of the operands, as shown here:

mysql> TABLE a EXCEPT TABLE c;
+------+------+
| m    | n    |
+------+------+
|    1 |    2 |
|    2 |    3 |
+------+------+
2 rows in set (0.00 sec)

mysql> TABLE c EXCEPT TABLE a;
+------+------+
| m    | n    |
+------+------+
|    1 |    3 |
+------+------+
1 row in set (0.00 sec)
As with UNION, the result sets to be compared must have the same number of columns. Result set column types are also determined as for UNION.

EXCEPT was added in MySQL 8.0.31.

***************************************************************

***************************************************************

13.2.8 INTERSECT Clause
query_expression_body INTERSECT [ALL | DISTINCT] query_expression_body
    [INTERSECT [ALL | DISTINCT] query_expression_body]
    [...]

query_expression_body:
    See Section 13.2.14, “Set Operations with UNION, INTERSECT, and EXCEPT”
INTERSECT limits the result from multiple query blocks to those rows which are common to all. Example:

mysql> TABLE a;
+------+------+
| m    | n    |
+------+------+
|    1 |    2 |
|    2 |    3 |
|    3 |    4 |
+------+------+
3 rows in set (0.00 sec)

mysql> TABLE b;
+------+------+
| m    | n    |
+------+------+
|    1 |    2 |
|    1 |    3 |
|    3 |    4 |
+------+------+
3 rows in set (0.00 sec)

mysql> TABLE c;
+------+------+
| m    | n    |
+------+------+
|    1 |    3 |
|    1 |    3 |
|    3 |    4 |
+------+------+
3 rows in set (0.00 sec)

mysql> TABLE a INTERSECT TABLE b;
+------+------+
| m    | n    |
+------+------+
|    1 |    2 |
|    3 |    4 |
+------+------+
2 rows in set (0.00 sec)

mysql> TABLE a INTERSECT TABLE c;
+------+------+
| m    | n    |
+------+------+
|    3 |    4 |
+------+------+
1 row in set (0.00 sec)
As with UNION and EXCEPT, if neither DISTINCT nor ALL is specified, the default is DISTINCT.

DISTINCT can remove duplicates from either side of the intersection, as shown here:

mysql> TABLE c INTERSECT DISTINCT TABLE c;
+------+------+
| m    | n    |
+------+------+
|    1 |    3 |
|    3 |    4 |
+------+------+
2 rows in set (0.00 sec)

mysql> TABLE c INTERSECT ALL TABLE c;
+------+------+
| m    | n    |
+------+------+
|    1 |    3 |
|    1 |    3 |
|    3 |    4 |
+------+------+
3 rows in set (0.00 sec)
(TABLE c INTERSECT TABLE c is the equivalent of the first of the two statements just shown.)

As with UNION, the operands must have the same number of columns. Result set column types are also determined as for UNION.

INTERSECT has greater precedence than and is evaluated before UNION and EXCEPT, so that the two statements shown here are equivalent:

TABLE r EXCEPT TABLE s INTERSECT TABLE t;

TABLE r EXCEPT (TABLE s INTERSECT TABLE t);
For INTERSECT ALL, the maximum supported number of duplicates of any unique row in the left hand table is 4294967295.

INTERSECT was added in MySQL 8.0.31.


***********************************************************************

***********************************************************************

13.2.19 VALUES Statement
VALUES is a DML statement introduced in MySQL 8.0.19 which returns a set of one or more rows as a table. In other words, it is a table value constructor which also functions as a standalone SQL statement.

VALUES row_constructor_list [ORDER BY column_designator] [LIMIT number]

row_constructor_list:
    ROW(value_list)[, ROW(value_list)][, ...]

value_list:
    value[, value][, ...]

column_designator:
    column_index
The VALUES statement consists of the VALUES keyword followed by a list of one or more row constructors, separated by commas. A row constructor consists of the ROW() row constructor clause with a value list of one or more scalar values enclosed in the parentheses. A value can be a literal of any MySQL data type or an expression that resolves to a scalar value.

ROW() cannot be empty (but each of the supplied scalar values can be NULL). Each ROW() in the same VALUES statement must have the same number of values in its value list.

The DEFAULT keyword is not supported by VALUES and causes a syntax error, except when it is used to supply values in an INSERT statement.

The output of VALUES is a table:

mysql> VALUES ROW(1,-2,3), ROW(5,7,9), ROW(4,6,8);
+----------+----------+----------+
| column_0 | column_1 | column_2 |
+----------+----------+----------+
|        1 |       -2 |        3 |
|        5 |        7 |        9 |
|        4 |        6 |        8 |
+----------+----------+----------+
3 rows in set (0.00 sec)
The columns of the table output from VALUES have the implicitly named columns column_0, column_1, column_2, and so on, always beginning with 0. This fact can be used to order the rows by column using an optional ORDER BY clause in the same way that this clause works with a SELECT statement, as shown here:

mysql> VALUES ROW(1,-2,3), ROW(5,7,9), ROW(4,6,8) ORDER BY column_1;
+----------+----------+----------+
| column_0 | column_1 | column_2 |
+----------+----------+----------+
|        1 |       -2 |        3 |
|        4 |        6 |        8 |
|        5 |        7 |        9 |
+----------+----------+----------+
3 rows in set (0.00 sec)
In MySQL 8.0.21 and later, the VALUES statement also supports a LIMIT clause for limiting the number of rows in the output. (Previously, LIMIT was allowed but did nothing.)

The VALUES statement is permissive regarding data types of column values; you can mix types within the same column, as shown here:

mysql> VALUES ROW("q", 42, '2019-12-18'),
    ->     ROW(23, "abc", 98.6),
    ->     ROW(27.0002, "Mary Smith", '{"a": 10, "b": 25}');
+----------+------------+--------------------+
| column_0 | column_1   | column_2           |
+----------+------------+--------------------+
| q        | 42         | 2019-12-18         |
| 23       | abc        | 98.6               |
| 27.0002  | Mary Smith | {"a": 10, "b": 25} |
+----------+------------+--------------------+
3 rows in set (0.00 sec)
Important
VALUES with one or more instances of ROW() acts as a table value constructor; although it can be used to supply values in an INSERT or REPLACE statement, do not confuse it with the VALUES keyword that is also used for this purpose. You should also not confuse it with the VALUES() function that refers to column values in INSERT ... ON DUPLICATE KEY UPDATE.

You should also bear in mind that ROW() is a row value constructor (see Section 13.2.15.5, “Row Subqueries”), whereas VALUES ROW() is a table value constructor; the two cannot be used interchangeably.

VALUES can be used in many cases where you could employ SELECT, including those listed here:

With UNION, as shown here:

mysql> SELECT 1,2 UNION SELECT 10,15;
+----+----+
| 1  | 2  |
+----+----+
|  1 |  2 |
| 10 | 15 |
+----+----+
2 rows in set (0.00 sec)

mysql> VALUES ROW(1,2) UNION VALUES ROW(10,15);
+----------+----------+
| column_0 | column_1 |
+----------+----------+
|        1 |        2 |
|       10 |       15 |
+----------+----------+
2 rows in set (0.00 sec)
You can union together constructed tables having more than one row, like this:

mysql> VALUES ROW(1,2), ROW(3,4), ROW(5,6)
     >     UNION VALUES ROW(10,15),ROW(20,25);
+----------+----------+
| column_0 | column_1 |
+----------+----------+
|        1 |        2 |
|        3 |        4 |
|        5 |        6 |
|       10 |       15 |
|       20 |       25 |
+----------+----------+
5 rows in set (0.00 sec)
You can also (and it is usually preferable to) omit UNION altogether in such cases and use a single VALUES statement, like this:

mysql> VALUES ROW(1,2), ROW(3,4), ROW(5,6), ROW(10,15), ROW(20,25);
+----------+----------+
| column_0 | column_1 |
+----------+----------+
|        1 |        2 |
|        3 |        4 |
|        5 |        6 |
|       10 |       15 |
|       20 |       25 |
+----------+----------+
VALUES can also be used in unions with SELECT statements, TABLE statements, or both.

The constructed tables in the UNION must contain the same number of columns, just as if you were using SELECT. See Section 13.2.18, “UNION Clause”, for further examples.

In MySQL 8.0.31 and later, you can use EXCEPT and INTERSECT with VALUES in much the same way as UNION, as shown here:

mysql> VALUES ROW(1,2), ROW(3,4), ROW(5,6)
    ->   INTERSECT 
    -> VALUES ROW(10,15), ROW(20,25), ROW(3,4);
+----------+----------+
| column_0 | column_1 |
+----------+----------+
|        3 |        4 |
+----------+----------+
1 row in set (0.00 sec)
 
mysql> VALUES ROW(1,2), ROW(3,4), ROW(5,6)
    ->   EXCEPT 
    -> VALUES ROW(10,15), ROW(20,25), ROW(3,4);
+----------+----------+
| column_0 | column_1 |
+----------+----------+
|        1 |        2 |
|        5 |        6 |
+----------+----------+
2 rows in set (0.00 sec)
See Section 13.2.4, “EXCEPT Clause”, and Section 13.2.8, “INTERSECT Clause”, for more information.

In joins. See Section 13.2.13.2, “JOIN Clause”, for more information and examples.

In place of VALUES() in an INSERT or REPLACE statement, in which case its semantics differ slightly from what is described here. See Section 13.2.7, “INSERT Statement”, for details.

In place of the source table in CREATE TABLE ... SELECT and CREATE VIEW ... SELECT. See the descriptions of these statements for more information and examples.



