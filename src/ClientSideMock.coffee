type = do ->  # from http://arcturo.github.com/library/coffeescript/07_the_bad_parts.html
  classToType = {}
  for name in "Boolean Number String Function Array Date RegExp Undefined Null".split(" ")
    classToType["[object " + name + "]"] = name.toLowerCase()

  (obj) ->
    strType = Object::toString.call(obj)
    classToType[strType] or "object"

class Iterator
  constructor: (@client) ->

  executeNext: (callback) ->
    @client._shiftNext()
    callback(@client.nextError, @client.nextResources, @client.nextHeaders)

  hasMoreResults: () ->
    @client.resourcesList.length > 0

  toArray: (callback) ->
    all = []
    innerF = () ->
      @executeNext((err, results, headers) =>
        if err?
          callback(err, results, headers)
        else
          all = all.concat()
          if @hasMoreResults()
            innerF()
          else
            callback(err, all, headers)
      )
    innerF()

module.exports = class ClientSideMock
  constructor: () ->
    @lastOptions = null
    @lastEntityLink = null
    @lastQueryFilter = null
    @lastRow = null
    @rows = []
    @nextError = null
    @nextResources = {}
    @nextHeaders = {}
    @errorList = null
    @resourcesList = null
    @headersList = null

    entitiesWithLinkParameter = ["Attachments", "Collections", "Conflicts", "Documents", "Permissions", "StoredProcedures", "Triggers", "UserDefinedFunctions", "Users"]
    entitiesWithNoLinkParameter = ["Databases", "Offers"]

    for entity in entitiesWithLinkParameter
      this['query' + entity] = (@lastEntityLink, @lastQueryFilter, @lastOptions) =>
        return @_queryAnything(@lastEntityLink, @lastQueryFilter, @lastOptions)
      this['read' + entity] = (@lastEntityLink, @lastOptions) =>
        return @_queryAnything(undefined, undefined, @lastOptions)

    for entity in entitiesWithNoLinkParameter
      this['query' + entity] = (@lastQueryFilter, @lastOptions) =>
        return @_queryAnything(undefined, @lastQueryFilter, @lastOptions)
      this['read' + entity] = (@lastOptions) =>
        return @_queryAnything(undefined, undefined, @lastOptions)

  _shiftNext: () ->
    if @errorList? and @errorList.length > 0
      @nextError = @errorList.shift()
    if @resourcesList? and @resourcesList.length > 0
      @nextResources = @resourcesList.shift()
    if @headersList? and @headersList.length > 0
      @nextHeaders = @headersList.shift()

  # TODO: Consider refactoring to reuse similar methods from ServerSideMock

  _queryAnything: (@lastEntityLink, @lastQueryFilter, @lastOptions) =>
    iterator = new Iterator(this)
    return iterator

#  createDocument: (@lastEntityLink, @lastRow, @lastOptions, callback) =>
#    if typeof(@lastOptions) is 'function'
#      callback = @lastOptions
#      @lastOptions = null
#    @_shiftNextCollectionOperationQueued()
#    if @nextCollectionOperationQueued
#      @rows.push(@lastRow)
#      if callback?
#        @_shiftNext()
#        callback(@nextError, @nextResources, @nextOptions)
#    return @nextCollectionOperationQueued
#
#  readDocument: (@lastEntityLink, @lastOptions, callback) =>
#    if typeof(@lastOptions) is 'function'
#      callback = @lastOptions
#      @lastOptions = null
#    @_shiftNextCollectionOperationQueued()
#    if @nextCollectionOperationQueued
#      @_shiftNext()
#      callback(@nextError, @nextResources, @nextOptions)
#    return @nextCollectionOperationQueued
#
#  replaceDocument: (@lastEntityLink, @lastRow, @lastOptions, callback) =>
#    if typeof(@lastOptions) is 'function'
#      callback = @lastOptions
#      @lastOptions = null
#    unless @lastRow?.id?
#      throw new Error("The input content is invalid because the required property, id, is missing.")
#    @_shiftNextCollectionOperationQueued()
#    if @nextCollectionOperationQueued
#      @rows.push(@lastRow)
#      if callback?
#        @_shiftNext()
#        callback(@nextError, @nextResources, @nextOptions)
#    return @nextCollectionOperationQueued
#
#  deleteDocument: (@lastEntityLink, @lastOptions, callback) =>
#    if typeof(@lastOptions) is 'function'
#      callback = @lastOptions
#      @lastOptions = null
#    @_shiftNextCollectionOperationQueued()
#    if @nextCollectionOperationQueued
#      @rows.push(@lastEntityLink)
#      if callback?
#        @_shiftNext()
#        callback(@nextError, @nextResources, @nextOptions)
#    return @nextCollectionOperationQueued