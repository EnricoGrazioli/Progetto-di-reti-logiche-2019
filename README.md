# Progetto-di-reti-logiche-2019

### Politecnico di Milano

#### Anno Accademico 2018- 2019

Documentazione

Enrico Grazioli Prof. Fabio Salice
Matricola: 871569
Codice persona 105 87806


- 1 Obiettivo e specifiche:
   - 1.1 Descrizione generale
   - 1.2 Dati
   - 1.3 Interfaccia del componente
   - 1.4 Note ulteriori sulla specifica
   - 1.5 Strumenti di sintesi utilizzati
- 2 Implementazione
   - 2.1 Descrizione generale
   - 2.2 Descrizione implementazione
      - 2.2.1 Segnali interni
      - 2.2.2 Descrizione Stati
   - 2.3 FSM
- 3. Test
   - 3.1 Testing Black Box
      - 3.1.1 Maschera d’ingresso “11111111”
         - Centroidi equidistanti
         - Centroidi coincidenti
         - Centroidi a posizione e distanza pseudo-casuali
      - 3.1.2 Maschera d’ingresso “00000000”
      - 3.1.3 Maschera pseudo casuale


## 1 Obiettivo e specifiche:

### 1.1 Descrizione generale

Sia dato uno spazio bidimensionale definito in termini di dimensione orizzontale e
verticale, siano date le posizioni di N punti, detti “centroidi”, appartenenti a tale
spazio. Si vuole implementare un componente hardware descritto in VHDL che, una
volta fornite le coordinate di un punto appartenente a tale spazio, sia in grado di
valutare quale/i e dei centroidi risulti più vicino secondo la distanza di Manhattan.
Degli N centroidi K <= N sono quelli su cui calcolare la distanza dal punto dato. I K
centroidi sono indicati da una maschera di ingresso a N bit: il bit a ‘1’ indica che il
centroide è valido e deve quindi essere calcolata la distanza, viceversa il bit a ‘0’
indica che il centroide non va esaminato. La vicinanza al centroide viene espressa
tramite una maschera di uscita di N bit dove ogni bit corrisponde ad un centroide: il
bit viene posto a 1 se il centroide è il più vicino al punto fornito, 0 negli altri casi.
Nel caso in cui il punto considerato sia equidistante da 2 o più centroidi, i bit della
maschera di uscita corrispondenti a tali centroidi saranno tutti posti a 1. Per
entrambe le maschere il bit meno significativo è quello più a destra e il bit i-esimo si
riferisce al centroide i-esimo. Per il progetto il numero di centroidi N è pari a 8.
Lo spazio in questione è un quadrato di dimensione 256x256, le coordinate dei
centroidi e del punto da valutare, così come la maschera di ingresso sono
memorizzate in una memoria (la cui implementazione non è parte del progetto).
La distanza di Manhattan nello spazio in questione è definita come la somma dei
valori assoluti delle differenze tra le coordinate.

### 1.2 Dati

I dati, ciascuno di dimensione 8 bit, sono memorizzati in una memoria con
indirizzamento al Byte partendo dalla posizione 0.
● L’indirizzo 0 è usato per memorizzare la maschera di ingresso.
● Gli indirizzi da 1 a 16 sono usati per memorizzare le coordinate a coppie X e
Y dei centroidi:
○ 1 - Coordinata X 1° centroide.
○ 2 - Coordinata Y 1° centroide.
○ 3 - Coordinata X 2° centroide.
○ 4 - Coordinata Y 2° centroide.
○ ...


```
○ 15 - Coordinata X 8° centroide.
○ 16 - Coordinata Y 8° centroide.
● Gli indirizzi 17 e 18 sono usati per memorizzare le coordinate X e Y
rispettivamente del punto da valutare.
● L’indirizzo 19 è usato per scrivere la maschera di uscita.
```
### 1.3 Interfaccia del componente

Il componente descritto ha la seguente interfaccia.
entity project_reti_logiche is
Port (
i_clk : in STD_LOGIC ;
i_start : in STD_LOGIC ;
i_rst : in STD_LOGIC ;
i_data : in STD_LOGIC_VECTOR (7 downto 0) ;
o_address : out STD_LOGIC_VECTOR (15 downto 0) ;
o_done : out STD_LOGIC ;
o_en : out STD_LOGIC ;
o_we : out STD_LOGIC ;
o_data : out STD_LOGIC_VECTOR (7 downto 0)
);


```
end project_reti_logiche;
```
In particolare:
● i_ clk è il segnale di CLOCK in ingresso generato dal TestBench;
● i_ start è il segnale di START generato dal TestBench;
● i_ rst è il segnale di RESET che inizializza la macchina pronta per ricevere il
primo segnale;
● i_ data è il segnale (vettore) che arriva dalla memoria in seguito ad una
richiesta di lettura;
● o_ address è il segnale (vettore) di uscita che manda l’indirizzo alla memoria;
● o_ done è il segnale di uscità che comunica la fine dell’elaborazione e la
conseguente scrittura in memoria del dato di uscita;
● o_ en è il segnale di ENABLE da dover mandare alla memoria (=1) per poter
comunicare sia in lettura che in scrittura;
● o_ w e è il segnale di WRITE ENABLE da dover mandare alla memoria (=1)
per poter scriverci. Per leggere da memoria esso deve sempre essere a 0;
● o_ data è il segnale (vettore) di uscita dal componente verso la memoria.

### 1.4 Note ulteriori sulla specifica

Il modulo si partirà nella elaborazione quando il segnale di START in ingresso verrà
posto a 1. Il segnale di START rimarrà alto fino a che il segnale di DONE non verrà
portato alto. Al termine della computazione e una volta scritto il risultato in
memoria, il modulo deve impostare a 1 il segnale di DONE che notifica la fine
dell’esecuzione. Il segnale DONE rimarrà alto fino a che il segnale di START non è
riportato a 0. Un nuovo segnale di start non può essere dato fin tanto che DONE non
è nuovamente portato a 0.

### 1.5 Strumenti di sintesi utilizzati

###### ● XILINX VIVADO WEBPACK;

```
● Target FPGA (xc7a200tfbg484•-1) ;
```

## 2 Implementazione

### 2.1 Descrizione generale

L’algoritmo implementato si basa su una FSM di cui ogni stato descrive le azioni da
compiere ad un determinato passaggio dell’algoritmo.
Inizialmente vengono salvate la maschera d’ingresso e le coordinate x e y del centroide
da valutare, rispettivamente nei registri mask, p_x e p_y. Gli indirizzi di memoria dall’
al 16 vengono valutati sequenzialmente.
La valutazione dei singoli centroidi avviene così: innanzi tutto viene valutato il primo bit
del registro mask che indica se il centroide corrente debba o meno essere valutato.
Se il suddetto bit è a ‘0’ il centroide va scartato quindi l’indirizzo corrente (salvato al
registro addr_buff inizializzato a ‘ooooooo1’) viene incrementato di 2 e il registro mask
viene shiftato a destra per portare il bit corrispondente al centroide successivo in prima
posizione. Inoltre, il bit discarded viene portato a ‘1’.
In caso contrario il registro distance viene inizializzato al valore della distanza tra la
coordinata x del centroide di riferimento e il valore letto all’indirizzo corrente. Poi
l’indirizzo corrente viene incrementato di 1 e il valore di distance sommato alla
differenza tra p_y e il valore letto all’indirizzo corrente. Il bit discarded è posto a ‘0’.
Infine l’indirizzo corrente viene ulteriormente incrementato di 1.
A questo punto la maschera di output (salvata al registro o_mask e inizializzata a
‘00000000’) viene aggiornata. Se la distanza del centroide corrente da quello di
riferimento è maggiore della distanza minima trovata o discarded è ‘1’ la maschera
subisce un semplice shift a destra. Se la distanza è pari a quella minima la maschera
viene sempre shiftata a destra ma questa volta il bit più a sinistra viene posto a ‘1’. Nel
caso in cui il centroide corrente sia il più vicino al riferimento trovato finora la maschera
viene reinizializzata a ‘ 10000000 ’.
Le operazioni descritte vengono ripetute per tutti i centroidi (quindi finché non viene
raggiunto l’indirizzo 18 non viene raggiunto).
A questo punto il registro o_mask viene scritto in memoria e l’algoritmo termina.

### 2.2 Descrizione implementazione

#### 2.2.1 Segnali interni

Il componente usa diversi segnali interni durante la computazione. I più importanti
dal punto di vista concettuale sono:
● signal curr_state : state; memorizza lo stato corrente della
macchina.


● signal next_state : state; memorizza lo stato da raggiungere al
seguente ciclo di clock

● signal discarded : std_logic; segnale di supporto utilizzato per
incrementare l’indirizzo di lettura della giusta quantità a seconda che l’ultimo
centroide sia valido o meno
● signal mask : std_logic_vector(7 downto 0); memorizza la
maschera di input e viene letta per determinare la validità dei
centroidi
● signal o_mask : std_logic_vector(7 downto 0); viene
inizializzata a ‘ 00000000 ’
● signal p_x : unsigned(7 downto 0); memorizza la
coordinata x del centroide di riferimento
● signal p_y : unsigned(7 downto 0); memorizza la coordinata
x del centroide di riferimento
● signal distance: U N SIG N ED (8 dow nto 0); viene
utilizzato per computare la distanza dei centroidi dal riferimento. Il segnale è
esteso di un bit per evitare problemi di overflow
● signal min_distance : unsigned(8 downto 0); memorizza la distanza
del più vicino centroide trovato fino a quel momento
● signal addr_buff : unsigned(15 downto 0); tiene traccia
dell’indirizzo di memoria il cui contenuto verrà letto al successivo ciclo di clock


#### 2.2.2 Descrizione Stati

```
● RST: è lo stato di inizializzazione della macchina. Tutti i segnali di output e
o_mask vengono settati a ‘ 0 ’ (o vettori interamente a ‘ 0 ’), mentre
min_distance a ‘1111 1111’;
● WAIT_S: setta o_address a ‘ 0000 0000 ’ e abilita la lettura ponendo o_en a
‘ 1 ’;
● STAR T: memorizza l’input in mask e assegna 17 all’indirizzo di output per
leggere la coordinata x del centroide di riferimento
● POINT_X: memorizza l’input in p_x e incrementa l’indirizzo a 18 per leggere
la coordinata y
● POINT_Y: memorizza l’input in p_y e setta indirizzo di uscita e addr_buff
a ‘ 000 0 0001’
● READ_X : assegna al segnale distance il valore assoluto della differenza tra
p_x e l’input corrente (che in questo stato corrisponde alla coordinata x di un
centroide)
● INTER: setta discarded a ‘ 0 ’ e incrementa di 1 o_address e addr_buff
● READ_Y: incrementa distance del valore assoluto della differenza tra p_y
e l’input corrente (che in questo stato corrisponde alla coordinata y di un
centroide). Poi incrementa o_address e address_buff di uno. Infine esegue uno
shift a destra di mask
● COMPUTE: qui viene aggiornato il segnale o_mask che al termine
dell’esecuzione conterrà la corretta maschera di output. Nel caso la distanza
sia maggiore della distanza minima finora calcolata oppure il segnale
discarded sia a ‘ 1 ’, o_mask viene semplicemente shiftato verso destra. Nel
caso invece in cui le due distanze siano uguali si esegue una sorta di shift a
destra ma il bit aggiunto a sinistra non varrà ‘ 0 ’ ma ‘ 1 ’. Infine nel caso in cui la
distanza calcolata dovesse risultare minore di min_distance il vettore o_mask
viene reinizializzato a ‘1000 0000’
● ADAPT: incrementa di due o_address e addr_buff di due, esegue lo shift a
destra di mask ed assegna il valore ‘ 1 ’ a discarded. Questo stato serve per
risparmiare un ciclo di clock nel caso in cui il centroide corrente debba
essere scartato
● SAVE: è lo stato che prepara il salvataggio in memoria del segnale o_mask. Il
segnale o_we (che abilita la scrittura in memoria) viene posto a ‘ 1 ’, ad o_data
viene assegnato il valore di o_mask e o_address posto a 19
● FINALIZE: i segnali di enable, o_en e o_we, vengono riportati a ‘0’, mentre
o_done a ‘1’, per indicare che la computazione è terminata e l’output è stato
salvato
```

### 2.3 FSM

![FSM GRAPH](https://github.com/EnricoGrazioli/Progetto-di-reti-logiche-2019/blob/master/Screenshot%20(19).png)


Per rendere più chiaro il grafo rappresentante la macchina a stati finiti sono stati
omessi gli archi uscenti da ogni stato e diretti verso lo stato di RESET che vengono
percorsi se il segnale i_rst viene posto a 1 indipendentemente dallo stato complessivo
della macchina in quel istante di tempo.


## 3. Test

Il componente supera tutti i casi di test a cui è stato sottoposto, ogni test è stato
eseguito in Behavioral Simulation, Post-Synthesis Functional Simulation, Post-
Synthesis Timing Simulation, Post-Implementation Functional Simulation e Post-
Implementation Timing Simulation. In particolare oltre al Test Bench fornito, ne
sono stati effettuati altri casi determinati sulla base di due approcci differenti: testing
black box e white box. Per ogni test vengono riportati i tempi di esecuzione. N ota:
per rendere più leggibili ed autoesplicative le tabelle riassuntive dei test effettuati,
entram be le m aschere sono invertite, cioè con il bit più significativo a destra,
rispetto alle m aschere lette e scritte in m em oria.

### 3.1 Testing Black Box

Il test del componente cercheranno di individuare le criticità dell’algoritmo
ricercando i casi limite delle specifiche di progetto.

I casi base sono evidentemente quelli dove la maschera è tutta a ‘ 0 ’ o tutta a ‘ 1 ’. La
configurazione a ‘ 0 ’ dovrebbe avere un unico output sempre, mentre la
configurazione a ‘ 1 ’ può essere utilizzata per provare diverse combinazioni di
centroidi. Infine si proverà a lasciare solo parte della maschera ad ‘ 1 ’ per verificare
che i centroidi corretti vengano effettivamente “scartati”.

#### 3.1.1 Maschera d’ingresso “11111111”

##### Centroidi equidistanti

In questo test si è predisposto che tutti gli 8 centroidi siano distinti tra loro e il
punto ed equidistanti dal punto.


##### Centroidi coincidenti

In questo test si è predisposto che tutti e gli 8 centroidi siano coincidenti al punto.

##### Centroidi a posizione e distanza pseudo-casuali

In questo test punto e centroidi sono stati scelti senza un criterio particolare.

#### 3.1.2 Maschera d’ingresso “00000000”

In questo caso, avendo la maschera di ingresso posta a “00000000”, nessun punto,


come da specifica, viene valutato. Di conseguenza un solo caso di test con coordinate
casuali è sufficiente.
