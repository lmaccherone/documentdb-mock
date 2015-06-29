# DocumentDBMock #

Copyright (c) 2015, Lawrence S. Maccherone, Jr.

_Mock for testing Stored Procedures in Microsoft Azure's DocumentDB_

Microsoft Azure's DocumentDB is a great PaaS NoSQL database. My absolute favorite feature is that you can write stored procedures in JavaScript (CoffeeScript in my case) but it's missing a mature way to test your stored procedures. Luckily, JavaScript runs just fine on node.js so your stored procedures will run there with mock data.

This package implements a thin mock for testing stored procedures.


## Source code ##

* [Source Repository](https://github.com/lmaccherone/documentdb-mock)


## Features ##

### Working ###

DocumentDBMock implements many of the methods in the [DocumentDB's Collection class](http://dl.windowsazure.com/documentDB/jsserverdocs/Collection.html) including:

* getResponse.setBody
* getSelfLink
* createDocument
* readDocument
* replaceDocument
* deleteDocument
* queryDocuments
* readDocuments

### Unimplemented ###

* Attachment operations - should be easy to implement following the patterns for document operations


## Install ##

`npm install -save documentdb-mock`


## Usage ##






## Changelog ##

* 0.2.0 - 2015-06-27 - Added mock testing using DocumentDBMock
* 0.1.2 - 2015-05-11 - Changed entry point to work via npm
* 0.1.1 - 2015-05-04 - Fixed `cake publish`
* 0.1.0 - 2015-05-03 - Initial release


## Contributing to documentDBUtils ##

### Triggers, UDFs, and Documents ###

As of 2015-05-03, documentDBUtils only supports stored procedures. I personally don't use triggers or UDFs... yet, but we should probably add that. It should be easier because I don't think we'll have the same throttling and resource limit issues with just creating, deleted, and upserting them. Perhaps even more useful (and a little more work) is to support document operations, particularly bulk updates and multi-page queries which should require retry logic.

### Delete Databases or Collections ###

Should be easy.

### Explicitly specify an operation ###

I realize that this design decision of automatically choosing an operation based upon which parameters are provided might be controversial. If we added an optional "operation" field, then we could check to confirm that they provided the right config fields for that operation.

### What about promises? ###

Promises make the writing of waterfall pattern async much easier. However, I find that they make the writing of complicated ascyn patterns like retries and branching based upon the results of a response much harder. So, I have chosen not to use promises in the implementation of documentDBUtils.

That said, since all of the complex async code is encapsulated inside of documentDBUtils, I want to implement a promises wrapper for documentDBUtils. I would gladly accept a pull-request for this.

### Documentation ###

Because Microsoft uses JSDoc for its library, I've decided to use it also. that said, I don't yet have any documentation generation in place. That's pretty high on my list to do myself but it's also a good candidate for pull requests if anyone wants to help. Use this approach to document the CoffeeScript.

```
###*
# Sets the language and redraws the UI.
# @param {object} data Object with `language` property
# @param {string} data.language Language code
###
handleLanguageSet: (data) ->
```

outputs

```
/**
 * Sets the language and redraws the UI.
 * @param {object} data Object with `language` property
 * @param {string} data.language Language code
 */
handleLanguageSet: function(data) {}
```

### Tests ###

I have a pattern for writing automated tests for my own stored procedures and I regularly exercise documentDBUtils in the course of running those stored procedures. I also have done extensive exploratory testing on DocumentDB's behavior using documentDBUtils... even finding some edge cases in DocumentDB's behavior. :-) However, you cannot run DoucmentDB locally and I don't have the patience to mock it out so there are currently no automated tests.

### Command line support ###

At the very least it would be nice to provide a "binary" (really just CoffeeScript that starts with #!) that does the count of a collection with optional command-line parameter for filterQuery.

However, it might also be nice to create a full CLI that would allow you to specify JavaScript (or even CoffeeScript) files that get pushed to stored procedures and executed. We'd have to support all of the same parameters. Then again, this might be unused functionality.


## MIT License ##

Copyright (c) 2015 Lawrence S. Maccherone, Jr.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
documentation files (the "Software"), to deal in the Software without restriction, including without limitation 
the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and 
to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
IN THE SOFTWARE.





