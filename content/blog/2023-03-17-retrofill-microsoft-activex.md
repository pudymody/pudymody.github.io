---
title: "Retrofill Microsoft ActiveX"
date: 2023-03-17
issueId: 103 
---

# Intro
This is the followup of my [previous post](/blog/2023-02-04-xfiles-game-web-standards/). If you want some background about how i arrived here, go read it, but you dont need it to understand this one. I will try to explain everything from scratch but some basic understanding about javascript or prototyped languages and parsers could be helpful.

What we are trying to do is pollyfill a Microsoft ActiveX control with CLSID of 333C7BC4-460F-11D0-BC04-0080C7055A83. Its called a *Tabular Data Control* or *TDC*. What it allows you to do is use tabular data like csv files from javascript.

I prefer to call it *retrofilling* because we are not writing code for things that will be available in the future, but for things that were available in the past and no longer works.

ActiveX is long dead, but today we have all the tools needed to write a **retrofill**.

# How it worked
Here is how it works, or at least what i could find around the internet and reading the source code.

There is the main tag with ```param``` childrens to configure how it works. This could also be set via javascript properties on the html DOM element. I dont know which ones would have precedence but i decided that js properties overwrite the DOM elements one.

Here are at least 5 that sets the following things:

- DataURL: Sets the url from where to fetch the data
- UseHeader: Sets if the first line are the column names
- FieldDelim: Sets the character used to separate fields
- TextQualifier: Sets the character used to quote the fields
- EscapeChar: Sets the character used to escape the TextQualifier character

```html
<OBJECT ID="tagList" CLASSID="CLSID:333C7BC4-460F-11D0-BC04-0080C7055A83">
 <PARAM NAME="DataURL" VALUE="tags.txt">
 <PARAM name=UseHeader value="TRUE">
 <PARAM name=FieldDelim value=",">
 <PARAM name=TextQualifier value='"'>
 <PARAM name=EscapeChar value='\'>
</OBJECT>
```

Next we have the methods and properties from the js side to access the data, iterate over and filter it, among other things.

```js
TDCElement.DataURL = "tags.txt"
TDCElement.UseHeader = "TRUE"
TDCElement.FieldDelim = ","
TDCElement.TextQualifier = '"';
TDCElement.EscapeChar = '\\';
TDCElement.sortAscending = true;
TDCElement.Sort = "fieldName";
TDCElement.caseSensitive = true;
TDCElement.filter = "fieldName='value'&fieldNumber>=5"
```

First of all we have the setters version of the params that we saw before. There is probably a need for the getters, but as i only made the things needed for the game to work, i never implemented them. Then we have the following ones, you could set them with param tags also, but i didnt see it used that way.

- sortAscending: Sets if the sorting is in ascending way
- Sort: Sets the field which will be used to sort the rows
- caseSensitive: Sets if the search is case sensitive
- filter: Sets the filter used for the search. This is the most interesting part about this and will have its own section in a moment.

Finally we have the methods needed to access the data. It works in an iterator pattern way. You have one to know how many rows you have, one to advance, go to the first item, to the last item, advance a given amount and finally one to get the value of the given field of the current item.

If you dont know what an iterator is, you could think about it as a list of items, and a way to move through them.

```js
TDCElement.recordset.moveFirst()
```
Moves the iterator to the first item.

```js
TDCElement.recordset.moveNext()
```
Moves the iterator to the next item.

```js
TDCElement.recordset.moveLast()
```
Moves the iterator to the last item.

```js
TDCElement.recordset.move(n)
```
Moves the iterator to the nth item.

```js
TDCElement.recordset.recordCount
```
Gets the total number of items.

```js
TDCElement.recordset("field")
```
Gets the field of the current item.

Something interesting about this design is that ```recordset``` works as a function and a property at the same time. A decision that i dont like, but this is how it was made. Here we will heavily use the prototype nature of javascript.

And the last one is the ```Reset``` method, the one used to filter and sort the data given the new settings params.
```js
TDCElement.Reset()
```

All of these methods works in a sync manner, so we will have to do some nasty things with ```XMLHttpRequest```.

# Custom element 
The first thing we have to do is define a custom element which allows us to set the params via properties or children ```param``` tags. Custom elements are a new thing in the js world which lets you define custom tags with user defined functionality. You do this by extending the ```HTMLElement``` class, which is the base of all DOM elements and then registering your component to a tag.

```js
class TDC extends HTMLElement {
	constructor(){
		super();

		this._params = new Map();
	}

	set DataURL(value){
		this._params.set("DataURL", value);
	}

	set UseHeader(value){
		this._params.set("UseHeader", value);
	}

	set FieldDelim(value){
		this._params.set("FieldDelim", value);
	}

	set TextQualifier(value){
		this._params.set("TextQualifier", value);
	}

	set EscapeChar(value){
		this._params.set("EscapeChar", value);
	}

	set sortAscending(value){
		this._params.set("sortAscending", value);
	}

	set Sort(value){
		this._params.set("Sort", value);
	}

	set caseSensitive(value){
		this._params.set("caseSensitive", value);
	}

	set filter(value){
		this._params.set("filter", value);
	}
}

customElements.define("poly-tdc", TDC);
```

With this, whenever we have a reference to a ```poly-tdc``` DOM element, we could set the properties for our params. Currently its the only way, we would allow to set them via ```param``` tags in a moment.

# Iterating our data
Next we will implement the methods needed for iterating over our data.

```js
class TDC extends HTMLElement {
	constructor(){
		super();

		this._params = new Map();
		this._data = null;
		this._index = 0;

	}

	// ...

	moveFirst(){
		this._index = 0;
	}

	moveNext(){
		this._index++;
	}

	moveLast(){
		this._index = this._data.length - 1;
	}

	move(index){
		this._index = index;
	}

	recordCount(){
		if( this._data != null ){
			return this._data.length;
		}else{
			return 0;
		}
	}

	recordset(field){
		return this._data[ this._index ][ field ];
	}
}
```

We add two new properties to hold our data and current index, and the new methods. If you know javascript you must be yelling that this wont work as i said before. ```TDCElement.recordset.moveFirst()``` will give you an error. And you are absolutely right, thats our next step.

```js
class TDC extends HTMLElement {
	constructor(){
		// ...

		this.moveFirst = this.moveFirst.bind(this);
		this.moveNext = this.moveNext.bind(this);
		this.moveLast = this.moveLast.bind(this);
		this.move = this.move.bind(this);
		this.recordset = this.recordset.bind(this);
		this.recordCount = this.recordCount.bind(this);
	}

	// ...
}
```

First we make sure that whenever the methods of the current poly-tdc element are called, the ```this``` variable is binded to the current element.

```js
class TDC extends HTMLElement {
	constructor(){
		// ...

		let recordsetProto = {
			moveFirst: this.moveFirst,
			moveNext: this.moveNext,
			moveLast: this.moveLast,
			move: this.move,
			_recordCount: this.recordCount
		};

		Object.defineProperty(recordsetProto, "recordCount", {
			enumerable: true,
			configurable: true,
			get(){ return this._recordCount() }
		});
		Object.setPrototypeOf( this.recordset, recordsetProto);
	}

	// ...
}
```

Here is where i said that we would use the prototype nature of javascript. We define a custom object that we will use as our custom prototype with our move methods and the count one. We also define a property called *recordCount* in our object, but with a custom getter.

Why is this you may ask? Well, the recordCount is used as a property, but our recordCount is a function, so we have to define a property that would return what our function returns.

And finally we set this object that we created as the prototype of our ```recordset``` function.

Dont know what prototypes are? Think of them as a chain of things. Whenever you look for a property in your object, if it is defined there, thats what will be returned. If not, it will look for it in its prototype. The prototype will do the same thing until we arrive at the first object which doesnt have a prototype.

So when we call ```recordset("field")``` we are using the function that we defined, but when we do ```recordset.moveNext()```, as ```recordset``` doesnt have the ```moveNext``` property, it will be looked in its prototype, in this case the custom object that we made, and it will return the function that have ```this``` binded to the current poly-tdc element.

# Firing things
The only thing left to do, is implement the ```Reset()``` method, which will glue everything and allow us to fetch and filter our data. I will show it in chunks to explain piece by piece.

```js
class TDC extends HTMLElement {
	// ...
	Reset(){
		const $params = Object.fromEntries(
			Array.from(this.querySelectorAll("param"))
			.map( p => [p.getAttribute("name"), p.getAttribute("value")] )
		);
		const attr_params = Object.fromEntries([...this._params.entries()]);
		let real_params = { ...$params, ...attr_params };
		real_params.UseHeader = real_params.UseHeader.toLowerCase() == "true";
	}
	// ...
}
```
First of all, we get all the `param` tags that are children of our poly-tdc element and get their name and value attributes. We make an object with them, having the name as key, and the value. We do the same with our `_params` property (the one we use to store when setting via js) and we merge both.

```js
import { parse as csvParse } from "csv-parse/browser/esm/sync";
class TDC extends HTMLElement {
	// ...
	Reset(){
		// ...
		const xhr = new XMLHttpRequest();
		xhr.open('GET', real_params.DataURL, false);
		xhr.send(null);

		let records = csvParse(xhr.responseText, {
			skip_empty_lines: true,
			columns: real_params.UseHeader,
			escape: real_params.EscapeChar,
			delimiter: real_params.FieldDelim,
			quote: real_params.TextQualifier
		});
	}
	// ...
}
```
Here we make a request to our url and parse its response as a csv file into the records variable using our defined params. Here is the nasty thing with XMLttpRequest, as our Reset method works in a sync manner (as this is how it was defined in its origin), we cant use fetch, or at least the async way. For the csv parsing we are using the [csv-parse](https://www.npmjs.com/package/csv-parse) library in its sync version for the same reason.

```js
// ...
import filterParser from "./grammar.jison"
class TDC extends HTMLElement {
	// ...
	Reset(){
		// ...
		if( real_params.filter.trim() ){
			const filterer = filterParser.parse(real_params.filter);
			records = records.filter(filterer);
		}

		if( real_params.Sort.trim() ){
			records.sort(function(a,b){
				if( real_params.sortAscending ){
					return a[real_params.Sort] <= b[real_params.Sort]
				}else{
					return a[real_params.Sort] >= b[real_params.Sort]
				}
			});
		}

		this._data = records;
		this._index = 0;
	}
	// ...
}
```

Here we apply the filter if we have any and sort the data. This isnt the most efficient way of doing it, but its good enough for now. If you are wondering what that *.jison* import is, or how the filterer works, i will explain in detail in the next section. For now, its a function that returns true or false when the given row is accepted or not by our filter. The jison file is preprocessed by [Rollup](https://rollupjs.org/) at build time. This is not standard js imports.

# The filterer
Here comes the star of the show. The reason why this is a standalone post and not a simple section in the previous one. First we have to understand how our filter property works. For this im going to use the example in the only [documentation](https://learn.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/platform-apis/ms531364(v=vs.85)) i could find.

## Syntax

```
(Column1 > 10 & Column3 = lime) | Column4 < 5
```
This filter matches any row that has a Column1 with a value greater than 10 and a Column3 equal to lime, or a Column4 less than 5. Something that if you know some programming is what you would expect.

But this is only one example, it doesnt tell us what operators are available or what are the rules of precendence between them. Luckily for us, in that documentation page, we have the full grammar.

```
Complex ::== Simple
 ::== Simple '&' Simple [ '&' Simple ... ]
 ::== Simple '|' Simple [ '|' Simple ... ]
Simple ::== '(' Complex ')'
 ::== Atom Relop Atom
Relop ::== '=' | '>' | '>=' | '<' | '<=' | '<>'
Atom ::== Characters up to a (, ), >, <, =, & or |
```

If you know something about grammars, maybe you recognize that this is written in [BNF](https://en.wikipedia.org/wiki/Backus%E2%80%93Naur_form). If not, i will try my best to explain what a grammar is.

Quoting [wikipedia](https://en.wikipedia.org/wiki/Formal_grammar):

> A formal grammar is a set of rules for rewriting strings, along with a "start symbol" from which rewriting starts. 

A rule is one of the lines of the previous code. They have two parts, the one to the left of the `::=` and the one to the right. Whenever you see an appearance of something in the left, you replace it with whats in the right. Starting from the "start symbol", which in this case is the one called *Complex*. Whats inside the *[ ... ]* its the BNF way of saying that this part is optional, you could put it or not. The *|* character is used to separate the different options. But it shouldnt be confused with '|' which is the literal character.

Lets see a derivation for our example filter to better understand it. A derivation is the needed replacements to generate the string. All derivations needs to end, you cant have something that is the left side of one of your rules.

*Each line corresponds to a replacement using the line in parens*
```
Complex

Simple '|' Simple (3)

'(' Complex ')' '|' Simple (4)

'(' Simple '&' Simple ')' '|' Simple (2)

'(' Atom Relop Atom '&' Simple ')' '|' Simple (5)

'(' Atom '>' Atom '&' Simple ')' '|' Simple (6)

'(' Atom '>' Atom '&' Atom Relop Atom ')' '|' Simple (5)

'(' Atom '>' Atom '&' Atom '=' Atom ')' '|' Simple (6)

'(' Atom '>' Atom '&' Atom '=' Atom ')' '|' Atom Relop Atom (5)

'(' Atom '>' Atom '&' Atom '=' Atom ')' '|' Atom '<' Atom (6)
```

With this, we can confirm that our example filter belongs to the grammar. So, a grammar is the set of strings that could be generated with some replacements of our rules.

And this is what a parser/compiler does, it takes a string, and tries to find the set of replacements needed to generate it. Although we could write one from scratch, i prefer to rely on tested tools.

In this case, as we are going to execute it in a javascript context, im going to use [jison](https://www.npmjs.com/package/jison) a javascript implementation of the [GNU Bison](https://www.gnu.org/software/bison/) software.

Our first step is to write the lexer rules in the jison syntax. A lexer is a set of rules that converts strings to a set of well defined and meaningful strings. In this case, we are converting spaces, carriage returns and tabs into nothing, AKA ignoring them. Anything between single or double quotes to the term ATOMQS/D (we are able to access the original string in the future), and any sucession of characters into the ATOMC. For every other symbol that we are interested, we only return it.

```
/* lexical grammar */
%lex

%%
[ \r\t]+                   {}
"'"[ \._\-\*0-9a-zA-Z]+"'" return 'ATOMQS';
"\""[ '\._\-\*0-9a-zA-Z]+"\"" return 'ATOMQD';
[0-9a-zA-Z]+  return 'ATOMC';
"&"                   return '&';
"|"                   return '|';
"("                   return '(';
")"                   return ')';
">="                   return '>=';
"<="                   return '<=';
"<>"                   return '<>';
"="                   return '=';
">"                   return '>';
"<"                   return '<';

/lex
```

Now we need to define our production rules. As our grammar was defined in BNF, and jison accepts it, its almost a copy and paste. We define from where to start using the `%start` directive.

```
%start expressions

%% /* language grammar */

expressions
    : complex
    ;

complex
    : simple
    | simple '&' simple complex_sub1
    | simple '|' simple complex_sub2
		;

complex_sub1
		: '&' simple complex_sub1
		|
		;

complex_sub2
		: '|' simple complex_sub1
		|
		;

simple
    : '(' complex ')'
    | atom relop atom
		;

relop 
    : '='
		| '<>'
    | '>'
    | '>='
		| '<'
    | '<='
		;
 
atom 
    : ATOMC
    | ATOMQS
    | ATOMQD
		;
```

## Semantics
Running this through jison will give us a parser which will return if the string belongs to the grammar or throw an error if not, but nothing more. It doesnt have any semantics nor functionality. So lets do this.

For this, jison allows us to define functionality in javascript to run per rule. I think it will be easier to understand if we represent our derivation as a graph. I will use three as an example, but the rest should be the same.

### `complex ::= simple '&' simple`
{{< rawhtml >}}
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 192.23 116">
  <g class="graph" transform="translate(4 112)">
    <g class="node">
      <ellipse cx="91.615" cy="-90" fill="none" stroke="#000" rx="27" ry="18"/>
      <text x="91.615" y="-85.8" font-family="Times,serif" font-size="14" text-anchor="middle">&amp;</text>
    </g>
    <g class="node">
      <ellipse cx="41.615" cy="-18" fill="none" stroke="#000" rx="41.731" ry="18"/>
      <text x="41.615" y="-13.8" font-family="Times,serif" font-size="14" text-anchor="middle">simple1</text>
    </g>
    <g class="edge">
      <path fill="none" stroke="#000" d="M80.27-73.662 59.44-43.67"/>
      <path stroke="#000" d="m62.192-41.495-8.579 6.218 2.83-10.21 5.749 3.992z"/>
    </g>
    <g class="node">
      <ellipse cx="142.615" cy="-18" fill="none" stroke="#000" rx="41.731" ry="18"/>
      <text x="142.615" y="-13.8" font-family="Times,serif" font-size="14" text-anchor="middle">simple2</text>
    </g>
    <g class="edge">
      <path fill="none" stroke="#000" d="m103.188-73.662 21.245 29.992"/>
      <path stroke="#000" d="m127.453-45.461 2.924 10.184-8.636-6.137 5.712-4.047z"/>
    </g>
  </g>
</svg>

{{< /rawhtml >}}

Lets suppose that `simple1` and `simple2` are already solved, and are two booleans (true or false). We could run a function that would return the value for this rule. *($$1 and $$3 is the jison way of referring to the different "parts" of the rule")*

```js
function(){
	return $$1 && $$3
}
```

### `complex ::= '&' simple complex_sub1`

I think this one is the hardest to grasp, because its something thats "inside" another rule, not a rule per se.

As you may be thinking, this could still be derived, but lets use only one level as it would only make the explanation harder.

{{< rawhtml >}}
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 306.36 44">
  <g class="graph" transform="translate(4 40)">
    <g class="node">
      <ellipse cx="27" cy="-18" fill="none" stroke="#000" rx="27" ry="18"/>
      <text x="27" y="-13.8" font-family="Times,serif" font-size="14" text-anchor="middle">&amp;</text>
    </g>
    <g class="node">
      <ellipse cx="109" cy="-18" fill="none" stroke="#000" rx="36.575" ry="18"/>
      <text x="109" y="-13.8" font-family="Times,serif" font-size="14" text-anchor="middle">simple</text>
    </g>
    <g class="node">
      <ellipse cx="231" cy="-18" fill="none" stroke="#000" rx="67.222" ry="18"/>
      <text x="231" y="-13.8" font-family="Times,serif" font-size="14" text-anchor="middle">complex_sub1</text>
    </g>
  </g>
</svg>

{{< /rawhtml >}}
In this one we could suppose similar things and do almost the same. The diferrences is that as we saw in the rules, `complex_sub1` could be empty, so we can check that. If its a boolean, we do the same as before, and if not, we return whatever is in the "simple" generation.

```js
function(){
	if($3 == undefined){
		return $2
	}else{
		return $2 && $3
	}
}
```

### `simple ::= atom relop atom`
{{< rawhtml >}}
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 166.35 116">
  <g class="graph" transform="translate(4 112)">
    <g class="node">
      <ellipse cx="35.176" cy="-18" fill="none" stroke="#000" rx="35.353" ry="18"/>
      <text x="35.176" y="-13.8" font-family="Times,serif" font-size="14" text-anchor="middle">atom1</text>
    </g>
    <g class="node">
      <ellipse cx="123.176" cy="-18" fill="none" stroke="#000" rx="35.353" ry="18"/>
      <text x="123.176" y="-13.8" font-family="Times,serif" font-size="14" text-anchor="middle">atom2</text>
    </g>
    <g class="node">
      <ellipse cx="79.176" cy="-90" fill="none" stroke="#000" rx="30.758" ry="18"/>
      <text x="79.176" y="-85.8" font-family="Times,serif" font-size="14" text-anchor="middle">relop</text>
    </g>
    <g class="edge">
      <path fill="none" stroke="#000" d="m68.749-72.937-17.552 28.72"/>
      <path stroke="#000" d="m54.035-42.148-8.201 6.707 2.228-10.358 5.973 3.651z"/>
    </g>
    <g class="edge">
      <path fill="none" stroke="#000" d="m89.603-72.937 17.552 28.72"/>
      <path stroke="#000" d="m110.29-45.799 2.228 10.358-8.201-6.707 5.973-3.651z"/>
    </g>
  </g>
</svg>
{{< /rawhtml >}}

Here lets suppose that relop is a function with the following signature `relop(a,b)` which returns a value. In this case a boolean, as all of our *relop* possible values *(=/<>/>/>=/</<=)* are comparation functions.

```js
function(){
	return $2($1,$3);
}
```

Here *$1* corresponds to *atom1*, *$3* to *atom3* and *$2* to *relop*

---

All the previous *suppose* doesnt present any problem, as this parsers executes from the bottom to the top. For more information look for *Bottom-Up Parsers*

This are the basics to how its implemented. If you read the [source code](IMPLEMENT ME) you will see a lot more things, like a ctx value passed around. This is so we could match against the current row that we are filtering. And hacky ways of checking if strings contains the * symbol, so we convert it to a [regexp](https://en.wikipedia.org/wiki/Regular_expression).

But as we now are returning a function from our start node whenever we parse a string of this grammar, jison will return us a function that we could use to filter our row, returning true or false if it passes the current filter.

**This is our `filterParser.parse` function**

# Glue code
We have the parser for our filter grammar, we have our custom element, the only thing left to do is join everything and provide some kind of build tools to simplify things. For this, im going to use [rollup.js](https://rollupjs.org/) with a custom plugin for jison files.[Baretest](https://volument.com/baretest) for testing some of the filters that i encounter while debugging.

```js
import pkg from 'jison';
const { Parser } = pkg;

import { createFilter, dataToEsm } from '@rollup/pluginutils';

const UMD_EXTRA = `if (typeof require !== 'undefined' && typeof exports !== 'undefined') {
exports.parser = parser;
exports.Parser = parser.Parser;
exports.parse = function () { return parser.parse.apply(parser, arguments); };
exports.main = function commonjsMain (args) {
    if (!args[1]) {
        console.log('Usage: '+args[0]+' FILE');
        process.exit(1);
    }
    var source = require('fs').readFileSync(require('path').normalize(args[1]), "utf8");
    return exports.parser.parse(source);
};
if (typeof module !== 'undefined' && require.main === module) {
  exports.main(process.argv.slice(1));
}
}`;

export default function jison(options = {}) {
  const filter = createFilter(options.include, options.exclude);

  return {
    name: 'jison',

    transform(code, id) {
      if (id.slice(-6) !== '.jison' || !filter(id)) return null;

			try  {
				const parser = new Parser(code);
				const generated = parser.generate();
				return {
					code: generated.slice(0,-UMD_EXTRA.length) + "export default parser",
					map: { mappings: '' }
				}
			}catch (err){
				console.log(err);
        const message = 'Could not parse JISON file';
        this.error({ message, id, cause: err });
        return null;
      }
    }
  };
}
```

This transform works as following: Whenever we see a file path ending with jison, we parse it with jison, remove some extra payload that it adds to use it as cli tool, and we add the needed exports.

# Outro

Now whenever we run `npm run build` it will generate a `tdc.js` file that we can use in our webpage as following

```html
<script type="module">
import TDC from "./tdc.js";
customElements.define("poly-tdc", TDC);
</script>
```

Returning to our original example,

```html
<OBJECT ID="tagList" CLASSID="CLSID:333C7BC4-460F-11D0-BC04-0080C7055A83">
 <PARAM NAME="DataURL" VALUE="tags.txt">
 <PARAM name=UseHeader value="TRUE">
 <PARAM name=FieldDelim value=",">
 <PARAM name=TextQualifier value='"'>
 <PARAM name=EscapeChar value='\'>
</OBJECT>
```

we can now use it like this with the exact same functionality

```html
<poly-tdc ID="tagList">
 <PARAM NAME="DataURL" VALUE="tags.txt">
 <PARAM name=UseHeader value="TRUE">
 <PARAM name=FieldDelim value=",">
 <PARAM name=TextQualifier value='"'>
 <PARAM name=EscapeChar value='\'>
</poly-tdc>
```

Its interesting to me, how today we have enought low-level apis to recreate a complete component from the past. It even runs a parser, something that may look that its only possible as a desktop software.

Could the parser be made with WASM to be *~ FASTER ~*?. I dont know, thats an exercise for the reader ;)

All in all this was an interest journey, and who knows, maybe in the future i tried to retrofill the [QuickTime VR file format](https://en.wikipedia.org/wiki/QuickTime_VR) also used in the same game to show 3D objects. Stay tuned.
