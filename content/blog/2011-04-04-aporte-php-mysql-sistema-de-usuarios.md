---
title: "[Aporte][PHP][MySQL] Sistema de usuarios"
date: 2011-04-04
issueId: 2
---
**Bueno Les Dejo Este Tutorial Hecho Por Mi En El Que Realizaremos Un Sistema De Usuarios Con PHP y MYSQL.Intentare Explicar Lo Mayor Posible Cada Archivo.**

**1)**Primero Debemos Crear Una Base En Mysql Y Ejecutar La Siguiente Consulta

```sql
CREATE TABLE `miembros` (
`ID` INT NOT NULL AUTO_INCREMENT ,
`user` VARCHAR( 32 ) NOT NULL ,
`pass` VARCHAR( 32 ) NOT NULL ,
`email` TEXT NOT NULL,
`activada` BOOL NOT NULL ,
`cod_act` VARCHAR( 32 ) NOT NULL ,
PRIMARY KEY ( `ID` )
) ENGINE = MYISAM ;
```

**2)**Ahora Pasamos A Los Archivos En Si.

**Conexion.php**

```php
<?php
//aca iniciamos la conexion dando los parametros server,user,password
mysql_connect("TU SERVER","TU USER","TU PASS");

//aca seleccionamos la base creada
mysql_select_db("NOMBRE DE LA BASE CREADA");


//creamos una funcion para encriptar en md5 valores como pueden ser el password,etc
function encriptar($valor){
    $encriptado = md5($valor);
    return $encriptado;
}


//creamos una funcion para facilitar el envio por mail del link de la validacion de cuenta.
function enviar_mail($email,$user,$cod_act)
{
$destinatario = $email;
$asunto = "Validación De Cuenta En **********";
$cuerpo = "
Para Completar Su Registro Debe Acceder Al Siguiente Enlace.
http://localhost/validar.php?user=$user&cod=$cod_act";
mail($destinatario,$asunto,$cuerpo,$headers);
}

?>
```

**Index.php**

```php
<?php
//aca incluimos el archivo conexión.php para establecer la conexion y poder tener acceso a las funciones antes creadas.
include('Conexion.php');

//iniciamos la informacion de sesion.
session_start();

//si $_SESSION['usuario'] esta definido, por lo que estara logueado lo redirigimos a main.php
if(isset($_SESSION['usuario'])){
    header("Location: main.php");
}

//creamos el formulario de login y registro
echo'<div id="loginbar"><form method="POST" action="Login.php">
Usuario: <input type="text" name="userlog" id="userlog">
Contraseña: <input type="text" name="passwordlog" id="passwordlog">
<input type="submit" value="Login"></form><div id="resultadologin" style="display: inline; margin-left: 5px;color:red;"></div>

<form method="POST" action="Registrar.php" style="float:right;">
Usuario: <input type="text" name="user" id="user">
Contraseña: <input type="text" name="password" id="pass">
Email: <input type="text" name="email" id="email">
<input type="submit" value="Registrarse">
<div id="resultadoregistrar" style="display: inline; margin-left: 5px;color:red;"></div></form></div>';
?>
```

**Registrar.php**

```php
<?php
//incluimos el archivo conexion.php para establecer la conexion y tener acceso a todas las funciones declaradas
include('Conexion.php');

//recogemos mediante POST los datos de user,password y email y los almacenamos en variables
$user = $_POST['user'];
$pass = $_POST['password'];
$email = $_POST['email'];

//si la variable del user,password o email se encuentran vacias damos mensaje que se deben completar todos los campos y detenemos la ejecucion del script.
if(empty($user) || empty($pass) || empty($email)){
    echo'Debe Completar Todos Los Campos';
    die();
} else {

//si la condicion anterior es falsa, encriptamos el user y pass con MD5, y generamos un codigo al azar de 16 digitos el cual sera usado para la activacion de la cuenta
    $user=encriptar($user);
    $pass=encriptar($pass);
    $cod_act = substr(md5(rand()),0,16);
}

//selecionamos de la tabla miembors donde user sea igual a la variable user
$comprobacion = mysql_query("SELECT user FROM miembros WHERE user = '$user'");

//si el numero de columnas devueltos es mayor de 0, significa que ya existe el usuario,entonces le informamos que elija otro nick
if(mysql_num_rows($comprobacion) > 0){
    echo'Nick En Uso Elije Otro';

//si lo anterior es falso, hacemos la misma comprobacion pero esta vez con el email y en caso de ser verdadera se lo informamos.
} elseif(mysql_num_rows(mysql_query("SELECT user FROM miembros WHERE email = '$email'")) > 0){
    echo'Email En Uso Elije Otro';
    } else {

//si todo lo anterior es falso, significa que podemos registrar el user, insertamos en la tabla miembros, en los campos user:variable user, pass:variable pass, email:variable email,activada:0, ya que la cuenta no esta activada ( perdon la redundacia), y en cod_act el codigo generado para la activacion.
    $agregar=mysql_query("INSERT INTO miembros (user,pass,email,activada,cod_act) VALUES ('$user','$pass','$email',0,'$cod_act')");
    if($agregar){
//si se agrega correctamente damos un mensaje de que se registro con exito y llamamos a la funcion enviar_email definida en conexion.php con los parametros email,usuario, y codigo de activacion
        echo'Te Has Registrado Con Exito, Activa Tu Cuenta Para Jugar';
        //echo"http://localhost/validar.php?user=$user&cod=$cod_act";
        enviar_mail($email,$user,$cod_act);
    }else{
//en caso de no poder insertar el nuevo usuario dejamos un codigo de error.
        echo'Hubo Un Error Al Intentar Registrarte, Intentalo De Nuevo';
    }
}
?>
```

**Validar.php**

```php
<?php
//incluimos conexion para establecer la conexion con la base y usar las funciones antes declaradas.
include('Conexion.php');

//recogemos mediante GET el valor MD% del user y el codigo de activacion y lo almacenamos en variables
$user = $_GET['user'];
$cod = $_GET['cod'];

//consultamos a la base los campos user,cod_act de la tabla miembros donde user sea igual a la variable user, cod_act sea igual a la variable cod_act y activada sea igual a 0
$validar = mysql_query("SELECT user,cod_act FROM miembros WHERE user='$user' AND cod_act = '$cod' AND activada = 0");

//si el numero devuelto de columnas es 0 significa que ya valido la cuenta, entonces damos mensaje de esto.
if(mysql_num_rows($validar) == 0){
    echo'Ya Validaste Tu Cuenta';
}else{

//en caso de ser falso lo anterior, cambiamos el valor activada a 1 donde user sea igual a la variable user de la tabla miembros
    $activar = mysql_query("UPDATE miembros SET activada=1 WHERE user = '$user'");

    if($activar){
        echo'Cuenta Activada Con Exito, Ya Puedes Jugar';
// si se cambia con exito, se muestra un mensaje informandolo
    }else{
//de no ser asi tambien se lo informa
        echo'Error Al Intentar Activar La Cuenta';
    }
}
?>
```

**Login.php**

```php
<?php
//incluimos conexion.php y almacenamos en variables los datos pasados por POST que son user y pass
include('Coneccion.php');
$user=$_POST['userlog'];
$pass=$_POST['passwordlog'];

//si la variable user esta vacia le informamos que debe completar el campo.
if(empty($user)){
    echo'Debe Colocar El User';
    die();
}

//al igual lo hacemos con la pass.
if(empty($pass)){
    echo'Debe Colocar La Contraseña';
    die();
}

//encriptamos el user y la pass para poder hacer la comprobacion en la base y almacenamos en la variable usermostrar el nombre del user actual.
$usermostrar=$user;
$user=encriptar($_POST['userlog']);
$pass=encriptar($_POST['passwordlog']);

//seleccionamos activada de la tabal miembros donde user sea igual a la variable user y pass sea igual a la variable dada
$loguear = mysql_query("SELECT activada FROM miembros WHERE user = '$user' AND pass = '$pass'");

if(mysql_num_rows($loguear) == 0){
//si devuelve 0 columnas significa que el user o el pass son incorrectos asi que se lo informamos y detenemos el script
    echo'Usario O Clave Invalida';
    die();
}

//almacenamos en un array loguear2 el valor de los campos devueltos por la consulta loguear.
$loguear2 = mysql_fetch_assoc($loguear);

if($loguear2['activada'] == 0){
    echo'Debe Activar Su Cuenta Para Poder Jugar';
//si activada, que es el campo que seleccionamos es 0, informamos que debe activar su cuenta para poder usarla
}else{

//en caso de no ser asi, iniciamos los datos de sesion y almacenamos en ella el nombre del user actual y su valor en MD5,luego redirigimos al main.php y asi seria como el user estaria logueado.
    session_start();
    $_SESSION['usuario'] = $usermostrar;
    $_SESSION['usuariomd5'] = $user;
        header("Location: main.php");
}
?>
```

**Main.php**

```php
<?php
//iniciamos datos de sesion y comprobamos que este definida la variable usuario, en caso de no estarlo dirigimos al index, pero en caso de estarlo, "imprimimos" un boton de deslogueo y una imagen con texto a modo ilustrativo.
session_start();
if(!isset($_SESSION['usuario'])){
    header("Location: index.php");

}else{
include('Incluir.php');
    echo '<a href="salir.php" title="Cerrar Sesión"><img src="/Images/close.png" align="right"></a>
    <img src="Images/money.png"><b>100</b>
    Mis Lugares';
}


?>
```

**Salir.php**

```php
<?php
//iniciamos datos de sesion
session_start();

//si no esta definido la variable usuario dirigimos al index
if(!isset($_SESSION['usuario'])){
    header("Location: index.php");
}else{

//en caso de estar definida destruimos todos los datos de sesion y dirigimos al index
    session_destroy();
    header("Location: index.php");
}
?>
```

**Cualquier Duda,Comentario,Mejora O Agradecimiento Comenten Y Sepan Por Lo Menos Agradecer.**
