---
title: "[Aporte][PHP][MySQL][AJAX] Agregale AJAX al sistema de user"
date: 2011-04-05
issueId: 3
---
Bueno Siguiendo Con Mi Tema Anterior

~~[https://www.taringa.net/comunidades/webdesign/2350804/%5BTutorial%5D%5BPHP+MYSQL%5D-Sistema-De-Usuarios.html](https://www.taringa.net/comunidades/webdesign/2350804/%5BTutorial%5D%5BPHP+MYSQL%5D-Sistema-De-Usuarios.html)~~

[/blog/2011-04-04-aporte-php-mysql-sistema-de-usuarios//](/blog/2011-04-04-aporte-php-mysql-sistema-de-usuarios//)

> Si Entendi Bien A Cada $_POST y $_GET deben encerralos con mysql_escape_real_string() para evitar intentons de injecion mysql, gracias por el dato pense que al hashearlos no era necesario 

Esta Vez Le Colocaremos Ajax Para MAyor Comiddad Del Usuario.

Primero creamos un archivo llamado Incluir.php el cual haremos uso de el en todas las paginas, ya que este archivo incluye los css,y javascrit, esto es a gusto propio, cada uno puede hacerlo como desee.

```php
<?php
//incluimos mi css ya que estos tutoriales pertenecen a un proyecto mio
    echo'<link href="Style.css" type="text/css" rel="stylesheet">';

//incluimos jquery, framework de javascript
    echo'<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.5.1/jquery.min.js"></script>';

// y aca nuestro js.
    echo'<script type="text/javascript" src="Actions.js"></script>';
?>
```

en el **login.php** cambiamos

> header("Location: main.php");

por

> echo'Te Has Logueado Con Exito';


en el **index.php** buscamos

> action="registrar.php"

y lo cambiamos por

> onsumit="Registrar(); return false"


y

> action="login.php"

por

> onsubmit="Login(); return false"


**Actions.js**

```js
//declaramos la funcion login que sera llamada al loguearse
function Login(){
//hacemos uso de ajax para poder pasa datos POST sin tener que recargar la pagina
$.ajax({

//indica el metodo en este caso POST
        type: 'POST',

//el archivo el cual recibira los datos.
        url: 'Login.php',

//los datos que seran un nombre representativo seguido de su valor.
        data: 'userlog='+ $('#userlog').val() +'&passwordlog='+ $('#passwordlog').val(),

//almacenamos en la vriable h el valor devuelto
        success: function(h){
        
//si h es igual a Te Has Logueado Con Exito dirigimos a main.php
            if(h == 'Te Has Logueado Con Exito'){
                location.href="main.php";
            }else{

//si no es asi en el div con id resultadologin colocamos los datos devueltos y los mostramos con fadein para efectos esteticos.
                $('#resultadologin').html(h);
                $('#resultadologin').fadeIn();
            }
        }        
    });
}

function Registrar(){

//declaramos la funcion registrar que sera llamada al registrar un user, no necesita explicacion con entender la anterior es suficiente...
$.ajax({
        type: 'POST',
        url: 'Registrar.php',
        data: 'user='+ $('#user').val() +'&password='+ $('#pass').val() +'&email='+$('#email').val(),
        success: function(h){
        
            $('#resultadoregistrar').html(h);
            $('#resultadoregistrar').fadeIn();
        }        
    });
} 
```
