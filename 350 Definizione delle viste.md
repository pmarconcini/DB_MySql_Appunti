# Definizione delle viste

## Creazione di una vista

Una vista è un oggetto che permette di visualizzare dati (o elaborazioni di dati) di una o più tabelle; ad essere salvata è la definizione della struttura (quindi il testo della query) e non i dati, che quindi saranno sempre quelli correnti e non quelli del momento della creazione.
E' possibile utilizzare qualsiasi forma di query accettata da MySql, secondo le regole viste nel capitolo dedicato al DQL.
Eventuali modifiche alla struttura delle tabelle e/o colonne utilizzate nella vista potrebbero portare all'invalidamento della stessa.
Se tutti i campi della chiave primaria di una tabella sono selezionati nel loro valore originale dalla vista è possibile utilizzare le DML sulla vista stessa.
Tutte le colonne indicate nella clausola SELECT della query devono avere un alias univoco a livello di istruzione: questo significa che è necessario specificare l'alias per tutte le espressioni e per tutti i campi presenti in più tabelle coinvolte ed estratti (c.d. "disambiguazione").

L'istruzione è la seguente:

    CREATE OR REPLACE] [DEFINER = <nome_utente>] [SQL SECURITY    DEFINER | INVOKER ]
        VIEW <nome_vista> [(<elenco_delle_colonne)]
        AS <query>;

Gli attributi DEFINER e SQL SECURITY permettono di stabilire il tipo di verifica dei privilegi al momento dell'utilizzo; se non specificato, il DEFINER è l'utente che ha creato la vista.
Per creare una vista è necessario possedere il privilegio CREATE VIEW e i privilegi sulle singole tabelle interessate (o, con l'attributo DEFINER), li deve possedere l'utente indicato.
Per la sostituzione della vista (OR REPLACE) è necessario avere anche il pivilegio DROP VIEW.
L' elenco delle colonne è una alternativa allo specificare tutti gli alias di colonna nella clausola SELECT

Esistono alcune restrizioni:
- la query della vista non può fare riferimento a variabili di sistema o user-defined .
- ogni tabella referenziata deve esistere
- non è possibile referenziare tabelle temporanee
- non è possibile associare triggeers alla vista
- gli alias di colonna possono avere una lunghezza massima di 64 caratteri ognuno
- è possibile definire la clausola ORDER BY, che è però ignorata se specificata anche nella select che punta alla vista


## Modifica di una vista

E' possibile variare gli attributi di una vista utilizzando l'istruzione ALTER, ma è sempre necessario riproporre la query: in sostanza l'utilizzo di ALTER è equiparabile all'uso della istruzione OR REPLACE vista nella creazione.
Logica e significati degli attributi e privilegi necessari sono i medesimi già descritti in precedenza.

L'istruzione è la seguente:

    ALTER [DEFINER = user] [SQL SECURITY   DEFINER | INVOKER ]    
    	VIEW <nome_vista> [(<elenco_colonne>)]
        AS <query>;

## Eliminazione di una vista

E' necessario che l'utente abbia il privilegio DROP VIEW.

L'istruzione è la seguente:

    DROP VIEW [IF EXISTS] <elenco_viste>;
    


