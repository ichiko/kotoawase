KanaGenerator = require('../../src/js/generator')

describe "generator", ->
  describe "instanciate", ->
    it "生成して返す", ->
      expect(KanaGenerator.CreateStaticGenerator(4)).toBeDefined()
