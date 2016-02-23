chai      = require('chai')
sinon     = require('sinon')
sinonChai = require('sinon-chai')

# ---

global.should = chai.should()

# ---

chai.use sinonChai

# ---

beforeEach ->
  this.sinon = sinon.sandbox.create()

afterEach ->
  this.sinon.restore()
