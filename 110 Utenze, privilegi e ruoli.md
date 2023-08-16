# Utenze, privilegi e ruoli

MySql è organizzato in modo tale che possano essere creati più utenti e che ad essi possano essere associati dei privilegi singolarmente o a gruppi tramite i ruoli. 
Le istruzioni per gestire utenze, privilegi e ruoli fanno parte del DCL (data control language); in passato venivano considerate DCL anche le istruzioni per la gestione delle transazioni, che sono trattate in un capitolo a parte e che ora vengono considerate parte del TCL (Transaction control language).

## Linee guida per la sicurezza

- Si deve evitare di garantire l'accesso alle tabelle di sistema a utenti diversi da "root"
- Impostare una password per l'utente "root"
- Non concedere mai privilegi a tutti gli host
- Non concedere privilegi non necessari
- Utilizzare l'istruzione SHOW GRANTS per verificare i privilegi concessi
- Non memorizzare le password come testo normale nel database
- Variazioni dei privilegi relativi a una tabella sono veerificati ad ogni utilizzo
- Variazioni dei privilegi relativi a un database sono verificati al successivo utilizzo dell'istruzione USE <database>;


---------------------
## Gestione delle utenze

Per controllare gli utenti che si connettono e le funzionalità a loro disposizione sono disponibili una serie di istruzioni: CREATE USER, GRANT e REVOKE
Esistono alcune cose che MySql non permette di fare a livello di gestione dei privilegi:
- Non è possibile negare l'accesso in maniera specifica ad un utente
- Non è possibile garantire il privilegio di creazione ed eliminazione delle tabelle escludendo la possibilità di creare o eliminare il database
- Impostare una password specifica per un singolo oggetto o database

I nomi delle utenze possono essere lunghi al massimo 32 caratteri e le relative password sono ovviamente memorizzate criptate.
Il nome dell'account è costituito dal nome utente e dal nome dell'host nella forma 'user_name'@'host_name', poiche un utente può essere abilitato a più host.
Il riferimento @'host_name' è opzionale ed ometterlo equivale ad utilizzare la forma 'user_name'@'%', cioè "tutti gli host".
E' possibile definire un utente anonimo utilizzando il riferimento ''@'host_name'.

Per creare le utenze è necessario utilizzare l'istruzione CREATE USER seguita dal nome dell'account e dall'eventuale istruzione IDENTIFIED BY per specificare la password, come negli esempi seguenti:

    CREATE USER 'utente'@'localhost' IDENTIFIED BY 'password';
    CREATE USER 'utente'@'%.example.com' IDENTIFIED BY 'password';
    CREATE USER 'utente'@'host47.example.com' IDENTIFIED BY 'password';
    CREATE USER 'senza_password'@'localhost';

Per visualizzare le informazioni relative ad un utente è possibile utilizzare l'istruzione SHOW CREATE USER indicando l'account:

    SHOW CREATE USER 'admin'@'localhost'

Per eliminare un utente è necessario utilizzare l'istruzione DROP USER seguita dal nome dell'account

    DROP USER 'utente'@'localhost';
    DROP USER 'utente'@'%.example.com';
    DROP USER 'senza_password'@'localhost';

Per assegnare o modificare la password si deve utilizzare la seguente istruzione:

    ALTER USER 'utente'@'host' IDENTIFIED BY 'password';

---------------------
### Resettare la password di 'root'@'localhost'

NB: per host diversi è necessario adeguare gli script seguenti.

- in ambiente Windows
    - Eseguire il login come amministratore
    - Stoppare il server MySql se è attivo (eventualmente utilizzando task manager se non è presente alcun servizio)
    - Creare un file di testo contenente lo script di modifica della password:
      
            ALTER USER 'root'@'localhost' IDENTIFIED BY 'NuovaPassword';
      
    - Salvare il file (ie: C:\mysql-init.txt)
    - Avviare il prompt di MS-Dos (cmd.exe)
    - Avviare il server MySql con le seguenti istruzioni (adeguando i percorsi e il nome del file):
    
            C:\> cd "C:\Program Files\MySQL\MySQL Server 8.0\bin"
            C:\> mysqld --init-file=C:\\mysql-init.txt
    
    - Il server esegue lo script del file all'avvio cambiando la password
    - Nel caso in cui l'installazione di MySql sia stata fatta tramite wizard potrebbe essere necessario modificare l'istruzione come segue (sempre adeguando percorsi e nome del file):
    
            C:\> mysqld
            --defaults-file="C:\\ProgramData\\MySQL\\MySQL Server 8.0\\my.ini"
            --init-file=C:\\mysql-init.txt
    
    - Eliminare il file
- in ambiente Unix e Unix-Like
    - Accedere al sistema con l'utente abitualmente utilizzato per avviare MySql server (ie: mysql)
    - Stoppare il server MySql se avviato con la seguente istruzione (adeguando i percorsi e il nome):

            $> kill `cat /mysql-data-directory/host_name.pid`

    - Creare un file contenente lo script di modifica della password:
      
            ALTER USER 'root'@'localhost' IDENTIFIED BY 'NuovaPassword';
      
    - Salvare il file (ie: /home/me/mysql-init)
    - Avviare il server MySql con le seguenti istruzioni (adeguando i percorsi e il nome del file):
    
            $> mysqld --init-file=/home/me/mysql-init &
      
    - Il server esegue lo script del file all'avvio cambiando la password
    - Eliminare il file


---------------------
## Gestione dei privilegi

Per una trattazione completa si rimanda alla documentazione ufficiale:
https://dev.mysql.com/doc/refman/8.0/en/privileges-provided.html

I privilegi determinano cosa un utente può fare e le seguenti sono le caratteristiche fondamentali:
- i privilegi amministrativi permettono di gestire aspetti a livello di server e non sono specifici per un dato database.
- i privilegi standard invece si possono impostare per uno specifico o per tutti gli oggetti di un dato tipo e per uno specifico database o per tutti i database.
- possono essere statici (impostati a livello di server) o dinamici (definiti runtime, sostanzialmente tutti destinati all'amministrazione)

I privilegi statici più frequentemente utilizzati:
- ALL [PRIVILEGES] > tutti i privilegi (amministrazione)
- ALTER	> modificare delle tabelle
- ALTER ROUTINE	> modificare di procedure e funzioni
- CREATE > creare database, tabelle e indici
- CREATE ROLE > creare un ruolo (amministrazione)
- CREATE ROUTINE > creare procedure e funzioni
- CREATE TEMPORARY TABLES > creare tabelle temporanee
- CREATE USER > creare utenti (amministrazione)
- CREATE VIEW > creare viste
- DELETE > eliminare dati nelle tabelle
- DROP > eliminare database, tabelle e indici
- DROP > eliminare ruoli (amministrazione)
- EVENT	> gestire la schedulazione (amministrazione)
- EXECUTE > eseguire procedure e funzioni
- FILE > accedere a file sul seerver
- GRANT OPTION > garantire privilegi su database, tabelle, procedure e funzioni
- INDEX	> gestire gli indici
- INSERT > inserire dati nelle tabelle
- LOCK TABLES > bloccare tabelle
- REFERENCES > Gestione delle foreign key
- SELECT eseguire query sulle tabelle
- SHOW DATABASES > esaminare i database (amministrazione)
- SHOW VIEW > esaminare le viste
- SHUTDOWN > eseguire lo shutdown (amministrazione)
- TRIGGER > gestire i trigger
- UPDATE > aggiornare i dati delle tabelle

Per impostare i privilegi è necessario utilizzare l'istruzione GRANT ALL|<privilegio>|<elenco privilegi> ON *|<database>.*|<oggetto> TO <account> [WITH GRANT OPTION]; come negli esempi seguenti:

    GRANT ALL   ON *.*   TO 'utente'@'localhost'   WITH GRANT OPTION;
    GRANT ALL   ON bankaccount.*   TO 'utente'@'localhost'; 
    GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP   ON expenses.*   TO 'utente'@'host47.example.com';
    GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP   ON customer.addresses   TO 'utente'@'%.example.com';

Per visualizzare i privilegi associati ad un utente è possibile utilizzare l'istruzione:

    SHOW GRANTS FOR 'nome_utente'@'host';


Per eliminare dei privilegi è necessario utilizzare l'istruzione REVOKE ALL|<privilegio>|<elenco privilegi> FROM *|<database>.*|<oggetto> TO <account>; come negli esempi seguenti:

    REVOKE ALL ON *.*  FROM 'utente'@'%.example.com';
    REVOKE CREATE,DROP  ON expenses.*  FROM 'utente'@'host47.example.com';
    REVOKE INSERT,UPDATE,DELETE  ON customer.addresses  FROM 'utente'@'%.example.com';


---------------------		
## Gestione dei ruoli
I ruoli sono collezioni di privilegi.
La semantica è la stessa vista per gli utenti, con alcune differenze: non è possibile definire un "ruolo anonimo" ed è necessario specificare l'host.

Per creare un ruolo è necessario utilizzare l'istruzione CREATE ROLE <elenco_ruoli>:

    CREATE ROLE 'app_developer', 'app_read', 'app_write';

Per assegnare privilegi ad un ruolo la semantica è la stessa vista per l'assegnazione agli utenti:

    GRANT ALL ON app_db.* TO 'app_developer';
    GRANT SELECT ON app_db.* TO 'app_read';
    GRANT INSERT, UPDATE, DELETE ON app_db.* TO 'app_write';

Per assegnare un ruolo ad un utente è necessario utilizzare l'istruzione GRANT <elenco ruoli> TO <elenco utenti>:

    GRANT 'app_read' TO 'read_user1'@'localhost', 'read_user2'@'localhost';
    GRANT 'app_read', 'app_write' TO 'rw_user1'@'localhost';

E' possibile definire dei ruoli come mandatari (cioè automaticamente impostati per tutti gli utenti) specificandone l'elenco nel file di configurazione my.cnf:

     mandatory_roles='role1,role2@localhost,r3@%.example.com'

oppure utilizzando l'istruzione SET PERSIST (richiede il privilegio ROLE_ADMIN)

    SET PERSIST mandatory_roles = 'role1,role2@localhost,r3@%.example.com';

I ruoli associati ad un utente possono essere attivi o disattivi ed è possibile utilizzare la funzione CURRENT_ROLE() per verificare l'elenco degli attivi:

    SELECT CURRENT_ROLE();

Per stabilire i ruoli che devono essere attivati alla connessione di un utente è necessario utilizzare l'istruzione SET DEFAULT ROLE ALL|<elenco ruoli> TO <elenco account>; come nell'esempio seguente:

    SET DEFAULT ROLE ALL TO   'dev1'@'localhost',   'read_user1'@'localhost',   'read_user2'@'localhost',   'rw_user1'@'localhost';

Durante una sessione un utente può variare lo stato dei propri ruoli utilizzando le seguenti istruzioni:

    SET ROLE NONE; -- > disattiva tutti i ruoli non mandatari
    SET ROLE ALL EXCEPT 'app_write'; -- > Attiva tutti i ruoli eccetto 'app_write'
    SET ROLE DEFAULT; -- > reimposta i ruoli allo stato iniziale (solo i mandatari)

Per revocare l'associazione di un privilegio con un ruolo si usa l'istruzione:

    REVOKE <elenco privilegi> ON <elenco ruoli>;

Per eliminare l'associazione di un ruolo a un utente si usa l'istruzione:

    REVOKE <elenco ruoli> FROM <elenco utenti>;

Per eliminare un ruolo si utilizza l'istruzione: 

    DROP ROLE <elenco ruoli>;

