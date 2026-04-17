---
title: "OWASP XML External Entity Prevention Cheat Sheet"
tags: [owasp, xml, xxe, injection, java, dotnet, php, python]
sources: [owasp-xxe-prevention.md]
updated: 2026-04-16
---

# OWASP XML External Entity Prevention Cheat Sheet

Source: `raw/owasp-xxe-prevention.md`

## Summary

XXE (CWE-611, OWASP Top 10 A4) attacks exploit weakly configured XML parsers that process untrusted XML containing external entity references. Impact: SSRF, arbitrary file read, port scanning, and DoS (Billion Laughs). **Primary defense: disable DTDs entirely.** Per-language guidance covers C/C++, ColdFusion, Java, .NET, iOS, PHP, and Python.

## Key Controls

### Universal Hardening Checklist

- Disable DOCTYPE / DTD declarations
- Disable external entities
- Disable external DTD loading
- Enable secure processing mode
- Disable XInclude
- Limit entity expansion depth
- Never parse untrusted XML with default settings

### Quick Impact Matrix

| Missing Control              | Vulnerability                          |
| ---------------------------- | -------------------------------------- |
| DOCTYPE not disabled         | Standard XXE fully exploitable         |
| External entities enabled    | SSRF, file exfiltration, port scanning |
| External DTD loading allowed | Blind XXE / hidden SSRF                |
| No expansion limits          | Billion Laughs DoS                     |
| XInclude enabled             | Local file disclosure + SSRF           |

## Language-Specific Guidance

### Java (highest risk — XXE enabled by default)

```java
// Preferred: disable DTDs entirely (Xerces 2)
DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
dbf.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
dbf.setXIncludeAware(false);
```

If DTDs cannot be disabled:

```java
dbf.setFeature("http://xml.org/sax/features/external-general-entities", false);
dbf.setFeature("http://xml.org/sax/features/external-parameter-entities", false);
dbf.setFeature("http://apache.org/xml/features/nonvalidating/load-external-dtd", false);
dbf.setFeature(XMLConstants.FEATURE_SECURE_PROCESSING, true);
dbf.setExpandEntityReferences(false);
```

Other Java parsers:

- **XMLInputFactory (StAX):** `setProperty(XMLInputFactory.SUPPORT_DTD, false)`
- **TransformerFactory:** set `ACCESS_EXTERNAL_DTD` and `ACCESS_EXTERNAL_STYLESHEET` to `""`
- **XMLReader/SAXReader/SAXBuilder:** set `disallow-doctype-decl` to true
- **JAXB Unmarshaller:** wrap input in a hardened `XMLInputFactory` first
- **`java.beans.XMLDecoder`:** fundamentally unsafe — avoid entirely

> Requires Java 7u67+ or Java 8u20+ for `DocumentBuilderFactory` / `SAXParserFactory` fixes (CVE-2014-6517).

### .NET

- **≥4.5.2:** `XmlReader`, `XmlDictionaryReader`, `XmlNodeReader`, `XDocument`/`XElement` are safe by default
- **XmlDocument/XmlTextReader/XPathNavigator pre-4.5.2:** must explicitly set `XmlResolver = null` or `DtdProcessing = Prohibit`
- **ASP.NET:** must set `<httpRuntime targetFramework="4.5.2+">` in Web.config — code version alone is not enough

### PHP

- PHP ≥8.0: secure by default
- PHP \<8.0: `libxml_set_external_entity_loader(null);`

### Python

- `sax`, `etree`, `minidom`, `pulldom`, `xmlrpc` are vulnerable to Billion Laughs / quadratic blowup
- Use **defusedxml** / **defusedexpat** packages for untrusted input

### C/C++ (libxml2)

- Version ≥2.9: XXE disabled by default
- Do not pass `XML_PARSE_NOENT` or `XML_PARSE_DTDLOAD` options

## Related Concepts

- [XXE](../concepts/xxe.md) — attack class
- [XML Security](../concepts/xml-security.md) — broader XML attack surface
- [Input Validation](../concepts/input-validation.md) — never rely on client-side validation
- [SSRF](../concepts/ssrf.md) — common XXE impact vector
