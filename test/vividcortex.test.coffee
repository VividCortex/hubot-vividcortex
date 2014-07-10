chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

describe 'vividcortex', ->
  beforeEach ->
    @robot =
      respond: sinon.spy()
      hear: sinon.spy()

    require('../src/vividcortex')(@robot)

  it 'Registers vividcortex respond listener', ->
    expect(@robot.respond).to.have.been.calledWith(/(vividcortex|vc) (.+)/i)
