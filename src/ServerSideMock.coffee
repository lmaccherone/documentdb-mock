rewire = require("rewire")
{_} = require('lodash')

type = do ->  # from http://arcturo.github.com/library/coffeescript/07_the_bad_parts.html
  classToType = {}
  for name in "Boolean Number String Function Array Date RegExp Undefined Null".split(" ")
    classToType["[object " + name + "]"] = name.toLowerCase()

  (obj) ->
    strType = Object::toString.call(obj)
    classToType[strType] or "object"

module.exports = class ServerSideMock
  # !TODO: Upgrade to support new `__` as alias for getContext().getCollection()
  constructor: (@package) ->
    if type(@package) is 'string'
      @package = rewire(@package)
    if @package?
      @package.__set__('getContext', @getContext)
    else
      throw new Error("Must provide a string or an already required package when instantiating ServerSideMock")
    @lastBody = null
    @lastOptions = null
    @lastEntityLink = null
    @lastQueryFilter = null
    @lastRow = null
    @rows = []
    @nextError = null
    @nextResources = {}
    @nextHeaders = {}
    @nextCollectionOperationQueued = true
    @errorList = null
    @resourcesList = null
    @headersList = null
    @collectionOperationQueuedList = null

  _shiftNext: () ->
    if @errorList? and @errorList.length > 0
      @nextError = @errorList.shift()
    if @resourcesList? and @resourcesList.length > 0
      @nextResources = @resourcesList.shift()
    if @headersList? and @headersList.length > 0
      @nextHeaders = @headersList.shift()

  _shiftNextCollectionOperationQueued: () ->
    if @collectionOperationQueuedList? and @collectionOperationQueuedList.length > 0
      @nextCollectionOperationQueued = @collectionOperationQueuedList.shift()

  getContext: () =>
    getResponse: () =>
      setBody: (body) =>
        @lastBody = body

    getCollection: () =>
      getSelfLink: () =>
        return 'mocked-self-link'

      queryDocuments: (@lastEntityLink, @lastQueryFilter, @lastOptions, callback) =>
        if typeof(@lastOptions) is 'function'
          callback = @lastOptions
          @lastOptions = null
        @_shiftNextCollectionOperationQueued()
        if @nextCollectionOperationQueued
          @_shiftNext()
          callback(@nextError, @nextResources, @nextHeaders)
        return @nextCollectionOperationQueued

      readDocuments: (@lastEntityLink, @lastOptions, callback) =>
        if typeof(@lastOptions) is 'function'
          callback = @lastOptions
          @lastOptions = null
        @_shiftNextCollectionOperationQueued()
        if @nextCollectionOperationQueued
          @_shiftNext()
          callback(@nextError, @nextResources, @nextHeaders)
        return @nextCollectionOperationQueued

      createDocument: (@lastEntityLink, @lastRow, @lastOptions, callback) =>
        if typeof(@lastOptions) is 'function'
          callback = @lastOptions
          @lastOptions = null
        @_shiftNextCollectionOperationQueued()
        if @nextCollectionOperationQueued
          @rows.push(_.cloneDeep(@lastRow))
          if callback?
            @_shiftNext()
            callback(@nextError, @nextResources, @nextHeaders)
        return @nextCollectionOperationQueued

      readDocument: (@lastEntityLink, @lastOptions, callback) =>
        if typeof(@lastOptions) is 'function'
          callback = @lastOptions
          @lastOptions = null
        @_shiftNextCollectionOperationQueued()
        if @nextCollectionOperationQueued
          @_shiftNext()
          callback(@nextError, @nextResources, @nextHeaders)
        return @nextCollectionOperationQueued

      replaceDocument: (@lastEntityLink, @lastRow, @lastOptions, callback) =>
        if typeof(@lastOptions) is 'function'
          callback = @lastOptions
          @lastOptions = null
        unless @lastRow?.id?
          throw new Error("The input content is invalid because the required property, id, is missing.")
        @_shiftNextCollectionOperationQueued()
        if @nextCollectionOperationQueued
          @rows.push(_.cloneDeep(@lastRow))
          if callback?
            @_shiftNext()
            callback(@nextError, @nextResources, @nextHeaders)
        return @nextCollectionOperationQueued

      deleteDocument: (@lastEntityLink, @lastOptions, callback) =>
        if typeof(@lastOptions) is 'function'
          callback = @lastOptions
          @lastOptions = null
        @_shiftNextCollectionOperationQueued()
        if @nextCollectionOperationQueued
          @rows.push(_.cloneDeep(@lastEntityLink))
          if callback?
            @_shiftNext()
            callback(@nextError, @nextResources, @nextHeaders)
        return @nextCollectionOperationQueued
