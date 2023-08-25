# Strutture e costrutti del codice

A differenza di quanto succede in altri RDBMS, in MySQL NON è possibile eseguire blocchi anonimi di codice ed è quindi necessario creare delle stored procedures e quindi eseguirle; in questo contesto creeremo ed aggiorneremo la procedura di prova "test" per poter apprendere le strutture disponibili. Le peculiarità delle stored procedure saranno esaminate in un capitolo a seguire.

------------------------------
## COMPOUND STATEMENT ed ETICHETTE

Gli elementi fondamentali sono:

- Il codice deve essere racchiuso in blocchi
- All'interno di ogni blocco devono esserci una o più istruzioni ognuna terminata da un ";"
- I blocchi sono annidabili in una organizzazione gerarchica per definire porzioni logiche del codice, gestirne il flusso e la visibilità delle variabili
- E' possibile definire una etichetta per ogni blocco
- In fase di preparazione dello script è necessario specificare quale è il carattere di separazione del codice dei vari oggetti tramite l'istruzione DELIMITER <caratteri>
- Al termine dello script va ripristinato il carattere di separazione standard tramite l'istruzione DELIMITER ;

Il template dello script è il seguente:

    [etichetta_1:] BEGIN
        [elenco istruzioni e/o blocchi]
    END [etichetta_1]

L'esempio seguente mostra invece:

- l'eliminazione della procedura "test" se esistente tramite l'istruzione DROP
- Definizione del carattere di separazione tramite DELIMITER
- la firma della creazione della nuova procedura "test"
- Alcuni blocchi con etichetta (le etichette possono ripetersi purchè non sia usato due volte lo stesso nome nella stessa linea gerarchica)
- Annidamento fino al terzo livello
- Alcune SELECT NON usate per valorizzare variabili e che quindi restituiscono un output
- La chiamata di esecuzione della procedura tramite l'istruzione CALL

		DROP PROCEDURE IF EXISTS test;
		
		DELIMITER $$
		
		CREATE PROCEDURE test ()
		blk_1: BEGIN

  			blk_2: BEGIN
				SELECT 'blocco annidato 1';
			END blk_2;

   			blk_2: BEGIN
				SELECT 'blocco annidato 2';

  				BEGIN
					SELECT 'blocco annidato 3';
				END;
			END blk_2;
		END blk_1
		$$
		
		DELIMITER ;
		
		CALL test();
		
Le etichette possono essere lunghe 16 caratteri e possono essere utilizzate anche per identificare e referenziare i cicli, come da templates seguenti:

	[nome_loop:] LOOP
	    [elenco istruzioni e/o blocchi]
	END LOOP [nome_loop] ;
	
	[nome_loop:] REPEAT
	    [elenco istruzioni e/o blocchi]
		UNTIL <condizione_di_uscita>
	END REPEAT [nome_loop] ;
	
	[nome_loop:] WHILE <condizione_di_entrata> DO
	    [elenco istruzioni e/o blocchi]
	END WHILE [nome_loop] ;


Nell'esempio seguente:

- tutti i cicli hanno delle etichette
- l'unica etichetta fondamentale è quella del primo ciclo perchè necessaria per l'istruzione di uscita LEAVE
- l'andare a capo non impatta sul codice perchè ad indicare la fine dell'istruzione è il carattere ";", come nel caso del ciclo "lp3", e quindi si potrebbe scrivere paradossalmente tutto su una unca riga

 		DROP PROCEDURE IF EXISTS test;
		DELIMITER $$
		CREATE PROCEDURE test ()
		blk_1: BEGIN
			DECLARE a INT;
			SET a = 0;
			lp1: LOOP
			    SET a = a +1;
		        IF a = 10 THEN 
					LEAVE lp1;
				END IF;
			END LOOP lp1;
			
			lp2: REPEAT
			    SET a = a +10;
				UNTIL a >= 100
			END REPEAT lp2;
			
			lp3: WHILE a < 1000 DO 			    SET a = a +100; 			END WHILE lp3; 		    
		    SELECT a;
		END blk_1
		$$
		DELIMITER ;
		CALL test();


--------------------------------------------
## DECLARE

L'istruzione DECLARE si trova SEMPRE in apertura di blocco (immediatamente dopo BEGIN) e permette di definire (appunto dichiarandoli) eventuali variabili locali, cursori e condizioni d'errore ("condition handler").
Il nome dell'elemento dichiarato DEVE essere unico a livello di blocco.
La visibilità (o scope) di quanto dichiarato è il blocco di dichiarazione e tutti i blocchi in esso annidati, ma in caso di dichiarazione omonima prevarrà l'elemento locale (anche in eventuali ulteriori livelli di annidamento).

A seguire un esempio relativo alla visibilità della variabile "a": la variabile dichiarata in apertura del blocco blk_1 copre teoricamente tutto il codice (si tratta del blocco principale contenente tutti gli altri), ma per omonimia nel blocco blk_3 (e in quelli in esso posizionati) prevale la variabile locale "più locale".

 
	DROP PROCEDURE IF EXISTS test;
	DELIMITER $$
	CREATE PROCEDURE test () 
	blk_1: BEGIN 	
		DECLARE a INT; 	
	    SET a = 1; 	
	    SELECT a; -- ==> 1
		blk_2a: BEGIN 	
			SET a = a + 1; 	
			SELECT a; -- ==> 2
			blk_3: BEGIN 	
				DECLARE a INT; 	
				SET a = 100; 	
				SELECT a; -- ==> 100
				blk_4: BEGIN 	
					SET a = a + 1; 	
					SELECT a; -- ==> 101
				END blk_4;
			END blk_3;
		END blk_2a;
		blk_2b: BEGIN 	
			SET a = a + 1; 	
			SELECT a; -- ==> 3
		END blk_2b;
	END blk_1
	$$
	DELIMITER ;
	CALL test();
	

L'ordine di dichiarazione DEVE sempre essere:

- variabili locali
- definizione delle CONDITION (condizioni d'errore definite dall'utente)
- cursori
- definizioni degli HANDLER (condizioni d'errore predefinite)

Le varie tipologie di elemento saranno affrontate nei prossimi paragrafi.


--------------------------------------------
## VARIABILI

Nel codice possono essere utilizzate liberamente: 

- Le variabili di sistema
- Le variabili di sessione definite dall'utente (@nome_variabile)
- Le variabili locali

A differenza delle altre le variabili locali devono essere dichiarate tramite l'istruzione DECLARE (v. paragrafo dedicato) secondo il seguente template:

	DECLARE <nome_variabile> <tipo_variabile> [DEFAULT <valore_iniziale>] ;

E' preferibile che il nome NON coincida con quello di altri oggetti perchè in alcune situazioni può causare degli errori logici (ie: il riferimento alla variabile prevale su quello alle colonne).
La tipologia è obbligatoria e può essere una di quelle utilizzabili nella definizione delle colonne delle tabelle.
Se non è definito un valore di inizializzazione la variabile assumerà il valore NULL.

Per valorizzare la variabile si può:
- Utilizzare l'istruzione: SET  <nome_variabile> = <valore>;
- Utilizzare la clausola INTO di una SELECT: SELECT <valore> INTO <nome_variabile> [...] ;
- Utilizzare la clausola FETCH all'interno di un cursore (argomento trattato in seguito): FETCH <valore> INTO <nome_variabile> [...] ;

Per ottenerne il valore è sufficiente riferirsi ad esa per nome.
 

--------------------------------------------
## ISTRUZIONI DI CONTROLLO DEL PROCESSO

Oltre a quelle già viste in precedenza (valorizzazione e lettura di variabili, definizione dei blocchi, dichiarazioni) sono disponibili queste istruzioni (affrontate nei paragrafi seguenti): 
- Strutture condizionali:
	- CASE
 	- IF 
- Strutture cicliche:
	- ITERATE
	- LOOP
 	- REPEAT
  	- WHILE
- Istruzioni
	- LEAVE
 	- RETURN

Strutture cicliche e condizionali possono essere annidate tra loro.



--------------------------------------------
### IF

Il costrutto IF permette di diversificare il processo tramite la verifica di uno o più insiemi alternativi di condizioni; la verifica segue l’ordine in cui gli insiemi sono presentati nel codice e termina in corrispondenza del primo caso positivo, proseguendo con le istruzioni che ad esso corrispondono. Eventuali altri insiemi di condizioni seguenti sono quindi ignorati, anche con un eventuale esito positivo della verifica.

Gli elementi del costrutto sono quelli seguenti: 

	IF <insieme_di_condizioni> THEN 	-- obbligatorio
		<sequenza_di_istruzioni>
	ELSIF <insieme_di_condizioni> THEN	-- facoltativo
		<sequenza_di_istruzioni>
	ELSIF <insieme_di_condizioni> THEN	-- facoltativo
		<sequenza_di_istruzioni>
	ELSE					-- facoltativo
		<sequenza_di_istruzioni>
	END IF;					-- obbligatorio

La strutturazione di un <insieme_di_condizioni> segue le stesse regole già incontrate nell’affrontare SQL.
La <sequenza_di_istruzioni> può comprendere tutte le istruzioni singole, condizionali e cicliche, anche annidate.

La prima “uscita” deve essere necessariamente “IF”, che deve essere necessariamente presente come la chiusura del costrutto “END IF;”. L’uscita “ELSE”, se presente, deve essere l’ultimo prima della chiusura ed intercetta tutte le casistiche che non hanno soddisfatto nessun insieme di condizioni precedenti.

 
Esempio di costrutto IF

	DROP PROCEDURE IF EXISTS test;
	DELIMITER $$
	CREATE PROCEDURE test () 
	blk_1: BEGIN 	
		DECLARE a INT DEFAULT 10;
		IF a = 1 THEN 
			SELECT 1;
		ELSEIF a < 5 THEN 
			SELECT 5;
		ELSE
			BEGIN
				SELECT 0;
			END;
		END IF;
	END blk_1
	$$
	DELIMITER ;
	CALL test();



--------------------------------------------
### CASE

E’ un costrutto logicamente simile al costrutto “IF” e quindi prevede l’eventuale esecuzione delle istruzioni associate alla prima condizione rispettata. La sostanziale differenza è che DEVE essere utilizzata una delle uscite e, qualora ciò non avvenisse, si verifica un errore (Error Code: 1339. Case not found for CASE statement).
 
 Esistono due forme di CASE:
- Semplice: è specificato una unica espressione da verificare e il processo si diversifica rispetto ai suoi valori
- Complesso (o searched): ad ogni “uscita” corrisponde un insieme di condizioni, esattamente come per il costrutto IF
 
Gli elementi delle due forme del costrutto sono quelli seguenti: 

 	-- CASE semplice
	CASE <espressione> 
	WHEN <valore 1> THEN	 		-- obbligatorio
		<sequenza_di_istruzioni>
	WHEN <valore 2> THEN			-- facoltativo
		<sequenza_di_istruzioni>
	WHEN <valore 3> THEN			-- facoltativo
		<sequenza_di_istruzioni>
	 […]
	ELSE					-- facoltativo
		<sequenza_di_istruzioni>
	END CASE;				-- obbligatorio

	-- CASE complesso
	CASE
	WHEN <insieme_di_condizioni> THEN 	-- obbligatorio
		<sequenza_di_istruzioni>
	WHEN <insieme_di_condizioni> THEN	-- facoltativo
		<sequenza_di_istruzioni>
	WHEN <insieme_di_condizioni> THEN	-- facoltativo
		<sequenza_di_istruzioni>
	ELSE					-- facoltativo
		<sequenza_di_istruzioni>
	END IF;					-- obbligatorio

La prima “uscita” deve essere necessariamente “CASE”, che deve essere necessariamente presente come la chiusura del costrutto “END CASE;”. 
L’uscita “ELSE”, se presente, deve essere l’ultima prima della chiusura ed intercetta tutte le casistiche che non hanno soddisfatto nessun insieme di condizioni precedenti (nella forma complessa) o non hanno avuto un valore corrispondente a quello dell’espressione (nella forma semplice).
La <sequenza_di_istruzioni> può comprendere tutte le istruzioni singole, condizionali e cicliche, anche annidate.

 
Esempio di costrutto CASE Semplice:

	DROP PROCEDURE IF EXISTS test;
	DELIMITER $$
	CREATE PROCEDURE test () 
	blk_1: BEGIN 	
		DECLARE a INT DEFAULT 10;
	    CASE a
		WHEN 1 THEN 
			SELECT 1;
		WHEN 2 THEN 
			SELECT 5;
		ELSE
			BEGIN
				SELECT 0;
			END;
	    END CASE;
	END blk_1
	$$
	DELIMITER ;
	CALL test();


Esempio di costrutto CASE Complesso:

	DROP PROCEDURE IF EXISTS test;
	DELIMITER $$
	CREATE PROCEDURE test () 
	blk_1: BEGIN 	
	    DECLARE a INT DEFAULT 10;
    	CASE 
      	WHEN a = 1 THEN 
			SELECT 1;
      	WHEN a < 5 THEN 
			SELECT 5;
       	ELSE
	    	BEGIN
				SELECT 0;
	        END;
	    END CASE;
	END blk_1
	$$
	DELIMITER ;
	CALL test();


--------------------------------------------
### ITERATE

L'istruzione ITERATE <etichetta>; permette di avviare nuovamente l'elaborazione di un ciclo (all'atto pratico significa che il flusso dell'elaborazione torna all'apertura del cursore corrispondente all'etichetta). 

Per l'esempio di utilizzo si rimanda al paragrafo dedicato ai cicli.



--------------------------------------------
### LEAVE

L'istruzione LEAVE <etichetta>; permette di interrompere un ciclo o l'elaborazione del processo. 
Può essere usato in procedure e triggers ma NON nelle funzioni (che si aspettano l'istruzione RETURN).

Esempio di interruzione del processo con esposizione del valore 10 ma NON del valore 100:

	DROP PROCEDURE IF EXISTS test;
	DELIMITER $$
	CREATE PROCEDURE test () 
	blk_1: BEGIN 	
		DECLARE a INT DEFAULT 10;
		SELECT a;
	    LEAVE blk_1;
	    SET a = 100;
		SELECT a;
	END blk_1
	$$
	DELIMITER ;
	CALL test();

Per gli esempi di uscita da cicli si rimanda al paragrafo dedicato a tale argomento.


--------------------------------------------
### RETURN

L'istruzione RETURN <espressione>; permette di interrompere l'elaborazione restituendo il valore dell'espressione. 
Può essere usato esclusivamente nelle funzioni (può essere presente più volte nella singola funzione) ma NON in procedure e triggers (in cui si può usare l'istruzione LEAVE per interrompere l'elaborazione).

Per gli esempi si rimanda al capitolo dedicato a lle funzioni user-defined.



--------------------------------------------
### STRUTTURE CICLICHE (LOOP, REPEAT e WHILE)

Sono disponibili tre tipologie di strutture cicliche:

- LOOP, non prevede una condizione di verifica e quindi è necessario specificare l'istruzione di uscita LEAVE
- REPEAT, prevede una o più condizioni associate alla parola chiave UNTIL e l'iterazione continua fino a che non si verificano
- WHILE, prevede una o più condizioni associate alla parola stessa e l'iterazione continua fino a che si verificano  

Nell'esempio seguente:

- il ciclo "loop_leave" si interrompe tramite l'istruzione LEAVE al verificarsi di una condizione specificata tramite struttura condizionale (non deve necessariamente essere IF)
- il ciclo "loop_iterate" si ripete (itera) all'esecuzione dell'istruzione ITERATE e si interrompe tramite l'istruzione LEAVE a cui il flusso arriva solo al verificarsi di una condizione specificata tramite struttura condizionale (non deve necessariamente essere IF) con relativo "salto" di ITERATE
- il ciclo "loop_repeat" si interrompe al verificarsi della condizione specificata dopo la clausola UNTIL (tale clausola DEVE trovarsi subito prima della chiusura del ciclo)
- il ciclo "loop_while" si ripete al verificarsi della condizione specificata dopo la clausola WHILE stessa
- Con il tipo LOOP l'eseguire o meno almeno una volta il codice all'interno del ciclo dipende dalla posizione in cui si trova l'istruzione di verifica (ovviamente con WHILE non è possibile far eseguire il codice "almeno una volta", mentre con REPEAT il codice è sempre eseguito "almeno una volta")

 		DROP PROCEDURE IF EXISTS test;
		DELIMITER $$
		CREATE PROCEDURE test ()
		blk_1: BEGIN
			DECLARE a INT DEFAULT 0;
			loop_leave: LOOP
			    SET a = a +1;
		        IF a = 10 THEN 
					LEAVE loop_leave;
				END IF;
			END LOOP loop_leave;

			loop_iterate: LOOP
			    SET a = a +10;
		        IF a < 100 THEN 
					ITERATE loop_iterate;
				END IF;
				LEAVE loop_iterate;
			END LOOP loop_iterate;
			
			loop_repeat: REPEAT
			    SET a = a +100;
				UNTIL a >= 1000
			END REPEAT loop_repeat;
			
			loop_while: WHILE a < 10000 DO
				SET a = a +1000;
			END WHILE loop_while; 		    
		    
            SELECT a;
		END blk_1
		$$
		DELIMITER ;
		CALL test();





--------------------------------------------
### CURSORI

I cursori sono strutture cicliche realizzate tramite l'istruzione LOOP per processare separatamente (uno per volta) i record presenti nel recordset del cursore stesso.
In MySQL i dati ricavati da cursori sono read-only e i cursori sono monodirezionali.
E' possibile annidare cursori (o, per meglio dire, i LOOP che ne ciclano il contenuto), facendo la dovuta attenzione all'ordine di apertura e chiusura degli stessi.

L'utilizzo del cursore prevede 4 diverse istruzioni:
- DECLARE: la dichiarazione del cursore, contenente la DQL necessaria al recepimento dei dati
- OPEN: l'apertura del cursore ed il recepimento del recordset
- FETCH: la lettura del "prossimo" record (è il primo, alla prima elaborazione) e l'incasellamento dei dati nelle variabili locali di destinazione. Il numero di colonne e di variabili devono coincidere per numero e tipologia di dato.
- CLOSE: la chiusura del cursore con la deallocazione della memoria (è implicita al termine dell'elaborazione del trigger/procedura/funzione

L'istruzione FETCH è l'unica che si trova (generalmente) all'interno di un LOOP perchè vengano processati tutti i record uno dopo l'altro; nel momento in cui sono esauriti i record da processare, la FETCH genera un errore "NOT FOUND" che va gestito tramite un HANDLER (per una valorizzare una variabile semaforo che deve essere a sua volta dichiarata) per causare l'uscita dal LOOP: 

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET <variabile> = TRUE;

Non gestire la mancata della FETCH genera l'errore bloccante con Error Code 1329 (No data - zero rows fetched, selected, or processed).
Se non coincide il numero di colonne estratte dalla FETCH col numero di variabili di destinazione si verifica l'errore bloccante con Error Code 1328 (Incorrect number of FETCH variables).

Nell'esempio seguente viene generato l'elenco dei nomi della tabella EMP utilizzando il cursore "cur_nomi" e la variabile semaforo "fine" che assume valore TRUE quando la FETCH non ha successo:

	DROP PROCEDURE IF EXISTS test;
	DELIMITER $$
	CREATE PROCEDURE test ()
	blk_1: BEGIN
		DECLARE fine INT DEFAULT FALSE;
		DECLARE elenco VARCHAR(400) DEFAULT '';
		DECLARE nome VARCHAR(400);
		DECLARE cur_nomi CURSOR FOR SELECT ename FROM emp;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET fine = TRUE;
		OPEN cur_nomi;
		read_loop: LOOP
			FETCH cur_nomi INTO nome;
			IF fine THEN
				LEAVE read_loop;
			END IF;
			SET elenco = concat(elenco, nome, ' ' );
		END LOOP read_loop;
		CLOSE cur_nomi;
		SELECT elenco;
	END blk_1
	$$
	DELIMITER ;
	CALL test();



--------------------------------------------
### GESTIONE DEGLI ERRORI (CONDITION HANDLING)

Un eventuale errore (di sistema o logico e quindi definito dall'utente) bloccante causa la terminazione dell'esecuzione del codice, ma in MySQL gli errori possono essere intercettati e gestiti tramite le istruzioni HANDLER e CONDITION.

- La CONDITION può essere richiamata durante l'elaborazione al verificarsi di una certa condizione e può permettere di gestire l'interruzione o la permettere la continuazione
- La HANDLER è richiamata durante l'elaborazione al verificarsi di uncerto errore di sistema e può permettere di gestire l'interruzione o la permettere la continuazione
- La CONDITION può essere rinominata e referenziata nella HANDLER
- In entrambi i casi è necessaria la dichiarazione tramite l'istruzione DECLARE
- Per causare il verificarsi di una condizione si utilizza l'istruzione SIGNAL (le informazioni relative possono essere aggiornate tramite l'istruzione RESIGNAL)

Il codice per definire una CONDITION è il seguente:

	DECLARE <nome_condizione> CONDITION FOR { <codice_numerico_errore_mysql> | SQLSTATE [VALUE] <valore_stato_sql> }
 
- La dichiarazione deve trovarsi prima di cursori ed handler (vedere l'elenco seguente)
- SQLSTATE [VALUE] prevede come valore un dato alfanumerico di 5 caratteri (vedere l'elenco seguente)
- CONDITION richiamate da SIGNAL o che utilizzano RESIGNAL devono essere necessariamente associate a valori SQLSTATE


Benchè si possa spesso gestire l'eccezione con il solo HANDLER è preferibile utilizzare anche CONDITION per migliorare la lettura del codice, come da confronto nell'esempio seguente:

	-- senza CONDITION
	DECLARE CONTINUE HANDLER FOR 1051
	  BEGIN
	    -- codice da eseguire
	  END;
	
	-- con CONDITION e error code
	DECLARE tabella_inesistente CONDITION FOR 1051;
	DECLARE CONTINUE HANDLER FOR tabella_inesistente
	  BEGIN
	    -- codice da eseguire
	  END;
	
	-- con CONDITION e SQLSTATE
	DECLARE tabella_inesistente CONDITION FOR SQLSTATE '42S02';
	DECLARE CONTINUE HANDLER FOR tabella_inesistente
	  BEGIN
	    -- codice da eseguire
	  END;


Il codice per definire una HANDLER è il seguente:

	DECLARE { CONTINUE | EXIT } HANDLER FOR <condizione> [, <condizione> [, ...]] { <istruzione> | <blocco_istruzioni>}
 
La "condizione" può essere uno dei seguenti valori:

- Codice di errore numerico di MySQL (o corrispondente costante di sistema, come da tabella di riepilogo finale)
- SQLSTATE [VALUE] <valore_sqlstate>
- <nome_condizione>
- SQLWARNING
- NOT FOUND
- SQLEXCEPTION

La HANDLER è eseguita al verificarsi di una delle condizioni. 
Il codice eseguito può essere costtuito da una riga singola o da un blocco di codice.
La dichiarazione deve essere dopo quella di variabili locali e CONDITION.

Dopo l'elaborazione del codice dell'HANDLER:
- l'opzione CONTINUE fa riprendere dalla istruzione successiva a quella che ha generato l'errore
- l'opzione EXIT fa riprendere dall'END del blocco in cui si trova l'istruzione che ha generato l'errore

SQLWARNING è una opzione che racchiude tutti gli errori con SQLSTATE che iniziano con '01'.
NOT FOUND è una opzione che racchiude tutti gli errori con SQLSTATE che iniziano con '02'. E' utilizzato soprattutto per gestire l'uscita dai LOOP dei cursori (SQLSTATE '02000', si rimanda al relativo paragrafo).
SQLEXCEPTION è una opzione che racchiude tutti gli errori con SQLSTATE che NON iniziano con '00', '01' o '02'.

Se si verifica un errore per cui non è stata realizzata la HANDLER possono verificarsi situazioni diverse:
- per condizioni SQLEXCEPTION l'elaborazione termina come se fosse stata utilizzata l'opzione EXIT ma senza codice specificato (quindi se l'errore si verifica in una procedura chiamata da altra procedura l'errore si propaga a quest'ultima per la ricerca di una eventuale HANDLER adeguata.
- per condizioni SQLWARNING l'elaborazione continua come se fosse stata utilizzata l'opzione CONTINUE ma senza codice specificato
- per condizioni NOT FOUND se l'errore si è verificato normalmente continua come con opzione CONTINUE mentre se è causato da SIGNAL o RESIGNAL interrompe l'elaborazione come con opzione EXIT


L'istruzione RESIGNAL prevede il seguente template e può essere inserita nel codice di una HANDLER in modo da modificare le caratteristiche del warning/errore che si è verificato:

	RESIGNAL [ { SQLSTATE [VALUE] <valore_sqlstate> | <nome_condition> }] [SET { MESSAGE_TEXT | MYSQL_ERRNO } [, { MESSAGE_TEXT | MYSQL_ERRNO } ] ...]

L'istruzione RESIGNAL senza opzioni semplicemente "rinnova" l'errore (per esempio come eccezione all'interno di una HANDLER con opzione CONTINUE.


L'istruzione SIGNAL prevede il seguente template e può essere inserita nel codice di un blocco in modo da forzare un warning o un errore:

	SIGNAL { SQLSTATE [VALUE] <valore_sqlstate> | <nome_condition> } [SET { MESSAGE_TEXT | MYSQL_ERRNO } [, { MESSAGE_TEXT | MYSQL_ERRNO } ] ...]

L'istruzione SIGNAL deve sempre fare riferimento a un SQLSTATE esistente o a una CONDITION.



Nell'esempio seguente si possono vedere tutti gli esempi di utilizzo singolo ed associato delle istruzioni per la gestione degli errori:
- blk_1: HANDLER per intercettare gli errori non gestiti localmente dei blocchi annidati; l'opzione CONTINUE fa riprendere dal punto di errore.
- blk_2: cursore con caso NOT FOUND e variabile semaforo "fine"
- blk_3: gestione locale con EXIT per errore 1365 ==> n1 valorizzato nell'HANDLER
- blk_4: gestione locale con CONTINUE per errore 1365 ==> n2 valorizzato nel blocco
- blk_5: gestione locale con EXIT per SQLEXCEPTION ==> n3 valorizzato nell'HANDLER
- blk_6: senza gestione locale eredita il CONTINUE ==> n4 valorizzato nel blocco
- blk_7: warning invocato con SIGNAL con gestione locale con EXIT senza gestione locale ==> n5 valorizzato nell'HANDLER
- blk_8: gestione locale con riferimento a CONDITION con EXIT per errore 1365 ==> n6 valorizzato nell'HANDLER
- blk_9: warning invocato con SIGNAL con riferimento a CONDITION senza gestione locale e CONTINUE ereditato ==> n7 valorizzato nel blocco
- blk_1: il warning di SIGNAL tra i blocchi "blk_9" e "blk_10" è intercettato dall'HANDLER
- blk_10: gestione locale che intercetta il warning causato da SIGNAL e, tramite RESIGNAL, modifica la segnalazione in errore non gestito e bloccante ==> n8 non valorizzato e ultima select non eseguita

 		DROP PROCEDURE IF EXISTS test;
		DELIMITER $$
		CREATE PROCEDURE test ()
		blk_1: BEGIN
			DECLARE n0 INT DEFAULT 0;
			DECLARE n1 INT;			DECLARE n2 INT;			DECLARE n3 INT;			DECLARE n4 INT;			DECLARE n5 INT;			DECLARE n6 INT;			
            DECLARE n7 INT;			DECLARE n8 INT;
			DECLARE elenco VARCHAR(400) DEFAULT '';
			DECLARE nome VARCHAR(400);
            DECLARE CONTINUE HANDLER FOR 1365, SQLEXCEPTION SET n0 = n0 + 1;
			blk_2: BEGIN -- esempio cursore
				DECLARE fine INT DEFAULT FALSE;
				DECLARE cur_nomi CURSOR FOR SELECT ename FROM emp;
				DECLARE CONTINUE HANDLER FOR NOT FOUND SET fine = TRUE;
				OPEN cur_nomi;
				read_loop: LOOP
					FETCH cur_nomi INTO nome;
					IF fine THEN
						LEAVE read_loop;
					END IF;
					SET elenco = concat(elenco, nome, ' ' );
				END LOOP read_loop;
				CLOSE cur_nomi;
                SELECT elenco;
			END blk_2;
			blk_3: BEGIN -- esempio EXIT Code: 1365 Division by 0 (SQLSTATE 22001)	
                DECLARE EXIT HANDLER FOR 1365 SET n1 = 2;
				SET n1 = 1/0;
				SET n1 = 3;
                SELECT n1;
			END blk_3;
			blk_4: BEGIN -- esempio CONTINUE Code: 1365 Division by 0 (SQLSTATE 22001)
                DECLARE CONTINUE HANDLER FOR 1365 SET n2 = 2;
				SET n2 = 1/0;
				SET n2 = 3;
                SELECT n2;
			END blk_4;
			blk_5: BEGIN -- esempio EXIT con SQLEXCEPTION	
 				DECLARE EXIT HANDLER FOR SQLEXCEPTION SET n3 = 2;
				SELECT empno INTO n3 FROM emp; -- causa SQLEXCEPTION
				SET n3 = 3;
                SELECT n3;
			END blk_5;
			blk_6: BEGIN -- esempio senza gestione con delega al blocco contenitore	(CONTINUE)
				SET n4 = 'aaa';
				SET n4 = 3;
                SELECT n4;
			END blk_6;
			blk_7: BEGIN -- esempio con WARNING da SIGNAL
 				DECLARE EXIT HANDLER FOR SQLWARNING SET n5 = 2;
				SET n5 = 1;
				SIGNAL SQLSTATE '01000';
                SET n5 = 3;
                SELECT n5;
			END blk_7;
			blk_8: BEGIN -- esempio con CONDITION e HANDLER
				DECLARE divisione_impossibile CONDITION FOR 1365;
 				DECLARE EXIT HANDLER FOR divisione_impossibile SET n6 = 2;
				SET n6 = 1/0;
                SET n6 = 3;
                SELECT n6;
			END blk_8;
			blk_9: BEGIN -- esempio con CONDITION e SIGNAL (wrning non gestito > CONTINUE)
				DECLARE w_divisione_impossibile CONDITION FOR SQLSTATE '01000';
				SIGNAL w_divisione_impossibile;
 				-- SIGNAL SQLSTATE '01000'; -- forma alternativa alle due righe precedenti
                SET n7 = 3;
                SELECT n7;
			END blk_9;
			SIGNAL SQLSTATE '01000' SET MESSAGE_TEXT = 'Interruzione forzata';
            SELECT elenco, n0, n1, n2, n3, n4, n5, n6, n7, n8, 'fine elaborazione';
			blk_10: BEGIN -- esempio con RESIGNAL
				DECLARE w_divisione_impossibile CONDITION FOR SQLSTATE '01000';
				DECLARE CONTINUE HANDLER FOR w_divisione_impossibile RESIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = 'Resignal interruzione forzata';
                SET n8 = 3;
				SIGNAL w_divisione_impossibile;
                SELECT n8;
			END blk_10;
		END blk_1
		$$
		DELIMITER ;
		CALL test();

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/a6dea971-7bac-4b06-aeb1-e94381151f9a)

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/b24e12f1-29b3-4b15-8141-424e58753cc5)


A seguire la tabella di riepilogo dei codici di errore più frequenti:

|MySQL Error Number|MySQL Error Name|State|
|----|-----|-----|
|1022|ER_DUP_KEY|23000|
|1046|ER_NO_DB_ERROR|3D000|
|1050|ER_TABLE_EXISTS_ERROR|42S01|
|1052|ER_NON_UNIQ_ERROR|23000|
|1053|ER_SERVER_SHUTDOWN|08S01|
|1054|ER_BAD_FIELD_ERROR|42S22|
|1058|ER_WRONG_VALUE_COUNT|21S01|
|1059|ER_TOO_LONG_IDENT|42000|
|1064|ER_PARSE_ERROR|42000|
|1065|ER_EMPTY_QUERY|42000|
|1102|ER_WRONG_DB_NAME|42000|
|1103|ER_WRONG_TABLE_NAME|42000|
|1104|ER_TOO_BIG_SELECT|42000|
|1106|ER_UNKNOWN_PROCEDURE|42000|
|1107|ER_WRONG_PARAMCOUNT_TO_PROCEDURE|42000|
|1109|ER_UNKNOWN_TABLE|42S02|
|1120|ER_WRONG_OUTER_JOIN|42000|
|1121|ER_NULL_COLUMN_IN_INDEX|42000|
|1138|ER_INVALID_USE_OF_NULL|22004|
|1139|ER_REGEXP_ERROR|42000|
|1142|ER_TABLEACCESS_DENIED_ERROR|42000|
|1148|ER_NOT_ALLOWED_COMMAND|42000|
|1149|ER_SYNTAX_ERROR|42000|
|1162|ER_TOO_LONG_STRING|42000|
|1166|ER_WRONG_COLUMN_NAME|42000|
|1169|ER_DUP_UNIQUE|23000|
|1171|ER_PRIMARY_CANT_HAVE_NULL|42000|
|1172|ER_TOO_MANY_ROWS|42000|
|1205|ER_LOCK_WAIT_TIMEOUT|40001|
|1207|ER_READ_ONLY_TRANSACTION|25000|
|1213|ER_LOCK_DEADLOCK|40001|
|1222|ER_WRONG_NUMBER_OF_COLUMNS_IN_SELECT|21000|
|1231|ER_WRONG_VALUE_FOR_VAR|42000|
|1232|ER_WRONG_TYPE_FOR_VAR|42000|
|1261|ER_WARN_TOO_FEW_RECORDS|01000|
|1262|ER_WARN_TOO_MANY_RECORDS|01000|
|1263|ER_WARN_NULL_TO_NOTNULL|22004|
|1264|ER_WARN_DATA_OUT_OF_RANGE|22003|
|1265|ER_WARN_DATA_TRUNCATED|01000|
|1304|ER_SP_ALREADY_EXISTS|42000|
|1305|ER_SP_DOES_NOT_EXIST|42000|
|1317|ER_QUERY_INTERRUPTED|70100|
|1339|ER_SP_CASE_NOT_FOUND|20000|
|1365|ER_DIVISION_BY_ZERO|22012|
|1406|ER_DATA_TOO_LONG|22001|
|1690|ER_DATA_OUT_OF_RANGE|22003|
|1698|ER_ACCESS_DENIED_NO_PASSWORD_ERROR|28000|
|1701|ER_TRUNCATE_ILLEGAL_FK|42000|
|1792|ER_CANT_EXECUTE_IN_READ_ONLY_TRANSACTION|25006|


