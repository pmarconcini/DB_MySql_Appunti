# Definizione delle tabelle

## Creazione di una tabella
Per creare una tabella è necessario avere il privilegio CREATE sul database di destinazione.
Una tabella temporanea (attributo TEMPORARY) è automaticamente eliminata al termine della sessione.

L'istruzione standard è la seguente:

    CREATE [TEMPORARY] TABLE [IF NOT EXISTS] <nome_tabella>
        (<elenco_definizioni_di_colonna>
    	[, <elenco_definizione_degli_indici>]
    	)
    	[, <elenco_opzioni_di_tabella>]
        [, <regole_di_partizionamento>]


La definizione di colonna standard, contenente i riferimenti più comuni, è la seguente:

    <nome_colonna> <tipo_dato> 
    	[NOT NULL | NULL] 
    	[DEFAULT <valore> | <funzione>] 
    	[VISIBLE | INVISIBLE] 
    	[AUTO_INCREMENT] 
    	[UNIQUE [KEY]] 
    	[[PRIMARY] KEY] 
    	[COMMENT 'testo'] 
    	[COLLATE <nome_collation>] 
    	[CHECK <espressione>] 
    	[REFERENCES <nome_tabella_2> (<nome_colonna_2>) [ON DELETE RESTRICT | CASCADE | SET NULL | NO ACTION | SET DEFAULT] [ON UPDATE RESTRICT | CASCADE | SET NULL | NO ACTION | SET DEFAULT] 
    	[,]

Le definizioni di colonna sono separatre tra loro da una virgola e ognuna è costituita da:
- un nome unico a livello di tabella e non coincidente con una parola chiave
- un tipo di dato tra quelli previsti in MySql è descritti nell'apposito capitolo
- zero o più attributi tra i seguenti:
	- Nonnullità: NOT NULL | NULL > Campo obbligatorio o opzionale; default NULL.
	- Valore predefinito: [DEFAULT <valore> | <funzione>] > Valore impostato se non è specificato un valore in fase di inserimento
	- Visibilità: [VISIBLE | INVISIBLE] > Visibilità della colonna; defaul VISIBLE.
	- Contatore: [AUTO_INCREMENT] > Colonna ad incremento automatico; deve essere di tipo numerico e deve far parte della chiave primaria
	- Unicità: [UNIQUE [KEY]] > Colonna che non ammette ripetizione dei valori
	- Chiave primaria: [[PRIMARY] KEY] > Colonna che costituisce la chiave primaria (da sola)
	- Commento:  [COMMENT 'testo'] > Descrizione della colonna
	- Collation specifica: [COLLATE <nome_collation>] > Collation considerata (in deroga all'impostazione di tabella o database)
	- Check constraint: CHECK <espressione> > Validazione del dato in fase di aggiornamento (dato validato se l'espressione è vera)
	- Foreign key: [REFERENCES <nome_tabella_2> (<nome_colonna_2>) [ON DELETE RESTRICT | CASCADE | SET NULL | NO ACTION | SET DEFAULT] [ON UPDATE RESTRICT | CASCADE | SET NULL | NO ACTION | SET DEFAULT] > Colonna che costituisce la foreign key riferendosi alla colonna e alla tabella specificate, seguento gli eventuali criteri di comportamento in caso di eliminazione o aggiornamento del dato referenziato (blocco, aggiornamento, annullamento, impostazione del default)
- unicità, chiave primaria e foreign key implicano la creazione automatica di un indice ed è preferibile gestire tali caratteristiche al termine delle definizioni di colonna o con istruzioni ad hoc di modifica della tabella o di creazione dell'indice. Nel caso in cui il vincolo coinvolga 2 o più colonne questa gestione "posticipata" diviente obbligatoria (questo considerazione vale anche per i Check constraints).
- nel caso in cui l'attributo indichi un vincolo è possibile nominarlo in maniera specifica tramite la scrittura CONSTRAINT <nome_vincolo> <attributo>

L'elenco di definizione degli indici (e dei check constraint su più colonne) permette di definire le caratteristiche di:
- Chiave primaria (implica un indice che garantisce l'unicità e la nonnullità dell'inisieme delle colonne): 
	- PRIMARY KEY <nome_constraint> (<elenco_campi)
	- CONSTRAINT PRIMARY KEY <nome_constraint> (<elenco_campi)
	- CONSTRAINT <nome_constraint> PRIMARY KEY (<elenco_campi)
- Foreign key (NB: attualmente un baco rende NON funzionante una FK definita nella creazione della tabella): 
	- CONSTRAINT FOREIGN KEY <nome_constraint> (<elenco_campi) REFERENCES <tabella_referenziata> (<elenco_campi_referenziati)
	- CONSTRAINT <nome_constraint> FOREIGN KEY (<elenco_campi) REFERENCES <tabella_referenziata> (<elenco_campi_referenziati)
	- CONSTRAINT FOREIGN KEY <nome_constraint> (<elenco_campi) REFERENCES <tabella_referenziata> (<elenco_campi_referenziati)
- Unicità:
	- UNIQUE INDEX | KEY <nome_constraint> (<elenco_campi)
	- CONSTRAINT UNIQUE INDEX | KEY  <nome_constraint> (<elenco_campi)
	- CONSTRAINT <nome_constraint> UNIQUE INDEX | KEY (<elenco_campi)
- Indice standard (finalizzato solo alla ricerca):
	- INDEX | KEY <nome_constraint> [USING  BTREE | HASH] (<elenco_campi)
- Check constraint:
	- CONSTRAINT <nome_constraint> CHECK <espressione>
	
Le opzioni di tabella più frequentemente utilizzate sono:
- Incremento del contatore: AUTO_INCREMENT [=] <valore>
- Charset: [DEFAULT] CHARACTER SET [=] <nome_charset>
- Collation: [DEFAULT] COLLATE [=] <nome_collation>
- Descrizione: COMMENT [=] 'testo'
- Motore: ENGINE [=] <nome_engine>


### Creazione di una tabella tramite query

E' possibile anche creare una tabella ricavando le definizioni di colonna direttamente da una query e popolanda coi relativi dati:

    CREATE [TEMPORARY] TABLE [IF NOT EXISTS] <nome_tabella>
        [(create_definition,...)]
        [table_options]
        [partition_options]
        [IGNORE | REPLACE]
        [AS] query_expression


### Creazione di una tabella da tabella

Infine è possibile creare una tabella ricavando le definizioni di colonna e gli indici direttamente da una tabella già esistente:

    CREATE [TEMPORARY] TABLE [IF NOT EXISTS] <nome_tabella>
        { LIKE old_tbl_name | (LIKE old_tbl_name) }

Il nome della tabella non può essere una parola chiave e deve essere unico a livello di database. Può coincidere con il nome usato per oggetti di tipo diverso (escluse le viste) ma è una pratica assolutamente da evitare.
Come impostazione predefinita la tabella è creata con motore InnoDB sul database predefinito, quindi per necessità diverse è richiesto specificare l'utilizzo di altro motore e/o collegarsi preventivamente al database di destinazione con l'istruzione USE <nome_database>


## Partizionamento della tabella

Il partizionamento di una tabella può essere utile in caso di presenza di una grande quantità di dati facilmente categorizzabili (per anno di riferimento per esempio) e fruiti filtrando proprio secondo tali categorie.
Le partizioni possono essere modificate, unite, aggiunte o eliminate da una tabella (o create contestualmente) e possono essere fino a 1024 (comprese le eventuali sottopartizioni).
Per un trattamento approfondito si rimanda alla documentazione ufficiale.

L'istruzione per definire le regole base di partizionamento è la seguente

    PARTITION BY
    	HASH(<espressione>) | KEY (<elenco_colonne>) | RANGE (<espressione>) |  LIST (<espressione>)
    [PARTITIONS n]
    [SUBPARTITION BY     HASH(<espressione>) | KEY (elenco_colonne>) 
      [SUBPARTITIONS n]
    ]
    [(<elenco_definizione_partizioni>)]

La modalità di partizionamento HASH implica un frazionamento del dato come criterio, KEY una suddivisione in n PARTITIONS in case alle combinazioni di dati dell'elenco delle coinvolte, RANGE una suddivisione per valore a fronte di una classificazione crescente o un elenco di valori.

Per ogni partizione è possibile definire degli attributi ed eventuali sottopartizioni secondo la seguente scrittura:

    PARTITION <nome_partizione>
        [VALUES
            LESS THAN (<espressione> | <valore>) | MAXVALUE 
			|
            IN (<valore>)]
        [[STORAGE] ENGINE [=] <nome_engine>]
        [COMMENT [=] 'testo' ]
        [<elenco_definizione_sottopartizioni]
		
A seguire alcuni esempi di partizionamento:		

    -- partizionamento HASH		
    CREATE TABLE t1 (col1 INT, col2 CHAR(5), col3 DATETIME)
        PARTITION BY HASH ( YEAR(col3) );
    
    -- partizionaento KEY con 4 partizioni
    CREATE TABLE t1 (col1 INT, col2 CHAR(5), col3 DATE)
        PARTITION BY KEY(col3)
        PARTITIONS 4;
    
    -- partizionamento RANGE con check valore
    CREATE TABLE t1 (
        year_col  INT,
        some_data INT
    )
    PARTITION BY RANGE (year_col) (
        PARTITION p0 VALUES LESS THAN (1991),
        PARTITION p1 VALUES LESS THAN (1995),
        PARTITION p2 VALUES LESS THAN (1999),
        PARTITION p3 VALUES LESS THAN (2002),
        PARTITION p4 VALUES LESS THAN (2006),
        PARTITION p5 VALUES LESS THAN MAXVALUE
    );
    
    -- partizionamento LIST con check valore
    CREATE TABLE t1 (
        id   INT,
        name VARCHAR(35)
    )
    PARTITION BY LIST (id) (
        PARTITION r0 VALUES IN (1, 5, 9, 13, 17, 21),
        PARTITION r1 VALUES IN (2, 6, 10, 14, 18, 22),
        PARTITION r2 VALUES IN (3, 7, 11, 15, 19, 23),
        PARTITION r3 VALUES IN (4, 8, 12, 16, 20, 24)
    );

