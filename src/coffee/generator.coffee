# generator.coffee
# usage
# KanaGenerator = require('path/to/file')

LOOP_MAX = 50

class KanaGenerator
  @CreateStaticGenerator: (size) ->
    return new StaticGenerator(size)

  @CreateRandomGenerator: (size) ->
    return new RandomGenerator(size)

class StaticGenerator
  constructor: (@size) ->

  initialize: (initialTable, array, @loop = true) ->
    @index = 0
    @setInitialTable(initialTable)
    @setKanaArray(array)

  # 初期状態テーブルを取得する
  # @return 二次元配列
  getInitialTable: ->
    return @initialTable

  setInitialTable: (@initialTable) ->

  # 次のKanaInfoを取得し、カーソルを進める
  nextKanaInfo: ->
    kanaInfo = @kanaArray[@index]
    @index++
    if (@loop && @index >= @kanaArray.length)
      @index = 0
    return kanaInfo

  # 次のKanaInfoを取得する(カーソルは進めない)
  getKanaInfo: ->
    return @kanaArray[@index]

  setKanaArray: (@kanaArray) ->

class RandomGenerator
  constructor: (@size) ->

  initialize: (@kanaInfoList) ->
    # nop

  getInitialTable: ->
    table = []
    for i in [0...@size]
      table.push new Array(@size)

    kanaCount = Math.floor(@size * @size / 3)
    count = 0
    i = 0
    while (count < kanaCount)
      if (i > LOOP_MAX)
        break
      index = Math.floor(Math.random() * @size * @size)
      x = index % @size
      y = (index - x) / @size
      if (! table[y][x]?)
        table[y][x] = @getKanaInfo()
        count++
      i++

    return table

  nextKanaInfo: ->
    return @getKanaInfo()

  getKanaInfo: ->
    return @kanaInfoList[Math.floor(Math.random() * @kanaInfoList.length)]

module.exports = KanaGenerator
