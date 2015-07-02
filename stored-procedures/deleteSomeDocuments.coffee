deleteSomeDocuments = (memo) ->

  collection = getContext().getCollection()

  unless memo?
    memo = {}
  unless memo.deleted?
    memo.deleted = []

  stillQueuingOperations = true

  query = () ->
    if stillQueuingOperations
      responseOptions =
        pageSize: memo.remaining
      setBody()
      stillQueuingOperations = collection.readDocuments(collection.getSelfLink(), responseOptions, onReadDocuments)

  onReadDocuments = (err, resources, options) ->
    if err
      throw err

    if resources.length isnt memo.remaining
      throw new Error("Expected memo.remaining (#{memo.remaining}) and the number of rows returned (#{resources.length}) to match. They don't.")

    memo.stillQueueing = true
    while memo.remaining > 0 and memo.stillQueueing
      oldDocument = resources[memo.remaining - 1]
      documentLink = oldDocument._self
      etag = oldDocument._etag
      options = {etag}  # Sending the etag per best practice, but not handling it if there is conflict.
      getContext().getResponse().setBody(memo)
      memo.stillQueueing = collection.deleteDocument(documentLink, options)
      if memo.stillQueueing
        memo.deleted.push(oldDocument)
        memo.remaining--

  setBody = () ->
    getContext().getResponse().setBody(memo)

  query()
  return memo

exports.deleteSomeDocuments = deleteSomeDocuments