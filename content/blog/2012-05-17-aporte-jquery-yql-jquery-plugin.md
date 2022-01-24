---
title: "[Aporte][Jquery] YQL Jquery Plugin"
date: 2012-05-17
issueId: 15
---
Bueno, boludeando por internet y con el [YQL (Yahoo! Query Language)](http://developer.yahoo.com/yql/), el cual es un sevicio que con una sintaxis similar a la de sql, podes acceder a distintos servicios webs, y en base a uno de los temas que aporte ([[Aporte][JS] Obtener datos web como facebook](/taringa/aporte-js-obtener-datos-web-como-facebook/)), se me ocurrio realizar en jquery un plugin para hacer mas simples las querys.

Las respuestas son en json, y en caso de error, el atributo "error" contendra un mensaje..

El unico requisito es Tener incluido Jquery 1.0 o superior

```js
(function($){
    $.YQL = function(query,callback){
        $.getJSON("http://query.yahooapis.com/v1/public/yql?q=" + encodeURIComponent(query) + "&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&format=json&callback=?",function(data){
            if(data.query.count){
                callback.call(this,data.query.results);
            }else{
                callback.call(this,eval({"error" : "No se encontraron resultados."}));
            }
        });
    };})
(jQuery);
```

Y para utilizarlos solo tienen que hacer

```js
$.YQL("MI QUERY ACA",callback);
```
//o tambien

```js
$.YQL("MI QUERY ACA",function(h){//funcion a realizar});
```

*Sobre las querys que se pueden realizar pueden averiguar mas en la [pagina oficial](http://developer.yahoo.com/yql/)*
