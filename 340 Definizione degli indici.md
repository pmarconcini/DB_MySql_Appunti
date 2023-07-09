# Definizione degli indici

## Creazione di un indice

Un indice è un oggetto memorizzato nel database che permette di ottiizzare la ricerca o la validazione (l'unicità in particolare) dei dati di una tabella.
La creazione può essere esplicita, tramite apposito script, o implicita, tramite gestione automatica del sistema quando vendono definite delle chiavi primarie e/o dei campi con vincolo di unicità.

Per una trattazione più completa dell'argomento si rimanda alla documentazione ufficiale.


L'istruzione di creazione è la seguente:

    CREATE [UNIQUE | FULLTEXT | SPATIAL] INDEX <nome_indice>
        ON <nome_tabella> (<elenco_campi_o_espressioni>);

Per ogni campo, porzione di campo o espressione utilizzato nell'indice è possibile stabilire l'ordinamento con le parole chiave ASC (predefinito) o DESC.
La parola chiave UNIQUE indica che l'indice è finalizzato alla verifica che l'insieme dei valori dell'elenco campi/espressioni sia unico a livello di tabella.

SPATIAL e FULLTEXT sono due indici speciali destinati all'utilizzo con colonne di riferimento geografico e con colonne di testo.

Per la creazione di una chiave primaria è preferibile l'utilizzo dell'istruzione ALTER TABLE (...).


## Modifica di un indice

Non esiste una istruzione per modificare un indice, che va quindi eliminato e ricreato.


## Eliminazione di un indice

L'istruzione per eliminare un indice è la seguente:

    DROP INDEX <nome_indice> ON <nome_tabella>;

Nel caso in cui si voglia eliminare la chiave primaria si può utilizzare l'istruzione ALTER TABLE o la seguente istruzione:

    DROP INDEX `PRIMARY` ON <nome_tabella>;
	



