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

