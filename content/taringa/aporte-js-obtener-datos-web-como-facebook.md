---
title: "[Aporte][JS] Obtener datos web como facebook"
date: 2012-01-12
---
Bueno, boludeando por internet y con el [YQL (Yahoo! Query Language)](http://developer.yahoo.com/yql/), el cual es un sevicio que con una sintaxis similar a la de sql, podes acceder a distintos servicios webs, se me ocurrio realizar en js(javascript) una funcion para obtener el titulo,descripcion y favicon de una url pasada, tal y como hace facebook cuando vas a publicar una.

El unico requisito es Tener incluido Jquery 1.0 o superior

1) Funcion comun de js. ejemplo: ```js var MyData = GetURLData('http://www.cuevana.tv/#!/peliculas/17/');```

```js
function GetURLData(url){
    var data = {};
    $.getJSON("http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20html%20where%20url%3D%22" + encodeURIComponent(url) + "%22%20and%20xpath%3D'%2F%2Fhead'&format=json&callback=?",function(h){
        if(h.query.count <= 0){return data['status'] =0;}

        data['url'] = url;
        data['title'] = h.query.results.head.title;
        data['favicon'] = "http://www.google.com/s2/favicons?domain=" + url.replace(/^http:///,'').replace(//.*/,'');
        data['description'] = '';
        data['status'] = 1;

        for(var i=0;i<h.query.results.head.meta.length;i++){
            if(h.query.results.head.meta[i].name == 'description'){
                data['description'] = h.query.results.head.meta[i].content;
            }
        }

    });
    return data;
}
```

2) Igual a la anterior pero minificada (Borrados espacios,tabulaciones,etc)

```js
function GetURLData(url){var data = {};$.getJSON("http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20html%20where%20url%3D%22" + encodeURIComponent(url) + "%22%20and%20xpath%3D'%2F%2Fhead'&format=json&callback=?",function(h){if(h.query.count <= 0){return data['status'] =0;}data['url'] = url;data['title'] = h.query.results.head.title;data['favicon'] = "http://www.google.com/s2/favicons?domain=" + url.replace(/^http:///,'').replace(//.*/,'');data['description'] = '';data['status'] = 1;for(var i=0;i<h.query.results.head.meta.length;i++){if(h.query.results.head.meta[i].name == 'description'){data['description'] = h.query.results.head.meta[i].content;}}});return data;}
```

3) Funcion de jquery. ejemplo: ```js var MyData = $.GetURLData('http://www.cuevana.tv/#!/peliculas/17/');```

```js
(function($){
    $.GetURLData = function(url){
        var data = {};
        $.getJSON("http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20html%20where%20url%3D%22" + encodeURIComponent(url) + "%22%20and%20xpath%3D'%2F%2Fhead'&format=json&callback=?",function(h){
            if(h.query.count <= 0){return data['status'] =0;}

            data['url'] = url;
            data['title'] = h.query.results.head.title;
            data['favicon'] = "http://www.google.com/s2/favicons?domain=" + url.replace(/^http:///,'').replace(//.*/,'');
            data['description'] = '';
            data['status'] = 1;

            for(var i=0;i<h.query.results.head.meta.length;i++){
                if(h.query.results.head.meta[i].name == 'description'){
                    data['description'] = h.query.results.head.meta[i].content;
                }
            }

        });
        return data;
    };
})(jQuery);
```

4) Igual a la anterior pero minificada (Borrados espacios,tabulaciones,etc)

```js
(function($){$.GetURLData = function(url){var data = {};$.getJSON("http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20html%20where%20url%3D%22" + encodeURIComponent(url) + "%22%20and%20xpath%3D'%2F%2Fhead'&format=json&callback=?",function(h){if(h.query.count <= 0){return data['status'] =0;}data['url'] = url;data['title'] = h.query.results.head.title;data['favicon'] = "http://www.google.com/s2/favicons?domain=" + url.replace(/^http:///,'').replace(//.*/,'');data['description'] = '';data['status'] = 1;for(var i=0;i<h.query.results.head.meta.length;i++){if(h.query.results.head.meta[i].name == 'description'){data['description'] = h.query.results.head.meta[i].content;}}});return data;};})(jQuery);
```

Los datos que devuelve es un array con los siguientes valores:

```js
status = 1 (exito) o 0 (error)
title = 'Cuevana | Inicio' (titulo de la web)
favicon = 'http://www.google.com/s2/favicons?domain=www.cuevana.tv' (favicon en formato png)
description = 'Índice de películas y series online. Cortos, noticias, recomendaciones y más.' (descripcion de la web, tag description)
url = 'http://www.cuevana.tv/#!/peliculas/17/' (url de la web)tatus = 1 (exito) o 0 (error)
title = 'Cuevana | Inicio' (titulo de la web)
favicon = 'http://www.google.com/s2/favicons?domain=www.cuevana.tv' (favicon en formato png)
description = 'Índice de películas y series online. Cortos, noticias, recomendaciones y más.' (descripcion de la web, tag description)
url = 'http://www.cuevana.tv/#!/peliculas/17/' (url de la web)
```
