---
title: "[Aporte][PHP][Class] Sistema de mensajeria para tu sitio"
date: 2011-04-29
---
Bueno, leyendo el siguiente [tema](http://www.taringa.net/comunidades/webdesign/2570503/%255BConsulta+PHP%255D+Mensajer%25C3%25ADa+interna%253A+usuario+elimina+sus+mp.html) de [@macadamQuejoso](https://www.taringa.net/macadamQuejoso) , se me ocurrio crear un sistema de mensajeria hecho en POO ( programacion orientada a objetos) para ir practicando un poco esto de POO, incluye lo escencial.

primero tienen que crear una tabla con el nombre que quieran, pero de la siguiente manera

```sql
`ID` int(11) NOT NULL AUTO_INCREMENT,
`from` varchar(32) NOT NULL,
`to` varchar(32) NOT NULL,
`subject` text NOT NULL,
`body` text NOT NULL,
`isread` tinyint(1) NOT NULL,
`deletefrom` tinyint(1) NOT NULL,
`deleteto` tinyint(1) NOT NULL,
PRIMARY KEY (`ID`)
```

antes de usar el sistema tienen que conectar y seleccionar la base de mysql asi

```php
<?php
mysql_connect('SERVER','USER','PASS');
mysql_select_db('BASE');
?>
```


Ahora la clase que deben utilizar, la documente toda en el codigo asi que no voy a dar explicaciones aca..

```php
<?php
class mensajeria{
    //creamos una variable privada donde almacenaremos el nombre de la tabla donde se almacenan los mensajes
    private $tabla;
    
    //al crear la clase pasamos como parametro el nombre de la base, si esta vacio doy un mensaje de error,si no lo almaceno en la variable privada $tabla
    public function __construct($base){
        if(empty($base)){
            die('Debe Seleccionar Una Base Para Poder Iniciar El Sistema De Mensajeria');
        }else{
            $this->tabla = $base;
        }
    }

    //pasamos como parametros el nombre del usuario que envia,a quien,el asunto y el mensaje para luego insertarlo en la tabla.
    //el parametro isread establece si el mensaje esta leido o no.
    //deletefrom define si el mensaje es borrado de la bandeja de salida (autor)
    //deleteto define si el mensaje es borrado de la bandeja de entrada (receptor)
    public function enviar($de,$para,$asunto,$mensaje){
        $enviar = mysql_query("INSERT INTO $this->tabla (de,para,subject,body,isread,deletefrom,deleteto) VALUES ('$de','$para','$asunto','$mensaje',0,0,0)");
        if($enviar){
            return true;
        }else{
            return false;
        }
    }
    
    //pasamos como parametro el nombre del usuario, para luego de hacer una consulta a la tabla, recorrer con un bucle el resultado, almacenar en un array todos los datos.
    //devuelve un array similar a este
    //Array ( [0] => Array ( [ID] => 12 [From] => DE QUIEN [Subject] => ASUNTO [IsRead] => 0 SI NO ESTA LEIDO,EN CASO CONTRARIO 1 ) ) 
    public    function obtenerrecibidos ($user){
        if(empty($user)){
            die('Debe Pasar Como Parametro Un Usuario Del Cual Obtener Los Mensajes');
        }else{
            $recibidos = mysql_query("SELECT ID,de,subject,isread FROM $this->tabla WHERE para = '$user' AND deleteto = 0");
            if(mysql_num_rows($recibidos) > 0){
                while ($r = mysql_fetch_assoc($recibidos)){
                    $mensajes[] = array(
                        'ID'=>$r['ID'],
                        'From'=>$r['de'],
                        'Subject'=>$r['subject'],
                        'IsRead'=>$r['isread'],
                    );
                }
                return $mensajes;
            }else{
                return 'No Tienes Ningun Mensaje';
            }
        }
    }
    
    //esta funcion es exactamente igual a la anterior, solo que obtiene los mensajes enviados, devolviendo un array similar a este
    //Array ( [0] => Array ( [ID] => 12 [To] => A QUIEN [Subject] => ASUNTO) ) 
    public function obtenerenviados ($user){
        if(empty($user)){
            die('Debe Pasar Como Parametro Un Usuario Del Cual Obtener Los Mensajes');
        }else{
            $recibidos = mysql_query("SELECT ID,para,subject FROM $this->tabla WHERE de = '$user' AND deletefrom = 0");
            if(mysql_num_rows($recibidos) > 0){
                while ($r = mysql_fetch_assoc($recibidos)){
                    $mensajes[] = array(
                        'ID'=>$r['ID'],
                        'To'=>$r['para'],
                        'Subject'=>$r['subject'],
                    );
                }
                return $mensajes;
            }else{
                return 'No Enviaste Ningun Mensaje';
            }
        }
    }
    
    //pasamos como parametro el id del mensaje, para luego de hacer la consulta a la tabla, devolver un array con todos los datos similar a este
    //Array ( [0] => Array ( [From] => DE QUIEN [Subject] => ASUNTO [Body] => MENSAJE) ) 
    public function ver($id){
        if(empty($id)){
            return 'Debe Pasar Como Parametro Un ID De Mensaje Para Ver';
        }else{
            $ver = mysql_query("SELECT de,subject,body FROM mensajes");
            while ($r = mysql_fetch_assoc($ver)){
                $datosmensaje = array(
                    'From'=> $r['de'],
                    'Subject'=> $r['subject'],
                    'Body'=> $r['body'],
                );
            }
            $marcarleido = mysql_query("UPDATE mensajes SET isread=1 WHERE ID = $id");
            return $datosmensaje;
        }
    
    }
    
    //borra de la bandeja de entrada el mensaje con id pasado por parametro
    public function borrarrecibido ($id){
        if(empty($id)){
            return 'Debe Pasar Como Parametro Un ID De Mensaje Para Borrar';
        }else{
            $borrarrecibido = mysql_query("UPDATE mensajes SET deleteto=1 WHERE ID=$id");
            if($borrarrecibido){
                return true;
            }else{
                return false;
            }
        }    
    }
    
    //borra de la bandeja de salida el mensaje con id pasado por parametro
    public function borrarenviado ($id){
        if(empty($id)){
            return 'Debe Pasar Como Parametro Un ID De Mensaje Para Borrar';
        }else{
            $borrarenviado = mysql_query("UPDATE mensajes SET deletefrom=1 WHERE ID=$id");
            if($borrarenviado){
                return true;
            }else{
                return false;
            }
        }    
    }    

}
?>
```

y se usa de la siguiente manera..

```php
<?php
//creamos una nueva instancia de la clase
$mensjaes = new mensajeria('ACA NOMBRE DE LA BASE');

//para enviar mensaje, pasando parametros
$mensjaes->enviar('DE','PARA','ASUNTO','MENSAJE');

//devuelve un array con los mensajes recibidos del user pasado como parametro
$mensjaes->obtenerrecibidos('USER');

//devuelve un array con los mensajes enviados del user pasado como parametro
$mensjaes->obtenerenviados('USER');

//devuelve un array con los datos del mensaje pasado como parametro a traves de su ID 
$mensjaes->ver('ID');

//borra de la baneja de enrtada el mensaje pasado como parametro a traves de su ID
$mensjaes->borrarrecibido('ID');

//borra de la baneja de salida el mensaje pasado como parametro a traves de su ID
$mensjaes->borrarenviado('ID');
?>
```

PD OLVIDADA : Lo Realize En POO Para Ir Practicando Ademas Al Tener Que Realizar Un Cambio, Lo Haces En La Clase, Y Listo, Cambias Absolutamente Casi Todo El Sitio
