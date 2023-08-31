# Messaggi di errore e problemi comuni

-----------------------------------------------------
## MySQL Database (SQL)

-----------------------------------------------------
### Criteri generali

Il messaggio di errore può essere generato lato client o lato server.
In caso di errore lato server, lo stesso scrive informazioni in vari sistemi di logging disponibili per i DBA e manda una notifica di errore all'eventuale client che ha fatto la richiesta.
In caso di errore lato client la notifica è ovviamente diretta.

Gli elementi che costituiscono la notifica di un errore sono:
- un Error code: valore numerico, in un elenco specifico di MySQL; ogni valore ha un corrispondente valore simbolico identificativo (a.e. per 1146 è ER_NO_SUCH_TABLE)
- il valore di SQLSTATE
- un testo descrittivo
  



***********************************************


The set of error codes used in error messages is partitioned into distinct ranges; see Error Code Ranges.

Error codes are stable across General Availability (GA) releases of a given MySQL series. Before a series reaches GA status, new codes may still be under development and are subject to change.

SQLSTATE value: This value is a five-character string (for example, '42S02'). SQLSTATE values are taken from ANSI SQL and ODBC and are more standardized than the numeric error codes. The first two characters of an SQLSTATE value indicate the error class:

Class = '00' indicates success.

Class = '01' indicates a warning.

Class = '02' indicates “not found.” This is relevant within the context of cursors and is used to control what happens when a cursor reaches the end of a data set. This condition also occurs for SELECT ... INTO var_list statements that retrieve no rows.

Class > '02' indicates an exception.

For server-side errors, not all MySQL error numbers have corresponding SQLSTATE values. In these cases, 'HY000' (general error) is used.

For client-side errors, the SQLSTATE value is always 'HY000' (general error), so it is not meaningful for distinguishing one client error from another.

Message string: This string provides a textual description of the error.

Error Code Ranges
The set of error codes used in error messages is partitioned into distinct ranges, each with its own purpose:

1 to 999: Global error codes. This error code range is called “global” because it is a shared range that is used by the server as well as by clients.

When an error in this range originates on the server side, the server writes it to the error log, padding the error code with leading zeros to six digits and adding a prefix of MY-.

When an error in this range originates on the client side, the client library makes it available to the client program with no zero-padding or prefix.

1,000 to 1,999: Server error codes reserved for messages sent to clients.

2,000 to 2,999: Client error codes reserved for use by the client library.

3,000 to 4,999: Server error codes reserved for messages sent to clients.

5,000 to 5,999: Error codes reserved for use by X Plugin for messages sent to clients.

10,000 to 49,999: Server error codes reserved for messages to be written to the error log (not sent to clients).

When an error in this range occurs, the server writes it to the error log, padding the error code with leading zeros to six digits and adding a prefix of MY-.

50,000 to 51,999: Error codes reserved for use by third parties.

The server handles error messages written to the error log differently from error messages sent to clients:

When the server writes a message to the error log, it pads the error code with leading zeros to six digits and adds a prefix of MY- (examples: MY-000022, MY-010048).

When the server sends a message to a client program, it adds no zero-padding or prefix to the error code (examples: 1036, 3013).











**********************************************


-----------------------------------------------------
### Error Code: 1175 - SAFE UPDATE MODE

L'errore si verifica eseguendo UPDATE o DELETE senza che nella clausola WHERE siano specificati filri per i campi della chiave primaria:
Error Code: 1175. You are using safe update mode and you tried to update a table without a WHERE that uses a KEY column. 

==> Per disabilitare il Safe Update Mode si può utilizzare la seguente istruzione:

    SET SQL_SAFE_UPDATES = 0;

==> Per abilitare il Safe Update Mode si può utilizzare la seguente istruzione:

    SET SQL_SAFE_UPDATES = 1;

 
-----------------------------------------------------
## MySQL Workbench

-----------------------------------------------------
### Unable to restore workspace
Errore che si può verificare alla connessione a un database e che implica l'impossibilità di ricaricare le schede aperte al momento della chiusura, a causa di un problema durante la chiusura stessa.

![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/d3a231f1-a1e2-46b5-aaa0-8d924546084a)

==> La soluzione consiste nell'eliminare tutti i file e le cartelle presenti nella cartella di lavoro e riavviare MySQL Workbench:
C:\Users\<utente_si_sistema_attivo>\AppData\Roaming\MySQL\Workbench\sql_workspaces



