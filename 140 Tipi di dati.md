# Tipi di dati
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

