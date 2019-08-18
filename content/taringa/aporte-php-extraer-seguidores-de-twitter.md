---
title: "[Aporte][PHP] Extraer seguidores de twitter"
date: 2011-04-16
---
Bueno, Pelotudeando Cree Esta Funcion De PHP Que Devuelve En Un Array Todos Los Seguidores De Twitter, Solo Funca En PHP5

ED:No Habia Leido Para Que Version Eran Los Comandos Tonces Habia Puesto Eso

```php
<?php
function SeguidoresTwitter($user){
    $usuario = simplexml_load_file("http://api.twitter.com/1/statuses/followers.xml?screen_name=".$user);
    foreach($usuario->user as $seguidor){
            $seguidores[(string)$seguidor->screen_name]=array(
                'nombre'=>(string)$seguidor->screen_name,
                'imagen'=>(string)$seguidor->profile_image_url,
            );
        }
    return $seguidores;
}
?>
```

Se Usa Asi:

```php
<?php
$VariableDondeAlmacenarElArray =  SeguidoresTwitter('UserQueQuierasObtener');
?>
```

Y En La Variable Habra Un Array De Este Estilo:

```
Array
(
    [NombreUser1] =>
        (
            [nombre] => NombreDelUser1
            [imagen] => LinkAvatarUser1
        )

    [NombreUser2] =>
        (
            [nombre] => NombreDelUser2
            [imagen] => LinkAvatarUser2
        )

    [NombreUser3] =>
        (
            [nombre] => NombreDelUser3
            [imagen] => LinkAvatarUser3
        )

) 
```
