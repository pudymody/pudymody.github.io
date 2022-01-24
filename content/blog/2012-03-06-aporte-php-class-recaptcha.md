---
title: "[Aporte][PHP][Class] Recaptcha"
date: 2012-03-06
issueId: 13
---
bueno, esta vez vengo a entregarles, una clase en php para el uso de [ReCaptcha](http://www.google.com/recaptcha/learnmore). Antes que todo, tienen que registrase [aca](https://www.google.com/recaptcha/admin/create) y crear un par de llaves (si estan logeados con una cuenta de google, no necesitaran registrarse.)

luego de crear las llaves, creamos un archivo llamado recaptcha.class.php, con el siguiente contenido en el:

```php
<?php
class Recaptcha {
    private $public_key,$secret_key;

    public function __construct($public,$secret){
        $this->public_key = $public;
        $this->secret_key = $secret;
    }

    public function show($theme = 'white'){
        $themes = array('red','white','blackglass','clean');
        if(!in_array($theme,$themes)){$theme = 'white';}

        return '
            <script type="text/javascript">var RecaptchaOptions = {theme : ''.$theme.''};</script>
            <script type="text/javascript" src="http://www.google.com/recaptcha/api/challenge?k='.$this->public_key.'"></script>
            <noscript>
                <iframe src="http://www.google.com/recaptcha/api/noscript?k='.$this->public_key.'" height="300" width="500" frameborder="0"></iframe><br>
                <textarea name="recaptcha_challenge_field" rows="3" cols="40"></textarea>
                <input type="hidden" name="recaptcha_response_field" value="manual_challenge">
            </noscript>
        ';
    }

    public function check($challenge,$response){
        $file = file_get_contents("http://www.google.com/recaptcha/api/verify?privatekey={$this->secret_key}&remoteip={$_SERVER['REMOTE_ADDR']}&challenge={$challenge}&response=".urlencode($response));
        $respuesta = explode("n",$file);
        if($respuesta[0] == 'true'){
            return true;
        }else{
            return false;
        }
    }
}
```

ahora para usarlo solo tienen que hacer lo siguiente.

```php
<?php
require_once('recaptcha.class.php');
$captcha = new Recaptcha('ACA TU KEY PUBLICA','ACA TU KEY SECRETA');
```

para mostrarlo se hace de la siguiente manera:

```php
<?php
$captcha->show('DISEÑO DESEADO');
```

el diseño puede ser: red, white, blackglass, clean

![Diseños de los distintos temas](/static/imgs/aporte-php-class-recaptcha/designs.png)

y despues para comprobar solo tienen que hacer

```php
<?php
if($captcha->check($challenge,$response)){
echo 'captcha correcto';
}else{
echo 'captcha incorrecto';
}
?>
```

$challenge y $response son dos variables con los valores de los campos del captcha del formulario,

que los pueden obtener via $_POST cuando hacen el submit.

```php
<?php
$challenge = $_POST['recaptcha_challenge_field'];
$response = $_POST['recaptcha_response_field'];
?>
```

o via jquery si desean enviarlo por ajax

```js
var challenge = $('#recaptcha_challenge_field').val();
var response = $('#recaptcha_response_field').val();
```
