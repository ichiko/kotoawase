{KanaInfo, KanaTable} = require('../../src/js/kana')
KanaGenerator = require('../../src/js/generator')

describe "generator", ->
  describe "生成処理", ->
    it "生成して返す StaticGenerator", ->
      result = KanaGenerator.CreateStaticGenerator(3)
      expect(result).toBeDefined()
    it "生成して返す RandomGenerator", ->
      result = KanaGenerator.CreateRandomGenerator(3)
      expect(result).toBeDefined()
    it "生成して返す RandomWithPeriodicStarGenerator", ->
      result = KanaGenerator.CreatePeriodicStarGenerator(3)
      expect(result).toBeDefined()

  describe "StaticGenerator", ->

    a = new KanaInfo('あ', 'kana1')
    i = new KanaInfo('い', 'kana2')

    describe "ループする指定のとき", ->
      table = [
        [undefined, undefined, a],
        [a, i, undefined],
        [undefined, undefined, i]
      ]
      kanaList = [a, i, i, a]

      generator = undefined

      beforeEach ->
        generator = KanaGenerator.CreateStaticGenerator(3)
        generator.initialize(table, kanaList)

      it "指定したとおりの初期状態を取得する", ->
        result_table = generator.getInitialTable()

      it "getしてもnextするまで値は変わらない", ->
        prev = generator.getKanaInfo()
        expect(generator.getKanaInfo()).toEqual(prev)
        expect(generator.nextKanaInfo()).toEqual(prev)
        prev = generator.getKanaInfo()
        expect(generator.getKanaInfo()).toEqual(prev)
        expect(generator.nextKanaInfo()).toEqual(prev)

      it "指定したとおりの順で文字を生成する", ->
        expect(generator.nextKanaInfo()).toEqual(a)
        expect(generator.nextKanaInfo()).toEqual(i)
        expect(generator.nextKanaInfo()).toEqual(i)
        expect(generator.nextKanaInfo()).toEqual(a)

      it "指定した生成配列のサイズを越えても、文字を生成する", ->
        expect(generator.nextKanaInfo()).toEqual(a)
        expect(generator.nextKanaInfo()).toEqual(i)
        expect(generator.nextKanaInfo()).toEqual(i)
        expect(generator.nextKanaInfo()).toEqual(a)
        expect(generator.nextKanaInfo()).toEqual(a)
        expect(generator.nextKanaInfo()).toEqual(i)
        expect(generator.nextKanaInfo()).toEqual(i)
        expect(generator.nextKanaInfo()).toEqual(a)

    describe "ループしない指定のとき", ->
      table = [
        [undefined, undefined, a],
        [a, i, undefined],
        [undefined, undefined, i]
      ]
      kanaList = [a, i, i, a]

      generator = undefined

      beforeEach ->
        generator = KanaGenerator.CreateStaticGenerator(3)
        generator.initialize(table, kanaList, false)

      it "指定したとおりの初期状態を取得する", ->
        result_table = generator.getInitialTable()

      it "getしてもnextするまで値は変わらない", ->
        prev = generator.getKanaInfo()
        expect(generator.getKanaInfo()).toEqual(prev)
        expect(generator.nextKanaInfo()).toEqual(prev)
        prev = generator.getKanaInfo()
        expect(generator.getKanaInfo()).toEqual(prev)
        expect(generator.nextKanaInfo()).toEqual(prev)

      it "指定したとおりの順で文字を生成する", ->
        expect(generator.nextKanaInfo()).toEqual(a)
        expect(generator.nextKanaInfo()).toEqual(i)
        expect(generator.nextKanaInfo()).toEqual(i)
        expect(generator.nextKanaInfo()).toEqual(a)

      it "指定した生成配列のサイズを越えたら文字を生成しない", ->
        expect(generator.nextKanaInfo()).toEqual(a)
        expect(generator.nextKanaInfo()).toEqual(i)
        expect(generator.nextKanaInfo()).toEqual(i)
        expect(generator.nextKanaInfo()).toEqual(a)
        expect(generator.nextKanaInfo()).not.toBeDefined()

  describe "RandomGenerator", ->

  describe "RandomWithPeriodicStarGenerator", ->

    a = new KanaInfo('あ', 'kana1')
    i = new KanaInfo('い', 'kana2')
    star = new KanaInfo('★', 'kana3')
    kanaInfoList = [a, i]

    generator = undefined

    beforeEach ->
      generator = KanaGenerator.CreatePeriodicStarGenerator(3)
      generator.initialize(kanaInfoList, 3, star)

    it "getしてもnextするまで値は変わらない", ->
      prev = generator.getKanaInfo()
      expect(generator.getKanaInfo()).toEqual(prev)
      expect(generator.nextKanaInfo()).toEqual(prev)
      prev = generator.getKanaInfo()
      expect(generator.getKanaInfo()).toEqual(prev)
      expect(generator.nextKanaInfo()).toEqual(prev)

    it '指定した個数おきに、指定の文字を生成する', ->
      expect(generator.nextKanaInfo()).not.toEqual(star)
      expect(generator.nextKanaInfo()).not.toEqual(star)
      expect(generator.nextKanaInfo()).toEqual(star)
      expect(generator.nextKanaInfo()).not.toEqual(star)
      expect(generator.nextKanaInfo()).not.toEqual(star)
      expect(generator.nextKanaInfo()).toEqual(star)
