---
title: Pasajes del mes en trenes argentinos
date: 2022-07-23
issueId: 60
---

Sacar pasajes en [Trenes argentinos](https://webventas.sofse.gob.ar/) es mas dificil que saber [que tiene sancor bebe 3](https://www.youtube.com/watch?v=G1RAEhQ6VdI).

Elegis fecha de partida, y te muestra 3 dias hacia adelante y hacia atras. Si sabes que a partir de tal dia podes salir, tenes que buscar 3 dias hacia adelante, para poder tener como inicial el que realmente queres salir, y aun asi solo podes ver pasajes de esa semana.

Capaz te das cuenta que podes elegir como fecha de vuelta la semana siguiente, para poder ver pasajes de la semana que queres salir y la siguiente. Pero asi perdes la posibilidad de tambien buscar pasajes para la vuelta.

Por que no puedo ver todos los pasajes del mes, es algo que escapa mi comprension. Asi que no me quedo otra opcion que hacer un script para buscar en los dos meses siguientes de la fecha elegida. Evitando tener que hacer todas estas sumas y calculos absurdos.

Si tenes conocimientos, podes ejecutarlo desde la consola del navegador (F12 o Ctrl+Shift+I).

```js
(function() {
	function isBefore(date, dateToCompare){
		return date.getTime() < dateToCompare.getTime()
	}

	function format_date(date){
		const day = String(date.getDate()).padStart(2, "0");
		const month = String(date.getMonth() + 1).padStart(2, "0");
		const year = date.getFullYear();

		return `${day}/${month}/${year}`;
	}

	function parse(date){
		const tokens = date.split("/").map( t => parseInt(t, 10) );
		return new Date(tokens[2], tokens[1] - 1, tokens[0]);
	}

	function addDays(n){
		return function(date){
			let copy = new Date(date);
			copy.setDate( date.getDate() + n );
			return copy;
		}
	}

	function addMonths(n){
		return function(date){
			let copy = new Date(date);
			copy.setMonth( date.getMonth() + n );
			return copy;
		}
	}

	const add3Days = addDays(3);
	const add7Days = addDays(7);
	const add3Months = addMonths(3);

	const parser = new DOMParser();

	const $button = document.createElement("button");
	$button.className = "btn_gral btn btn-block";
	$button.innerText = "BUSCAR PROXIMO";
	$button.addEventListener("click", submit);
	document.getElementById("form_busqueda").appendChild($button);

	let $results = document.createElement("div");
	$results.style.background = "aliceblue";
	$results.style.padding = "1rem";
	$results.style.display = "flex";
	$results.id = "MY_SUPER_ID";
	$results.style.overflowX = "auto";
	$results.style.inset = 0;
	$results.style.zIndex = 2;
	document.body.prepend($results);

	function submit(e){
		document.body.style.cursor = "wait";
		$button.disabled = true;
		$results.style.position = "fixed";
		$results.innerHTML = "";

		const fecha_ida = document.getElementById("fecha_ida").value;
		const start_date = add3Days(parse(fecha_ida));
		const last_day = add3Months(start_date);
		const dates = [];

		let start = start_date;
		while( isBefore(start, last_day) ){
			let end = add7Days(start);
			dates.push([
				format_date(start),
				format_date(end),
			]);

			start = add7Days(end);
		}

		Promise.allSettled(
			dates.map( ([inicio,fin]) => ({ origen: document.getElementById("origen").value, destino: document.getElementById("destino").value, fecha_ida: inicio, fecha_vuelta: fin, adulto: document.getElementById("adulto").value }) ).map( obj => search(obj) )
		)
		.then( results => {
			let available = results.filter( p => p.status == "fulfilled" ).map( p => p.value ).flat();
			$results.innerHTML = [...new Map(available).entries()].map( ([dia,cant]) => `<div class="p-1"><div class="dia_disponible" style="background:#fff"><div class="py-2"><div class="pb-3"><span class="dia_numero">${dia}</span></div><div class="disponibles"><p>${cant}</p></div></div></div></div>`).join("");

			document.body.style.cursor = null;
			$button.disabled = false;
			$results.style.position = "initial";
			$results.scrollIntoView({ behavior: "smooth" });
		});

		e.preventDefault();
		e.stopPropagation();
		return false;
	}

	async function search({ origen, destino, fecha_ida, fecha_vuelta, adulto, jubilado, discapacitado, menor, bebe }){
		const query = new URLSearchParams({
			"busqueda[tipo_viaje]": "2",
			"busqueda[origen]": origen,
			"busqueda[destino]": destino,
			"busqueda[fecha_ida]": fecha_ida,
			"busqueda[fecha_vuelta]": fecha_vuelta,
			"busqueda[cantidad_pasajeros][adulto]": adulto,
			"busqueda[cantidad_pasajeros][jubilado]": 0,
			"busqueda[cantidad_pasajeros][discapacitado]": 0,
			"busqueda[cantidad_pasajeros][menor]": 0,
			"busqueda[cantidad_pasajeros][bebe]": 0
		});
		const req = await fetch("https://webventas.sofse.gob.ar/calendario.php", {
			"body": query,
			"method": "POST"
		}).then( r => r.text() );
		const doc = parser.parseFromString(req,"text/html");
		const dias_ida = [...doc.querySelectorAll("#calendario_ida .web div[class*=dia_]")]
			.filter( i => i.className.indexOf("dia_disponible") > -1 )
			.map( i => ([i.querySelector(".dia_numero").textContent.trim(),i.querySelector(".disponibles").textContent.trim() ]));
		const dias_vuelta = [...doc.querySelectorAll("#calendario_vuelta .web div[class*=dia_]")]
			.filter( i => i.className.indexOf("dia_disponible") > -1 )
			.map( i => ([i.querySelector(".dia_numero").textContent.trim(),i.querySelector(".disponibles").textContent.trim() ]));

		return dias_ida.concat(dias_vuelta);
	}
})()
```

Otra opcion es arrastrar el siguiente {{< rawhtml >}}<a href="javascript:(function()%7B(function()%20%7B%0A%09%09function%20isBefore(date%2C%20dateToCompare)%7B%0A%09%09%09%09return%20date.getTime()%20%3C%20dateToCompare.getTime()%0A%09%09%7D%0A%0A%09%09function%20format_date(date)%7B%0A%09%09%09%09const%20day%20%3D%20String(date.getDate()).padStart(2%2C%20%220%22)%3B%0A%09%09%09%09const%20month%20%3D%20String(date.getMonth()%20%2B%201).padStart(2%2C%20%220%22)%3B%0A%09%09%09%09const%20year%20%3D%20date.getFullYear()%3B%0A%0A%09%09%09%09return%20%60%24%7Bday%7D%2F%24%7Bmonth%7D%2F%24%7Byear%7D%60%3B%0A%09%09%7D%0A%0A%09%09function%20parse(date)%7B%0A%09%09%09%09const%20tokens%20%3D%20date.split(%22%2F%22).map(%20t%20%3D%3E%20parseInt(t%2C%2010)%20)%3B%0A%09%09%09%09return%20new%20Date(tokens%5B2%5D%2C%20tokens%5B1%5D%20-%201%2C%20tokens%5B0%5D)%3B%0A%09%09%7D%0A%0A%09%09function%20addDays(n)%7B%0A%09%09%09%09return%20function(date)%7B%0A%09%09%09%09%09%09let%20copy%20%3D%20new%20Date(date)%3B%0A%09%09%09%09%09%09copy.setDate(%20date.getDate()%20%2B%20n%20)%3B%0A%09%09%09%09%09%09return%20copy%3B%0A%09%09%09%09%7D%0A%09%09%7D%0A%0A%09%09function%20addMonths(n)%7B%0A%09%09%09%09return%20function(date)%7B%0A%09%09%09%09%09%09let%20copy%20%3D%20new%20Date(date)%3B%0A%09%09%09%09%09%09copy.setMonth(%20date.getMonth()%20%2B%20n%20)%3B%0A%09%09%09%09%09%09return%20copy%3B%0A%09%09%09%09%7D%0A%09%09%7D%0A%0A%09%09const%20add3Days%20%3D%20addDays(3)%3B%0A%09%09const%20add7Days%20%3D%20addDays(7)%3B%0A%09%09const%20add3Months%20%3D%20addMonths(3)%3B%0A%0A%09%09const%20parser%20%3D%20new%20DOMParser()%3B%0A%0A%09%09const%20%24button%20%3D%20document.createElement(%22button%22)%3B%0A%09%09%24button.className%20%3D%20%22btn_gral%20btn%20btn-block%22%3B%0A%09%09%24button.innerText%20%3D%20%22BUSCAR%20PROXIMO%22%3B%0A%09%09%24button.addEventListener(%22click%22%2C%20submit)%3B%0A%09%09document.getElementById(%22form_busqueda%22).appendChild(%24button)%3B%0A%0A%09%09let%20%24results%20%3D%20document.createElement(%22div%22)%3B%0A%09%09%24results.style.background%20%3D%20%22aliceblue%22%3B%0A%09%09%24results.style.padding%20%3D%20%221rem%22%3B%0A%09%09%24results.style.display%20%3D%20%22flex%22%3B%0A%09%09%24results.id%20%3D%20%22MY_SUPER_ID%22%3B%0A%09%09%24results.style.overflowX%20%3D%20%22auto%22%3B%0A%09%09%24results.style.inset%20%3D%200%3B%0A%09%09%24results.style.zIndex%20%3D%202%3B%0A%09%09document.body.prepend(%24results)%3B%0A%0A%09%09function%20submit(e)%7B%0A%09%09%09document.body.style.cursor%20%3D%20%22wait%22%3B%0A%09%09%09%24button.disabled%20%3D%20true%3B%0A%09%09%09%24results.style.position%20%3D%20%22fixed%22%3B%0A%09%09%09%24results.innerHTML%20%3D%20%22%22%3B%0A%0A%09%09%09const%20fecha_ida%20%3D%20document.getElementById(%22fecha_ida%22).value%3B%0A%09%09%09const%20start_date%20%3D%20add3Days(parse(fecha_ida))%3B%0A%09%09%09const%20last_day%20%3D%20add3Months(start_date)%3B%0A%09%09%09const%20dates%20%3D%20%5B%5D%3B%0A%0A%09%09%09let%20start%20%3D%20start_date%3B%0A%09%09%09while(%20isBefore(start%2C%20last_day)%20)%7B%0A%09%09%09%09let%20end%20%3D%20add7Days(start)%3B%0A%09%09%09%09dates.push(%5B%0A%09%09%09%09%09%09format_date(start)%2C%0A%09%09%09%09%09%09format_date(end)%2C%0A%09%09%09%09%5D)%3B%0A%0A%09%09%09%09start%20%3D%20add7Days(end)%3B%0A%09%09%09%7D%0A%0A%09%09%09Promise.allSettled(%0A%09%09%09%09dates.map(%20(%5Binicio%2Cfin%5D)%20%3D%3E%20(%7B%20origen%3A%20document.getElementById(%22origen%22).value%2C%20destino%3A%20document.getElementById(%22destino%22).value%2C%20fecha_ida%3A%20inicio%2C%20fecha_vuelta%3A%20fin%2C%20adulto%3A%20document.getElementById(%22adulto%22).value%20%7D)%20).map(%20obj%20%3D%3E%20search(obj)%20)%0A%09%09%09)%0A%09%09%09.then(%20results%20%3D%3E%20%7B%0A%09%09%09%09let%20available%20%3D%20results.filter(%20p%20%3D%3E%20p.status%20%3D%3D%20%22fulfilled%22%20).map(%20p%20%3D%3E%20p.value%20).flat()%3B%0A%09%09%09%09%24results.innerHTML%20%3D%20%5B...new%20Map(available).entries()%5D.map(%20(%5Bdia%2Ccant%5D)%20%3D%3E%20%60%3Cdiv%20class%3D%22p-1%22%3E%3Cdiv%20class%3D%22dia_disponible%22%20style%3D%22background%3A%23fff%22%3E%3Cdiv%20class%3D%22py-2%22%3E%3Cdiv%20class%3D%22pb-3%22%3E%3Cspan%20class%3D%22dia_numero%22%3E%24%7Bdia%7D%3C%2Fspan%3E%3C%2Fdiv%3E%3Cdiv%20class%3D%22disponibles%22%3E%3Cp%3E%24%7Bcant%7D%3C%2Fp%3E%3C%2Fdiv%3E%3C%2Fdiv%3E%3C%2Fdiv%3E%3C%2Fdiv%3E%60).join(%22%22)%3B%0A%0A%09%09%09%09document.body.style.cursor%20%3D%20null%3B%0A%09%09%09%09%24button.disabled%20%3D%20false%3B%0A%09%09%09%09%24results.style.position%20%3D%20%22initial%22%3B%0A%09%09%09%09%24results.scrollIntoView(%7B%20behavior%3A%20%22smooth%22%20%7D)%3B%0A%09%09%09%7D)%3B%0A%0A%09%09%09e.preventDefault()%3B%0A%09%09%09e.stopPropagation()%3B%0A%09%09%09return%20false%3B%0A%09%09%7D%0A%0A%09%09async%20function%20search(%7B%20origen%2C%20destino%2C%20fecha_ida%2C%20fecha_vuelta%2C%20adulto%2C%20jubilado%2C%20discapacitado%2C%20menor%2C%20bebe%20%7D)%7B%0A%09%09%09const%20query%20%3D%20new%20URLSearchParams(%7B%0A%09%09%09%09%22busqueda%5Btipo_viaje%5D%22%3A%20%222%22%2C%0A%09%09%09%09%22busqueda%5Borigen%5D%22%3A%20origen%2C%0A%09%09%09%09%22busqueda%5Bdestino%5D%22%3A%20destino%2C%0A%09%09%09%09%22busqueda%5Bfecha_ida%5D%22%3A%20fecha_ida%2C%0A%09%09%09%09%22busqueda%5Bfecha_vuelta%5D%22%3A%20fecha_vuelta%2C%0A%09%09%09%09%22busqueda%5Bcantidad_pasajeros%5D%5Badulto%5D%22%3A%20adulto%2C%0A%09%09%09%09%22busqueda%5Bcantidad_pasajeros%5D%5Bjubilado%5D%22%3A%200%2C%0A%09%09%09%09%22busqueda%5Bcantidad_pasajeros%5D%5Bdiscapacitado%5D%22%3A%200%2C%0A%09%09%09%09%22busqueda%5Bcantidad_pasajeros%5D%5Bmenor%5D%22%3A%200%2C%0A%09%09%09%09%22busqueda%5Bcantidad_pasajeros%5D%5Bbebe%5D%22%3A%200%0A%09%09%09%7D)%3B%0A%09%09%09const%20req%20%3D%20await%20fetch(%22https%3A%2F%2Fwebventas.sofse.gob.ar%2Fcalendario.php%22%2C%20%7B%0A%09%09%09%09%22body%22%3A%20query%2C%0A%09%09%09%09%22method%22%3A%20%22POST%22%0A%09%09%09%7D).then(%20r%20%3D%3E%20r.text()%20)%3B%0A%09%09%09const%20doc%20%3D%20parser.parseFromString(req%2C%22text%2Fhtml%22)%3B%0A%09%09%09const%20dias_ida%20%3D%20%5B...doc.querySelectorAll(%22%23calendario_ida%20.web%20div%5Bclass*%3Ddia_%5D%22)%5D%0A%09%09%09%09.filter(%20i%20%3D%3E%20i.className.indexOf(%22dia_disponible%22)%20%3E%20-1%20)%0A%09%09%09%09.map(%20i%20%3D%3E%20(%5Bi.querySelector(%22.dia_numero%22).textContent.trim()%2Ci.querySelector(%22.disponibles%22).textContent.trim()%20%5D))%3B%0A%09%09%20%20const%20dias_vuelta%20%3D%20%5B...doc.querySelectorAll(%22%23calendario_vuelta%20.web%20div%5Bclass*%3Ddia_%5D%22)%5D%0A%09%09%09%09.filter(%20i%20%3D%3E%20i.className.indexOf(%22dia_disponible%22)%20%3E%20-1%20)%0A%09%09%09%09.map(%20i%20%3D%3E%20(%5Bi.querySelector(%22.dia_numero%22).textContent.trim()%2Ci.querySelector(%22.disponibles%22).textContent.trim()%20%5D))%3B%0A%0A%09%09%09return%20dias_ida.concat(dias_vuelta)%3B%0A%09%09%7D%0A%7D)()%7D)()%3B">enlace</a>{{< /rawhtml >}}
 a la barra de favoritos, y una vez en el sitio de [Trenes argentinos](https://webventas.sofse.gob.ar/) clickearlo. Es importante que lo arrastres, ya que si lo clickeas desde aca, no va a suceder nada.

Una vez clickeado, en el formulario de busqueda va a aparecer un nuevo boton "Buscar proximo".

![Image](/static/imgs/pasajes-mes-trenes-argentinos/form.jpg)

Despues de llenar origen, destino, fecha a partir de la cual buscar, y cantidad de pasajeros, al apretarlo, y esperar un momento, va a mostrar al inicio de la pagina, arriba de todo, los pasajes que encuentre. En caso de no mostrar nada, puede ser que no haya. Es importante saber que solo son indicativos, si queres sacar los pasajes, vas a tener que buscar esa fecha en concreto con el formulario normal.

![Image](/static/imgs/pasajes-mes-trenes-argentinos/resultado.jpg)
