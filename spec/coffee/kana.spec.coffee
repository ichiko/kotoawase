# kana.spec.coffee

KanaGenerator = require('../../src/js/generator')
ScoreBoard = require('../../src/js/scoreboard')
{KanaInfo, KanaTable} = require('../../src/js/kana')
KanaComparationRuleList = require('../../src/js/compalator')

describe 'KanaTable', ->

  tableSize = 3

  CHAR_STAR = '★'
  CHAR_A = 'あ'
  CHAR_I = 'い'
  CHAR_W = 'を'

  WORD_AI = '愛'

  a = KanaInfo.Create(CHAR_A, 'kana1')
  i = KanaInfo.Create(CHAR_I, 'kana2')
  w = KanaInfo.Create(CHAR_W, 'kana3')
  n = undefined
  s = KanaInfo.CreateAsStar(CHAR_STAR, 'kana6')

  ruleList = new KanaComparationRuleList()
  ruleList.addCombineRule(CHAR_A, CHAR_I, WORD_AI)

  cellsAreEmpty = (table, cellsYX) ->
    for [y, x] in cellsYX
      expect(table.rows[y].cells[x].isEmpty()).toBe(true)

  cellCharactersAreStar = (table, cellsYX) ->
    for [y, x] in cellsYX
      expect(table.rows[y].cells[x].kana).toEqual(CHAR_STAR)

  cellIsStarAndMarked = (table, y, x) ->
    expect(table.rows[y].cells[x].isStar()).toBe(true)
    expect(table.rows[y].cells[x].willBeClear()).toBe(true)
    expect(table.rows[y].cells[x].isEmpty()).toBe(false)
    expect(table.rows[y].cells[x].isCombined()).toBe(false)
    expect(table.rows[y].cells[x].isUnited()).toBe(false)

  describe '左に移動させたとき', ->
    describe '[0,0]に言葉ができたとき', ->
      describe '隣にStarがあるとき', ->
        generator = KanaGenerator.CreateStaticGenerator(tableSize)
        initTable = [
          [a, i, s],
          [s, n, n],
          [n, n, n]
        ]
        generator.initialize(initTable, [a,i,w])

        table = new KanaTable(tableSize, generator, new ScoreBoard(), ruleList)
        table.shiftLeft()

        it '言葉ができている', ->
          expect(table.rows[0].cells[0].isCombined()).toBe(true)

        it 'できた言葉が正しい', ->
          expect(table.rows[0].cells[0].kana).toEqual(WORD_AI)

        it '隣の文字がStar', ->
          cellCharactersAreStar(table, [
            [0, 1], [1, 0]
          ])

        it '隣接するStarがマークされている', ->
          cellIsStarAndMarked(table, 0, 1)
          cellIsStarAndMarked(table, 1, 0)

        it '出現した文字が正しい', ->
          expect(table.rows[0].cells[2].kana).toEqual(CHAR_A)

        it '空のセルが正しい', ->
          cellsAreEmpty(table, [
            [1, 1], [1, 2], [2, 0], [2, 1], [2, 2]
          ])

    describe '[0,1]に言葉ができたとき', ->
      describe '隣にStarがあるとき', ->
        generator = KanaGenerator.CreateStaticGenerator(tableSize)
        initTable = [
          [s, a, i],
          [w, s, n],
          [n, n, n]
        ]
        generator.initialize(initTable, [s])

        table = new KanaTable(tableSize, generator, new ScoreBoard(), ruleList)
        table.shiftLeft()

        it '言葉ができている', ->
          expect(table.rows[0].cells[1].isCombined()).toBe(true)

        it 'できた言葉が正しい', ->
          expect(table.rows[0].cells[1].kana).toEqual(WORD_AI)

        it '隣の文字がStar', ->
          cellCharactersAreStar(table, [
            [0, 0], [0, 2], [1, 1]
          ])

        it '隣接するStarがマークされている', ->
          cellIsStarAndMarked(table, 0, 0)
          cellIsStarAndMarked(table, 0, 2)
          cellIsStarAndMarked(table, 1, 1)

        it '出現した文字が正しい', ->
          expect(table.rows[0].cells[2].kana).toEqual(CHAR_STAR)

        it '移動しなかった文字が正しい', ->
          expect(table.rows[1].cells[0].kana).toEqual(CHAR_W)

        it '空のセルが正しい', ->
          cellsAreEmpty(table, [
            [1, 2], [2, 0], [2, 1], [2, 2]
          ])

    describe '[1,0]に言葉ができたとき', ->
      describe '隣にStarがあるとき', ->
        generator = KanaGenerator.CreateStaticGenerator(tableSize)
        initTable = [
          [s, n, n],
          [a, i, s],
          [s, n, n]
        ]
        generator.initialize(initTable, [a])

        table = new KanaTable(tableSize, generator, new ScoreBoard(), ruleList)
        table.shiftLeft()

        it '言葉ができている', ->
          expect(table.rows[1].cells[0].isCombined()).toBe(true)

        it 'できた言葉が正しい', ->
          expect(table.rows[1].cells[0].kana).toEqual(WORD_AI)

        it '隣の文字がStar', ->
          cellCharactersAreStar(table, [
            [0, 0], [1, 1], [2, 0]
          ])

        it '隣接するStarがマークされている', ->
          cellIsStarAndMarked(table, 0, 0)
          cellIsStarAndMarked(table, 1, 1)
          cellIsStarAndMarked(table, 2, 0)

        it '出現した文字が正しい', ->
          expect(table.rows[1].cells[2].kana).toEqual(CHAR_A)

        it '空のセルが正しい', ->
          cellsAreEmpty(table, [
            [0, 1], [0, 2], [2, 1], [2, 2]
          ])

    describe '[1,1]に言葉ができたとき', ->
      describe '隣にStarがあるとき', ->
        generator = KanaGenerator.CreateStaticGenerator(tableSize)
        initTable = [
          [w, s, n],
          [s, a, i],
          [w, s, n]
        ]
        generator.initialize(initTable, [s])

        table = new KanaTable(tableSize, generator, new ScoreBoard(), ruleList)
        table.shiftLeft()

        it '言葉ができている', ->
          expect(table.rows[1].cells[1].isCombined()).toBe(true)

        it 'できた言葉が正しい', ->
          expect(table.rows[1].cells[1].kana).toEqual(WORD_AI)

        it '隣の文字がStar', ->
          cellCharactersAreStar(table, [
            [0, 1], [1, 0], [1, 2], [2, 1]
          ])

        it '隣接するStarがマークされている', ->
          cellIsStarAndMarked(table, 0, 1)
          cellIsStarAndMarked(table, 1, 0)
          cellIsStarAndMarked(table, 1, 2)
          cellIsStarAndMarked(table, 2, 1)

        it '出現した文字が正しい', ->
          expect(table.rows[1].cells[2].kana).toEqual(CHAR_STAR)

        it '移動しなかった文字が正しい', ->
          expect(table.rows[0].cells[0].kana).toEqual(CHAR_W)
          expect(table.rows[2].cells[0].kana).toEqual(CHAR_W)

        it '空のセルが正しい', ->
          cellsAreEmpty(table, [
            [0, 2], [2, 2]
          ])

  describe '右に移動させたとき', ->
    describe '[2,2]に言葉ができたとき', ->
      describe '隣にStarがあるとき', ->
        generator = KanaGenerator.CreateStaticGenerator(tableSize)
        initTable = [
          [n, n, n],
          [n, n, s],
          [s, i, a]
        ]
        generator.initialize(initTable, [a])

        table = new KanaTable(tableSize, generator, new ScoreBoard(), ruleList)
        table.shiftRight()

        it '言葉ができている', ->
          expect(table.rows[2].cells[2].isCombined()).toBe(true)

        it 'できた言葉が正しい', ->
          expect(table.rows[2].cells[2].kana).toEqual(WORD_AI)

        it '隣の文字がStar', ->
          cellCharactersAreStar(table, [
            [1, 2], [2, 1]
          ])

        it '隣接するStarがマークされている', ->
          cellIsStarAndMarked(table, 1, 2)
          cellIsStarAndMarked(table, 2, 1)

        it '出現した文字が正しい', ->
          expect(table.rows[2].cells[0].kana).toEqual(CHAR_A)

        it '空のセルが正しい', ->
          cellsAreEmpty(table, [
            [0, 0], [0, 1], [0, 2], [1, 0], [1,1]
          ])

    describe '[2,1]に言葉ができたとき', ->
      describe '隣にStarがあるとき', ->
        generator = KanaGenerator.CreateStaticGenerator(tableSize)
        initTable = [
          [n, n, n],
          [n, s, w],
          [a, i, s]
        ]
        generator.initialize(initTable, [s])

        table = new KanaTable(tableSize, generator, new ScoreBoard(), ruleList)
        table.shiftRight()

        it '言葉ができている', ->
          expect(table.rows[2].cells[1].isCombined()).toBe(true)

        it 'できた言葉が正しい', ->
          expect(table.rows[2].cells[1].kana).toEqual(WORD_AI)

        it '隣の文字がStar', ->
          cellCharactersAreStar(table, [
            [1, 1], [2, 0], [2, 2]
          ])

        it '隣接するStarがマークされている', ->
          cellIsStarAndMarked(table, 1, 1)
          cellIsStarAndMarked(table, 2, 0)
          cellIsStarAndMarked(table, 2, 2)

        it '出現した文字が正しい', ->
          expect(table.rows[2].cells[0].kana).toEqual(CHAR_STAR)

        it '移動しなかった文字が正しい', ->
          expect(table.rows[1].cells[2].kana).toEqual(CHAR_W)

        it '空のセルが正しい', ->
          cellsAreEmpty(table, [
            [0, 0], [0, 1], [0, 2], [1, 0]
          ])

    describe '[1,2]に言葉ができたとき', ->
      describe '隣にStarがあるとき', ->
        generator = KanaGenerator.CreateStaticGenerator(tableSize)
        initTable = [
          [n, n, s],
          [s, i, a],
          [n, n, s]
        ]
        generator.initialize(initTable, [a])

        table = new KanaTable(tableSize, generator, new ScoreBoard(), ruleList)
        table.shiftRight()

        it '言葉ができている', ->
          expect(table.rows[1].cells[2].isCombined()).toBe(true)

        it 'できた言葉が正しい', ->
          expect(table.rows[1].cells[2].kana).toEqual(WORD_AI)

        it '隣の文字がStar', ->
          cellCharactersAreStar(table, [
            [0, 2], [1, 1], [2, 2]
          ])

        it '隣接するStarがマークされている', ->
          cellIsStarAndMarked(table, 0, 2)
          cellIsStarAndMarked(table, 1, 1)
          cellIsStarAndMarked(table, 2, 2)

        it '出現した文字が正しい', ->
          expect(table.rows[1].cells[0].kana).toEqual(CHAR_A)

        it '空のセルが正しい', ->
          cellsAreEmpty(table, [
            [0, 0], [0, 1], [2, 0], [2, 1]
          ])

  describe '上に移動させたとき', ->
    describe '[0,2]に言葉ができたとき', ->
      describe '隣にStarがあるとき', ->
        generator = KanaGenerator.CreateStaticGenerator(tableSize)
        initTable = [
          [n, s, i],
          [n, n, a],
          [n, n, s]
        ]
        generator.initialize(initTable, [a])

        table = new KanaTable(tableSize, generator, new ScoreBoard(), ruleList)
        table.shiftUp()

        it '言葉ができている', ->
          expect(table.rows[0].cells[2].isCombined()).toBe(true)

        it 'できた言葉が正しい', ->
          expect(table.rows[0].cells[2].kana).toEqual(WORD_AI)

        it '隣の文字がStar', ->
          cellCharactersAreStar(table, [
            [0, 1], [1, 2]
          ])

        it '隣接するStarがマークされている', ->
          cellIsStarAndMarked(table, 0, 1)
          cellIsStarAndMarked(table, 1, 2)

        it '出現した文字が正しい', ->
          expect(table.rows[2].cells[2].kana).toEqual(CHAR_A)

        it '空のセルが正しい', ->
          cellsAreEmpty(table, [
            [0, 0], [1, 0], [1, 1], [2, 0], [2, 1]
          ])

    describe '[1,2]に言葉ができたとき', ->
      describe '隣にStarがあるとき', ->
        generator = KanaGenerator.CreateStaticGenerator(tableSize)
        initTable = [
          [n, w, s],
          [n, s, i],
          [n, n, a]
        ]
        generator.initialize(initTable, [s])

        table = new KanaTable(tableSize, generator, new ScoreBoard(), ruleList)
        table.shiftUp()

        it '言葉ができている', ->
          expect(table.rows[1].cells[2].isCombined()).toBe(true)

        it 'できた言葉が正しい', ->
          expect(table.rows[1].cells[2].kana).toEqual(WORD_AI)

        it '隣の文字がStar', ->
          cellCharactersAreStar(table, [
            [0, 2], [1, 1], [2, 2]
          ])

        it '隣接するStarがマークされている', ->
          cellIsStarAndMarked(table, 0, 2)
          cellIsStarAndMarked(table, 1, 1)
          cellIsStarAndMarked(table, 2, 2)

        it '出現した文字が正しい', ->
          expect(table.rows[2].cells[2].kana).toEqual(CHAR_STAR)

        it '移動しなかった文字が正しい', ->
          expect(table.rows[0].cells[1].kana).toEqual(CHAR_W)

        it '空のセルが正しい', ->
          cellsAreEmpty(table, [
            [0, 0], [1, 0], [2, 0], [2, 1]
          ])

    describe '[0,1]に言葉ができたとき', ->
      describe '隣にStarがあるとき', ->
        generator = KanaGenerator.CreateStaticGenerator(tableSize)
        initTable = [
          [s, a, s],
          [n, i, n],
          [n, s, n]
        ]
        generator.initialize(initTable, [a])

        table = new KanaTable(tableSize, generator, new ScoreBoard(), ruleList)
        table.shiftUp()

        it '言葉ができている', ->
          expect(table.rows[0].cells[1].isCombined()).toBe(true)

        it 'できた言葉が正しい', ->
          expect(table.rows[0].cells[1].kana).toEqual(WORD_AI)

        it '隣の文字がStar', ->
          cellCharactersAreStar(table, [
            [0, 0], [0, 2], [1, 1]
          ])

        it '隣接するStarがマークされている', ->
          cellIsStarAndMarked(table, 0, 0)
          cellIsStarAndMarked(table, 0, 2)
          cellIsStarAndMarked(table, 1, 1)

        it '出現した文字が正しい', ->
          expect(table.rows[2].cells[1].kana).toEqual(CHAR_A)

        it '空のセルが正しい', ->
          cellsAreEmpty(table, [
            [1, 0], [1, 2], [2, 0], [2, 2]
          ])

  describe '下に移動させたとき', ->
    describe '[2,0]に言葉ができたとき', ->
      describe '隣にStarがあるとき', ->
        generator = KanaGenerator.CreateStaticGenerator(tableSize)
        initTable = [
          [s, n, n],
          [i, n, n],
          [a, s, n]
        ]
        generator.initialize(initTable, [a])

        table = new KanaTable(tableSize, generator, new ScoreBoard(), ruleList)
        table.shiftDown()

        it '言葉ができている', ->
          expect(table.rows[2].cells[0].isCombined()).toBe(true)

        it 'できた言葉が正しい', ->
          expect(table.rows[2].cells[0].kana).toEqual(WORD_AI)

        it '隣の文字がStar', ->
          cellCharactersAreStar(table, [
            [1, 0], [2, 1]
          ])

        it '隣接するStarがマークされている', ->
          cellIsStarAndMarked(table, 1, 0)
          cellIsStarAndMarked(table, 2, 1)

        it '出現した文字が正しい', ->
          expect(table.rows[0].cells[0].kana).toEqual(CHAR_A)

        it '空のセルが正しい', ->
          cellsAreEmpty(table, [
            [0, 1], [0, 2], [1, 1], [1, 2], [2, 2]
          ])

    describe '[1,0]に言葉ができたとき', ->
      describe '隣にStarがあるとき', ->
        generator = KanaGenerator.CreateStaticGenerator(tableSize)
        initTable = [
          [a, n, n],
          [i, s, n],
          [s, w, n]
        ]
        generator.initialize(initTable, [s])

        table = new KanaTable(tableSize, generator, new ScoreBoard(), ruleList)
        table.shiftDown()

        it '言葉ができている', ->
          expect(table.rows[1].cells[0].isCombined()).toBe(true)

        it 'できた言葉が正しい', ->
          expect(table.rows[1].cells[0].kana).toEqual(WORD_AI)

        it '隣の文字がStar', ->
          cellCharactersAreStar(table, [
            [0, 0], [1, 1], [2, 0]
          ])

        it '隣接するStarがマークされている', ->
          cellIsStarAndMarked(table, 0, 0)
          cellIsStarAndMarked(table, 1, 1)
          cellIsStarAndMarked(table, 2, 0)

        it '出現した文字が正しい', ->
          expect(table.rows[0].cells[0].kana).toEqual(CHAR_STAR)

        it '移動しなかった文字が正しい', ->
          expect(table.rows[2].cells[1].kana).toEqual(CHAR_W)

        it '空のセルが正しい', ->
          cellsAreEmpty(table, [
            [0, 1], [0, 2], [1, 2], [2, 2]
          ])

    describe '[2,1]に言葉ができたとき', ->
      describe '隣にStarがあるとき', ->
        generator = KanaGenerator.CreateStaticGenerator(tableSize)
        initTable = [
          [n, s, n],
          [n, i, n],
          [s, a, s]
        ]
        generator.initialize(initTable, [a])

        table = new KanaTable(tableSize, generator, new ScoreBoard(), ruleList)
        table.shiftDown()

        it '言葉ができている', ->
          expect(table.rows[2].cells[1].isCombined()).toBe(true)

        it 'できた言葉が正しい', ->
          expect(table.rows[2].cells[1].kana).toEqual(WORD_AI)

        it '隣の文字がStar', ->
          cellCharactersAreStar(table, [
            [1, 1], [2, 0], [2, 2]
          ])

        it '隣接するStarがマークされている', ->
          cellIsStarAndMarked(table, 1, 1)
          cellIsStarAndMarked(table, 2, 0)
          cellIsStarAndMarked(table, 2, 2)

        it '出現した文字が正しい', ->
          expect(table.rows[0].cells[1].kana).toEqual(CHAR_A)

        it '空のセルが正しい', ->
          cellsAreEmpty(table, [
            [0, 0], [0, 2], [1, 0], [1, 2]
          ])
