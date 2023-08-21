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
## VALUES e TABLE NELLE SUBQUERIES

A partire dalla versione 8.0.19 di MySql è possibile utilizzare VALUES e TABLE nelle subqueries, come da esempi seguenti:

    SELECT * FROM tabella WHERE campo > ANY (VALUES ROW(2), ROW(4), ROW(6));
    
    SELECT * FROM tabella_1 WHERE campo > ANY (TABLE tabella_2);
    


--------------------------------------------
## CLAUSOLA WITH (o CTE, Common Table Expressions)

Una alternativa alla vista inline è l’utilizzo della clausola WITH in cui si deve definire prima della clausola SELECT la query necessaria per stabilire i dati che faranno da “bacino” nella query principale. E’ preferibile all’utilizzo della vista inline soprattutto nei casi in cui sia necessario accedere più volte al contenuto di una data tabella. 

In maniera analoga è possibile utilizzare WITH con le istruzioni DML, direttamente nel caso di UPDATE e DELETE e indirettamente con INSERT e REPLACE (l'argomento è trattato nel capitolo dedicato alle DML).

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


E' possibile definire una CTE (Common Table Expressions) ricorsivamente (ovvero la query fa riferimento a se stessa) aggiungendo l'opzione RECURSIVE; nel'esempio seguente viene generato un recordset contenente i numeri da 1 a 10:

    WITH RECURSIVE numeri (n) AS
    (
      SELECT 1
      UNION ALL
      SELECT n + 1 FROM numeri WHERE n <= 10
    )
    SELECT * FROM numeri;


