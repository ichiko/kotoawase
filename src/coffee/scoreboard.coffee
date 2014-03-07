# scoreboard.coffee

class ScoreBoard
  constructor: ->
    @chain = 0
    @score = 0
    @turn = 0

  startTurn: ->
    @turn++
    @wordCount = 0
    @starCount = 0

  calculateTurn: ->
    add = 0
    if @wordCount > 0
      @chain++
      add += Math.pow(ScoreBoard.PointPerWord, @wordCount) * @chainBonus()
      if @starCount > 0
        add += Math.pow(ScoreBoard.PointPerStar, @starCount)

      @score += add
    else
      @chain = 0

    if ScoreBoard.DEBUG
      console.log "ScoreBoard", @score, "(+", add, ")"

  chainBonus: ->
    return @chain

  addBirthWordCount: (count) ->
    @wordCount += count

  addMarkedStarCount: (count) ->
    @starCount += count

ScoreBoard.PointPerWord = 2
ScoreBoard.PointPerStar = 2

ScoreBoard.DEBUG = false

module.exports = ScoreBoard
