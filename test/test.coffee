# build time tests for recycler plugin
# see http://mochajs.org/

recycler = require '../client/recycler'
expect = require 'expect.js'

describe 'recycler plugin', ->

  describe 'expand', ->

    it 'can make itallic', ->
      result = recycler.expand 'hello *world*'
      expect(result).to.be 'hello <i>world</i>'
