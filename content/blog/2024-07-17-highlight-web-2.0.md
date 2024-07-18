---
title: "Highlight Web 2.0"
date: 2024-07-17
issueId: 123
---

Following [my old post](/blog/2023-08-05-highlight-web/), i realized that highlighting content, creating a new file and copying everything was too slow when im in a marathon reading.

Thats how this 2.0 version was born. Inspired by [Going Lean](https://lea.verou.me/blog/2023/going-lean/#open-file-in-vs-code-from-the-browser%3F) by Lea Verou i started looking if i can do something similar but the other way around. Prepopulate a new file in github with the content of the current article. I found a [github issue](https://github.com/isaacs/github/issues/1527) that answers this.

So the only thing left was extend my previous bookmarklet to also save the selected text and make some ui with two buttons: one for highlighting, and one for sharing.

For the ui, nothing fancy, just a wrapper div with two buttons.
```js
let $wrapper, $buttonHighlight;
function buildUI(){
    $wrapper = document.querySelector(".pudymody-highlighter")
    if( $wrapper !== null ){
        return;
    }

    $wrapper = document.createElement("div");
    $wrapper.className = "pudymody-highlighter"

    $buttonHighlight = document.createElement("button");
    $buttonHighlight.style = `
        all: unset;
        padding: 0.5rem;
        background: #000;
        color: #fff;
        border-radius: 50%;
        cursor: pointer;
        display:block;
        user-select:none;
        position: fixed;
        bottom: 0.5rem;
        left: 0.5rem;
    `;
    $buttonHighlight.innerHTML = `
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" style="width:1rem;height:1rem;display:block;">
            <path stroke-linecap="round" stroke-linejoin="round" d="M9.53 16.122a3 3 0 0 0-5.78 1.128 2.25 2.25 0 0 1-2.4 2.245 4.5 4.5 0 0 0 8.4-2.245c0-.399-.078-.78-.22-1.128Zm0 0a15.998 15.998 0 0 0 3.388-1.62m-5.043-.025a15.994 15.994 0 0 1 1.622-3.395m3.42 3.42a15.995 15.995 0 0 0 4.764-4.648l3.876-5.814a1.151 1.151 0 0 0-1.597-1.597L14.146 6.32a15.996 15.996 0 0 0-4.649 4.763m3.42 3.42a6.776 6.776 0 0 0-3.42-3.42" />
        </svg>`
    $buttonHighlight.addEventListener("click", highlightText);
    $wrapper.appendChild($buttonHighlight);

    $buttonShare = document.createElement("button");
    $buttonShare.style = `
        all: unset;
        padding: 0.5rem;
        background: #000;
        color: #fff;
        border-radius: 50%;
        cursor: pointer;
        display:block;
        user-select:none;
        position: fixed;
        bottom: 0.5rem;
        left: 3rem;
    `;
    $buttonShare.innerHTML = `
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" style="width:1rem;height:1rem;display:block;">
            <path stroke-linecap="round" stroke-linejoin="round" d="M7.217 10.907a2.25 2.25 0 1 0 0 2.186m0-2.186c.18.324.283.696.283 1.093s-.103.77-.283 1.093m0-2.186 9.566-5.314m-9.566 7.5 9.566 5.314m0 0a2.25 2.25 0 1 0 3.935 2.186 2.25 2.25 0 0 0-3.935-2.186Zm0-12.814a2.25 2.25 0 1 0 3.933-2.185 2.25 2.25 0 0 0-3.933 2.185Z" />
        </svg>`
    $buttonShare.addEventListener("click", share);
    $wrapper.appendChild($buttonShare);

    document.body.appendChild($wrapper);
}
```

To save the selected texts, its almost the same as the previous one, but also using the fabolous [cloneContents](https://developer.mozilla.org/en-US/docs/Web/API/Range/cloneContents) of the Range object.
```js
let selections = [];
function highlightText(){
    const currentSelection = window.getSelection();
    const totalSelections = currentSelection.rangeCount;
    for(let i = 0; i < totalSelections; i++){
        const range = currentSelection.getRangeAt(i);
        selections.push(
            range.cloneContents()
        );
        [...range.getClientRects()]
            .map( e => {
                const a = document.createElement("mark");
                a.style.position = "absolute";
                a.style.pointerEvents = "none";
                a.style.background = highlightColor;
                a.style.left= (e.left+document.documentElement.scrollLeft)+"px";
                a.style.top = (e.top+document.documentElement.scrollTop)+"px";
                a.style.height = e.height+"px";
                a.style.width = e.width+"px";
                return a;
            })
            .forEach(d => { $wrapper.appendChild(d); });
    }
}
```

And finally, to convert the html to markdown, im using the [unified](https://github.com/unifiedjs/unified) library with the [rehype-remark plugin](https://github.com/rehypejs/rehype-remark). Which is an ecosystem of tools to work with syntax trees. Im also using the amazing [ESM cdn](https://esm.sh/) to convert this libraries to ESM ones.

```js
const {unified} = await import('https://esm.sh/unified?exports=unified')
const {default: rehypeParse} = await import('https://esm.sh/rehype-parse')
const {default: remarkStringify} = await import('https://esm.sh/remark-stringify')
const {default: rehypeRemark} = await import('https://esm.sh/rehype-remark')
const processor = unified()
    .use(rehypeParse)
    .use(rehypeRemark)
    .use(remarkStringify);

function getFileName(){
    const date = new Date();

    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, "0");
    const day = (date.getDate()).toString().padStart(2, "0");

    const hour = (date.getHours()).toString().padStart(2, "0");
    const minutes = (date.getMinutes()).toString().padStart(2, "0");

    return `${year}-${month}-${day}_${hour}-${minutes}.md`
}

function share(){
    const fileName = getFileName();

    const htmlBody = selections
        .flatMap( e => [...e.childNodes] )
        .map( e => e.nodeType === e.TEXT_NODE ? `<p>${e.textContent}</p>` : e.outerHTML)
        .join("");

    const markdownTxt = processor.processSync(htmlBody)
        .value
        .split("\n\n")
        .map( l => `> ${l}`)
    
    markdownTxt.push(`From [${document.title}](${location.toString()})`)
    markdownTxt.unshift(`---
layout: "post"
date: ${formatISO(new Date())}
---`);

    fileContent = markdownTxt.join("\n\n");

    window.open(`https://github.com/pudymody/pudymody.github.io/new/master/content/stream?filename=${encodeURIComponent(fileName)}&value=${encodeURIComponent(fileContent)}`);
}
```

## Code

And finally, all the code together and as a {{< rawhtml >}}<a href="javascript:(function()%7B(async%20function(window%2C%20document)%7B%0A%20%20%20%20%2F*%20esm.sh%20-%20esbuild%20bundle(date-fns%403.6.0%2FformatISO)%20es2022%20production%20*%2F%0A%20%20%20%20function%20p(t)%7Blet%20n%3DObject.prototype.toString.call(t)%3Breturn%20t%20instanceof%20Date%7C%7Ctypeof%20t%3D%3D%22object%22%26%26n%3D%3D%3D%22%5Bobject%20Date%5D%22%3Fnew%20t.constructor(%2Bt)%3Atypeof%20t%3D%3D%22number%22%7C%7Cn%3D%3D%3D%22%5Bobject%20Number%5D%22%7C%7Ctypeof%20t%3D%3D%22string%22%7C%7Cn%3D%3D%3D%22%5Bobject%20String%5D%22%3Fnew%20Date(t)%3Anew%20Date(NaN)%7Dfunction%20o(t%2Cn)%7Blet%20e%3Dt%3C0%3F%22-%22%3A%22%22%2Ci%3DMath.abs(t).toString().padStart(n%2C%220%22)%3Breturn%20e%2Bi%7Dfunction%20formatISO(t%2Cn)%7Blet%20e%3Dp(t)%3Bif(isNaN(e.getTime()))throw%20new%20RangeError(%22Invalid%20time%20value%22)%3Blet%20i%3Dn%3F.format%3F%3F%22extended%22%2Cf%3Dn%3F.representation%3F%3F%22complete%22%2Cs%3D%22%22%2Cc%3D%22%22%2Cd%3Di%3D%3D%3D%22extended%22%3F%22-%22%3A%22%22%2Cm%3Di%3D%3D%3D%22extended%22%3F%22%3A%22%3A%22%22%3Bif(f!%3D%3D%22time%22)%7Blet%20r%3Do(e.getDate()%2C2)%2Ca%3Do(e.getMonth()%2B1%2C2)%3Bs%3D%60%24%7Bo(e.getFullYear()%2C4)%7D%24%7Bd%7D%24%7Ba%7D%24%7Bd%7D%24%7Br%7D%60%7Dif(f!%3D%3D%22date%22)%7Blet%20r%3De.getTimezoneOffset()%3Bif(r!%3D%3D0)%7Blet%20u%3DMath.abs(r)%2CD%3Do(Math.trunc(u%2F60)%2C2)%2Ch%3Do(u%2560%2C2)%3Bc%3D%60%24%7Br%3C0%3F%22%2B%22%3A%22-%22%7D%24%7BD%7D%3A%24%7Bh%7D%60%7Delse%20c%3D%22Z%22%3Blet%20a%3Do(e.getHours()%2C2)%2Cl%3Do(e.getMinutes()%2C2)%2Cg%3Do(e.getSeconds()%2C2)%2C%24%3Ds%3D%3D%3D%22%22%3F%22%22%3A%22T%22%2Cb%3D%5Ba%2Cl%2Cg%5D.join(m)%3Bs%3D%60%24%7Bs%7D%24%7B%24%7D%24%7Bb%7D%24%7Bc%7D%60%7Dreturn%20s%7D%3B%0A%0A%20%20%20%20const%20%7Bunified%7D%20%3D%20await%20import('https%3A%2F%2Fesm.sh%2Funified%3Fexports%3Dunified')%0A%20%20%20%20const%20%7Bdefault%3A%20rehypeParse%7D%20%3D%20await%20import('https%3A%2F%2Fesm.sh%2Frehype-parse')%0A%20%20%20%20const%20%7Bdefault%3A%20remarkStringify%7D%20%3D%20await%20import('https%3A%2F%2Fesm.sh%2Fremark-stringify')%0A%20%20%20%20const%20%7Bdefault%3A%20rehypeRemark%7D%20%3D%20await%20import('https%3A%2F%2Fesm.sh%2Frehype-remark')%0A%0A%20%20%20%20const%20highlightColor%20%3D%20%22rgba(255%2C255%2C0%2C.3)%22%0A%0A%20%20%20%20let%20%24wrapper%2C%20%24buttonHighlight%3B%0A%20%20%20%20function%20buildUI()%7B%0A%20%20%20%20%20%20%20%20%24wrapper%20%3D%20document.querySelector(%22.pudymody-highlighter%22)%0A%20%20%20%20%20%20%20%20if(%20%24wrapper%20!%3D%3D%20null%20)%7B%0A%20%20%20%20%20%20%20%20%20%20%20%20return%3B%0A%20%20%20%20%20%20%20%20%7D%0A%0A%20%20%20%20%20%20%20%20%24wrapper%20%3D%20document.createElement(%22div%22)%3B%0A%20%20%20%20%20%20%20%20%24wrapper.className%20%3D%20%22pudymody-highlighter%22%0A%0A%20%20%20%20%20%20%20%20%24buttonHighlight%20%3D%20document.createElement(%22button%22)%3B%0A%20%20%20%20%20%20%20%20%24buttonHighlight.style%20%3D%20%60%0A%20%20%20%20%20%20%20%20%20%20%20%20all%3A%20unset%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20padding%3A%200.5rem%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20background%3A%20%23000%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20color%3A%20%23fff%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20border-radius%3A%2050%25%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20cursor%3A%20pointer%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20display%3Ablock%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20user-select%3Anone%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20position%3A%20fixed%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20bottom%3A%200.5rem%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20left%3A%200.5rem%3B%0A%20%20%20%20%20%20%20%20%60%3B%0A%20%20%20%20%20%20%20%20%24buttonHighlight.innerHTML%20%3D%20%60%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20fill%3D%22none%22%20viewBox%3D%220%200%2024%2024%22%20stroke-width%3D%221.5%22%20stroke%3D%22currentColor%22%20style%3D%22width%3A1rem%3Bheight%3A1rem%3Bdisplay%3Ablock%3B%22%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpath%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%20d%3D%22M9.53%2016.122a3%203%200%200%200-5.78%201.128%202.25%202.25%200%200%201-2.4%202.245%204.5%204.5%200%200%200%208.4-2.245c0-.399-.078-.78-.22-1.128Zm0%200a15.998%2015.998%200%200%200%203.388-1.62m-5.043-.025a15.994%2015.994%200%200%201%201.622-3.395m3.42%203.42a15.995%2015.995%200%200%200%204.764-4.648l3.876-5.814a1.151%201.151%200%200%200-1.597-1.597L14.146%206.32a15.996%2015.996%200%200%200-4.649%204.763m3.42%203.42a6.776%206.776%200%200%200-3.42-3.42%22%20%2F%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3C%2Fsvg%3E%60%0A%20%20%20%20%20%20%20%20%24buttonHighlight.addEventListener(%22click%22%2C%20highlightText)%3B%0A%20%20%20%20%20%20%20%20%24wrapper.appendChild(%24buttonHighlight)%3B%0A%0A%20%20%20%20%20%20%20%20%24buttonShare%20%3D%20document.createElement(%22button%22)%3B%0A%20%20%20%20%20%20%20%20%24buttonShare.style%20%3D%20%60%0A%20%20%20%20%20%20%20%20%20%20%20%20all%3A%20unset%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20padding%3A%200.5rem%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20background%3A%20%23000%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20color%3A%20%23fff%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20border-radius%3A%2050%25%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20cursor%3A%20pointer%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20display%3Ablock%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20user-select%3Anone%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20position%3A%20fixed%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20bottom%3A%200.5rem%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20left%3A%203rem%3B%0A%20%20%20%20%20%20%20%20%60%3B%0A%20%20%20%20%20%20%20%20%24buttonShare.innerHTML%20%3D%20%60%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20fill%3D%22none%22%20viewBox%3D%220%200%2024%2024%22%20stroke-width%3D%221.5%22%20stroke%3D%22currentColor%22%20style%3D%22width%3A1rem%3Bheight%3A1rem%3Bdisplay%3Ablock%3B%22%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpath%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%20d%3D%22M7.217%2010.907a2.25%202.25%200%201%200%200%202.186m0-2.186c.18.324.283.696.283%201.093s-.103.77-.283%201.093m0-2.186%209.566-5.314m-9.566%207.5%209.566%205.314m0%200a2.25%202.25%200%201%200%203.935%202.186%202.25%202.25%200%200%200-3.935-2.186Zm0-12.814a2.25%202.25%200%201%200%203.933-2.185%202.25%202.25%200%200%200-3.933%202.185Z%22%20%2F%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3C%2Fsvg%3E%60%0A%20%20%20%20%20%20%20%20%24buttonShare.addEventListener(%22click%22%2C%20share)%3B%0A%20%20%20%20%20%20%20%20%24wrapper.appendChild(%24buttonShare)%3B%0A%0A%20%20%20%20%20%20%20%20document.body.appendChild(%24wrapper)%3B%0A%20%20%20%20%7D%0A%0A%20%20%20%20let%20selections%20%3D%20%5B%5D%3B%0A%20%20%20%20function%20highlightText()%7B%0A%20%20%20%20%20%20%20%20const%20currentSelection%20%3D%20window.getSelection()%3B%0A%20%20%20%20%20%20%20%20const%20totalSelections%20%3D%20currentSelection.rangeCount%3B%0A%20%20%20%20%20%20%20%20for(let%20i%20%3D%200%3B%20i%20%3C%20totalSelections%3B%20i%2B%2B)%7B%0A%20%20%20%20%20%20%20%20%20%20%20%20const%20range%20%3D%20currentSelection.getRangeAt(i)%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20selections.push(%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20range.cloneContents()%0A%20%20%20%20%20%20%20%20%20%20%20%20)%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%5B...range.getClientRects()%5D%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20.map(%20e%20%3D%3E%20%7B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20const%20a%20%3D%20document.createElement(%22mark%22)%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20a.style.position%20%3D%20%22absolute%22%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20a.style.pointerEvents%20%3D%20%22none%22%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20a.style.background%20%3D%20highlightColor%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20a.style.left%3D%20(e.left%2Bdocument.documentElement.scrollLeft)%2B%22px%22%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20a.style.top%20%3D%20(e.top%2Bdocument.documentElement.scrollTop)%2B%22px%22%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20a.style.height%20%3D%20e.height%2B%22px%22%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20a.style.width%20%3D%20e.width%2B%22px%22%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20return%20a%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%7D)%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20.forEach(d%20%3D%3E%20%7B%20%24wrapper.appendChild(d)%3B%20%7D)%3B%0A%20%20%20%20%20%20%20%20%7D%0A%20%20%20%20%7D%0A%0A%20%20%20%20const%20processor%20%3D%20unified()%0A%20%20%20%20%20%20%20%20.use(rehypeParse)%0A%20%20%20%20%20%20%20%20.use(rehypeRemark)%0A%20%20%20%20%20%20%20%20.use(remarkStringify)%3B%0A%0A%20%20%20%20function%20getFileName()%7B%0A%20%20%20%20%20%20%20%20const%20date%20%3D%20new%20Date()%3B%0A%0A%20%20%20%20%20%20%20%20const%20year%20%3D%20date.getFullYear()%3B%0A%20%20%20%20%20%20%20%20const%20month%20%3D%20(date.getMonth()%20%2B%201).toString().padStart(2%2C%20%220%22)%3B%0A%20%20%20%20%20%20%20%20const%20day%20%3D%20(date.getDate()).toString().padStart(2%2C%20%220%22)%3B%0A%0A%20%20%20%20%20%20%20%20const%20hour%20%3D%20(date.getHours()).toString().padStart(2%2C%20%220%22)%3B%0A%20%20%20%20%20%20%20%20const%20minutes%20%3D%20(date.getMinutes()).toString().padStart(2%2C%20%220%22)%3B%0A%0A%20%20%20%20%20%20%20%20return%20%60%24%7Byear%7D-%24%7Bmonth%7D-%24%7Bday%7D_%24%7Bhour%7D-%24%7Bminutes%7D.md%60%0A%20%20%20%20%7D%0A%0A%20%20%20%20function%20share()%7B%0A%20%20%20%20%20%20%20%20const%20fileName%20%3D%20getFileName()%3B%0A%0A%20%20%20%20%20%20%20%20const%20htmlBody%20%3D%20selections%0A%20%20%20%20%20%20%20%20%20%20%20%20.flatMap(%20e%20%3D%3E%20%5B...e.childNodes%5D%20)%0A%20%20%20%20%20%20%20%20%20%20%20%20.map(%20e%20%3D%3E%20e.nodeType%20%3D%3D%3D%20e.TEXT_NODE%20%3F%20%60%3Cp%3E%24%7Be.textContent%7D%3C%2Fp%3E%60%20%3A%20e.outerHTML)%0A%20%20%20%20%20%20%20%20%20%20%20%20.join(%22%22)%3B%0A%0A%20%20%20%20%20%20%20%20const%20markdownTxt%20%3D%20processor.processSync(htmlBody)%0A%20%20%20%20%20%20%20%20%20%20%20%20.value%0A%20%20%20%20%20%20%20%20%20%20%20%20.split(%22%5Cn%5Cn%22)%0A%20%20%20%20%20%20%20%20%20%20%20%20.map(%20l%20%3D%3E%20%60%3E%20%24%7Bl%7D%60)%0A%20%20%20%20%20%20%20%20%0A%20%20%20%20%20%20%20%20markdownTxt.push(%60From%20%5B%24%7Bdocument.title%7D%5D(%24%7Blocation.toString()%7D)%60)%0A%20%20%20%20%20%20%20%20markdownTxt.unshift(%60---%0Alayout%3A%20%22post%22%0Adate%3A%20%24%7BformatISO(new%20Date())%7D%0A---%60)%3B%0A%0A%20%20%20%20%20%20%20%20fileContent%20%3D%20markdownTxt.join(%22%5Cn%5Cn%22)%3B%0A%0A%20%20%20%20%20%20%20%20window.open(%60https%3A%2F%2Fgithub.com%2Fpudymody%2Fpudymody.github.io%2Fnew%2Fmaster%2Fcontent%2Fstream%3Ffilename%3D%24%7BencodeURIComponent(fileName)%7D%26value%3D%24%7BencodeURIComponent(fileContent)%7D%60)%3B%0A%20%20%20%20%7D%0A%0A%20%20%20%20buildUI()%3B%0A%20%20%20%20highlightText()%3B%0A%7D)(window%2C%20document)%7D)()%3B">bookmarklet</a>{{< /rawhtml >}} for your use:
```js
(async function(window, document){
    /* esm.sh - esbuild bundle(date-fns@3.6.0/formatISO) es2022 production */
    function p(t){let n=Object.prototype.toString.call(t);return t instanceof Date||typeof t=="object"&&n==="[object Date]"?new t.constructor(+t):typeof t=="number"||n==="[object Number]"||typeof t=="string"||n==="[object String]"?new Date(t):new Date(NaN)}function o(t,n){let e=t<0?"-":"",i=Math.abs(t).toString().padStart(n,"0");return e+i}function formatISO(t,n){let e=p(t);if(isNaN(e.getTime()))throw new RangeError("Invalid time value");let i=n?.format??"extended",f=n?.representation??"complete",s="",c="",d=i==="extended"?"-":"",m=i==="extended"?":":"";if(f!=="time"){let r=o(e.getDate(),2),a=o(e.getMonth()+1,2);s=`${o(e.getFullYear(),4)}${d}${a}${d}${r}`}if(f!=="date"){let r=e.getTimezoneOffset();if(r!==0){let u=Math.abs(r),D=o(Math.trunc(u/60),2),h=o(u%60,2);c=`${r<0?"+":"-"}${D}:${h}`}else c="Z";let a=o(e.getHours(),2),l=o(e.getMinutes(),2),g=o(e.getSeconds(),2),$=s===""?"":"T",b=[a,l,g].join(m);s=`${s}${$}${b}${c}`}return s};

    const {unified} = await import('https://esm.sh/unified?exports=unified')
    const {default: rehypeParse} = await import('https://esm.sh/rehype-parse')
    const {default: remarkStringify} = await import('https://esm.sh/remark-stringify')
    const {default: rehypeRemark} = await import('https://esm.sh/rehype-remark')

    const highlightColor = "rgba(255,255,0,.3)"

    let $wrapper, $buttonHighlight;
    function buildUI(){
        $wrapper = document.querySelector(".pudymody-highlighter")
        if( $wrapper !== null ){
            return;
        }

        $wrapper = document.createElement("div");
        $wrapper.className = "pudymody-highlighter"

        $buttonHighlight = document.createElement("button");
        $buttonHighlight.style = `
            all: unset;
            padding: 0.5rem;
            background: #000;
            color: #fff;
            border-radius: 50%;
            cursor: pointer;
            display:block;
            user-select:none;
            position: fixed;
            bottom: 0.5rem;
            left: 0.5rem;
        `;
        $buttonHighlight.innerHTML = `
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" style="width:1rem;height:1rem;display:block;">
                <path stroke-linecap="round" stroke-linejoin="round" d="M9.53 16.122a3 3 0 0 0-5.78 1.128 2.25 2.25 0 0 1-2.4 2.245 4.5 4.5 0 0 0 8.4-2.245c0-.399-.078-.78-.22-1.128Zm0 0a15.998 15.998 0 0 0 3.388-1.62m-5.043-.025a15.994 15.994 0 0 1 1.622-3.395m3.42 3.42a15.995 15.995 0 0 0 4.764-4.648l3.876-5.814a1.151 1.151 0 0 0-1.597-1.597L14.146 6.32a15.996 15.996 0 0 0-4.649 4.763m3.42 3.42a6.776 6.776 0 0 0-3.42-3.42" />
            </svg>`
        $buttonHighlight.addEventListener("click", highlightText);
        $wrapper.appendChild($buttonHighlight);

        $buttonShare = document.createElement("button");
        $buttonShare.style = `
            all: unset;
            padding: 0.5rem;
            background: #000;
            color: #fff;
            border-radius: 50%;
            cursor: pointer;
            display:block;
            user-select:none;
            position: fixed;
            bottom: 0.5rem;
            left: 3rem;
        `;
        $buttonShare.innerHTML = `
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" style="width:1rem;height:1rem;display:block;">
              <path stroke-linecap="round" stroke-linejoin="round" d="M7.217 10.907a2.25 2.25 0 1 0 0 2.186m0-2.186c.18.324.283.696.283 1.093s-.103.77-.283 1.093m0-2.186 9.566-5.314m-9.566 7.5 9.566 5.314m0 0a2.25 2.25 0 1 0 3.935 2.186 2.25 2.25 0 0 0-3.935-2.186Zm0-12.814a2.25 2.25 0 1 0 3.933-2.185 2.25 2.25 0 0 0-3.933 2.185Z" />
            </svg>`
        $buttonShare.addEventListener("click", share);
        $wrapper.appendChild($buttonShare);

        document.body.appendChild($wrapper);
    }

    let selections = [];
    function highlightText(){
        const currentSelection = window.getSelection();
        const totalSelections = currentSelection.rangeCount;
        for(let i = 0; i < totalSelections; i++){
            const range = currentSelection.getRangeAt(i);
            selections.push(
                range.cloneContents()
            );
            [...range.getClientRects()]
                .map( e => {
                    const a = document.createElement("mark");
                    a.style.position = "absolute";
                    a.style.pointerEvents = "none";
                    a.style.background = highlightColor;
                    a.style.left= (e.left+document.documentElement.scrollLeft)+"px";
                    a.style.top = (e.top+document.documentElement.scrollTop)+"px";
                    a.style.height = e.height+"px";
                    a.style.width = e.width+"px";
                    return a;
                })
                .forEach(d => { $wrapper.appendChild(d); });
        }
    }

    const processor = unified()
        .use(rehypeParse)
        .use(rehypeRemark)
        .use(remarkStringify);

    function getFileName(){
        const date = new Date();

        const year = date.getFullYear();
        const month = (date.getMonth() + 1).toString().padStart(2, "0");
        const day = (date.getDate()).toString().padStart(2, "0");

        const hour = (date.getHours()).toString().padStart(2, "0");
        const minutes = (date.getMinutes()).toString().padStart(2, "0");

        return `${year}-${month}-${day}_${hour}-${minutes}.md`
    }

    function share(){
        const fileName = getFileName();

        const htmlBody = selections
            .flatMap( e => [...e.childNodes] )
            .map( e => e.nodeType === e.TEXT_NODE ? `<p>${e.textContent}</p>` : e.outerHTML)
            .join("");

        const markdownTxt = processor.processSync(htmlBody)
            .value
            .split("\n\n")
            .map( l => `> ${l}`)
        
        markdownTxt.push(`From [${document.title}](${location.toString()})`)
        markdownTxt.unshift(`---
layout: "post"
date: ${formatISO(new Date())}
---`);

        fileContent = markdownTxt.join("\n\n");

        window.open(`https://github.com/pudymody/pudymody.github.io/new/master/content/stream?filename=${encodeURIComponent(fileName)}&value=${encodeURIComponent(fileContent)}`);
    }

    buildUI();
    highlightText();
})(window, document)
```