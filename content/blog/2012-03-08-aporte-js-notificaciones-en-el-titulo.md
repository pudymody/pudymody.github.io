---
title: "[Aporte][JS] Notificaciones en el titulo"
date: 2012-03-08
issueId: 14
---
Bueno, esta vez vengo a dejarles un plugin Jquery, con el cual pueden colocar notificaciones en el titulo, como las que tiene Facebook cuando te llega un mensaje del chat, es decir, alternando el titulo por otro cada x segundos.


1: Crean un archivo llamado TitleBlink.js con el siguiente contenido

```js
(function($){
$.TitleBlink = function(msg,sec){
var options = {
'OldTitle' : document.title,
'NewTitle' : (!msg) ? 'Tienes Movimientos' : msg,
'Interval' : (typeof sec != 'number') ? 1000 : sec*1000
};

var Blinker = setInterval(function() {
document.title = (document.title == options.OldTitle) ? options.NewTitle : options.OldTitle;
}, options.Interval);

$(window).bind('mousemove',function(){
clearInterval(Blinker);
document.title = options.OldTitle;
$(window).unbind('mousemove');
});
    };
})(jQuery);
```

2: En su archivo html, lo incluyen junto a jquery

```html
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
<script type="text/javascript" src="TitleBlink.js"></script>
```

3: Y cuando deseen ejecutarlo, lo pueden hacer en sus llamadas ajax,en el ready,donde deseen, solo tienen que hacer asi:

```html
<script type="text/javascript">
    //...
    $.TitleBlink('Mensaje A Alternar','Duracion en segundos');
    //...
</script>
```

Cualquier duda,sugerencia,error, no duden en comentar.
