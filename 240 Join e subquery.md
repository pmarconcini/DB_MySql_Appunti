# JOIN E SUBQUERIES

--------------------------------------------
## JOIN

La join è la rappresentazione della relazione che intercorre tra due tabelle; tale relazione può coinvolgere una o più colonne di ogni tabella e può coincidere con un vincolo di integrità referenziale o essere una relazione solamente logica.

La join può essere specificata a integrazione della clausola FROM tramite la specifica del tipo di join e l'utilizzo dell'opzione ON seguita dalle condizioni di join oppure direttamente all'interno della clausola WHERE (generalmente in apertura della stessa, prima delle reali condizioni di filtro) per l'INNER JOIN.

Nei paragrafi seguenti vengono analizzate tutte le tipologie di relazione tra tabelle

--------------------------------------------
### SIMPLE o INNER JOIN
Per la “simple (o inner) join” si intende la rappresentazione standard in cui, al netto di eventuali filtri specificati, vengono considerati solo e soltanto i dati per cui esiste una relazione diretta tra le due tabelle; ciò avviene specificando tutti i campi coinvolti nella clausola WHERE o nell'opzione ON collegando logicamente le espressioni necessarie tramite l’operatore logico AND. Per esempio, date due tabelle T1 e T2 in relazione tramite i campi A e B (NB: non necessariamente i campi devono avere lo stesso nome sulle tabelle coinvolte), il risultato sarà la presenza della doppia espressione T1.A = T2.A AND T1.B = T2.B al netto di eventuali condizioni di filtro.
Record non coinvolti dalla relazione (dipartimenti senza dipendenti, nel db di esempio) saranno esclusi dalla query.
NB: nel caso della simple o inner join la parola chiave INNER si può omettere e l’ordine delle tabelle non incide

Esempio di INNER JOIN (scritture equivalenti): 

    SELECT count(*) k -- conta 14 record, cioè gli impiegati associati a un dipartimento
    FROM emp i, dept d
    WHERE i.deptno = d.deptno;
    
    SELECT COUNT(*) k -- conta 14 record, cioè gli impiegati associati a un dipartimento
    FROM dept d INNER JOIN emp i
    ON i.deptno = d.deptno;

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/e20a48b7-93c0-4c90-920b-0b288be155c7)


--------------------------------------------
### NATURAL JOIN
E’ una join in cui la relazione tra i campi della tabella è automaticamente interpretata da Oracle in base a nome e tipo di dato.

Esempio di NATURAL JOIN (per la join viene automaticamente considerato l’unico campo presente in entrambe le tabelle: DEPTNO): 

    SELECT COUNT(*) k -- conta 14 record, cioè gli impiegati associati a un dipartimento
    FROM dept d NATURAL JOIN emp i;

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/e20a48b7-93c0-4c90-920b-0b288be155c7)


--------------------------------------------
### LEFT o RIGHT o FULL OUTER JOIN
E’ una join in cui viene forzata la restituzione dei record di una tabella NON collegati all’altra. Il nome LEFT o RIGHT o FULL deriva dalla posizione della tabella forzata nella clausola FROM, cioè quella in cui manca il record per completare la join (FULL indica la forzatura da entrambe le parti).
In MySql NON è possibile forzare direttamente la FULL join ed è necessario utilizzare una UNION di LEFT e RIGHT join per ottenere il medesimo risultato)

Esempi di OUTER JOIN (se potesse esistere ed esistesse un impiegato non associato ad alcun dipartimento, il conteggio sarebbe della terza query sarebbe di 16 record): 

    SELECT COUNT(*) k -- conta 15 record, cioè i 14 impiegati associati e il dipartimento vuoto
    FROM dept d RIGHT JOIN emp i ON i.deptno = d.deptno;
    
    SELECT COUNT(*) k -- conta 15 record, cioè i 14 impiegati associati e il dipartimento vuoto
    FROM dept d LEFT JOIN emp i ON i.deptno = d.deptno;
    
    SELECT COUNT(*) k -- conta 15 record, cioè i 14 impiegati associati e il dipartimento vuoto
    FROM 
    (SELECT EMPNO
        FROM dept d RIGHT JOIN emp i ON i.deptno = d.deptno
        UNION
        SELECT EMPNO
        FROM dept d LEFT JOIN emp i ON i.deptno = d.deptno
    ) a;

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/e20a48b7-93c0-4c90-920b-0b288be155c7)

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/9cec7ac7-36d8-48e0-928f-eb459f1e08a3)

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/d89649ef-17df-413d-87f6-6575af0c25f5)


--------------------------------------------
### SELF (inner o outer) JOIN
E’ una join che mette in relazione uno o più campi di una tabella con uno o più campi della tabella stessa, come nell’esempio seguente. Di fatto è una INNER o OUTER JOIN tra una tabella e la replica di se stessa (tramite alias)

Esempi di SELF (INNER o OUTER) JOIN: 

    SELECT i.ename NOME, i.empno MATRICOLA, i2.ename NOME_SUP, i2.empno MATRICOLA_SUP
    FROM emp i, emp i2 WHERE i.mgr = i2.empno;

    -- è equivalente alla precedente
    SELECT i.ename NOME, i.empno MATRICOLA, i2.ename NOME_SUP, i2.empno MATRICOLA_SUP
    FROM emp i JOIN emp i2 ON i.mgr = i2.empno;
    
    SELECT i.ename NOME, i.empno MATRICOLA, i2.ename NOME_SUP, i2.empno MATRICOLA_SUP
    FROM emp i LEFT JOIN emp i2 ON i.mgr = i2.empno;

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/31fb434d-1064-4706-890d-7d455151e73d)

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/2471e27b-40d2-4d53-9b8b-86d3c1b2f2bf)


--------------------------------------------
## PRODOTTO CARTESIANO
E’ considerato una NON-JOIN (o NON EQUIJOIN, in contrasto con le EQUIJOIN che presentano una uguaglianza di confronto) perchè non esiste una relazione di uguaglianza tra i campi delle due tabelle, pur essendoci un legame logico (spesso esplicato nella clausola WHERE). All’atto pratico il prodotto cartesiano produce l’incrocio di tutti i record delle tabelle coinvolte (nel database di esempio 14 impiegati per 5 dipartimenti per un totale di 70 record). 
L’esempio classico di utilizzo corretto è l’incrocio tra salari e livelli salariali come da codice seguente:

Esempi di join tramite prodotto cartesiano (restituiscono lo stesso risultato):

    SELECT i.ename, i.sal, s.losal, s.hisal, s.grade
    FROM emp i, salgrade s
    WHERE i.sal BETWEEN s.losal AND s.hisal;
    
    SELECT i.ename, i.sal, s.losal, s.hisal, s.grade
    FROM emp i JOIN salgrade s ON i.sal BETWEEN s.losal AND s.hisal;

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/d909f652-7164-4409-86e4-ce1c9eb0c224)

Non specificare la relazione logica implica l'incrocio di tutte le combinazioni dei record:

    SELECT * FROM 
    (SELECT 1 numero UNION SELECT 2 UNION SELECT 3) tab_a,
    (SELECT 'a' lettera UNION SELECT 'b' UNION SELECT 'c') tab_b
    ORDER BY numero, lettera;
    
    SELECT * FROM 
    (SELECT 1 numero UNION SELECT 2 UNION SELECT 3) tab_a JOIN (SELECT 'a' lettera UNION SELECT 'b' UNION SELECT 'c') tab_b
    ORDER BY numero, lettera;

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/a5b4538e-0b37-49d0-bc02-a6a1884f5568)

--------------------------------------------
## CROSS JOIN

In MySql è possibile, tramite CROSS join, stabilire in maniera più rapida relazioni multiple di una tabella, come da esempio seguente; indicata una volta la tipologia di relazione si specifica l'elenco di tabelle associate:

    SELECT * FROM t1 LEFT JOIN (t2, t3, t4)
                     ON (t2.a = t1.a AND t3.b = t1.b AND t4.c = t1.c);
    --oppure
    SELECT * FROM t1 LEFT JOIN (t2 CROSS JOIN t3 CROSS JOIN t4)
                     ON (t2.a = t1.a AND t3.b = t1.b AND t4.c = t1.c);



--------------------------------------------
--------------------------------------------
## SUBQUERIES

Una subquery è una query annidata all’interno di un’altra query, detta parent (tale rapporto gerarchico può essere riproposto per più livelli); deve essere racchiusa tra parentesi tonde e può essere utilizzata in tutte le clausole e, in caso di necessità, può fare riferimento ai campi della query parent specificandone gli alias di tabella. Con gli stessi criteri le subqueries possono essere utilizzate anche nelle DML di manipolazione dati vera e propria. 

--------------------------------------------
## OPERATORI IN, ANY, SOME, EXISTS E ALL

Alcuni operatori utilizzabili nella clausola WHERE utilizzano subqueries (in tutti i casi è possibile utilizzare la forma negativa con l'operatore NOT): 

-	= (verificata se il valore è l'unico eventualmente restituito nel recordset)
-	<> (verificata se il valore è diverso dall'unico eventualmente restituito nel recordset; in assenza di record la condizione NON è mai verificata per il confronto con valore NULL)
-	IN (verificata se il valore è uno di quelli dell’elenco)
-	<operatore di confronto> ANY (condizione rispettata rispetto ad almeno uno dei valori)
-	EXISTS (esistenza di almeno un valore)
-	<operatore di confronto> ALL (condizione rispettata rispetto a tutti i valori)

NB: SOME ha esattamente lo stesso utilizzo di ANY e restituisce lo stesso risultato. Di fatto sono interscambiabili.


Il valore restituito da una subquery per ogni record può essere sia un dato semplice (quindi una unica colonna) che complesso (quindi sottoforma di riga); in questo secondo caso esistono dei limiti nella modalità di utilizzo:

-	Nella condizione IN le due parti del confronto devono avere lo stesso numero di colonne, corrispondenti per tipo di dato
-	Non è possibile utilizzare dati complessi con gli operatori ANY, ALL e SOME.


Nell'esempio seguente sono presenti subqueries usate con la clausola IN e nella SELECT come fonte dati (sia con riferimento alla parent che senza):

    SELECT empno, ename, mgr, -- non è necessario l'alias perchè non c'è ambiguità con le subqueries
        (SELECT ename FROM emp WHERE empno = e.mgr) MANAGER, -- nella condizione si fa riferimento all'alias della parent
        sal - (SELECT AVG(sal) FROM emp) DELTA_SAL_MEDIO, -- nessuna neccessità di legarsi alla parent
        sal - (SELECT AVG(sal) FROM emp WHERE deptno = e.deptno) DELTA_SAL_MEDIO_SEDE -- neccessità di legarsi alla parent
    FROM emp e
    WHERE deptno IN (SELECT deptno FROM dept WHERE loc IN ('NEW YORK', 'DALLAS'))
    ORDER BY DELTA_SAL_MEDIO DESC;

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/ae9e00ff-1452-4791-bb5a-4a85c8863b66)


Nell'esempio seguente l'utilizzo con l'operatore EXISTS (decisamente preferibile a IN in termini di performance, ove utilizzabile, perchè la ricerca termina al rinvenimento della prima occorrenza):

    SELECT deptno, count(*) k, AVG(sal) media, SUM(sal) somma, MAX(sal) massimo, MIN(sal) minimo
    FROM emp x
    WHERE EXISTS (SELECT 1 FROM emp WHERE x.deptno = deptno AND job IN ('SALESMAN', 'ANALYST'))
    GROUP BY deptno;

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/cc487fd4-5727-45ff-92c3-73ff3f1b3bbb)


Nell'esempio seguente l'utilizzo dell'operatore ALL con uno degli operatori di confronto (la query retituisce i dipendenti con salario maggiore sia della media salariale dei pari ruolo che della media salariale del loro dipartimento):

    SELECT ename, job, sal
    FROM emp e
    WHERE sal > ALL (SELECT avg(sal)  FROM emp sq WHERE sq.job = e.job
                 UNION
                 SELECT avg(sal)  FROM emp sq WHERE sq.deptno = e.deptno
                 );		 

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/905ff824-e58c-4349-87ae-5e9360bbe868)


Nell'esempio seguente l'utilizzo dell'operatore ANY con uno degli operatori di confronto (la query retituisce i dipendenti con salario maggiore di ALMENO un valore tra la media salariale dei pari ruolo e la media salariale del loro dipartimento):

    SELECT ename, job, sal
    FROM emp e
    WHERE sal > ANY (SELECT avg(sal)  FROM emp sq WHERE sq.job = e.job
                 UNION
                 SELECT avg(sal)  FROM emp sq WHERE sq.deptno = e.deptno
                 );		 

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/599199fd-1882-4792-9029-fc327281ff5c)


Nell'esempio seguente la subquery è utilizzata nella clausola FROM e il recordset che restituisce è referenziabile tramite l'alias (obbligatorio in questo caso):

    SELECT empno, ename, e.deptno, sal, media, sal - media delta_sal
    FROM emp e, (SELECT deptno, AVG (sal) media FROM emp GROUP BY deptno) sq1
    WHERE e.deptno = sq1.deptno
    ORDER BY delta_sal DESC;

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/e46f142d-8483-45f8-b9e0-b93ca45d9fd4)


--------------------------------------------
## INLINE VIEW

Una particolare forma di subquery è la Inline View, in cui il recordset ottenuto dalla query è oggetto a sua volta di query e si trova, sempre racchiuso tra parentesi e identificato tramite alias, nella clausola FROM. Nell’esempio seguente la query più interna serve per ordinare i dati, la seconda per associare l’ordinale grazie al ROWNUM e la terza per filtrare (è il meccanismo utilizzato per ottenere un set posizionato di record prima della versione 12.1 di Oracle).

Nell'esempio seguente grazie alla inline view è possibile selezionare gli impiegati nelle posizioni pari della classifica:

    SELECT ename, sal, ordine
    FROM (    
        SELECT ename, sal, @rownum := @rownum + 1 ordine
        FROM emp, (SELECT @rownum := 0) r
        ORDER BY sal DESC
        ) iv
    WHERE MOD(ordine, 2) = 0;   

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/f4b94ad0-efb9-4f21-80b6-21d887217444)


--------------------------------------------
## CLAUSOLA WITH

Una alternativa alla vista inline è l’utilizzo della clausola WITH in cui si deve definire prima della clausola SELECT la query necessaria per stabilire i dati che faranno da “bacino” nella DML. E’ preferibile all’utilizzo della vista inline soprattutto nei casi in cui sia necessario accedere più volte al contenuto di una data tabella. 

Dall'esempio seguente si comprende come sia necessario, dopo la parola chiave WITH, definire un nome che può a sua volta avere un alias nella clausola FROM:
 
    WITH 
        dept_medie AS (
            SELECT deptno, AVG(sal) sal_medio
            FROM   emp
            GROUP BY deptno)
    SELECT e.ename,       e.sal,       e.deptno,    dm.sal_medio,       dm.sal_medio - e.sal sal_diff
    FROM   emp e,       dept_medie dm
    WHERE  e.deptno = dm.deptno
    ORDER BY e.ename;

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/1beb0777-da2e-4bae-ae58-139019936c6d)

NB: gli alias di colonna del recordet possono essere definiti anche come elenco di parametri dopo il nome:

    WITH 
        dept_medie (deptno, sal_medio) AS (
            SELECT deptno, AVG(sal)
            [...]



E' possibile definire più set temporanei in una unica clausola WITH:

    WITH
        rs_temp1 AS (SELECT a, b FROM tabella_1),
        rs_temp2 AS (SELECT c, d FROM tabella_2)
    SELECT b, d FROM rs_temp1 JOIN rs_temp2
    WHERE rs_temp1.a = rs_temp2.c;


--------------------------------------------
## VALUES e TABLE NELLE SUBQUERIES

A partire dalla versione 8.0.19 di MySql è possibile utilizzare VALUES e TABLE nelle subqueries, come da esempi seguenti:

    SELECT * FROM tabella WHERE campo > ANY (VALUES ROW(2), ROW(4), ROW(6));
    
    SELECT * FROM tabella_1 WHERE campo > ANY (TABLE tabella_2);
    


**********************************************************************

**********************************************************************

WITH cte AS
(
  SELECT 1 AS col1, 2 AS col2
  UNION ALL
  SELECT 3, 4
)
SELECT col1, col2 FROM cte;
A WITH clause is permitted in these contexts:

At the beginning of SELECT, UPDATE, and DELETE statements.

WITH ... SELECT ...
WITH ... UPDATE ...
WITH ... DELETE ...
At the beginning of subqueries (including derived table subqueries):

SELECT ... WHERE id IN (WITH ... SELECT ...) ...
SELECT * FROM (WITH ... SELECT ...) AS dt ...
Immediately preceding SELECT for statements that include a SELECT statement:

INSERT ... WITH ... SELECT ...
REPLACE ... WITH ... SELECT ...
CREATE TABLE ... WITH ... SELECT ...
CREATE VIEW ... WITH ... SELECT ...
DECLARE CURSOR ... WITH ... SELECT ...
EXPLAIN ... WITH ... SELECT ...
Only one WITH clause is permitted at the same level. WITH followed by WITH at the same level is not permitted, so this is illegal:

WITH cte1 AS (...) WITH cte2 AS (...) SELECT ...
To make the statement legal, use a single WITH clause that separates the subclauses by a comma:

WITH cte1 AS (...), cte2 AS (...) SELECT ...
However, a statement can contain multiple WITH clauses if they occur at different levels:

WITH cte1 AS (SELECT 1)
SELECT * FROM (WITH cte2 AS (SELECT 2) SELECT * FROM cte2 JOIN cte1) AS dt;
A WITH clause can define one or more common table expressions, but each CTE name must be unique to the clause. This is illegal:

WITH cte1 AS (...), cte1 AS (...) SELECT ...
To make the statement legal, define the CTEs with unique names:

WITH cte1 AS (...), cte2 AS (...) SELECT ...
A CTE can refer to itself or to other CTEs:

A self-referencing CTE is recursive.

A CTE can refer to CTEs defined earlier in the same WITH clause, but not those defined later.

This constraint rules out mutually-recursive CTEs, where cte1 references cte2 and cte2 references cte1. One of those references must be to a CTE defined later, which is not permitted.

A CTE in a given query block can refer to CTEs defined in query blocks at a more outer level, but not CTEs defined in query blocks at a more inner level.

For resolving references to objects with the same names, derived tables hide CTEs; and CTEs hide base tables, TEMPORARY tables, and views. Name resolution occurs by searching for objects in the same query block, then proceeding to outer blocks in turn while no object with the name is found.

Like derived tables, a CTE cannot contain outer references prior to MySQL 8.0.14. This is a MySQL restriction that is lifted in MySQL 8.0.14, not a restriction of the SQL standard. For additional syntax considerations specific to recursive CTEs, see Recursive Common Table Expressions.

Recursive Common Table Expressions
A recursive common table expression is one having a subquery that refers to its own name. For example:

WITH RECURSIVE cte (n) AS
(
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM cte WHERE n < 5
)
SELECT * FROM cte;
When executed, the statement produces this result, a single column containing a simple linear sequence:

+------+
| n    |
+------+
|    1 |
|    2 |
|    3 |
|    4 |
|    5 |
+------+
A recursive CTE has this structure:

The WITH clause must begin with WITH RECURSIVE if any CTE in the WITH clause refers to itself. (If no CTE refers to itself, RECURSIVE is permitted but not required.)

If you forget RECURSIVE for a recursive CTE, this error is a likely result:

ERROR 1146 (42S02): Table 'cte_name' doesn't exist
The recursive CTE subquery has two parts, separated by UNION ALL or UNION [DISTINCT]:

SELECT ...      -- return initial row set
UNION ALL
SELECT ...      -- return additional row sets
The first SELECT produces the initial row or rows for the CTE and does not refer to the CTE name. The second SELECT produces additional rows and recurses by referring to the CTE name in its FROM clause. Recursion ends when this part produces no new rows. Thus, a recursive CTE consists of a nonrecursive SELECT part followed by a recursive SELECT part.

Each SELECT part can itself be a union of multiple SELECT statements.

The types of the CTE result columns are inferred from the column types of the nonrecursive SELECT part only, and the columns are all nullable. For type determination, the recursive SELECT part is ignored.

If the nonrecursive and recursive parts are separated by UNION DISTINCT, duplicate rows are eliminated. This is useful for queries that perform transitive closures, to avoid infinite loops.

Each iteration of the recursive part operates only on the rows produced by the previous iteration. If the recursive part has multiple query blocks, iterations of each query block are scheduled in unspecified order, and each query block operates on rows that have been produced either by its previous iteration or by other query blocks since that previous iteration's end.

The recursive CTE subquery shown earlier has this nonrecursive part that retrieves a single row to produce the initial row set:

SELECT 1
The CTE subquery also has this recursive part:

SELECT n + 1 FROM cte WHERE n < 5
At each iteration, that SELECT produces a row with a new value one greater than the value of n from the previous row set. The first iteration operates on the initial row set (1) and produces 1+1=2; the second iteration operates on the first iteration's row set (2) and produces 2+1=3; and so forth. This continues until recursion ends, which occurs when n is no longer less than 5.

If the recursive part of a CTE produces wider values for a column than the nonrecursive part, it may be necessary to widen the column in the nonrecursive part to avoid data truncation. Consider this statement:

WITH RECURSIVE cte AS
(
  SELECT 1 AS n, 'abc' AS str
  UNION ALL
  SELECT n + 1, CONCAT(str, str) FROM cte WHERE n < 3
)
SELECT * FROM cte;
In nonstrict SQL mode, the statement produces this output:

+------+------+
| n    | str  |
+------+------+
|    1 | abc  |
|    2 | abc  |
|    3 | abc  |
+------+------+
The str column values are all 'abc' because the nonrecursive SELECT determines the column widths. Consequently, the wider str values produced by the recursive SELECT are truncated.

In strict SQL mode, the statement produces an error:

ERROR 1406 (22001): Data too long for column 'str' at row 1
To address this issue, so that the statement does not produce truncation or errors, use CAST() in the nonrecursive SELECT to make the str column wider:

WITH RECURSIVE cte AS
(
  SELECT 1 AS n, CAST('abc' AS CHAR(20)) AS str
  UNION ALL
  SELECT n + 1, CONCAT(str, str) FROM cte WHERE n < 3
)
SELECT * FROM cte;
Now the statement produces this result, without truncation:

+------+--------------+
| n    | str          |
+------+--------------+
|    1 | abc          |
|    2 | abcabc       |
|    3 | abcabcabcabc |
+------+--------------+
Columns are accessed by name, not position, which means that columns in the recursive part can access columns in the nonrecursive part that have a different position, as this CTE illustrates:

WITH RECURSIVE cte AS
(
  SELECT 1 AS n, 1 AS p, -1 AS q
  UNION ALL
  SELECT n + 1, q * 2, p * 2 FROM cte WHERE n < 5
)
SELECT * FROM cte;
Because p in one row is derived from q in the previous row, and vice versa, the positive and negative values swap positions in each successive row of the output:

+------+------+------+
| n    | p    | q    |
+------+------+------+
|    1 |    1 |   -1 |
|    2 |   -2 |    2 |
|    3 |    4 |   -4 |
|    4 |   -8 |    8 |
|    5 |   16 |  -16 |
+------+------+------+
Some syntax constraints apply within recursive CTE subqueries:

The recursive SELECT part must not contain these constructs:

Aggregate functions such as SUM()

Window functions

GROUP BY

ORDER BY

DISTINCT

Prior to MySQL 8.0.19, the recursive SELECT part of a recursive CTE also could not use a LIMIT clause. This restriction is lifted in MySQL 8.0.19, and LIMIT is now supported in such cases, along with an optional OFFSET clause. The effect on the result set is the same as when using LIMIT in the outermost SELECT, but is also more efficient, since using it with the recursive SELECT stops the generation of rows as soon as the requested number of them has been produced.

These constraints do not apply to the nonrecursive SELECT part of a recursive CTE. The prohibition on DISTINCT applies only to UNION members; UNION DISTINCT is permitted.

The recursive SELECT part must reference the CTE only once and only in its FROM clause, not in any subquery. It can reference tables other than the CTE and join them with the CTE. If used in a join like this, the CTE must not be on the right side of a LEFT JOIN.

These constraints come from the SQL standard, other than the MySQL-specific exclusions of ORDER BY, LIMIT (MySQL 8.0.18 and earlier), and DISTINCT.

For recursive CTEs, EXPLAIN output rows for recursive SELECT parts display Recursive in the Extra column.

Cost estimates displayed by EXPLAIN represent cost per iteration, which might differ considerably from total cost. The optimizer cannot predict the number of iterations because it cannot predict at what point the WHERE clause becomes false.

CTE actual cost may also be affected by result set size. A CTE that produces many rows may require an internal temporary table large enough to be converted from in-memory to on-disk format and may suffer a performance penalty. If so, increasing the permitted in-memory temporary table size may improve performance; see Section 8.4.4, “Internal Temporary Table Use in MySQL”.

Limiting Common Table Expression Recursion
It is important for recursive CTEs that the recursive SELECT part include a condition to terminate recursion. As a development technique to guard against a runaway recursive CTE, you can force termination by placing a limit on execution time:

The cte_max_recursion_depth system variable enforces a limit on the number of recursion levels for CTEs. The server terminates execution of any CTE that recurses more levels than the value of this variable.

The max_execution_time system variable enforces an execution timeout for SELECT statements executed within the current session.

The MAX_EXECUTION_TIME optimizer hint enforces a per-query execution timeout for the SELECT statement in which it appears.

Suppose that a recursive CTE is mistakenly written with no recursion execution termination condition:

WITH RECURSIVE cte (n) AS
(
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM cte
)
SELECT * FROM cte;
By default, cte_max_recursion_depth has a value of 1000, causing the CTE to terminate when it recurses past 1000 levels. Applications can change the session value to adjust for their requirements:

SET SESSION cte_max_recursion_depth = 10;      -- permit only shallow recursion
SET SESSION cte_max_recursion_depth = 1000000; -- permit deeper recursion
You can also set the global cte_max_recursion_depth value to affect all sessions that begin subsequently.

For queries that execute and thus recurse slowly or in contexts for which there is reason to set the cte_max_recursion_depth value very high, another way to guard against deep recursion is to set a per-session timeout. To do so, execute a statement like this prior to executing the CTE statement:

SET max_execution_time = 1000; -- impose one second timeout
Alternatively, include an optimizer hint within the CTE statement itself:

WITH RECURSIVE cte (n) AS
(
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM cte
)
SELECT /*+ SET_VAR(cte_max_recursion_depth = 1M) */ * FROM cte;

WITH RECURSIVE cte (n) AS
(
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM cte
)
SELECT /*+ MAX_EXECUTION_TIME(1000) */ * FROM cte;
Beginning with MySQL 8.0.19, you can also use LIMIT within the recursive query to impose a maximum number of rows to be returned to the outermost SELECT, for example:

WITH RECURSIVE cte (n) AS
(
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM cte LIMIT 10000
)
SELECT * FROM cte;
You can do this in addition to or instead of setting a time limit. Thus, the following CTE terminates after returning ten thousand rows or running for one second (1000 milliseconds), whichever occurs first:

WITH RECURSIVE cte (n) AS
(
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM cte LIMIT 10000
)
SELECT /*+ MAX_EXECUTION_TIME(1000) */ * FROM cte;
If a recursive query without an execution time limit enters an infinite loop, you can terminate it from another session using KILL QUERY. Within the session itself, the client program used to run the query might provide a way to kill the query. For example, in mysql, typing Control+C interrupts the current statement.

Recursive Common Table Expression Examples
As mentioned previously, recursive common table expressions (CTEs) are frequently used for series generation and traversing hierarchical or tree-structured data. This section shows some simple examples of these techniques.

Fibonacci Series Generation

Date Series Generation

Hierarchical Data Traversal

Fibonacci Series Generation
A Fibonacci series begins with the two numbers 0 and 1 (or 1 and 1) and each number after that is the sum of the previous two numbers. A recursive common table expression can generate a Fibonacci series if each row produced by the recursive SELECT has access to the two previous numbers from the series. The following CTE generates a 10-number series using 0 and 1 as the first two numbers:

WITH RECURSIVE fibonacci (n, fib_n, next_fib_n) AS
(
  SELECT 1, 0, 1
  UNION ALL
  SELECT n + 1, next_fib_n, fib_n + next_fib_n
    FROM fibonacci WHERE n < 10
)
SELECT * FROM fibonacci;
The CTE produces this result:

+------+-------+------------+
| n    | fib_n | next_fib_n |
+------+-------+------------+
|    1 |     0 |          1 |
|    2 |     1 |          1 |
|    3 |     1 |          2 |
|    4 |     2 |          3 |
|    5 |     3 |          5 |
|    6 |     5 |          8 |
|    7 |     8 |         13 |
|    8 |    13 |         21 |
|    9 |    21 |         34 |
|   10 |    34 |         55 |
+------+-------+------------+
How the CTE works:

n is a display column to indicate that the row contains the n-th Fibonacci number. For example, the 8th Fibonacci number is 13.

The fib_n column displays Fibonacci number n.

The next_fib_n column displays the next Fibonacci number after number n. This column provides the next series value to the next row, so that row can produce the sum of the two previous series values in its fib_n column.

Recursion ends when n reaches 10. This is an arbitrary choice, to limit the output to a small set of rows.

The preceding output shows the entire CTE result. To select just part of it, add an appropriate WHERE clause to the top-level SELECT. For example, to select the 8th Fibonacci number, do this:

mysql> WITH RECURSIVE fibonacci ...
       ...
       SELECT fib_n FROM fibonacci WHERE n = 8;
+-------+
| fib_n |
+-------+
|    13 |
+-------+
Date Series Generation
A common table expression can generate a series of successive dates, which is useful for generating summaries that include a row for all dates in the series, including dates not represented in the summarized data.

Suppose that a table of sales numbers contains these rows:

mysql> SELECT * FROM sales ORDER BY date, price;
+------------+--------+
| date       | price  |
+------------+--------+
| 2017-01-03 | 100.00 |
| 2017-01-03 | 200.00 |
| 2017-01-06 |  50.00 |
| 2017-01-08 |  10.00 |
| 2017-01-08 |  20.00 |
| 2017-01-08 | 150.00 |
| 2017-01-10 |   5.00 |
+------------+--------+
This query summarizes the sales per day:

mysql> SELECT date, SUM(price) AS sum_price
       FROM sales
       GROUP BY date
       ORDER BY date;
+------------+-----------+
| date       | sum_price |
+------------+-----------+
| 2017-01-03 |    300.00 |
| 2017-01-06 |     50.00 |
| 2017-01-08 |    180.00 |
| 2017-01-10 |      5.00 |
+------------+-----------+
However, that result contains “holes” for dates not represented in the range of dates spanned by the table. A result that represents all dates in the range can be produced using a recursive CTE to generate that set of dates, joined with a LEFT JOIN to the sales data.

Here is the CTE to generate the date range series:

WITH RECURSIVE dates (date) AS
(
  SELECT MIN(date) FROM sales
  UNION ALL
  SELECT date + INTERVAL 1 DAY FROM dates
  WHERE date + INTERVAL 1 DAY <= (SELECT MAX(date) FROM sales)
)
SELECT * FROM dates;
The CTE produces this result:

+------------+
| date       |
+------------+
| 2017-01-03 |
| 2017-01-04 |
| 2017-01-05 |
| 2017-01-06 |
| 2017-01-07 |
| 2017-01-08 |
| 2017-01-09 |
| 2017-01-10 |
+------------+
How the CTE works:

The nonrecursive SELECT produces the lowest date in the date range spanned by the sales table.

Each row produced by the recursive SELECT adds one day to the date produced by the previous row.

Recursion ends after the dates reach the highest date in the date range spanned by the sales table.

Joining the CTE with a LEFT JOIN against the sales table produces the sales summary with a row for each date in the range:

WITH RECURSIVE dates (date) AS
(
  SELECT MIN(date) FROM sales
  UNION ALL
  SELECT date + INTERVAL 1 DAY FROM dates
  WHERE date + INTERVAL 1 DAY <= (SELECT MAX(date) FROM sales)
)
SELECT dates.date, COALESCE(SUM(price), 0) AS sum_price
FROM dates LEFT JOIN sales ON dates.date = sales.date
GROUP BY dates.date
ORDER BY dates.date;
The output looks like this:

+------------+-----------+
| date       | sum_price |
+------------+-----------+
| 2017-01-03 |    300.00 |
| 2017-01-04 |      0.00 |
| 2017-01-05 |      0.00 |
| 2017-01-06 |     50.00 |
| 2017-01-07 |      0.00 |
| 2017-01-08 |    180.00 |
| 2017-01-09 |      0.00 |
| 2017-01-10 |      5.00 |
+------------+-----------+
Some points to note:

Are the queries inefficient, particularly the one with the MAX() subquery executed for each row in the recursive SELECT? EXPLAIN shows that the subquery containing MAX() is evaluated only once and the result is cached.

The use of COALESCE() avoids displaying NULL in the sum_price column on days for which no sales data occur in the sales table.

Hierarchical Data Traversal
Recursive common table expressions are useful for traversing data that forms a hierarchy. Consider these statements that create a small data set that shows, for each employee in a company, the employee name and ID number, and the ID of the employee's manager. The top-level employee (the CEO), has a manager ID of NULL (no manager).

CREATE TABLE employees (
  id         INT PRIMARY KEY NOT NULL,
  name       VARCHAR(100) NOT NULL,
  manager_id INT NULL,
  INDEX (manager_id),
FOREIGN KEY (manager_id) REFERENCES employees (id)
);
INSERT INTO employees VALUES
(333, "Yasmina", NULL),  # Yasmina is the CEO (manager_id is NULL)
(198, "John", 333),      # John has ID 198 and reports to 333 (Yasmina)
(692, "Tarek", 333),
(29, "Pedro", 198),
(4610, "Sarah", 29),
(72, "Pierre", 29),
(123, "Adil", 692);
The resulting data set looks like this:

mysql> SELECT * FROM employees ORDER BY id;
+------+---------+------------+
| id   | name    | manager_id |
+------+---------+------------+
|   29 | Pedro   |        198 |
|   72 | Pierre  |         29 |
|  123 | Adil    |        692 |
|  198 | John    |        333 |
|  333 | Yasmina |       NULL |
|  692 | Tarek   |        333 |
| 4610 | Sarah   |         29 |
+------+---------+------------+
To produce the organizational chart with the management chain for each employee (that is, the path from CEO to employee), use a recursive CTE:

WITH RECURSIVE employee_paths (id, name, path) AS
(
  SELECT id, name, CAST(id AS CHAR(200))
    FROM employees
    WHERE manager_id IS NULL
  UNION ALL
  SELECT e.id, e.name, CONCAT(ep.path, ',', e.id)
    FROM employee_paths AS ep JOIN employees AS e
      ON ep.id = e.manager_id
)
SELECT * FROM employee_paths ORDER BY path;
The CTE produces this output:

+------+---------+-----------------+
| id   | name    | path            |
+------+---------+-----------------+
|  333 | Yasmina | 333             |
|  198 | John    | 333,198         |
|   29 | Pedro   | 333,198,29      |
| 4610 | Sarah   | 333,198,29,4610 |
|   72 | Pierre  | 333,198,29,72   |
|  692 | Tarek   | 333,692         |
|  123 | Adil    | 333,692,123     |
+------+---------+-----------------+
How the CTE works:

The nonrecursive SELECT produces the row for the CEO (the row with a NULL manager ID).

The path column is widened to CHAR(200) to ensure that there is room for the longer path values produced by the recursive SELECT.

Each row produced by the recursive SELECT finds all employees who report directly to an employee produced by a previous row. For each such employee, the row includes the employee ID and name, and the employee management chain. The chain is the manager's chain, with the employee ID added to the end.

Recursion ends when employees have no others who report to them.

To find the path for a specific employee or employees, add a WHERE clause to the top-level SELECT. For example, to display the results for Tarek and Sarah, modify that SELECT like this:

mysql> WITH RECURSIVE ...
       ...
       SELECT * FROM employees_extended
       WHERE id IN (692, 4610)
       ORDER BY path;
+------+-------+-----------------+
| id   | name  | path            |
+------+-------+-----------------+
| 4610 | Sarah | 333,198,29,4610 |
|  692 | Tarek | 333,692         |
+------+-------+-----------------+
Common Table Expressions Compared to Similar Constructs
Common table expressions (CTEs) are similar to derived tables in some ways:

Both constructs are named.

Both constructs exist for the scope of a single statement.

Because of these similarities, CTEs and derived tables often can be used interchangeably. As a trivial example, these statements are equivalent:

WITH cte AS (SELECT 1) SELECT * FROM cte;
SELECT * FROM (SELECT 1) AS dt;
However, CTEs have some advantages over derived tables:

A derived table can be referenced only a single time within a query. A CTE can be referenced multiple times. To use multiple instances of a derived table result, you must derive the result multiple times.

A CTE can be self-referencing (recursive).

One CTE can refer to another.

A CTE may be easier to read when its definition appears at the beginning of the statement rather than embedded within it.

CTEs are similar to tables created with CREATE [TEMPORARY] TABLE but need not be defined or dropped explicitly. For a CTE, you need no privileges to create tables.


*******************************************************************************************

*******************************************************************************************
