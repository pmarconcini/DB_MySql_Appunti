# Tipi di dati

-----------------------------------
## Dati numerici
Nella definizione di colonne e variabili è possibile specificare gli attributi ZEROFILL per indicare che il valore nullo deve essere convertito in 0 e UNSIGNED per escludere valori negativi.

Le due macro categorie disponibili sono:
- Numeri precisi interi:
	- BIT da i 1 64
	- TINYINT[(M)] da -128 a 127
	- BOOL (o BOOLEAN) 0 (falso) o 1 (vero)
	- SMALLINT[(M)] da -32768 a 32767. UNSIGNED da 0 a 65535.
	- MEDIUMINT[(M)] da -8388608 a 8388607. UNSIGNED da 0 a 16777215.
	- INTEGER[(M)] (o INT[(M)]) da -2147483648 a 2147483647. UNSIGNED da 0 to 4294967295.
	- BIGINT[(M)] da -9223372036854775808 a 9223372036854775807. UNSIGNED da 0 a 18446744073709551615.
- Numeri decimali a virgola fissa:
	- DECIMAL[(M[,D])] (o DEC o NUMERIC o FIXED) con massimo 65 cifre (M) di cui al massimo 30 decimali (D).
- Numeri decimali a virgola flottante (c.d. approssimati):
	- FLOAT[(M,D)] da -3.402823466E+38 a 3.402823466E+38. E' un tipo di dato deprecato.
	- DOUBLE[(M,D)] (o DOUBLE PRECISION o REAL) da -2.2250738585072014E-308 a 2.2250738585072014E-308 ma il limite reale è dato presumibilmente dalle componenti hardware. I decimali sono considerati affidabili fino ad un valore di 15 per D. E' un tipo di dato deprecato.

-----------------------------------

## Date e ore
Tutti i tipi di dato hanno un valore corrispondente allo "zero" che è utilizzato in caso di valore proposto non valido.

MySql cerca sempre di interpretare il dato atteso nel formato standard per la tipologia, ma cerca comunque eventualmente di interpretare il valore sencondo altri formati accettabili.
In presenza di date contenenti il riferimento all'anno con 2 caratteri compresi tra 70 e 90 si suppone che si intenda gli anni dal 1970 al 1999, mentre negli altri casi (00-69) si intende il range 2000-2069.

I tipi di dato utilizzabili per i valori temporali sono:
- DATE => formato 'yyyy-mm-dd', valori tra '1000-01-01' e '9999-12-31', zero: '00:00:00'
- TIME[(fsp)] => formato 'hh:mi:ss[.fsp decimali]', valori tra '-838:59:59.000000' e '838:59:59.000000', zero: '0000-00-00'
- DATETIME[(fsp)] => formato 'yyyy-mm-dd hh:mi:ss[.fsp decimali]', valori tra '1000-01-01 00:00:00.000000' e '9999-12-31 23:59:59.999999', zero: '0000-00-00 00:00:00'
- TIMESTAMP[(fsp)] => formato 'yyyy-mm-dd hh:mi:ss[.fsp decimali]', valori tra '1970-01-01 00:00:01.000000' e '2038-01-19 03:14:07.999999', zero: '0000-00-00 00:00:00'
- YEAR => formato 'yyyy', valori tra 1901 e 2155, zero: '0000'

fsp: fractional second precision


## Peculiarità di DATETIME e TIMESTAMP

Come da esempio seguente, nella definizione di una colonna è possibile specificare:
- che il valore predefinito, se non specificato, non segue la regola standard, tramite attributo NULL o NOT NULL
- che ha un valore predefinito con l'attributo DEFAULT valorizzato a 0, CURRENT_TIMESTAMP o un timestamp specifico
- che deve essere aggiornato automaticamente in caso di update della riga tramite l'attributo ON UPDATE CURRENT_TIMESTAMP
	
		CREATE TABLE t1 (
			ts1 TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,      -- default CURRENT_TIMESTAMP
			ts2 TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,                                -- default 0
			ts3 TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,                           -- default NULL
			ts4 TIMESTAMP,                                                            -- default 0, non aggiornato con update
			dt1 DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,       -- default CURRENT_TIMESTAMP
			dt2 DATETIME ON UPDATE CURRENT_TIMESTAMP,                                 -- default NULL
			dt3 DATETIME NOT NULL ON UPDATE CURRENT_TIMESTAMP,                        -- default 0
			dt4 DATETIME,                                                             -- default NULL, non aggiornato con update
		);


-----------------------------------
## Formati testuali

I tipi di dato utilizzabili per il testo sono i seguenti:
- CHAR[(n)] > testo a dimensione fissa di n caratteri; la dimensione massima è 255 caratteri e, se omessa, la dimensione è 1
- VARCHAR(n) > testo a dimensione variabile fino a n caratteri; la dimensione massima è 65535 caratteri
- BINARY[(n)] > testo a dimensione fissa di n byte; la dimensione massima è 255 byte e, se omessa, la dimensione è 1
- VARBINARY(n) > testo a dimensione variabile fino a n byte; la dimensione massima è 65535 byte
- TINYBLOB > testo a dimensione variabile fino a circa 255 byte 
- TINYTEXT > testo a dimensione variabile fino a circa 255 caratteri
- BLOB(n) > testo a dimensione variabile fino a n byte; la dimensione massima è 65535 byte
- TEXT(n) > testo a dimensione variabile fino a n caratteri; la dimensione massima è 65535 caratteri
- MEDIUMBLOB(n) > testo a dimensione variabile fino a n byte; la dimensione massima è 16777215 byte
- MEDIUMTEXT(n) > testo a dimensione variabile fino a n caratteri; la dimensione massima è 16777215 caratteri
- LONGBLOB(n) > testo a dimensione variabile fino a n byte; la dimensione massima è 4294967295 byte (4 GB)
- LONGTEXT(n) > testo a dimensione variabile fino a n caratteri; la dimensione massima è 4294967295 caratteri (4 GB)
- ENUM('val1', 'val2', ...) > valore specifico dell'elenco; gli elementi possono essere al massimo 65535, con singolo peso di 255 caratteri o 1020 byte massimi
- SET('val1', 'val2', ...) > valore specifico dell'elenco; gli elementi possono essere al massimo 64, con singolo peso di 255 caratteri o 1020 byte massimi

NB: la dimensione specificata si intende in caratteri per CHAR, VARCHAR e TEXT e in byte per BINARY, VARBINARY e BLOB.

Nella definizione di colonne di tipo CHAR, VARCHAR, TEXT, ENUM e SET (e sinonimi) è possibile specificare anche un charset e/o una collation di riferimento.


-----------------------------------
## AUTO_INCREMENT
  AUTO_INCREMENT è un attributo di colonna utilizzabile per generare un identificativo numerico unico incrementale per ogni nuovo record di una tabella. 
  Il comportamento varia a seconda del motore utilizzato per la specifica colonna.
  
  Con *motore INNO_DB* l'identificativo è unico a livello di tabella e la colonna DEVE essere la prima della chiave primaria.
  L'intero proposto è, come impostazione predefinita, quello successivo al massimo presente in tabella.
  E' possibile passare in maniera esplicita un valore per la colonna e, nel caso in cui siano proposti il valore 0 o il valore NULL, MySql genera comunque un nuovo ID autoincrementato.
  NB: nel caso in cui sia abilitata la modalità NO_AUTO_VALUE_ON_ZERO è mantenuto un eventuale 0 proposto.

    DROP TABLE IF EXISTS animals;

    CREATE TABLE animals (
    id MEDIUMINT NOT NULL AUTO_INCREMENT,
    name CHAR(30) NOT NULL,
    primary key (id)
    );

    INSERT INTO animals (name) VALUES
    ('dog'),('cat'),('penguin'),
    ('lax'),('whale'),('ostrich');
    INSERT INTO animals (id,name) VALUES(0,'groundhog');
    INSERT INTO animals (id,name) VALUES(NULL,'squirrel');
    INSERT INTO animals (id,name) VALUES(100,'rabbit');
    INSERT INTO animals (id,name) VALUES(NULL,'mouse');
    INSERT INTO animals (name) VALUES ('bull');

    SELECT * FROM animals;

  ==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/c5868d89-4eda-4b94-9422-26730757ef29)

  Nell'esempio seguente il penultimo inserimento produce l'ID 101 poichè l'autoincremento è sempre rispetto al massimo valore in tabella.
  E' possibile comunque indicare un valore di partenza tramite l'istruzione seguente:

      ALTER TABLE <tabella> AUTO_INCREMENT = <valore iniziale>;

  E' possibile sapere l'ultimo ID prodotto nella sessione corrente tramite la funzioen LAST_INSERT_ID(). 
    Attenzione! In caso di inserimento multiplo il dato restituito è l'ID del primo record inserito, non dell'ultimo. 

  E' preferibile utilizzare il tipo di dato numerico minimo sufficiente per la quantità di record prevista, specificando l'attributo UNSIGNED per ridurre lo spazio utilizzato. 


  Con *motore MyISAM* la colonna autoincrementata NON deve necessariamente essere la prima della chiave primaria e l'incremento è relativo al gruppo di colonne che la precedono nella definizione della chiave stessa.
  
    DROP TABLE IF EXISTS animals;

    CREATE TABLE animals (
    grp ENUM('fish','mammal','bird') NOT NULL,
    id MEDIUMINT NOT NULL AUTO_INCREMENT,
    name CHAR(30) NOT NULL,
    PRIMARY KEY (grp,id)
    ) ENGINE=MyISAM;

    INSERT INTO animals (grp,name) VALUES
    ('mammal','dog'),('mammal','cat'),
    ('bird','penguin'),('fish','lax'),('mammal','whale'),
    ('bird','ostrich');

    SELECT * FROM animals ORDER BY grp,id;
    Which returns:

  ==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/827e3bc3-55a0-4459-8742-ff814d3e7695)

