---
title: Creating an edit-in-place in AngularJS
date: 2015-08-11
issueId: 21
---

Today we are going to create an edit in place directive for angularjs. [Here](http://pudymody.github.io/angular-edit-in-place/) you got a demo so you can see what it's about or if you already have some knowledge about angular and just only want to read the code [here](https://github.com/pudymody/angular-edit-in-place) its the repository

So, lets start building things.
First, we need a simple structure for our project, and angular attributes so we can bootstrap it.
```html
<!doctype html>
<html lang="en" ng-app="App">
<head>
	<meta charset="UTF-8">
	<title>Document</title>
	<script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.4.3/angular.min.js"></script>
</head>
<body ng-controller="main">
</body>
</html>
```


Now, we have to create our controller so we can bootstrap our app, and add an scope var to store our model.
```js
var App = angular.module('App', [] );
	App.controller('main', function( $scope ){
		$scope.name = 'Federico';
	});
```

Then, we need to create a new file called *edit-in-place.js* where we are going to make our directive (*im going to explain it after*)
```js
var App = angular.module('EditInPlace', []);
App.directive("clickToEdit", function() {
	var editorTemplate = '<div class="click-to-edit">' +
							'<div ng-hide="view.editorEnabled" ng-click="enableEditor()" class="click-to-edit-value">' +
								'{{value}} ' +
							'</div>' +
							'<div ng-show="view.editorEnabled">' +
								'<input class="click-to-edit-input" ng-model="view.editableValue">' +
								'<a ng-click="save()" class="click-to-edit-btn save">Save</a>' +
								'<a ng-click="disableEditor()" class="click-to-edit-btn close">Cancel</a>.' +
							'</div>' +
						'</div>';

	return {
		restrict: "A",
		replace: true,
		template: editorTemplate,
		scope: {
			value: "=clickToEdit",
		},
		controller: function($scope, $element) {
			$scope.view = {
				editableValue: $scope.value,
				editorEnabled: false
			};

			$scope.enableEditor = function() {
				$scope.view.editorEnabled = true;
				$scope.view.editableValue = $scope.value;
			};

			$scope.disableEditor = function() {
				$scope.view.editorEnabled = false;
			};

			$scope.save = function() {
				$scope.value = $scope.view.editableValue;
				$scope.disableEditor();
			};
		}
	};
});
```

Now im going to explain whats happening here.

In the first line, we are creating a module name *EditInPlace* to store our directive, and in the following one, we are declarating our directive called *clickToEdit*.
After that, we declare a var with our template, which works the following way.

* When the editor is disabled, we hide our first div which yous our value, and when clicked, we enable the editor.
* When the editor is enabled, we show the second div which is our editor. It has an input binded to the model *editableValue*. And then the two inputs for Save and cancel.

In our directive declaration we have to return an object with some properties ( [You can read the docs for more info](https://docs.angularjs.org/guide/directive) ), here we are returning the following ones:

* *restrict:* Here we define if our directive is restricted to an **Attribute (A)** , **Element (E)** or **Class (C)**. In our case we are going to use attributes
* *replace:* Here we're telling angular to replace our element with our defined template
* *template:* I think its self explained, but in case not, it defines our directive template
* *scope:* This is one of the most imporant things in our template, here we are retrieving the attribute called click-to-edit and two-ways binding it to our scope, so whatever change made to it, will be reflected everywhere.
* *controller:* Here we define our controller functions. First, we set the editor as disabled, and store our attributed passed. Then we define our 3 main functions.
	* enableEditor: Here we set the editor as enabled, and retrieve the current value to our *internal* model.
	* disableEditor: We disable our editor (*Really?*)
	* save: Here we set our value to the current *internal* value and disable the editor.

Now, we have to append our script and inject it, so after our angular injection we are going to add our current file
```html
<script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.4.3/angular.min.js"></script>
<script src="edit-in-place.js"></script>
```

And in our app declaration we have to insert it as a dependency
```js
var App = angular.module('Ingresos', ['EditInPlace'] );
```

Now we only need to add an element, add our new attribute and pass it our model of our scope
```html
<span click-to-edit="name"></span>
```
