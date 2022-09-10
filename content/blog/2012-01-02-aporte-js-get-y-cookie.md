---
title: "[Aporte][JS] $_GET y $_COOKIE"
date: 2012-01-02
issueId: 11
---
Bueno, revisando el blog de aNieto2K, vi un aporte donde mostraba como usar el $_GET de php pero con javascript, ya sea porque necesitas obtener los datos con js,te es mas simple,curiosidad,te acostumbraste a php, o solo porque lo queres hacer.

asi que aca te dejo el code:

```js
;(function(window){
var
 $_GET = window.$_GET = {},
 $_VAN = window.$_VAN = {},
 location = window.location,
 search = location.search,
 href = location.href, 

 index = search.indexOf('?') != -1 ? search.indexOf('?') + 1 : 0,
 get = search.substr(index).split('&'),
 vanity = href.replace(/^https?://(.*?)//i, '').replace(/?.*$/i, '').split('/'); 

 for (var i in get){
 var split = get[i].split('=');
 $_GET[split[0]] = split[1]||null;
 }
 for (var i in vanity)
 $_VAN[i] = vanity[i]||null;
})(window);
```

y para usarlo, solo hacen como en php:

```js
$_GET['ID']
```

FUENTE : [https://www.anieto2k.com/2009/09/24/_get-en-javascript/](https://www.anieto2k.com/2009/09/24/_get-en-javascript/)

Basandome en exactamente el mismo codigo, cree este para utilizar las cookies con $_COOKIE

```js
String.prototype.trim = function(){ return this.replace(/^s+|s+$/g,'') }
;(function(window){
    var $_COOKIE = window.$_COOKIE = {};
    var cs = document.cookie.split(';');

    for (var i in cs){
        var name = cs[i].substr(0,cs[i].indexOf('=')).trim();
        var value = cs[i].substr(cs[i].indexOf('=') + 1);
        $_COOKIE[name] = value||null;
    }
})(window);
```

el cual utilizan con

```js
$_COOKIE['taringa_user_id'] 
```
