latex input:        mmd-article-header
Title:              NodeJS Notes
Author:             Ethan C. Petuchowski
Base Header Level:  1
latex mode:         memoir
Keywords:           Node.js, Express.js, Web, Web Framework
CSS:                http://fletcherpenney.net/css/document.css
xhtml header:       <script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
Copyright:          2014 Ethan Petuchowski
latex input:        mmd-natbib-plain
latex input:        mmd-article-begin-doc
latex footer:       mmd-memoir-footer

Many of these notes come from *Web Development with Node and Express*, by Ethan
Brown.

# NodeJS

## What is NodeJS?

1. A *web server* (like Apache)
2. *Minimal*, meaning easy to set up and configure
3. Single threaded -- you can always spin up more instances of Node
4. Uses Google's V8 JavaScript Engine to JIT compile JavaScript to native
   machine code
    * Automatically compiled for you behind the scenes
5. Has interfaces to all major relational and NoSQL databases
6. Biggest difference from Apache: the app you write *is* the web server

## How does it relate to Nginx fit in here?

* For one thing, on larger projects, Nginx might be your *proxy server* routing
  requests to a cache or different app instances.
* Other than that, I'm not sure

## Intro NodeJS

1. `helloWorld.js`
     ```javascript
     var http = require('http');
     http.createServer( function (req, res) {
       res.writeHead(200, { 'Content-Type': 'text/plain' });
       res.end('Hello world!');
     }).listen(3000);
     console.log('Server started on localhost:3000; press Ctrl-C to terminate....');
     ```
     Now type `node helloWorld.js` and go to [`http://localhost:3000`]().

    * `req` refers to the *request*, and `res` to the *response*.
2. Handy global varible `__dirname` resolves to the directory the executing
   script resides in
3. Requiring files
    * To look among `npm` packages (`global` or in `'./node_modules'`)
    
            var express = require('express')
    * To look in current directory
    
            var fortune = require('./lib/fortune.js')
4. [`module.exports`][modexp] is the object that's actually returned as the
   result of a `require` call. ([StOve][stove modexp])
    * `x.js`:
      ```javascript
      module.exports = { a: "hello" };
      ```
    * `y.js`:
      ```javascript
      var x = require('./x');
      console.log(x.a);
      ```
   
[modexp]: http://nodejs.org/api/modules.html#modules_module_exports
[stove modexp]: http://stackoverflow.com/questions/5311334

### Request Object

1. **Parameters** can come from
    1. querystring
    2. session (cookies)
    3. request body (POST)
    4. named routing parameters (`'/:name'`)   
2.  Book author says
    1. normal `req.param` method munges all parameters together
    2. so avoid it
    3. instead, use Express's explicit parameter-holding properties

### Hooking in MongoDB

1. "While there’s a low-level driver available for MongoDB , you’ll
   probably want to use an **'object document mapper' (ODM)**. The officially
   supported ODM for MongoDB is **`Mongoose`**."

# ExpressJS

## What is ExpressJS?

1. A web framework (a bit) like Ruby on Rails
    * Not the *only* web framework for Node, but pretty dominant right now
2. Written by the one and only TJ Holowaychuk
3. Default **templating engine** is (TJ's) `Jade`, which is dope
4. It has **scaffolding** (boilerplate generation via script), inspired by
   Rails

## Intro ExpressJS

1. Here is an example route

    ```javascript
    app.get('/ab', function(req, res) {
      res.type('text/plain');
      res.send('Meadowlark Travel');
    });
    ```

    This says,
    
     1. Route any of the following HTTP `GET` paths to the callback
         * `/ab`
         * `/ab/`
         * `/ab?cd=ef`
         * `/ab/?cd=ef`
     2. Set the `Content-Type` header to `'text/plain'`
     3. `end` the `response` by putting
        the given text through the wire over TCP
2. `app.use` adds *"middleware"* to Express
3. Note, routes and middleware are added **in order**
4. To render a template and pass in a variable, we have
    ```javascript
    router.get('/', function(req, res) {
      res.render('index', { title: 'Express' });
    });
    ```
5. The `static` middleware makes serving static files easier
6. By default, Express looks for *views* to render (e.g. `index` above) in the
   `views/` directory
    * It looks for *layouts* (html reused on multiple pages) in
      `views/layouts/`


### Request/Response object

1. Requests start as an instance of Node's `http.IncomingMessage`, to which
   methods are added
2. Responses start as instances of Node's `http.ServerResponse` objects.
3. `res.send(body)`, `res.send(status, body)`
    1. defaults to a content type of `text/html` so if you want to change it,
       call `res.set('Content-Type', 'text/plain')` or `res.type('txt')`
       before `res.send`
    2. If `body` is an `object` or `array`, the response is sent as `JSON`
        * Though you *should **explicitly*** send `JSON` using `res.json(json)`
4. `res.query` -- querystring values
5. `req.session` -- session values
6. `req.cookie`/`req.signedCookies` -- cookies
7. `res.render` -- render a view within a layout


### Middleware

1. *Middleware is a function* that takes three arguments:
    1. Request object
    2. Response object
    3. "Next" function
2. Executed in a *pipeline* -- order matters: things added by one middleware
   are available to everyone downstream
3. Insert middleware into the pipeline with `app.use`
4. **Don't forget to call `next()`** -- otherwise the request will terminate!

    ```javascript
    app.use(function(req, res, next) { 
      console.log('processing request for "' + req.url + '"....');
      next(); // <-= NB
    });
    ```
5. Add middleware to specific verbs with `app.VERB`

    ```javascript
    app.get('/b', function(req, res, next) {
      console.log('/b: route not terminated');
      next();
    });
    ```


# npm

## What is npm

1. Node's amazing ubiquitous package manager
2. Stands for "npm is not an acronym" (?? doofii)

## How To

1. Install a package *globally* (make it available to your whole system)

        npm install -g grunt-cli
2. Save the package(s) in `node_modules/` *and* update the `package.json` file

        npm install --save express
3. Save the package in `devDependencies` instead of `dependencies` to reduce
   dependencies required to deploy (e.g. for *testing*-related modules)
   
        npm install --save-dev mocha
