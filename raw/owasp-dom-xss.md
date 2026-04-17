# DOM based XSS Prevention Cheat Sheet

## Introduction

When looking at XSS (Cross-Site Scripting), there are three generally recognized forms of XSS:

* Reflected or Stored
* DOM Based XSS

The XSS Prevention Cheatsheet addresses Reflected and Stored XSS. This cheatsheet addresses DOM (Document Object Model) based XSS.

**Key difference:** Reflected and Stored XSS are server side injection issues while DOM based XSS is a client (browser) side injection issue.

When a browser is rendering HTML it identifies various rendering contexts: HTML, HTML attribute, URL, and CSS. JavaScript execution context has distinct semantics for each subcontext.

## RULE #1 - HTML Escape then JavaScript Escape Before Inserting Untrusted Data into HTML Subcontext

Dangerous HTML methods that accept untrusted data:

```
element.innerHTML = "<HTML> Tags and markup";
element.outerHTML = "<HTML> Tags and markup";
document.write("<HTML> Tags and markup");
document.writeln("<HTML> Tags and markup");
```

**Guideline:** HTML encode then JavaScript encode:

```js
element.innerHTML = "<%=ESAPI.encoder().encodeForJavascript(ESAPI.encoder().encodeForHTML(untrustedData))%>";
```

## RULE #2 - JavaScript Escape Before Inserting Untrusted Data into HTML Attribute Subcontext

In a DOM execution context, only JavaScript encode HTML attributes that do not execute code (not event handlers, CSS, or URL attributes). Do NOT HTML attribute encode — it causes double-encoding.

```js
x.setAttribute("value", '<%=ESAPI.encoder().encodeForJavascript(companyName)%>');
```

## RULE #3 - Be Careful with Event Handler and JavaScript Code Subcontexts

**Primary recommendation: avoid including untrusted data in this context.**

JavaScript encoding does not reliably stop attacks in execution contexts. `setAttribute(name, value)` implicitly coerces the value to the attribute's datatype — if the attribute is an event handler, the value becomes executable code.

Avoid `setTimeout`, `setInterval`, `new Function` with untrusted string data.

## RULE #4 - JavaScript Escape Before Inserting Untrusted Data into CSS Attribute Subcontext

```js
document.body.style.backgroundImage = "url(<%=ESAPI.encoder().encodeForJavascript(ESAPI.encoder().encodeForURL(companyName))%>)";
```

## RULE #5 - URL Escape then JavaScript Escape for URL Attribute Subcontext

```js
x.setAttribute("href", '<%=ESAPI.encoder().encodeForJavascript(ESAPI.encoder().encodeForURL(userRelativePath))%>');
```

## RULE #6 - Use Safe JavaScript Functions/Properties

Most fundamental safe way: use `textContent` (does not execute code):

```js
element.textContent = untrustedData;
```

## RULE #7 - Fixing DOM XSS Vulnerabilities

Use the right output method (sink). Instead of `innerHTML`, use `innerText` or `textContent`:

```js
document.getElementById("contentholder").textContent = document.baseURI;
```

**It is always a bad idea to use user-controlled input in `eval()`.**

## Guidelines for Developing Secure JavaScript Applications

- **GUIDELINE #1:** Untrusted data should only be treated as displayable text.
- **GUIDELINE #2:** Always JavaScript encode and delimit untrusted data as quoted strings: `var x = "<%= Encode.forJavaScript(untrustedData) %>";`
- **GUIDELINE #3:** Use `document.createElement()`, `element.setAttribute()`, `element.appendChild()` to build dynamic interfaces. Note: `setAttribute` is only safe for non-command-execution attributes.
- **GUIDELINE #4:** Avoid `element.innerHTML`, `element.outerHTML`, `document.write()`, `document.writeln()` with untrusted data.
- **GUIDELINE #5:** Avoid methods that implicitly `eval()` — use closures or N-levels of encoding.
- **GUIDELINE #6:** Use untrusted data on the right side of expressions only.
- **GUIDELINE #7:** Be aware of character set issues when URL encoding in DOM.
- **GUIDELINE #8:** Limit object property access when using `object[x]` accessors — add indirection between untrusted input and object properties.
- **GUIDELINE #9:** Run JavaScript in ECMAScript 5 sandbox (DOMPurify, js-xss, sanitize-html).
- **GUIDELINE #10:** Don't `eval()` JSON — use `JSON.parse()`.

## Common Problems

- **Complex Contexts:** Data can pass through multiple encoding contexts (URL → JavaScript → URL).
- **Encoding Library Inconsistencies:** Many libraries use denylists; ESAPI uses allowlist encoding.
- **Encoding Misconceptions:** HTML encoding does not protect inside `<script>` tags (`&#x61;lert(1)` still executes). Encoding is lost when reading DOM element `.value`.
- **Usually Safe Methods:** `innerText` is NOT safe when applied to `<script>` tag.
- **Variant Analysis:** Use Semgrep rules to detect DOM XSS sources like `location.hash` passed to `document.write`.
