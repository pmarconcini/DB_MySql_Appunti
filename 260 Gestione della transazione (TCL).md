# Gestione della transazione (TCL)

MySQL, come impostazione predefinita, esegue l’autocommit (salvataggio automatico) della manipolazione dei dati; è una impostazione che può essere variata sia a livello globale che di sessione; all’atto pratico ciò significa che eventuali modifiche sono automaticamente "committate" (salvate) ed è necessario gestire la transazione esplicitamente per rendere le stesse “visibili” solo per la sessione in atto e mantenerle tali finché non verrà utilizzata l’istruzione di salvataggio o quella di annullamento (direttamente o per l’interruzione della sessione/elaborazione). 

L'istruzione per disattivare l'AUTOCOMMIT a livello di sessione è la seguente (per attivarla il valore da utilizzare è 1), mentre a livello globale è necessario intervenire a livello di configurazione e riavviare il server:

    SET AUTCOMMIT = 0;
    

Disabilitando l'autocommit, quindi, per gestire lo stato dei dati si deve necessariamente far uso delle seguenti istruzioni di controllo, che sono sempre seguite da “;”:

- COMMIT: memorizza le modifiche apportate ai dati dall’inizio della sessione o dall’ultima COMMIT eseguita; MySQL esegue comunque automaticamente la COMMIT in caso di elaborazioni di tipo DDL
- ROLLBACK: esegue l’annullamento delle modifiche apportate ai dati dall’inizio della sessione o dall’ultima COMMIT eseguita; è possibile eseguire un annullamento parziale facendo riferimento a un punto di salvataggio intermedio (ROLLBACK TO SAVEPOINT <<nome_savepoint>>). MySQL esegue automaticamente il ROLLBACK dell'intera transizione nel caso in cui termini la sessione.  
- SAVEPOINT: permette di creare un punto di ripristino intermedio dei dati (SAVEPOINT <<nome_savepoint>>); in caso di ripristino, sono automaticamente eliminati tutti i punti di ripristino temporalmente successivi.

Spesso viene utilizzata la sigla TCL (transaction control language) per identificare l’insieme delle istruzioni di gestione delle transazioni, ma nella documentazione storica di le istruzioni per la gestione delle transazioni facevano parte della categoria DCL (Data Control Language).
A prescindere dalle istruzioni DML, la manipolazione dei dati è soggetta alla verifica di tutti i vincoli imposti ai dati stessi (tipi di dato, integrità referenziale e vincoli di riga e/o tabella): una istruzione non accettabile in tal senso “stoppa” l’elaborazione esattamente in quel punto il che implica una eventuale correzione per ripartire o il ROLLBACK per il ripristino. TRUNCATE e DDL implicano il COMMIT della sessione corrente. Un errore non gestito implica il ROLLBACK e quindi il ritorno al momento dell’ultimo COMMIT;

Nell'esempio seguente è possibile valutare i vari comportamenti:

    SET autocommit = 0;
    truncate table prova;             -- > Table PROVA troncato.
    start transaction;                -- > Senza l'autocommit non è necessario perchè l'avvio della sessione, "commit;" e "rollback;" avviano automaticamente una nuova transazione
    insert into prova (n) values (1); -- > 1 riga inserito.
    insert into prova (n) values (2); -- > 1 riga inserito.
    savepoint step_1;                 -- > Creato savepoint.
    update prova set n = n*10;        -- > 2 righe aggiornato.
    rollback to savepoint step_1;     -- > Rollback completato.
    commit;                           -- > Commit completato.
    insert into prova (n) values (3); -- > 1 riga inserito.
    savepoint step_2;                 -- > Creato savepoint.
    insert into prova (n) values (4); -- > 1 riga inserito.
    rollback;                         -- > Rollback completato.
    select n from prova; 			  

==> ![image](https://github.com/pmarconcini/DB_MySql_Appunti/assets/82878995/36730372-ecf4-4cda-853e-def5e7dc64b8)


-----------------------------------
### SET TRANSACTION

In MySQL è possibile definire il comportamento della transazione sia a livello globale che a livello di sessione utilizzando il seguente template di script:

    SET [GLOBAL | SESSION] TRANSACTION { ISOLATION LEVEL level | access_mode }

E' necessario quindi specificare il livello di isolamento, che può assumere generalmente uno dei seguenti valori:

- REPEATABLE READ (impostazione di default) − in caso di lettura multipla è considerato lo snapshot del momento della prima esecuzione (variazioni di altri utenti non sno recepite anche se committate)
- READ COMMITTED − in caso di lettura multipla  è considerato l'ultimo dato committato in ogni esecuzione
- READ UNCOMMITTED − in caso di lettura multipla  è considerato l'ultimo dato anche non committato in ogni esecuzione


Per quanto riguarda la modalità di accesso al dato ("access_modes") i valori ammissibili sono:

- READ WRITE (default)
- READ ONLY

