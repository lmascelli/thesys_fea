# Modello computazionale del campo sonoro nel MEA

## Introduzione

Come strumento per la simulazione del campo sonoro ho scelto la libreria
*deal.ii*, disponibile a [https://dealii.org](https://wwww.dealii.org). E'
una libreria scritta in C++ con licenza open source che si occupa di importare
una mesh generata esternamente (nel mio caso ho utilizzato 
[gmsh](https://gmsh.info)) o fornisce delle funzioni per generarne di
semplici, fornisce una serie di utilità per impostare e risolvere il problema
alle derivate parziali che va interamente formulato dall'utente e genera un
ampio insieme di formati di output apribili con i maggiori software di 
visualizzazione (tra cui ho scelto [Paraview](https//www.paraview.org)).
Cercherò nel seguito di questo documento di spiegarne il funzionamento passo
dopo passo esponendo frammenti del codice.
L'intero codice dovrebbe comunque essere costituito da:
  - **mesh.geo**: script di gmsh che genera una mesh del sistema
  - **sound_pressure.cpp**: sorgente c++ del programma
  - **run.ps1**: script di PowerShell che automatizza la maggior parte del
    processo di compilazione, esecuzione.
  - **Dockerfile**: script di Docker per generare un'immagine in grado di
    compliare, eseguire ed esportare la simulazione ed i suoi risultati.


## run.ps1
```
./run.ps1 COMMAND

commands:
  build:            build the sound_pressure.cpp source
  run               run the simulation
  mesh              build the gmsh's mesh
  clear             clear the project
  docker_create     create a container from deal.ii image
  docker_rm         remove the created image
```

## deal.ii
