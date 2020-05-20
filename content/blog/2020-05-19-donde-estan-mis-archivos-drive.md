---
title: "¿Donde estan mis archivos de Google Drive?"
date: 2020-05-19
---
## Intro
Todos usamos alguna vez Google Drive, ya sea para compartir archivos con un amigo, guardar los nuestros, o incluso para bajar peliculas de forma ilegal, pero nunca nos preguntamos "¿Donde se encuentran esos archivos?". Uno abre su trabajo practico o simplemente este archivo de texto y ya sabe que esta en el disco duro de su pc. El cual si se destruye o se daña nos deja sin posibilidad de aprobar la materia o una situacion mas real, se corta la luz y ya nos es imposible continuar editando el archivo desde nuestro celular. ¿Como es posible que a Google nunca se le corte la luz? ¿O que nunca se le dañen los discos duros? ¿Que clase de tecnologia ultra secreta usan? ¿Sera porque son del primer mundo?.

## Servidores
Para esto primero es necesario entender como funciona Internet. Segun Wikipedia, se define como:

> Internet (el internet o, también, la internet) es un conjunto descentralizado de redes de comunicación interconectadas que utilizan la familia de protocolos TCP/IP, lo cual garantiza que las redes físicas heterogéneas que la componen constituyan una red lógica única de alcance mundial

Pero esto es demasiado tecnicismo para el nivel de este articulo; Asi que, en terminos mas sencillos, internet puede pensarse como: *un conjunto de computadoras(servidores) interconectadas entre si, las cuales utilizan un medio (Fibra Optica/Satelital) y un lenguaje de comunicacion (TCP/IP) para intercambiar informacion entre ellas*. Es de publico conocimiento que estos servidores estan distribuidos a lo largo del mundo. ¿Quien nunca entro en una pagina extranjera?. En terminos simples, uno podria decir que cuando esta descargando un archivo, en realidad lo que esta haciendo es acceder a este archivo, el cual se encuentra en otra computadora del planeta, luego de haberse conectado y establecido cierto "dialogo" con la misma. Pero esto solo explica como funciona internet y no responde la pregunta principal.

## Garantias
Antes de responder esa pregunta, es necesario analizar ciertos problemas por los que estos servicios son tan populares.

### 1. Tolerancia a fallos

Un buen servidor debe garantizar la integridad de sus recursos, en este caso nuestros archivos.
- ¿Se corto la luz? No importa, [generadores para estos casos existen y se ponen en funcionamiento](https://www.google.com/about/datacenters/data-security/).
- ¿Hubo un terremoto en *donde ud cree google se hospeda* y destruyo los servidores? No importa, para esto existen tambien otros [20 centros de datos distribuidos a lo largo del planeta](https://www.google.com/about/datacenters/locations/).
- ¿Se daño una pc o un disco duro de algun centro? No importa, cada centro consiste en miles de computadoras con la informacion distribuida y duplicada del mismo e incluso de los demas del planeta.

Estas son medidas basicas que un servidor debe ofrecer para poder garantizar su disponibilidad, la diferencia respecto a Google es su nivel y alcance mundial que posee.

### 2. Disponibilidad

Asi como se garantiza que nuestra informacion siempre estara disponible, tambien es necesario que se garantice el acceso a ella. Siendo uno de los servicios mas usados, uno podria pensar "¿Como es que no se atasca la gente o se traban los servidores?". Parte de esta respuesta es el hecho de poseer varios centros de datos distribuidos. Cuando uno accede a un archivo puede no estar descargandolo del mismo centro de datos que lo hizo hace cinco minutos, incluso puede ser que partes del mismo archivo no esten siendo otorgadas por el mismo pais (aunque esto no es generalmente el caso). De esta forma es posible distribuir la carga a lo largo de distintos centros de datos.

### 3. Precio

Este es el punto fundamental por el cual se destacan estos servicios para mi criterio. Una cuenta gratuita de Google posee 15GB de almacenamiento, cantidad suficiente para una persona promedio. Por 2 USD al mes, es posible acceder a 100GB. Por 2 USD al mes, lo mismo que una cerveza, uno puede disponer de toda la infraestructura de google "a prueba de fallos" sin temor a que sus archivos sean perdidos por un cortocircuito limpiando la habitacion. Obviamente esto no nos soluciona el problema de gente eliminando por error sus archivos, ese es otro tema.

## ¿Donde estan mis archivos?
Como leimos anteriormente, nuestros archivos pueden estar en todo el planeta a la vez, no existe un lugar fisico unico donde se encuentren, ya que esto seria una seria amenaza, un unico punto de falla contra la garantia de proveer tolerancia a fallos.

Pero creo que la pregunta mas importante que uno tiene que hacerse es "**¿Quien es dueño de estos archivos?**". Uno estaria tentado a responder que es quien los sube, *"pero mis archivos no estan en mi pc"* podria argumentar otro, y es totalmente correcto. [¿Que pasa si un dia Google desaparece o decide eliminar su servicio?](https://killedbygoogle.com/) o incluso peor, establece que para acceder a esos archivos uno tiene que mejorar su cuenta a su nuevo paquete SuperPlusPremium.

Mis archivos estan en la computadora de otra persona, ¿Pueden verlos? ¿Bajo que ley responden los archivos que uno sube? ¿Que sucede si el gobierno donde se encuentra un centro de datos decide tener acceso a los archivos de las personas de ese pais?

¿Como estamos seguros de que cuando eliminamos un archivo el mismo es efectivamente eliminado de todos sus centros, o incluso es eliminado siquiera?. Estas son preguntas que no poseen respuesta, ya que el "programa" que utiliza Drive para proveer su servicio no se conoce, no se posee acceso al mismo, no puede ser auditado o incluso leido por alguien ajeno a la empresa!.

**Es por este motivo que solo podemos depositar nuestra fe en ellos. Y yo no pienso depositar mis archivos y fe en algo que no es transparente y no se como funciona.**