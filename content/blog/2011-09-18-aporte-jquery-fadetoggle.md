---
title: "[Aporte][Jquery] FadeToggle"
date: 2011-09-18
issueId: 10
---
bueno, desde hace mucho tiempo, viendo que existe .toggle, .slideToggle, y quejandome porque no hay un .fadeToggle, asi que investigando sobre como crear plugins jquery, me tope con una buena guia, y decidi crear el .fadeToggle

**1)** Inlcuyen Jquery En Su Sistio

**2)** Guardan Lo Siguiente Con El Nombre Que Deseen .js Y Tambien Lo Incluyen En Su Sitio

```js
(function($){  
      
    $.fn.fadeToggle = function(){
        this.each( function(time){
            if($(this).is(':visible')){
                $(this).fadeOut();
            }else{
                $(this).fadeIn();
            }
        });
    };  
      
})(jQuery);  
```

**3)** Se Utiliza Con CualquierSelector.fadeToggle();

```
$('#DivConID').fadeToggle();
$('.DivConID').fadeToggle();
$('DIV').fadeToggle(); 
```
