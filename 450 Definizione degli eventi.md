# Definizione degli eventi
------------------------------

## EVENT SCHEDULER
------------------------------

MySQL Event Scheduler è la componente software di MySQL che permette di programmare (o "schedulare") ed eseguire delle elaborazioni, dette "eventi".
La creazione di un evento è, di fatto, la creazione di un oggetto nel database e, come tale, è soggetto all'unicità del nome per tipo di oggetto e database.
Quando viene creato un evento è necessario definirne, oltre al nome, le istruzioni da eseguire, il numero di ripetizioni, l'intervallo temporale tra ripetizioni e il range temporale di attività.
Concettualmente la logica è simile a quella del crontab di Unix e del task scheduler di Windows, dei quali è a tutti gli effetti una alternativa in ambito database.
Un evento può essere disattivato o eliminato.
Un evento ripetitivo che non termina entro l'elaborazione successiva implica più elaborazioni contemporanee che possono causare conflitti e lock non risolvibili autonomamente e da gestire da parte dello sviluppatore.


## CONFIGURAZIONE E STATO
------------------------------

Gli utenti con privilegio PROCESS possono verificare lo stato dello schedulatore tramite l'istruzione SHOW PROCESSLIST: se è avviato è presente una riga relativa allo user "event_scheduler" con valore "Daemon" nella colonna Command.

E' possibile vedere l'impostazione della variabile di riferimento anche tramite l'istruzione: 

    SHOW VARIABLES LIKE 'event_scheduler';

La schedulazione può assumere stati diversi:

- ON: l'Event Scheduler è avviato; lo stato può essere variato in OFF a caldo.
- OFF: l'Event Scheduler è stoppato; lo stato può essere variato in ON a caldo.
- DISABLED: l'Event Scheduler è non operativo e lo stato NON può essere cambiato a caldo.
  
Lo stato può essere variato da ON (o 1) a OFF (o 0) con l'istruzione SET con due scritture equivalenti:

    SET GLOBAL event_scheduler = ON;
    SET @@GLOBAL.event_scheduler = ON;

Per disabilitare l'event scheduler è possibile intervenire nelle seguenti due modalità:

- Tramite command-line all'avvio del server:    --event-scheduler=DISABLED
- Nel file di configurazione my.cnf o my.ini:    event_scheduler=DISABLED

Per riattivare la schedulazione è sufficiente riavviare il server senza la riga aggiunta.


Per ottenere informazioni relative agli eventi si può eseguire una ricerca sulla tabella EVENTS del database INFORMATION_SCHEMA database, utilizzare l'istruzione SHOW CREATE EVENT o l'istruzione  SHOW EVENTS <nome_evento>.


--------------------------------------
### PRIVILEGI

Per poter gestire un evento è necessario avere il privilegio EVENT.


--------------------------------------
### CREATE

E' possibile creare un nuovo evento utilizzando il seguente template:

    CREATE    [DEFINER = user]    EVENT    [IF NOT EXISTS]    <nome_evento>    
    ON SCHEDULE  { AT <timestamp> [+ INTERVAL <intervallo>]  |  EVERY <intervallo> [STARTS <timestamp> [+ INTERVAL <intervallo>] ...] [ENDS <timestamp> [+ INTERVAL <intervallo>] ...] }
    [ON COMPLETION [NOT] PRESERVE]     [ENABLE | DISABLE | DISABLE ON SLAVE]     [COMMENT 'descrizione della schedulata']
    DO <body>;

L'intervallo può essere definito tramite una delle seguenti opzioni:  
{YEAR | QUARTER | MONTH | DAY | HOUR | MINUTE | WEEK | SECOND | YEAR_MONTH | DAY_HOUR | DAY_MINUTE | DAY_SECOND | HOUR_MINUTE | HOUR_SECOND | MINUTE_SECOND}

La creazione di un evento non implica l'attivazione.
Il nome dell'evento deve essere unico per tipo di oggetto e database.
La clausola ON SCHEDULE determina quando e quanto spesso deve essere eseguito l'evento.
La clausola DO contiene le istruzione SQL da eseguire.
Se viene utilizzata l'opzione DEFINER  nella creazione della funzione saranno considerati i privilegi dell'utente indicato, altrimenti sono considerati quelli dell'utente creatore.
L'opzione IF NOT EXISTS evita l'errore che occorre quando si cerca di creare un oggetto con un nome già in uso.
L'opzione COMMENT permette di specificare una descrizione per la funzione (l'informazione è visibile con SHOW CREATE PROCEDURE).
Per fare eseguire l'evento una volta sola si deve utilizzare l'opzione AT indicando il momento di esecuzione assoluto o relativo aggiungendo un intervallo a CURRENT_TIMESTAMP.
Per fare eseguire l'evento con ripetizioni si deve utilizzare le opzioni EVERY (indicando l'intervallo di ripetizione), eventualmente STARTS per indicare dopo quanto deve partire la prima elaborazione ed eventualmente ENDS per stabilire quando si deve interromprere la ripetizione.
L'opzione ON COMPLETION PRESERVE permette di mantenere l'oggetto anche dopo la scadenza, pur non essendo più schedulato ed elaborato; senza questa opzione viene automaticamente eliminato l'oggetto (l'opzione ON COMPLETION NOT PRESERVE è quella predefinita).
Con l'opzione DISABLE è possibile disattivare l'evento alla creazione per poi attivarlo modificando successivamente l'evento (utilizzando l'opzione ENABLE, che è la predefinita); l'opzione DISABLE ON SLAVE esclude l'elaborazione in eventuali database replicati.
L'opzione DO specifica l'istruzione (o il blocco di istruzioni) da eseguire.

A seguire un esempio di schedulazione con avvio a 10 secondi di distanza, ripetizione ogni ora, per le successive 48 ore:

    DROP EVENT IF EXISTS ev_test;
    DELIMITER $$
    CREATE EVENT scott.ev_test
        ON SCHEDULE 
         EVERY 1 HOUR STARTS CURRENT_TIMESTAMP  + INTERVAL 10 SECOND ENDS CURRENT_TIMESTAMP + INTERVAL 48 HOUR
        DO
          BEGIN
              DECLARE maxId INT;
              SELECT coalesce(MAX(n), 0) INTO maxId FROM prova;
              SET maxId = maxId + 1;
              INSERT INTO prova (n, t, d) VALUES (maxId, 'evento', current_timestamp());
          END
    $$      
    DELIMITER ;
    SELECT p.* FROM prova p;

