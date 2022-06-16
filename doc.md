# Modello computazionale del campo sonoro nel MEA

## Introduzione

Come strumento per la simulazione del campo sonoro ho scelto la libreria
*deal.ii*, disponibile a [https://dealii.org](https://wwww.dealii.org). E'
una libreria scritta in C++ con licenza open source che si occupa di importare
una mesh generata esternamente (o fornisce delle funzioni per generarne di
semplici), fornisce una serie di utilità per impostare e risolvere il problema
alle derivate parziali che va interamente formulato dall'utente e genera un
ampio insieme di formati di output apribili con i maggiori software di 
visualizzazione (tra cui ho scelto [Paraview](https//www.paraview.org)).
