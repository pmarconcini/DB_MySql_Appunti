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



