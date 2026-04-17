# REST Assessment Cheat Sheet

## About RESTful Web Services

Web Services are an implementation of web technology used for machine to machine communication. RESTful web services (often called simply REST) are a light weight variant based on the RESTful design pattern, utilizing HTTP requests similar to regular HTTP calls.

## Key relevant properties of RESTful web services

- Use of HTTP methods (`GET`, `POST`, `PUT` and `DELETE`) as the primary verb for the requested operation.
- Non-standard parameters specifications: as part of the URL, in headers.
- Structured parameters and responses using JSON or XML.
- Custom authentication and session management, often utilizing custom security tokens.
- Lack of formal documentation (WADL was proposed but never officially adopted).

## The challenge of security testing RESTful web services

- Inspecting the application does not reveal the attack surface, because:
  - No application utilizes all the available functions and parameters exposed by the service.
  - Those used are often activated dynamically by client side code, not as links in pages.
  - The client application is often not a web application.
- The parameters are non-standard making it hard to determine what is a constant vs. a parameter worth fuzzing.
- As a machine interface the number of parameters used can be very large (a JSON structure may include dozens of parameters).
- Custom authentication mechanisms require reverse engineering and make popular tools not useful.

## How to pentest a RESTful web service

### Determine the attack surface through documentation

Look for:
- Formal service description (WSDL 2.0 or WADL if available).
- Developer guides for using the service.
- Application source or configuration files (in many frameworks the REST service definition can be obtained from config files).

### Collect full requests using a proxy

Always use a proxy (e.g., ZAP) to collect full requests — not just URLs, as REST services utilize more than just GET parameters.

### Analyze collected requests to determine the attack surface

Look for non-standard parameters:
- Abnormal HTTP headers — often header-based parameters.
- URL segments with repeating patterns (dates, numbers, IDs) — indicate embedded URL parameters.
  - Example: `http://server/srv/2013-10-21/use.php`
- Structured parameter values (JSON, XML).
- URL segments without extensions if the technology normally uses extensions.
  - Example: `http://server/svc/Grid.asmx/GetRelatedListItems`
- Highly varying URL segments with many values.

### Verify non-standard parameters

Setting a URL segment suspected of being a parameter to an invalid value:
- If it's a path element: the web server will return 404.
- If it's a parameter: the answer will be an application-level message.

### Optimize fuzzing

After identifying potential parameters:
- Analyze collected values to determine valid vs. invalid values.
- Focus fuzzing on marginal invalid values (e.g., send 0 for a value found to always be a positive integer).
- Look for sequences allowing fuzzing beyond the range presumably allocated to the current user.

When fuzzing, always emulate the authentication mechanism used.
