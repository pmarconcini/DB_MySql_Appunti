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


------------------------------------------
### La clausole INTO

La clausola opzionale INTO permette di definire la destinazione dei dati estratti; tale destinazione può essere un set di variabili locali o di sessione (ma solo user-defined) oppure un file di output, formattato (opzione OUTFILE, CSV-like, con separatori e fine linea) o meno (opzione DUMPFILE, con scrittura di una sola linea senza formattazioni accessorie).
La clausola è utilizzabile esclusivamente nella query principale (purchè unica, quindi sono escluse le sub-query ma anche query legate da UNION e simili) e può essere posizionata dopo la clausola SELECT (la scelta abituale), dopo la clausola FROM e, nelle ultime versioni di MySql, dopo la clausola FOR UPDATE.
In caso di valorizzazione di variabili o di opzione DUMPFILE la query DEVE restituire un record; se non restituisce record si genera il warning con error code 1329, mentre se restituisce più di un record si genera l'errore 1172.
In presenza della clausola INTO il recordset NON viene restituito come output.

Come da esempio seguente, l'utilizzo per valorizzare le variabili richiede:
- che le variabili di destinazione siano in pari numero rispetto alle colonne
- con variabili locali (come vedremo in un capitolo successivo) le stesse devono essere adatte per tipo a ricevere il dato

        SELECT avg(sal) media, max(sal) massimo INTO @val1, @val2 FROM emp;
        
        SELECT @val1, @val2;

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/76d6f508-83db-4c54-973c-aa6cfa4b9bab)


Come da esempio seguente, l'uso dell'opzione OUTFILE permette di scrivere su un file ed indicare il separatore (FIELDS TERMINATED BY), l'identificatore di testo (OPTIONALLY ENCLOSED BY), il carattere di escape (ESCAPED BY) e il carattere di fine linea (LINES TERMINATED BY). Per poter scrivere i dati l'utente deve avere il privilegio FILE e la variabile secure_file_priv deve essere valorizzata.

    SELECT * FROM emp 
    INTO OUTFILE '/tmp/export_data.csv'
    FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"', ESCAPED BY '\'
    LINES TERMINATED BY '\n';


L'uso con l'opzione DUMPFILE non prevede opzioni perchè i dati sono inseriti in una unica riga continua:

    SELECT * FROM emp 
    INTO OUTFILE '/tmp/export_data.txt';


In caso di utilizzo della tabella DUAL con a clausola INTO è necessario che essa venga esplicitata; come da esempio seguente è disponibile però una formula alternativa di valorizzazione:

    SELECT @usr := current_user();
    SELECT current_user() INTO @usr FROM dual;
 

--------------------------------
## Istruzione DO

L'istruzione DO esegue una espressione ma senza restituire l'output; è simile all'istruzione SELECT utilizzata con la tabella virtuale DUAL ma l'assenza di output può renderlo preferibile in alcune circostanze per migliorare le performance e ridurre i tempi di lock delle risorse.

Considerando l'esempio seguente si evince che la select produce sempre un recordset mentre DO restituisce il solo esito in console. Non potendo fare riferimento a tabelle (comresa DUAL) l'unica istruzione di valorizzazione utilizzabile con DO è "DO @variabile := <valore>;", ma è comunque un tipo di scrittura deprecata.

    SELECT SLEEP(5); -- > Output del recordset
    SELECT @usr := current_user(); -- > Output del recordset
    SELECT current_user() INTO @usr FROM dual; -- > Output del recordset
    DO SLEEP(5);
    DO @usr := current_user();
    SELECT @usr; -- > Output del recordset


--------------------------------
## Istruzione TABLE

TABLE è una istruzione aggiunta dalla versione 8.0.19 che restituisce tutte le righe e le tutte colonne non invisibili della tabella o vista specificata come parametro; è sostanzialmente simile all'istruzione "SELECT *", ma sono utilizzabili solo le clausole opzionali ORDER BY e LIMIT con le modalità già viste in precedenza.

Lo script base è il seguente:

    TABLE <nome_tabella> [ORDER BY column_name] [LIMIT number [OFFSET number]];

TABLE può essere usato anche con le tabelle temporanee, con i costrutti UNION, INTERSECT e EXCEPT e, in alcuni casi, con le istruzioni CREATE TABLE e CREATE VIEW (tutti argomenti che saranno analizzati in seguito).

Le due istruzioni seguenti restituiscono lo stesso output:

    SELECT * FROM emp ORDER BY sal DESC LIMIT 2, 3; -- i 3 impiegati più pagati saltando i primi due
    
    TABLE emp ORDER BY sal DESC LIMIT 2, 3; -- i 3 impiegati più pagati saltando i primi due

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/acdaca68-981b-47ca-b8ad-9537d29a04c0)


--------------------------------
## Istruzioni di associazione: UNION, INTERSECT e EXCEPT

Sono istruzioni che permettono di applicare regole di insiemistica a recordset di dati ottenendone un unico recordset; il vincolo è che i recordset utilizzati siano coerenti per numero di colonne e specifica tipologia di dato.
Le istruzioni possono essere utilizzate con SELECT, TABLE e VALUES (che verrà analizzato in seguito), o combinazioni di essi, con il seguente script:

        <recordset_1> { UNION | INTERSECT | EXCEPT } [ DISTINCT | ALL ] <recordset_2>;

- UNION: aggrega i due recordset in uno unico
- INTERSECT: combina i due recordset in uno unico mantenendo solo le righe presenti in entrambi
- EXCEPT: sottrae dal primo recordset le righe presenti nel secondo recordset (corrisponde all'istruzione MINUS presente in altri RDBMS)

L'opzione DISTINCT, che è la predefinita, esclude i duplicati, mentre ALL li mantiene.

Le istruzioni sono combinabili e l'elaborazione segue l'ordine di scrittura, ma è possibile utilizzare le parentesi per cambiare la logica dei recordset; lo script seguente restituisce 3 e 1 come dati benchè 1 sia escluso sia da INTERSECT che da EXCEPT perchè la UNION finale è l'ultima ad essere elaborata:

    (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 )
    INTERSECT 
    (SELECT 3 UNION SELECT 4 )
    EXCEPT
    (SELECT 4 UNION SELECT 1)
    UNION
    SELECT 1;


--------------------------------
## L'istruzione VALUES

L'istruzione VALUES è stata introdotta dalla versione 8.0.19 di MySql e restituisce un recordset costituito da record ottenuti da una sequenza di elaborazioni della funzione ROWS, in cui vengono passati come parametri l'elenco di valori corrispondenti per posizione alle colonne di destinazione.
Può essere utilizzata all'interno di query DQL e DML, con le istruzioni UNION, INTERSECT e EXCEPT

Lo script standard è il seguente:

    VALUES ROW(<elenco_valori>)[, ROW(<elenco_valori>)][, ...] [ORDER BY <elenco_criteri>] [LIMIT <numero_elementi>];

Nell'esempio seguente si evidenzia l'uso di tutte le opzioni (ORDER BY e LIMIT seguono le regole già viste in precedenza):

    VALUES ROW(1,-2,3), ROW(5,7,9), ROW(4,6,8), ROW(6,6,6) ORDER BY column_2, 1 DESC LIMIT 1, 2;

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/1bc12467-dbb0-4a17-9b31-61ad2fd39692)



--------------------------------
### L'opzione facoltativa WITH ROLLUP

La clausola GROUP BY permette di specificare l'opzione WITH ROLLUP, che genera l'inserimento nell'output di righe aggiuntive che riportano valori aggregati parziali e totali.

L'esempio seguente evidenzia la media salariale per dipartimento e la media salariale totale ed utilizza le funzioni GROUPING per identificare le celle di aggregazione e IF per discriminarne il valore:

    SELECT IF(GROUPING(deptno), 'TUTTI ==>', deptno) AS deptno, IF(GROUPING(job), concat('DEPTNO ', deptno, ' =>'), job) AS job, AVG(sal) sal_medio
    FROM emp
    GROUP BY deptno, job WITH ROLLUP;

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/b74c20f6-0e40-416b-801a-5f9cb1048c9c)

