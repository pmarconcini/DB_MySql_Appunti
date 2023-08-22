# Messaggi di errore e problemi comuni

-----------------------------------------------------
## MySQL Database (SQL)

-----------------------------------------------------
### Error Code: 1175 - SAFE UPDATE MODE

L'errore si verifica eseguendo UPDATE o DELETE senza che nella clausola WHERE siano specificati filri per i campi della chiave primaria:
Error Code: 1175. You are using safe update mode and you tried to update a table without a WHERE that uses a KEY column. 

==> Per disabilitare il Safe Update Mode si può utilizzare la seguente istruzione:

    SET SQL_SAFE_UPDATES = 0;

 
-----------------------------------------------------
## MySQL Workbench

-----------------------------------------------------
### Unable to restore workspace
Errore che si può verificare alla connessione a un database e che implica l'impossibilità di ricaricare le schede aperte al momento della chiusura, a causa di un problema durante la chiusura stessa.

![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/d3a231f1-a1e2-46b5-aaa0-8d924546084a)

==> La soluzione consiste nell'eliminare tutti i file e le cartelle presenti nella cartella di lavoro e riavviare MySQL Workbench:
C:\Users\<utente_si_sistema_attivo>\AppData\Roaming\MySQL\Workbench\sql_workspaces



