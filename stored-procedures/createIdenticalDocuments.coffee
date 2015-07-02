generateData = (memo) ->

  unless memo?.remaining?
    throw new Error('generateData must be called with an object containing a `remaining` field.')
  unless memo.totalCount?
    memo.totalCount = 0
  memo.countForThisRun = 0
  timeout = memo.timeout or 600  # Get 408 RequestTimeout at 800. Works at 700.
  startTime = new Date()
  memo.stillTime = true

  collection = getContext().getCollection()
  collectionLink = collection.getSelfLink()

  memo.stillQueueing = true
  while memo.remaining > 0 and memo.stillQueueing and memo.stillTime
    row = {a: 1, b: 2}
    getContext().getResponse().setBody(memo)
    memo.stillQueueing = collection.createDocument(collectionLink, row)
    if memo.stillQueueing
      memo.remaining--
      memo.countForThisRun++
      memo.totalCount++
    nowTime = new Date()
    memo.nowTime = nowTime
    memo.startTime = startTime
    memo.stillTime = (nowTime - startTime) < timeout
    if memo.stillTime
      memo.continuation = null
    else
      memo.continuation = 'Value does not matter'

  getContext().getResponse().setBody(memo)
  return memo

exports.generateData = generateData
