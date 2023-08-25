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

- Codice di errore numerico di MySQL
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

Se si verifica un errore per cui non è stata realizzata la HANDLER possono veerificarsi situazioni diverse:
- per condizioni SQLEXCEPTION l'elaborazione termina come se fosse stata utilizzata l'opzione EXIT ma senza codice specificato (quindi se l'errore si verifica in una procedura chiamata da altra procedura l'errore si propaga a quest'ultima per la ricerca di una eventuale HANDLER adeguata.
- per condizioni SQLWARNING l'elaborazione continua come se fosse stata utilizzata l'opzione CONTINUE ma senza codice specificato
- per condizioni NOT FOUND se l'errore si è verificato normalmente continua come con opzione CONTINUE mentre se è causato da SIGNAL o RESIGNAL interrompe l'elaborazione come con opzione EXIT




mysql> delimiter //

mysql> CREATE PROCEDURE handlerdemo ()
       BEGIN
         DECLARE CONTINUE HANDLER FOR SQLSTATE '23000' SET @x2 = 1;
         SET @x = 1;
         INSERT INTO test.t VALUES (1);
         SET @x = 2;
         INSERT INTO test.t VALUES (1);
         SET @x = 3;
       END;
       //
Query OK, 0 rows affected (0.00 sec)

mysql> CALL handlerdemo()//
Query OK, 0 rows affected (0.00 sec)

mysql> SELECT @x//
    +------+
    | @x   |
    +------+
    | 3    |
    +------+
    1 row in set (0.00 sec)
Notice that @x is 3 after the procedure executes, which shows that execution continued to the end of the procedure after the error occurred. If the DECLARE ... HANDLER statement had not been present, MySQL would have taken the default action (EXIT) after the second INSERT failed due to the PRIMARY KEY constraint, and SELECT @x would have returned 2.

To ignore a condition, declare a CONTINUE handler for it and associate it with an empty block. For example:

DECLARE CONTINUE HANDLER FOR SQLWARNING BEGIN END;
The scope of a block label does not include the code for handlers declared within the block. Therefore, the statement associated with a handler cannot use ITERATE or LEAVE to refer to labels for blocks that enclose the handler declaration. Consider the following example, where the REPEAT block has a label of retry:

CREATE PROCEDURE p ()
BEGIN
  DECLARE i INT DEFAULT 3;
  retry:
    REPEAT
      BEGIN
        DECLARE CONTINUE HANDLER FOR SQLWARNING
          BEGIN
            ITERATE retry;    # illegal
          END;
        IF i < 0 THEN
          LEAVE retry;        # legal
        END IF;
        SET i = i - 1;
      END;
    UNTIL FALSE END REPEAT;
END;
The retry label is in scope for the IF statement within the block. It is not in scope for the CONTINUE handler, so the reference there is invalid and results in an error:

ERROR 1308 (42000): LEAVE with no matching label: retry
To avoid references to outer labels in handlers, use one of these strategies:

To leave the block, use an EXIT handler. If no block cleanup is required, the BEGIN ... END handler body can be empty:

DECLARE EXIT HANDLER FOR SQLWARNING BEGIN END;
Otherwise, put the cleanup statements in the handler body:

DECLARE EXIT HANDLER FOR SQLWARNING
  BEGIN
    block cleanup statements
  END;
To continue execution, set a status variable in a CONTINUE handler that can be checked in the enclosing block to determine whether the handler was invoked. The following example uses the variable done for this purpose:


CREATE PROCEDURE p ()
BEGIN
  DECLARE i INT DEFAULT 3;
  DECLARE done INT DEFAULT FALSE;
  retry:
    REPEAT
      BEGIN
        DECLARE CONTINUE HANDLER FOR SQLWARNING
          BEGIN
            SET done = TRUE;
          END;
        IF done OR i < 0 THEN
          LEAVE retry;
        END IF;
        SET i = i - 1;
      END;
    UNTIL FALSE END REPEAT;
END;
