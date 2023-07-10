# Funzioni e operatori

Per una trattazione completa dell'argomento si rimanda all'apposita sezione della documentazione:
https://dev.mysql.com/doc/refman/8.0/en/built-in-function-reference.html

Alle funzioni preinstallate possono essere aggiunte le "loadable functions":
https://dev.mysql.com/doc/refman/8.0/en/server-loadable-functions.html

---------------------------------------
## Concetto di espressione

Un'espressione è un valore che può essere di qualsiasi tipo di dato ed essere il risultato dell'elaborazione di funzioni (di sistema o user-defined), di un confronto con operatori, di costanti, di dati di colonne o di combinazioni tra questi elementi.
Come vedremo può essere utilizzata in diversi punti di SQL, ma anche nel codice degli oggetti che ne fanno uso.

In MySql una espressione che contiene un elemento con valore NULL assume sempre il valore NULL (la cosiddetta propagazione del nullo).


---------------------------------------
## La tabella DUAL

Per comodità nell'affrontare funzioni e operatori si farà uso di una tabella fittizia di nome DUAL contenente una unica riga e senza colonne definite; in MySql una istruzione DQL in cui si omette la clausola FROM fa riferimento, per definizione, alla tabella DUAL.

Le due istruzioni seguenti sono, di fatto, identiche:

    SELECT 1 + 2 AS tot, 1 + NULL AS nullo;
    
    SELECT 1 + 2 AS tot, 1 + NULL AS nullo FROM DUAL;

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/8a297b42-0326-4bd9-b13e-31a574128bd3)


---------------------------------------
## Conversione di dati

la conversione può essere esplicita o implicita; in questo secondo caso la scelta di cosa convertire è delegata a MySql e dipende in buona sostanza dai formati attesi per i parametri e da quelli restituiti dalle funzioni o dagli operatori.

Negli esempi di conversione implicita seguenti l'operatore "+" fa convertire i dati in numero e la funziona CONCAT in testo; la conversione in numeri può avvenire parzialmente prendendo esclusivamente la parte iniziale realmente numerica e in assenza di dato utile il valore diventa 0: 

    SELECT 2.1+2.1 AS c1, 2.1+'2z' AS c2, '2,1'+'2.1' AS c3, CONCAT(2,2) AS c4, 1 * 'z6' AS c5;

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/2bb71a43-9a26-458e-994a-ed5b3bb32de4)


La conveersione esplicita invece si può ottenere tramite la funzione CAST, che richiede di indicare il valore da convertire e il tipo dato in cui eseguire la conversione:

    SELECT 4.1 AS numero, CAST(4.1 AS CHAR) AS testo;

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/339fa5ed-7457-4c99-8f8c-86ac11564891)


---------------------------------------
## Operatori

Gli operatori più frequentemente utilizzati sono i seguenti:

- \>	==> Maggiore di 
- \>= ==> Maggiore o uguale di 
- \<	==> Minore di
- <> (oppure !=) ==> Diverso da
- <= ==> Minore o uguale di
- %  ==> Modulo (il resto di una divisione); si può usare anche la funzione MOD
- \*	==> Moltiplicazione
- \+	==> Addizione
- \-	==> Sottrazione o cambio di segno
- -> ==> Restituzione di un valore da una colonna di JSON (anche con funzione JSON_EXTRACT())		
- ->>	==> Restituzione di un valore "unquoted" da una colonna di JSON (anche con funzione JSON_UNQUOTE(JSON_EXTRACT())
- /	==> Divisione
- := ==> Assegnazione di un valore 
- =	==> Assegnazione di un valore (con istruzione SET o UPDATE) o Uguale a
- =	==> Equal operator		
- AND (oppure &&) ==> Operatore logico AND
- BETWEEN <min> AND <max> ==> Valore compreso tra ... e ... (estremi inclusi)
- CASE ==> Operatore CASE (condizionale multiplo)
- IN(<elenco>) ==> Appartenenza all'elenco
- IS NOT NULL ==> Verifica nonnullità
- IS NULL ==> Verifica nullità
- LIKE ==> Verifica testo con pattern matching		
- NOT (oppure !) ==> Negazione
- OR (oppure ||) ==> Operatore logico OR
- REGEXP (oppure RLIKE) ==> Verifica testo con espressione regolare
- ^ ==> Elevamento a potenza


L'ordine di elaborazione degli operatori più comuni è il seguente ma, in ogni caso, vengono prima considerate eventuali parentesi.

- INTERVAL
- COLLATE
- !
- ^
- *, /, DIV, %, MOD
- -, \+
- = (confronto), >=, >, <=, <, <>, !=, IS, LIKE, REGEXP, IN
- BETWEEN, CASE
- NOT
- AND (oppure &&)
- OR (oppure ||)
- \= (assegnamento), :=

-----------------------------------

## Operatori matematici

    SELECT  3+5 AS somma,
            3-5 AS sottrazione,
            -3 AS negativo,
            3*5 AS moltiplicazione,
            3/5 AS divisione,
            5 DIV 2 AS ris_intero,
            33 % 5 AS modulo_1,
            33 MOD 5 AS modulo_2;
==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/8001b7db-4197-460e-a148-4c395e5d4982)

---------------------------------------
## Funzioni e operatori di confronto

Restituiscono un valore booleano vero (true, 1) o falso (false, 0).

        SELECT  
            2 > 1 AS c1, -- A maggiore di B ==> vero
            2 >= 1 AS c2, -- A maggiore o uguale di B ==> vero
            1 < 2 AS c3, -- A minore di B ==> vero
            1 <= 2 AS c4, -- A minore o uguale di B ==> vero
            1 <> 2 AS c5, -- A diverso da B ==> vero
            1 != 2 AS c6, -- A diverso da B ==> vero
            1 <=> 1 AS c7, -- A uguale a B ==> vero (compresi valori NULL)
            1 = 1 AS c8, -- A uguale a B ==> vero (NULL valori NULL)
            2 BETWEEN 1 AND 3 AS c9, -- A compreso tra B e C ==> vero
            COALESCE(NULL, NULL, 1, 2) AS c10, -- Il primo valore non nullo in elenco ==> 1
            GREATEST(0, -3, 1, 2) AS c11, -- Il valore più grande nell'elenco ==> 2 (con propagazione del nullo)
            1 IN (null, 1, -1, 2, 3) AS c12, -- Valore nell'elenco ==> vero (compresi nulli)
            INTERVAL(10, 0, 10, 20, 0) AS c13, -- Indice (da 0) del primo valore di cui è minore o uguale il primo parametro ==> 2
            1 IS NOT NULL AS c14, -- test nonnullità ==> vero
            1 IS NULL AS c15, -- test nullità ==> falso
            ISNULL(1) AS c16, -- test nullità ==> falso
            LEAST(3, -3, 1, 4) AS c17, -- Il valore più piccolo nell'elenco ==> -3 (con propagazione del nullo)
            'abcd' LIKE	'%c%' AS c18; -- corrispondenza del pattern ==> vero

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/8cc92b0e-e8fa-445b-8b6e-170dbf263547)

---------------------------------------

## Funzioni di controllo del flusso (o condizionali)

Le seguenti funzioni diversificano il risultato in base alla verifica di una o più condizioni:

- CASE  ==> Operatore Case (2 forme di scrittura)
- IF()	==> Costrutto If/else (
- IFNULL() ==> Verifica nullità if/else
- NULLIF() ==> Nullificazione con <espressione1> = <espressione2>

      SET @a = 1, @b=2;
      SELECT  CASE @a WHEN 1 THEN 'uno' WHEN 2 THEN 'due' ELSE 'altro' END AS c1, 
              -- ==> CASE <espressione> WHEN <val1> THEN <ris1> WHEN <val2> THEN <ris2> ELSE <ris_altro> END
              CASE WHEN @a>0 THEN 'vero' ELSE 'falso' END AS c2,
              -- ==> CASE WHEN <test_espressione1> THEN <ris1> WHEN <test_espressione2> THEN <ris2> ELSE <ris_altro> END
              IF(@a > @b, 1, 2) AS c3, 
              -- ==> IF (<test_espressione>, <ris_se_vero>, <ris_se_falso>)
              IFNULL (1,0) AS c4,
              IFNULL (NULL, 10) AS c5,
              -- ==> IFNULL (<ris_se_non_nullo>, <ris_se_primo_null>)
              NULLIF(1,1) AS c6,
              NULLIF(1,2) AS c7
              -- ==> NULLIF (<espr1>, <espr2>) ==> se uguali ris = NULL, altrimenti ris = <espr1>
              ;
  
==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/68d9a574-af9c-4997-a42d-c5aaad7a8439)

---------------------------------------

## Funzioni matematiche

NB: tutte le funzioni matematiche restituiscono NULL in caso di errore

    SELECT  ABS(-32) AS c1, -- valore assoluto
            CEIL(1.23) AS c2, -- il più piccolo intero maggiore di 1.23
            CEILING(-1.23) AS c3, -- sinonimo di CEIL
            CONV('a',16,2) AS c4, -- conversione di 'a' da base 16 a base 2
            FLOOR(1.23) AS c5, -- il più grande intero minore di 1.23
            MOD(234, 10) AS c6, -- il resto della divisione per 10 di 234;
            POW(2,3) AS c7, -- elevamento di 2 alla potenza 3
            RAND() as c8, -- numero randomico compreso tra 0 e 1
            FLOOR(7 + (RAND() * 5)) AS c9, -- numero randomico intero compreso ta 7 e 12
            ROUND(-1.23) AS c10, -- arrotondamento all'unità
            ROUND(1.298, 1) AS c11, -- arrotondamento al primo decimale
            ROUND(23.298, -1) AS c12, -- arrotondamento alle decine
            SIGN(-1.23) AS c13, -- il segno del valore -1.23 ==> 1 se positivo, 0 se 0, -1 se negativo, NULL se nullo
            SQRT(25) AS c14, -- radice quadrata di 25
            TRUNCATE(1.223,1) AS c15, -- troncamento al primo decimale
            TRUNCATE(1.999,0) AS c16, -- troncamento all'unità
            TRUNCATE(122,-2) AS c17 -- troncamento al centinaio
            ;

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/39665bbf-286e-4f36-8461-991366f39972)

Esistono anche altre funzioni matematiche per le quali si rimanda alla documentazione ufficiale.



