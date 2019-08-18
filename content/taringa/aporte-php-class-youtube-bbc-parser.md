---
title: "[Aporte][PHP][Class] Youtube BBC parser"
date: 2011-09-05
---
Bueno, esta vez les traigo un bbcode parser para youtube, el cual detecta los links que son antecedidos por un espacio o por el principio de la linea.
Es mi primer code en POO, cualquier sugerencia es bienvenida.

```php
<?php
class YoutubeBBC {
    private $body, $data = array();
    
    public function __construct($string){
        $this->body = $string;
    }
    
    public function GetId(){
        (empty($this->body)) ? die('Debe Especificar El String') : '';
        preg_match_all('~(?<=s|^)(?:https?://)?(?:www.)?youtube.com/watch?v=([w-]{0,11})~',$this->body,$IDS);
        if(!empty($IDS[1])){
            foreach($IDS[1] as $id){
                $this->data[$id]['ID'] = $id;
            }
            
        }else{
            die("Link De Youtube Invalido");
        }
    }
    
    public function GetThumbs(){
        (empty($this->body)) ? die('Debe Especificar El String') : '';
        (empty($this->data)) ? $this->GetId() : '' ;
        foreach($this->data as $id){
            $this->data[$id['ID']]['Thumbs'] = array(
                '0' => 'http://img.youtube.com/vi/'. $id['ID'] .'/0.jpg',
                '1' => 'http://img.youtube.com/vi/'. $id['ID'] .'/1.jpg',
                '2' => 'http://img.youtube.com/vi/'. $id['ID'] .'/2.jpg',
                '3' => 'http://img.youtube.com/vi/'. $id['ID'] .'/3.jpg',
            );
        }
    }
    
    public function GetEmbed($width = '640', $height = '385'){
        (empty($this->body)) ? die('Debe Especificar El String') : '';
        (empty($this->data)) ? $this->GetId() : '' ;
        foreach($this->data as $id){
                $this->data[$id['ID']]['Embed'] = '<center><embed width="'.$width.'px" height="'.$height.'px" wmode="transparent" autoplay="false" allowfullscreen="true" type="application/x-shockwave-flash" quality="high" src="http://www.youtube.com/v/'.$id['ID'].'"></center>';
        }
    }
    
    public function GetData(){
        (empty($this->body)) ? die('Debe Especificar El String') : '';
        (empty($this->data)) ? $this->GetId() : '' ;
        return $this->data;
    }
}
?>
```

Se usa asi:

```php
<?php
$BBC = new YoutubeBBC("http://www.youtube.com/watch?v=uelHwf8o7_U&feature=feedrec http://www.youtube.com/watch?v=SUMcA--ejOc&feature=feedrec"); //creamos un nuevo objeto pasando el texto con los links
$BBC->GetID(); //obtenemos los ids de los videos
$BBC->GetThumbs(); //obtenemos los thumbs de los videos
$BBC->GetEmbed(); //obtenemos el code embed de los videos, se puede pasar como primer parametro el ancho y como segundo el alto, por default 640x385
$datos = $BBC->GetData(); //obtenemos el array con todos los datos anteriores y lo almacenamos en $datos
?>
```

lo que devolvera un array como el siguiente;

```php
Array
(
    [uelHwf8o7_U] => Array
        (
            [ID] => uelHwf8o7_U
            [Thumbs] => Array
                (
                    [0] => http://img.youtube.com/vi/uelHwf8o7_U/0.jpg
                    [1] => http://img.youtube.com/vi/uelHwf8o7_U/1.jpg
                    [2] => http://img.youtube.com/vi/uelHwf8o7_U/2.jpg
                    [3] => http://img.youtube.com/vi/uelHwf8o7_U/3.jpg
                )

            [Embed] => <center><embed width="640px" height="385px" src="http://www.youtube.com/v/uelHwf8o7_U" quality="high" type="application/x-shockwave-flash" allowfullscreen="true" autoplay="false" wmode="transparent"></center>
        )

    [SUMcA--ejOc] => Array
        (
            [ID] => SUMcA--ejOc
            [Thumbs] => Array
                (
                    [0] => http://img.youtube.com/vi/SUMcA--ejOc/0.jpg
                    [1] => http://img.youtube.com/vi/SUMcA--ejOc/1.jpg
                    [2] => http://img.youtube.com/vi/SUMcA--ejOc/2.jpg
                    [3] => http://img.youtube.com/vi/SUMcA--ejOc/3.jpg
                )

            [Embed] => <center><embed width="640px" height="385px" src="http://www.youtube.com/v/SUMcA--ejOc" quality="high" type="application/x-shockwave-flash" allowfullscreen="true" autoplay="false" wmode="transparent"></center>
        )

) 
```
