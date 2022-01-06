---
title: "[Aporte][PHP5] Twitter fan list"
date: 2011-04-17
---
Bueno, En Base A Mi Tema Anterior Hice Esta Lista+CSS Donde Muestra El Total De Seguidores De Twitter De Cierto Usuario,Link Para Seguir,Y 12 Usuarios Seguidores Al Azar Con Link A Sus Respectivos Twitters.

![Demo del listado](/static/imgs/aporte-php5-twitter-fan-list/demo.png)

**SeguidoresTwitter.php**
```php
<?php
function SeguidoresTwitter($user){
    echo'<link href="SeguidoresTwitter.css" type="text/css" rel="stylesheet">';
    $usuario = simplexml_load_file("http://api.twitter.com/1/statuses/followers.xml?screen_name=".$user);
    $TotalSeguidores = simplexml_load_file("http://api.twitter.com/1/users/show.xml?screen_name=".$user);
    $TotalSeguidores = (int)$TotalSeguidores->followers_count;
    $Total=0;
    echo'<div id="twitterfanslist">';
    echo'<center class="botontwitterfanslist">Fans En Twitter<br>(', $TotalSeguidores ,')</center><div class="cajatwitterfanslist">';
    foreach($usuario->user as $seguidor){
    
            if($Total == 12){
                break;
            }
            
            echo '<a href="http://twitter.com/#!/', $seguidor->screen_name ,'"><img style="margin:2px;" title="', $seguidor->screen_name ,'" src="', $seguidor->profile_image_url ,'"></a>';
            $Total++;
        }
    echo'</div><a href="http://twitter.com/#!/', $user ,'" class="botontwitterfanslist">Join</a>';
    echo'</div>';
}
?>
```

**SeguidoresTwitter.css**
```css
#twitterfanslist{
width:162px;
background:#A2D876;
padding:5px;
-webkit-border-radius: 10px;
-moz-border-radius: 10px;
border-radius: 10px;
border:1px solid;
}

.botontwitterfanslist{
    -moz-border-bottom-colors: none;
    -moz-border-image: none;
    -moz-border-left-colors: none;
    -moz-border-right-colors: none;
    -moz-border-top-colors: none;
    background: #7FBF4D; /* old browsers */
    background: -moz-linear-gradient(top, #7FBF4D 0%, #63A62F 100%); /* firefox */
    background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#7FBF4D), color-stop(100%,#63A62F)); /* webkit */
    filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#7FBF4D', endColorstr='#63A62F',GradientType=0 ); /* ie */
    border-color: #63A62F #63A62F #5B992B;
    border-radius: 3px 3px 3px 3px;
    border-style: solid;
    border-width: 1px;
    box-shadow: 0 1px 0 0 #96CA6D inset;
    color: #FFFFFF;
    font-family: "Lucida Grande","Lucida Sans Unicode","Lucida Sans",Geneva,Verdana,sans-serif;
    font-size: 11px;
    font-weight: bold;
    line-height: 1;
    padding: 7px 5px 8px;
    text-align: center;
    text-shadow: 0 -1px 0 #4C9021;
    display:block;
}

.botontwitterfanslist:hover {
    background: #76B347; /* old browsers */
    background: -moz-linear-gradient(top, #76B347 0%, #5E9E2E 100%); /* firefox */
    background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#76B347), color-stop(100%,#5E9E2E)); /* webkit */
    filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#76B347', endColorstr='#5E9E2E',GradientType=0 ); /* ie */
    box-shadow: 0 1px 0 0 #8DBF67 inset;
    cursor: pointer;
}

.cajatwitterfanslist{
    padding:2px;
    background: #7FBF4D; /* old browsers */
    background: -moz-linear-gradient(top, #7FBF4D 0%, #63A62F 100%); /* firefox */
    background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#7FBF4D), color-stop(100%,#63A62F)); /* webkit */
    filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#7FBF4D', endColorstr='#63A62F',GradientType=0 ); /* ie */
    border-color: #63A62F #63A62F #5B992B;
    border-radius: 3px 3px 3px 3px;
    border-style: solid;
    border-width: 1px;margin:5px 0px;
}
```


Y Para Usarlo Solo Tienen Que Llamarlo Asi..

```php
<?php
SeguidoresTwitter('USERAMOSTRAR');
?> 
```
