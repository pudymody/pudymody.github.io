---
title: "[Aporte][PHP] Funcion obtener datos post Taringa"
date: 2011-04-25
---
Bueno Lo Siguiente Son Dos Funciones Que Devuelven En Un Array La Cantidad De Favoritos,Visitas,Puntos,Seguidores Y Comentarios De Un Post Pasado Como Parametro.

Se Debe Usar Asi:

```php
$variabledondealmacenarelarray = datos_post('URLDELPOST');
```

y devolvera en ese mismo array

```php
Array
(
    [favoritos] => CANTIDADDEFAVORITOS
    [visitas] => CANTIDADDEVISITAS
    [puntos] => CANTIDADDEPUNTOS
    [seguidores] => CANTIDADDESEGUIDORES
    [comentarios] => CANTIDADDECOMENTARIOS
)
```

Funcion:

```php
<?php
function obtener ($inicio,$fin,$sobre){
    $r = explode($inicio,$sobre);
    $r = explode($fin,$r[1]);
    return $r[0];
}

function datos_post($url){
    if($post = file_get_contents($url)){
        $datosresultado['favoritos'] = obtener('<span class="icons favoritos_post">','</span>',$post);
        $datosresultado['visitas'] = obtener('<span class="icons visitas_post">','</span>',$post);
        $datosresultado['puntos'] = obtener('<span class="icons puntos_post">','</span>',$post);
        $datosresultado['seguidores'] = obtener('<span class="icons monitor">','</span>',$post);
        $datosresultado['comentarios'] = obtener('<div class="comentarios-title">','</div>',$post);
        $datosresultado['comentarios'] = obtener('<h4 class="titulorespuestas floatL">',' Comentarios</h4>',$datosresultado['comentarios']);
        return $datosresultado;
    }
}
?>
```

Inspirado En El Perfil Dinamico De [@Pichoncitotv](https://taringa.net/pichoncitotv)
Pueden Resultar Similar Las Funciones, Pero No Es La Misma, Cualquier Cosa, Agradecimientos A El
