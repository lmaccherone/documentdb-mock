path = require('path')

module.exports =
  ServerSideMock: require(path.join(__dirname, 'src', 'ServerSideMock'))
  ClientSideMock: require(path.join(__dirname, 'src', 'ClientSideMock'))
