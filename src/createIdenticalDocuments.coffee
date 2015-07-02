documentDBUtils = require('documentdb-utils')

{generateData} = require('../stored-procedures/createIdenticalDocuments')
config =
  databaseID: 'test-stored-procedure'
  collectionID: 'testing-s3'
  storedProcedureID: 'generateData'
  storedProcedureJS: generateData
  memo: {remaining: 10000}
  debug: true

processResponse = (err, response) ->
  if err?
    console.dir(err)
    throw new Error(err)

  console.log(response.stats)
  console.log(response.memo)

documentDBUtils(config, processResponse)