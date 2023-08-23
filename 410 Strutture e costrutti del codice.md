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


