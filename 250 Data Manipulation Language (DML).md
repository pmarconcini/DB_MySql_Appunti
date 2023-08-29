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

Per utilizzare l'istruzione REPLACE è necessario avere i privilegi INSERT e DELETE.

Nell'esempio seguente l'ID 80 è già esistente e quindi viene aggiornata la descrizione (e vengono nullificate le colonne per cui non è disponibile un valore) mentre l'ID 88 non esiste e quindi viene eseguito l'inserimento:

    REPLACE INTO dept (deptno, dname) VALUES (80, 'E-SHOP'), (88, 'E-SHOP');

==> 3 row(s) affected Records: 2  Duplicates: 1  Warnings: 0	0.063 sec

NB: al momento la console calcola erroneamente il numero di record processati, come si evince dalla risposta

 
--------------------------------------------
## UPDATE

L’istruzione, utilizzata per aggiornare dati in una singola tabella, prevede alcune parti necessarie e alcune facoltative:
- UPDATE <nome_della_singola_tabella: es. dept> => parte necessaria. E’ possibile specificare un alias di tabella, spesso necessario in caso di subquery nelle clausole SET e/o WHERE
- SET <elenco_delle_valorizzazioni_dei_campi_separate_da_virgola: es. loc = INITCAP(loc)> => parte necessaria. Le espressioni valide sono tutte quelle utilizzabili nella clausola SELECT. E’ possibile valorizzare contemporaneamente più campi tramite una unica subquery: in questo caso l’elenco dei campi deve essere racchiuso tra parentesi.
- WHERE  <condizioni> => parte facoltativa. Esattamente come nel caso delle queries di interrogazione permette il filtro dei record. In assenza della clausola WHERE l’aggiornamento riguarderà tutti i record presenti in tabella, a meno che non sia attivo il "Safe update mode" di MySQL che impedische aggiornamenti e modifiche che non facciano riferimento alla chiave primaria nella clausola WHERE.
- Nell'istruzione si può fare riferimento al valore corrente delle colonne coinvolte (es: UPDATE tabella SET colonna = colonna + 1; incrementa "colonna" di 1), ma l'utilizzo successivo all'aggiornamento sarà con il valore nuovo (es: UPDATE tab SET col1 = col1 + 1, col2 = col1; supponendo un valore iniziale di col1 = 10, dopo l'update entrambe le colonne avranno valore 11); la clausola WHERE è elaborata prima della clausola SET e quindi in quel contesto i valori saranno sempre quelli originali.
- Tramite la clausola facoltativa ORDER BY è possibile impostare l'ordine di aggiornamento dei record  selezionati dalla clausola WHERE.
- Tramite la clausola facoltativa LIMIT è possibile limitare il numero di record aggiornati a prescindere dal numero di record selezionati dalla clausola WHERE.

NB: è possibile utilizzare l’istruzione con le viste con i seguenti vincoli:
- la vista deve prendere in considerazione nella clausola SELECT tutti i campi della chiave primaria della tabella che si vuole aggiornare
- la DML di manipolazione deve intervenire esclusivamente su campi presenti nella clausola SELECT della vista nella loro forma originale (quindi non variati da elaborazioni e/o funzioni)

Per utilizzare l'istruzione UPDATE è necessario avere il privilegio UPDATE.


Nell'esempio seguente due aggiornamenti in cui è necessario specificare il riferimento alla chiave (campo DEPTNO); da notare come la secondo UPDATE esegua esattamente lo stesso aggiornamento della prima sul campo LOC e MySQL risponda segnalando le 16 righe interessate e le 0 modificate (il valore originale e quello proposto coincidono):

    UPDATE dept d
    SET dname = concat(dname, '*'), loc = UPPER(loc)
    WHERE deptno > 0 AND NOT EXISTS (SELECT 1 FROM emp WHERE deptno = d.deptno);
    
    UPDATE dept d
    SET loc = UPPER(loc)
    WHERE deptno > 0; -- la condizione si può omettere in assenza di Safe Update Mode attivo

==> Rows matched: 13  Changed: 13  Warnings: 0	0.032 sec ==> Rows matched: 16  Changed: 0  Warnings: 0	0.000 sec



I dati di valorizzazione possono essere ricavati anche da subqueries o da altre tabelle (detta "update multitabella"), come negli esempi seguenti equivalenti:

    UPDATE tabella_1 t1
    SET colonna_1 = (SELECT colonna_2 FROM tabella_2 t2 WHERE t2.ID = t1.ID)
    WHERE ID = 123;

    UPDATE tabella_1 t1, tabella_2 t2
    SET t1.colonna_1 = t2.colonna_2 
    WHERE t1.ID = t2.ID AND t1.ID = 123;



E' possibile aggiungere l'opzione IGNORE per bypassare eventuali errori bloccanti, come nel caso della UPDATE seguente che causa un errore di chiave duplicata:
    
    UPDATE IGNORE dept d
    SET deptno = 10 
    WHERE deptno > 80;    

==> 0 row(s) affected, 1 warning(s): 1062 Duplicate entry '10' for key 'dept.PRIMARY'	0.000 sec


Non è possibile aggiornare una tabella e contemporaneamente eseguire su di essa una query poichè si genera l'errore 1093, come nell'esempio seguente:

    UPDATE tabella
    SET colonna = colonna * 0.9
    WHERE id IN (SELECT id FROM tabella WHERE colonna BETWEEN 0 AND 1000);

==> ERROR 1093 (HY000): You can't specify target table 'tabella' for update in FROM clause


Per ottenere una UPDATE valida è necessario trasformare lo script in un'update multitabella. La subquery utilizzata come INLINE VIEW può anche essere utilizzata per valorizzare una o più colonne della tabella in aggiornamento:

    UPDATE tabella t1, (SELECT id, colonna1, colonna2 FROM tabella WHERE colonna BETWEEN 0 AND 1000) t2
    SET t1.colonna1 = t1.colonna1 * 0.9
        t1.colonna2 = t2.colonna2
    WHERE t1.id = t2.id;



--------------------------------------------
##  DELETE E TRUNCATE

L’istruzione DELETE, utilizzata per eliminare dati in una singola tabella, prevede una parte necessaria e una facoltativa:
- DELETE FROM <nome della singola tabella: es. dept => parte necessaria. E’ possibile specificare un alias di tabella, spesso necessario in caso di subquery nella clausola WHERE
- WHERE  <condizioni> => parte facoltativa. Esattamente come nel caso delle queries di interrogazione permette il filtro dei record. In assenza della clausola WHERE l’eliminazione riguarderà tutti i record presenti in tabella, a meno che non sia attivo il "Safe update mode" di MySQL che impedische aggiornamenti e modifiche che non facciano riferimento alla chiave primaria nella clausola WHERE.
- Tramite la clausola facoltativa ORDER BY è possibile impostare l'ordine di eliminazione dei record  selezionati dalla clausola WHERE.
- Tramite la clausola facoltativa LIMIT è possibile limitare il numero di record eliminati a prescindere dal numero di record selezionati dalla clausola WHERE.

NB: è possibile utilizzare l’istruzione con le viste, con il seguente vincolo:
•	la vista deve prendere in considerazione nella clausola SELECT tutti i campi della chiave primaria della tabella di cui si vuole eliminare dati

Per utilizzare l'istruzione DELETE è necessario avere il privilegio DELETE.

    DELETE FROM dept d
    WHERE deptno > 40;

==> 12 row(s) affected	0.031 sec

Una diversa e spesso migliore alternativa per l’eliminazione di tutti i record di una tabella è l’istruzione TRUNCATE che è però considerabile una DDL e, in quanto tale, implica l’esecuzione automatica della COMMIT e l’eliminazione delle versioni precedenti dei dati da parte di Oracle. La TRUNCATE NON può essere utilizzata su tabelle la cui chiave primaria sia parte di vincoli di integrità referenziale attivi.
 
    TRUNCATE TABLE tabella;



Non è possibile eliminare i dati di una tabella e contemporaneamente eseguire su di essa una query poichè si genera l'errore 1093, come nell'esempio seguente:

    DELETE tabella
    WHERE id IN (SELECT id FROM tabella WHERE colonna BETWEEN 0 AND 1000);

==> ERROR 1093 (HY000): You can't specify target table 'tabella' for update in FROM clause



Per ottenere una DELETE valida è necessario trasformare lo script in una delete multitabella. La subquery utilizzata come INLINE VIEW può anche essere utilizzata per eliminare i dati:

    DELETE FROM tabella t1, (SELECT id FROM tabella WHERE colonna BETWEEN 0 AND 1000) t2
    WHERE t1.id = t2.id;


Se l'eliminazione coinvolge una quantità parziale delle righe della tabella compresa quella con l'ultima valorizzazione tramite AUTO_INCREMENT il valore NON sarà riutilizzato nè con MyISAM nè con InnoDB. Se tutti i record vengono eliminati il conteggio ripartirà da 1.


E' possibile eliminare dati contemporaneamente da più tabelle; per farlo esistono due tipi di scrittura:

    DELETE t1, t2 FROM t1 INNER JOIN t2 INNER JOIN t3 -- elimina i dati delle tabelle t1 e t2; t3 è usata esclusivamente come filtro
    WHERE t1.id=t2.id AND t2.id=t3.id;

    DELETE FROM t1, t2 USING t1 INNER JOIN t2 INNER JOIN t3 -- elimina i dati delle tabelle t1 e t2; t3 è usata esclusivamente come filtro
    WHERE t1.id=t2.id AND t2.id=t3.id;
    
E' possibile utilizzare gli alias di tabella in questo modo:

    DELETE a1, a2 FROM t1 AS a1 INNER JOIN t2 AS a2
    WHERE a1.id=a2.id;
    
    DELETE FROM a1, a2 USING t1 AS a1 INNER JOIN t2 AS a2
    WHERE a1.id=a2.id;

