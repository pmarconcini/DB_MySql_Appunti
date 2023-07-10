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

---------------------------------------

## Funzioni su date e tempo

NB: le funzioni che si aspettano date come parametri generalmente accettano valori temporali e viceversa. MySql si attende un formato ben preciso ('YYYY-MM-DD HH:MI:SS.mmmmm') ma cerca di interpretare il dato che viene passato (ie-dati in formato più corto, ordine diverso, etc).

    SELECT 
        ADDDATE('2008-01-02', 31) AS c1, -- aggiunge 31 giorni
        ADDTIME('2007-12-31 23:59:59.999999', '1 1:1:1.000002') AS c2, -- aggiunge 1 DD, 1 HH, 1 MI, 1 SS e 2 mmmmm
        CONVERT_TZ('2004-01-01 12:00:00','GMT','MET') AS c3, -- converte una data/ora dalla zona GMT alla zona MET
        CURDATE() AS c4, -- data corrente in formato 'YYYY-MM-DD' o YYYYMMDD
        CURRENT_DATE() AS c5, -- come CURRDATE()
        CURRENT_TIME() AS c6, -- come CURTIME()
        CURRENT_TIMESTAMP() AS c7, -- come NOW()
        CURTIME() AS c8a, -- ora corrente senza frazioni di secondo, in formato 'hh:mm:ss' o hhmmss
        CURTIME(3) AS c8b, -- ora corrente con 3 decimali di secondo, in formato 'hh:mm:ss.mmmmm' o hhmmss.mmmmm
        DATE('2003-12-31 01:02:03') AS c9, -- estrazione della data
        DATEDIFF('2007-12-31 23:59:59','2007-12-30') AS c10, -- differenza in giorni tra 2 date
        DATE_ADD('2008-01-02', INTERVAL 31 DAY) AS c11, -- aggiunge un intervallo di 31 giorni
        DATE_SUB('2018-05-01',INTERVAL 1 YEAR) AS c12, -- sottrae un intervallo di 1 anno
        DAYNAME('2007-02-03') AS c13, -- giorno della settimana letterale della data
        DAYOFMONTH('2007-02-03') AS c14, -- giorno del mese della data
        DAYOFWEEK('2007-02-03') AS c15, -- giorno della settimana numerico dela data (1 = domenica)
        DAYOFYEAR('2007-02-03') AS c16, -- giorno dell'anno
        HOUR('10:05:03') AS c17, -- ore di un orario
        LAST_DAY('2003-02-05') AS c18, -- ultimo giorno del mese di una data
        MINUTE('2008-02-03 10:05:03') AS c19, -- minuti di un orario
        MONTH('2008-02-03') AS c20, -- mese di una data
        MONTHNAME('2008-02-03') AS c21, -- mese testuale di una data
        NOW() AS c22a, -- questo momento (data e ora)
        NOW(3) AS c22b, -- questo momento con decimali di secondo (data e ora)
        SECOND('10:05:03') AS c23, -- secondi di un orario
        STR_TO_DATE('01,5,2013','%d,%m,%Y') AS c24a, -- conversione di testo in data
        STR_TO_DATE('a09:30:17','a%h:%i:%s') AS c24b, -- conversione di testo in data
        SUBTIME('2007-12-31 23:59:59.999999','1 1:1:1.000002') AS c25, -- sottrae 1 DD, 1 HH, 1 MI, 1 SS e 2 mmmmm
        TIME('2003-12-31 01:02:03') AS c26, -- estrae l'orario da un date/time
        TIMEDIFF('2008-12-31 23:59:59.000001','2008-12-30 01:01:01.000002') AS c27, -- differenza temporale in ore, minuti e secondi
        WEEK('2008-02-20') AS c28, -- settimana dell'anno
        YEAR('1987-01-01') AS c29 -- l'anno di un date/time
        ;

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/69f1fc2e-1b62-4dcd-8900-1251da3596c4)

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/a87ab649-db14-40ba-9899-c0efe06601eb)


Esistono anche altre funzioni per la gestione di date e orari per le quali si rimanda alla documentazione ufficiale.


### Formattare le date e gli orari

La funzione DATE_FORMAT(<data>,<formato>) permette di formattare come teto una data, utilizzando i seguenti indicatori:
%a	Giorno letterale in breve
%b	Mese letterale in breve
%c	Mese numerico (0..12)
%D	Giorno del mese con suffisso inglese
%d	Giorno del mese numerico (00..31)
%e	Giorno del mese numerico (0..31)
%f	Microsecondi (000000..999999)
%H	Ore (00..23)
%h	Ore (01..12)
%I	Ore (01..12)
%i	Minuti numerici (00..59)
%j	Giorno dell'anno (001..366)
%k	Ore (0..23)
%l	Ore (1..12)
%M	Mese letterale esteso (Gennaio..Dicembre)
%m	Mese numerico (00..12)
%p	AM o PM
%r	Orario, 12-ore (hh:mm:ss seguito da AM o PM)
%S	Secondi (00..59)
%s	Secondi (00..59)
%T	Orario, 24-ore (hh:mm:ss)
%U	Settimana (00..53), con Domenica primo giorno ==> WEEK() modo 0
%u	Settimana (00..53), con Lunedì primo giorno ==> WEEK() modo 1
%V	Settimana (01..53), con Domenica primo giorno ==> WEEK() modo 2
%v	Settimana (01..53), con Lunedì primo giorno ==> WEEK() modo 3
%W	Giorno della settimana testuale esteso (Domenica..Sabato)
%w	Giorno della settimana numerico (0=Domenica..6=Sabato)
%X	Anno come parametro della settimana, numerico, 4 caratteri; usato con %V
%x	Anno come parametro della settimana, numerico, 4 caratteri; usato con %v
%Y	Anno, numerico, 4 caratteri
%y	Anno, numerico, 2 caratteri
%%	Il carattere %

    SELECT DATE_FORMAT('2009-10-04 22:23:00', '%W %M %Y') AS c1,
        DATE_FORMAT('2007-10-04 22:23:00', '%H:%i:%s') AS c2, 
        DATE_FORMAT('1900-10-04 22:23:00', '%D %y %a %d %m %b %j') AS c3,
        DATE_FORMAT('1997-10-04 22:23:00', '%H %k %I %r %T %S %w') AS c4, 
        DATE_FORMAT('1999-01-01', '%X %V') AS c5, 
        DATE_FORMAT('2006-06-00', '%d') AS c6;

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/cbae7dd8-60e0-43f9-b017-df1f26e80b75)

---------------------------------------

## Funzioni su testi

        SELECT 
            ASCII('dx') AS c1, -- codice ascii del primo carattere da sinistra del parametro
            LENGTH('città') AS c2, -- lunghezza in byte 
            CHAR_LENGTH('città') AS c3, -- lunghezza in caratteri
            CONCAT('My', 'S', 'QL') AS c4, -- concatenamento
            'My' 'S' 'QL' AS c5, -- concatenamento di testi quotati
            CONCAT_WS(',','Nome','Cognome','Telefono') AS c6, -- concatenamento con ',' come separatore
            ELT(4, 'Aa', 'Bb', 'Cc', 'Dd') AS c7, -- estrae il quarto elemento dall'elenco (NULL se l'indice è inferiore a 1 o superiore agli elementi)
            FIELD('Bb', 'Aa', 'Bb', 'Cc', 'Dd', 'Ff') AS c8, -- restituisce l'indice (base 1) della posizione di Bb nell'elenco seguente (0 se assente, NULL con nulli presenti)
            FIND_IN_SET('b','a,b,c,d') AS c9, -- restituisce l'indice (base 1) della posizione di b in una stringa con separatori
            INSERT('Quadratic', 3, 6, 'What') AS c10, -- inserisce What in terza posizione sostituendo 6 caratteri
            INSTR('foobarbar', 'bar') AS c11, -- trova la posizione della prima occorrenza di bar (0 se non presente)
            LCASE('TESTO') AS c12, -- converte il testo in minuscolo
            LOWER('TESTO') AS c13, -- converte il testo in minuscolo
            LEFT('foobarbar', 5) AS c14, -- estrae i primi 5 caratteri
            LOCATE('bar', 'foobarbar') AS c15, -- trova la posizione della prima occorrenza di bar (0 se non presente)
            LPAD('hi',4,'??') AS c16, -- porta il testo "hi" a 4 caratteri di lunghezza, eventualmente riempiendo a sinistra con "??"
            LTRIM('  barbar') AS c17, -- elimina gli spazi iniziali a sinistra
            REPEAT('MySQL', 3) AS c18, -- ripete il testo 3 volte
            REPLACE('www.mysql.com', 'w', 'Ww') AS c19, -- sostituisce ogni occorrenza di w con Ww
            REVERSE('abc') AS c20, -- inverte il testo
            RIGHT('foobarbar', 4) AS c21, -- estrae i primi 4 caratteri da destra
            RPAD('hi',5,'?') AS c22, -- porta il testo "hi" a 5 caratteri di lunghezza, eventualmente riempiendo a destra con "??"
            RTRIM('barbar   ') AS c23, -- elimina gli spazi iniziali a destra
            SPACE(6) AS c24, -- restituisce una stringa di 6 spazi
            SUBSTRING('Quadratically',5) AS c25a, -- estrae tutto dal 5 carattere in poi
            SUBSTRING('Quadratically',5,6) AS c25b, -- estrae 6 caratteri dal 5 carattere in poi
            SUBSTRING('Sakila', -3) AS c25c, -- estrae gli ultimi 3 caratteri
            SUBSTRING('Sakila', -5, 3) AS c25d, -- estrae 3 caratteri dal 5 carattere contando da destra
            TRIM('  bar   ') AS c26, -- elimina gli spazi iniziali a destra e sinistra 
            UCASE('testo') AS c27, -- converte il testo in maiuscolo
            UPPER('testo') AS c28 -- converte il testo in maiuscolo
            ;

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/625ed927-c28f-4858-bb81-35e14224cd93)

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/fa5ff058-65f8-4355-b91f-c4ee55146142)

Esistono anche altre funzioni per la gestione dei testi per le quali si rimanda alla documentazione ufficiale.


### Espressioni regolari

        SELECT 
            'Michael!' REGEXP '.*' AS c1, -- vero se il pattern corrisponde
            REGEXP_INSTR('dog cat dog', 'dog') AS c2, -- posizione della prima occorrenza di dog
            REGEXP_INSTR('dog cat dog', 'dog', 2) AS c3, -- posizione della seconda occorrenza di dog
            REGEXP_INSTR('aa aaa aaaa', 'a{4}') AS c4, -- posizione della prima occorrenza del pattern ("aaaa")
            REGEXP_LIKE('CamelCase', 'CAMELCASE') AS c5, -- vero se il pattern corrisponde
            REGEXP_LIKE('CamelCase', 'CAMELCASE', 'c') AS c6, -- vero se il pattern corrisponde 
            -- c: Case-sensitive matching
            -- i: Case-insensitive matching
            -- m: Multiple-line mode
            -- n: Il "." è il termine della linea
            -- u: Unix-only line endings
            REGEXP_REPLACE('a b c', 'b', 'X') AS c7, -- sostituisce b con X
            REGEXP_REPLACE('abc def ghi jkl', '[a-z]+', 'X', 1, 3) AS c8, -- sostituisce con X una sequenza di lettere minuscole a partire dalla terza
            REGEXP_SUBSTR('abc def ghi', '[a-z]+') AS c9, -- estrae la pima sequenza di lettere minuscole
            REGEXP_SUBSTR('abc def ghi jkl', '[a-z]+', 1, 3) AS c10 -- estrae la pima sequenza di lettere minuscole partendo dalla terza
        ;

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/1d428c1b-d2a8-49f8-87fc-229e741974e2)

Segue un prospetto delle combinazioni di caratteri speciali usabili nel pattern (i valori sono combinabili).

- ^	Inizio testo/riga
- $	Fine testo/riga
- \*	Zero o più occorrenze
- \+	Una o più occorrenze
- ?	Zero o una occorrenza
- |	Valori alternativi
- []	Uno tra i singoli valori racchiusi. Range impostabile collegando due valori con -
- [^ ]	Nessuno tra i singoli valori racchiusi
- ( )	Per raggruppare una espressione
- [: :]	Classe di caratteri (v. elenco a seguire)
- {m}	Numero di occorrenza dell’elemento che precede
- {m,}	Numero minimo di occorrenza dell’elemento che precede
- {m,n}	Numero di occorrenza compreso tra m e n dell’elemento che precede

Dettaglio delle principali classi di caratteri:
- [:alnum:] Tutti caratteri alfanumerici
- [:alpha:] Tutti caratteri alfabetici
- [:blank:] Tutti caratteri vuoti
- [:cntrl:] Tutti caratteri di controllo (non stampati)
- [:digit:] Tutti caratteri numerici
- [:graph:] Tutti i caratteri compresi in [:punct:], [:upper:], [:lower:] e [:digit:]
- [:lower:] Tutti i caratteri alfabetici minuscoli 
- [:print:] Tutti i caratteri stampabili 
- [:punct:] Tutti i caratteri non stampabili 
- [:space:] Tutti spazi 
- [:upper:] Tutti i caratteri alfabetici maiuscoli
- [:xdigit:] Tutti i caratteri esadecimali

Segue il prospetto relativo al parametro utilizzato per indicare la case sensitivity:
- 'c'	Case sensitive
- 'i'	NON Case sensitive
- 'n'	Abilita l’identificazione della nuova linea con il carattere “.”
- 'm'	L’espressione è multilinea e i caratteri ^ e $ si riferiscono ad ogni linea.
- 'x'	I blank sono ignorati

---------------------------------------

## Funzioni di conversione

La funzione CAST permette di convertire secondo la seguente scrittura: CAST( <valore> AS <tipo_dato>)
Siccome MySql interpreta il dato, a volte conviene specificare il formato iniziale del valore, come nell'elsempio seguente.
La funzione CONVERT invece può avere due forme per i parametri: (<espressione> USING <nome_collezione>) o (<espressione>, <tipo_dato>)


    SELECT 
        CAST("11:35:00" AS YEAR) AS c1, -- errata interpretazione di 11
        CAST(TIME '11:35:00' AS YEAR) AS c2, -- specifica del formato dell'orario
        CONVERT('test' USING utf8mb4) COLLATE utf8mb4_bin AS c3, -- prima forma di trascodifica
        CONVERT('test', CHAR CHARACTER SET utf8mb4) COLLATE utf8mb4_bin AS c4, -- seconda forma di trascodifica
        CAST('test' AS CHAR CHARACTER SET utf8mb4) COLLATE utf8mb4_bin AS c5 -- trascodifica con CAST
        ;

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/222f4658-1188-4901-a6a9-8785fe691563)


---------------------------------------

## Funzioni per dati XML

Le funzioni utili per la gestione dell'XML utilizzano le funzionalità di xPath, la cui sèiegazione esula da questa trattazione. 

        SET @xml = '<a><b>X</b><b>Y</b></a>', @i =1, @j = 2;
        
        SELECT 
            ExtractValue(@xml, '//b[$@i]') AS c1, -- valore dell'occorrenza i del tag b
            ExtractValue(@xml, '//b[$@j]') AS c2, -- valore dell'occorrenza j del tag b
            ExtractValue(@xml, '//b[$@k]') AS c3, -- valore dell'occorrenza inesistente del tag b (NULL)
            ExtractValue(@xml, '/a/b') AS c4, -- elenco dei valori dell'occorrenza "a dentro b"
            ExtractValue(@xml, 'count(/a/b)') AS c5, -- conteggio dei valori dell'occorrenza "a dentro b"
            UpdateXML(@xml, '/a', '<e>fff</e>') AS c6, -- una occorrenza, sostituisce tutto
            UpdateXML(@xml, '/b', '<e>fff</e>') AS c7, -- nessuna occorrenza, non sostituisce
            UpdateXML(@xml, '//b', '<e>fff</e>') AS c8, -- occorrenza multiple, non sostituisce
            UpdateXML(@xml, '//c', '<e>fff</e>') AS c9, -- occorrenza singola, sostituisce localmente 
            UpdateXML(@xml, '/a/d', '<e>fff</e>') AS c10 -- occorrenza singola vuota, sostituisce localmente 
        ;

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/15d540af-ab8f-452c-a162-a71d07d93abb)

---------------------------------------

## Funzioni di compressione e crittatura

Per le altre funzioni della categoria si rimanda alla documentazione ufficiale.

        SELECT 
            LENGTH(COMPRESS(REPEAT('a',1000))) AS c1, -- compressione
            UNCOMPRESS(COMPRESS('any string')) AS c2, -- decompressione
            MD5('testing') AS c3, -- crittatura MD5
            SHA1('abc') AS c4, -- crittatura SHA1
            SHA2('abc', 224) AS c5 -- crittatura SHA2 (modalità 224, 256, 384, 512)
        ;

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/f12b284b-3450-4b14-915e-c82ecde8be1e)

---------------------------------------

## Funzioni informative

Per le altre funzioni della categoria si rimanda alla documentazione ufficiale.

        SELECT 
            CONNECTION_ID() AS c1, -- thread ID di connessione;
            CURRENT_ROLE() AS c2, -- i ruoli attualmente assegnati all'utente;
            CURRENT_USER() AS c3, -- una combinazione di username e host
            DATABASE() AS c4, -- il database corrente
            LAST_INSERT_ID() AS c5, -- l'ultimo ID riga calcolato
            ROW_COUNT() AS c6, -- il numero di righe processate nell'ultima DML
            SCHEMA() AS c7, -- è un sinonimo di DATABASE()
            USER() AS c8, -- l'utente collegato (anche SESSION_USER() e SYSTEM_USER())
            VERSION() AS c9 -- la versione di MySql
            ;

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/3e277aea-7571-4e74-bbec-57a091aa6791)

---------------------------------------




