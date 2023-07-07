# Definizione del database

In MySql il concetto di DATABASE e quello di SCHEMA coincidono, quindi il secondo termine è di fatto un sinonimo del primo.
Le impostazioni sono memorizzate nel data dictionary e non c'è un limite massimo ai database creabili, se non lo spazio fisico a livello di sistema operativo. 

## Creazione del database

L'istruzione di creazione è il seguente:

    CREATE  DATABASE | SCHEMA [IF NOT EXISTS] <nome_db>
     [DEFAULT] 
     [CHARACTER SET [=] <nome_charset> ] 
     [COLLATE [=] <nome_collation> ]
     [ENCRYPTION [=] 'Y' | 'N']
     ;

Character set e/o collation devono essere tra quelli installati e disponibili e, se omessi, assumono il valore di default del db server.
L'impostazione della crittografia dei dati, se omessa, assume il valore di default del db server.
L'istruzione DEFAULT imposta il database come predefinito tra quelli nel server.

## Modifica del database

L'istruzione di modifica del database permette di modificare le stesse impostazioni e di passare il database dalla modalità lettura e scrittura alla modalità sola lettura, come da esempio seguente:

    ALTER  DATABASE | SCHEMA  [ <nome_db> ]
     [[DEFAULT] CHARACTER SET [=] <nome_charset> ] 
     [[DEFAULT] COLLATE [=] <nome_collation> ]
     [[DEFAULT] ENCRYPTION [=] 'Y' | 'N']
     [READ ONLY [=] DEFAULT | 0 | 1 ]
     ;

Il privilegio necessario è ALTER sul database.
Se è omesso il nome del database la modifica è applicata al database predefinito.
Le impostazioni relative ai caratteri avranno un impatto solo sugli oggetti creati dopo la variazione.
L'opzione "read only" è stata integrata solo dalla versione 8.0.22 ed è utile soprattutto in caso di migrazione di dati tra database.

## Eliminazione del database

L'istruzione per eliminare un database è la seguente:

    DROP DATABASE | SCHEMA [IF EXISTS] <nome_db> ;

L'eliminazione di un database comporta l'eliinazione di tutti gli oggetti in esso memorizzati; per poter eliminare il database è necessarrio prima eliminare tutti i privilegi ad esso associati.
