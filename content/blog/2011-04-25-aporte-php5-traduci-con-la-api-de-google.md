---
title: "[Aporte][PHP5] Traduci con la API de Google."
date: 2011-04-25
---
Bueno, Esta Vez Les Dejo Otra Funcion (Solo PHP5) Creada Por Mi Para Traducir Con La Api De Google.
Se Debe Usar Asi:

```php
$mivariable = traducir("MI TEXTO");
echo traducir("MI TEXTO");
```

Cualquiera De Las Dos Es Valida, Ya Que El Resultado Lo Devuelve Con Return Y No Con Echo

```php
<?php
function traducir ($texto){
    $url = 'http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q='.urlencode($texto).'&langpair=en|es';

    if($respuesta = file_get_contents($url)){
        $arrayrespuesta = json_decode($respuesta, true);
        return $arrayrespuesta['responseData']['translatedText'];
    }
}
?> 
```
