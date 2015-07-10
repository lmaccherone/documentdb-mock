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
* Right now, you pretty much have to pre-configure the mock with every response that you expect to get from DocumentDB operations. 


## Install ##

`npm install -save documentdb-mock`


## Usage ##

You can look at the code in the test and stored-procedure folders to see how to use DocumentDBMock. 

Basically:

1. Create a module to hold one or more stored procedures. You simply need to `exports` your function(s).
2. Create your mock with `mock = new DocumentDBMock('path/to/stored/procedure')`
3. Set `mock.nextResources`, `mock.nextError`, `mock.nextOptions`, and/or `mock.nextCollectionOperationQueued` to control
   the response that your stored procedure will see to the next collection operation. Note, nextCollectionOperationQueued
   is the Boolean that is immediately returned from collection operation calls. Setting this to `false` allows you to test
   situations where your stored procedure is defensively timed out by DocumentDB.
4. Call your stored procedure like it was a function from within your test with `mock.package.your-stored-procedure()`
5. Inspect `mock.lastBody` to see the output of your stored procedure. You can also inspect `mock.lastResponseOptions`
   'mock.lastCollectionLink`, and `mock.lastQueryFilter` to see the last values that your stored procedure sent into
   the most recent collection operation.

As an example, here is a stored procedure that will count all of the documents in a collection:

    count = (memo) ->
    
        collection = getContext().getCollection()
    
        unless memo?
        memo = {}
        unless memo.count?
        memo.count = 0
        unless memo.continuation?
        memo.continuation = null
        unless memo.example?
        memo.example = null
    
        stillQueuingOperations = true
    
        query = () ->
    
        if stillQueuingOperations
            responseOptions =
            continuation: memo.continuation
            pageSize: 1000
    
            if memo.filterQuery?
            stillQueuingOperations = collection.queryDocuments(collection.getSelfLink(), memo.filterQuery, responseOptions, onReadDocuments)
            else
            stillQueuingOperations = collection.readDocuments(collection.getSelfLink(), responseOptions, onReadDocuments)
    
        setBody()
    
        onReadDocuments = (err, resources, options) ->
        if err
            throw err
    
        count = resources.length
        memo.count += count
        memo.example = resources[0]
        if options.continuation?
            memo.continuation = options.continuation
            query()
        else
            memo.continuation = null
            setBody()
    
        setBody = () ->
        getContext().getResponse().setBody(memo)
    
        query()
        return memo
    
    exports.count = count

Here is a simple nodeunit test of the above stored procedure:

    DocumentDBMock = require('documentdb-mock')
    mock = new DocumentDBMock('./stored-procedures/countDocuments')
    
    exports.countTest =
    
      basicTest: (test) ->
        mock.nextResources = [
          {id: 1, value: 10}
          {id: 2, value: 20}
          {id: 3, value: 30}
        ]
    
        mock.package.count()
    
        test.equal(mock.lastBody.count, 3)
        test.ok(!mock.lastBody.continuation?)
    
        test.done()
        
If you want to test the ability of a stored procedure to be restarted:
        
      testContinuation: (test) ->
        firstBatch = [
          {id: 1, value: 10}
          {id: 2, value: 20}
        ]
        secondBatch = [
          {id: 3, value: 30}
          {id: 4, value: 40}
        ]
        mock.resourcesList = [firstBatch, secondBatch]
    
        firstOptions = {continuation: 'ABC123'}
        secondOptions = {}
        mock.optionsList = [firstOptions, secondOptions]
    
        mock.package.count()
    
        test.equal(mock.lastBody.count, 4)
        test.ok(!mock.lastBody.continuation?)
    
        # Note, lastResponseOptions is NOT the options returned from a collection operation. 
        # It is the last one you sent in.
        test.equal(mock.lastOptions.continuation, 'ABC123')
    
        test.done()
        
Here's an example of testing a stored procedure being forceably timed out by DocumentDB and then restarted by you:

      testTimeout: (test) ->
        firstBatch = [
          {id: 1, value: 10}
          {id: 2, value: 20}
        ]
        secondBatch = [
          {id: 3, value: 30}
          {id: 4, value: 40}
        ]
        mock.resourcesList = [firstBatch, secondBatch]
    
        firstOptions = {continuation: 'ABC123'}
        secondOptions = {}
        mock.optionsList = [firstOptions, secondOptions]
    
        mock.collectionOperationQueuedList = [true, false, true]
    
        mock.package.count()
    
        memo = mock.lastBody
    
        test.equal(memo.count, 2)
        test.equal(memo.continuation, 'ABC123')
    
        mock.package.count(memo)
    
        test.equal(memo.count, 4)
    
        test.done()


## Changelog ##

* 0.1.4 - 2015-07-09 - Now correctly supports missing options parameter. Also fixed createVariedDocuments to use callback, which exposed the problem with the optional options parameter.
* 0.1.3 - 2015-07-07 - Lots of little fixes found when using to test documentdb-lumenize
* 0.1.2 - 2015-06-30 - Fixed src examples broken when this was split from documentdb-utils
* 0.1.1 - 2015-06-29 - Minor documentation tweaks
* 0.1.0 - 2015-06-28 - Initial release


## Contributing to DocumentDBMock ##

I'd be willing to accept pull requests implementing any unimplemented functionality listed as "Unimplemented" above. Also, I'd love to hear feedback from other people using it.


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





