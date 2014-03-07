# usage
# {KanaInfo, KanaTable} = require('path/to/file')

Kana_Empty = '　'
LOOP_MAX = 50

class KanaInfo
	constructor: (@kana, @styleClass, @type = KanaInfo.TYPE_KANA) ->

	@Create: (kana, styleClass) ->
		return new KanaInfo(kana, styleClass)

	@CreateAsDefault: ->
		return new KanaInfo(KanaInfo.DefaultKana, KanaInfo.DefaultStyleClass)

	@CreateAsStar: (kana, styleClass)->
		return new KanaInfo(kana, styleClass, KanaInfo.TYPE_STAR)

KanaInfo.DefaultKana = Kana_Empty
KanaInfo.DefaultStyleClass = 'kana-neutral'

KanaInfo.TYPE_KANA = "TYPE_KANA"
KanaInfo.TYPE_STAR = "TYPE_STAR"

class KanaCell
	constructor: (@x, @y, kanaInfo) ->
		@kana = kanaInfo.kana
		@style = kanaInfo.styleClass
		@type = kanaInfo.type
		@combined = false
		@united = false
		@willClear = false
	isEmpty: ->
		return (@kana == KanaInfo.DefaultKana)
	isStar: ->
		return (@type == KanaInfo.TYPE_STAR)
	combine: ->
		@combined = true
	isCombined: ->
		return @combined
	unite: ->
		@united = true
	isUnited: ->
		return @united
	markClear: ->
		@willClear = true
	willBeClear: ->
		return @willClear
	setKanaInfo: (kanaInfo) ->
		@kana = kanaInfo.kana
		@style = kanaInfo.styleClass
		@type = kanaInfo.type
	setNeutral: ->
		@combined = false
		@united = false
	clear: ->
		@combined = false
		@united = false
		@willClear = false
		@kana = KanaInfo.DefaultKana
		@style = KanaInfo.DefaultStyleClass
		@type = KanaInfo.TYPE_KANA

class ShiftResult
	# param moved 移動が発生したか
	# param birthWordsCount 成立した言葉の数
	constructor: (@moved, @birthWordsCount) ->

class KanaGroup
	constructor: (@size) ->

	push: (cell) ->
		@cells or= []
		if (@cells.length < @size)
			@cells.push cell

	# 前方へつめる
	shiftForward: ->
		moved = false
		wordCount = 0
		for i in [0...@size - 1]
			if (@cells[i].isEmpty())
				if (! @cells[i+1].isEmpty())
					@swap(@cells[i], @cells[i+1])
					moved = true
				# else
				#	moved = false
			else
				result = @comparator.compare(@cells[i].kana, @cells[i+1].kana)
				if (result)
					if (result.isNewWord())
						@cells[i].clear()
						@cells[i+1].clear()
						@cells[i].kana = result.kana
						@cells[i].combine()
					else if (result.isUnitedKana())
						@cells[i+1].clear()
						@cells[i].kana = result.kana
						@cells[i].unite()
					moved = true
					wordCount++
		return new ShiftResult(moved, wordCount)

	# 後方へつめる
	shiftBack: ->
		moved = false
		wordCount = 0
		for i in [1...@size]
			j = @size - i
			if (@cells[j].isEmpty())
				if (! @cells[j-1].isEmpty())
					@swap(@cells[j], @cells[j-1])
					moved = true
				# else
				#	moved = false
			else
				result = @comparator.compare(@cells[j].kana, @cells[j-1].kana)
				if (result)
					if (result.isNewWord())
						@cells[j].clear()
						@cells[j-1].clear()
						@cells[j].kana = result.kana
						@cells[j].combine()
					else if (result.isUnitedKana())
						@cells[j-1].clear()
						@cells[j].kana = result.kana
						@cells[j].unite()
					moved = true
					wordCount++
		return new ShiftResult(moved, wordCount)

	setHeadCell: (kanaInfo) ->
		@cells[0].setKanaInfo(kanaInfo)

	setTailCell: (kanaInfo) ->
		@cells[@size-1].setKanaInfo(kanaInfo)

	swap: (cell_a, cell_b) ->
		tmp = cell_a.kana
		cell_a.kana = cell_b.kana
		cell_b.kana = tmp
		tmp = cell_a.completed
		cell_a.completed = cell_b.completed
		cell_b.completed = tmp
		tmp = cell_a.style
		cell_a.style = cell_b.style
		cell_b.style = tmp
		tmp = cell_a.type
		cell_a.type = cell_b.type
		cell_b.type = tmp

	# 手詰まりか
	# いずれの条件も満さない場合に真
	#  (1) 配列内に空きがある
	#  (2) 言葉になる組合せがある
	isInDeadlock: ->
		for i in [0...@cells.length]
			cell = @cells[i]
			if (cell.isEmpty())
				return false
			if (i < @cells.length - 1)
				cell_b = @cells[i+1]
				if @comparator.compare(cell.kana, cell_b.kana)
					return false
		return true

class KanaRow extends KanaGroup
	constructor: (@size, @comparator) ->
		super @size

	shiftLeft: ->
		return @shiftForward()

	shiftRight: ->
		return @shiftBack()

	addLeftside: (kanaInfo) ->
		@setHeadCell(kanaInfo)

	addRightside: (kanaInfo) ->
		@setTailCell(kanaInfo)

class KanaColumn extends KanaGroup
	constructor: (@size, @comparator) ->
		super @size

	shiftUp: ->
		return @shiftForward()

	shiftDown: ->
		return @shiftBack()

	addUpside: (kanaInfo) ->
		@setHeadCell(kanaInfo)

	addDownside: (kanaInfo) ->
		@setTailCell(kanaInfo)

class KanaTable
	# @param size size of table
	# @param kana array of Hiragana
	constructor: (@size, @generator, @scoreBoard, @comparator) ->
		@rows = []
		@cols = []

		for i in [0...@size]
			@cols.push new KanaColumn(@size, @comparator)

		for i in [0...@size]
			row = new KanaRow(@size, @comparator)
			for j in [0...@size]
				cell =  new KanaCell(j, i, KanaInfo.CreateAsDefault())
				row.push cell
				@cols[j].push cell
			@rows.push row
		@initialize()

	initialize: ->
		@score = 0
		@completeWord = false
		@state = KanaTable.STATE_MOVED

		initialTable = @generator.getInitialTable()
		for y in [0...@size]
			for x in [0...@size]
				kanaInfo = initialTable[y][x]
				if kanaInfo?
					@rows[y].cells[x].setKanaInfo(kanaInfo)

	# shiftLeft/shiftRight/shiftUp/shiftDown
	# @return true/false 移動が発生したか
	shiftLeft: ->
		@scoreBoard.startTurn()
		@resetCells()
		movedRows = []
		for i in [0...@rows.length]
			row = @rows[i]
			result = row.shiftLeft()
			if result.moved
				movedRows.push(i)
			if result.birthWordsCount > 0
				@completeWord = true
				@scoreBoard.addBirthWordCount(result.birthWordsCount)
		if @completeWord
			@scoreBoard.addMarkedStarCount(@markClear())
		if (movedRows.length > 0)
			addIndex = movedRows[Math.floor(Math.random() * movedRows.length)]
			@rows[addIndex].addRightside(@generator.nextKanaInfo())
		@updateState(movedRows.length > 0)
		@scoreBoard.calculateTurn()
		return (movedRows.length > 0)


	shiftRight: ->
		@scoreBoard.startTurn()
		@resetCells()
		movedRows = []
		for i in [0...@rows.length]
			row = @rows[i]
			result = row.shiftRight()
			if result.moved
				movedRows.push(i)
			if result.birthWordsCount > 0
				@completeWord = true
				@scoreBoard.addBirthWordCount(result.birthWordsCount)
		if @completeWord
			@scoreBoard.addMarkedStarCount(@markClear())
		if (movedRows.length > 0)
			addIndex = movedRows[Math.floor(Math.random() * movedRows.length)]
			@rows[addIndex].addLeftside(@generator.nextKanaInfo())
		@updateState(movedRows.length > 0)
		@scoreBoard.calculateTurn()
		return (movedRows.length > 0)

	shiftUp: ->
		@scoreBoard.startTurn()
		@resetCells()
		movedCols = []
		for i in [0...@cols.length]
			col = @cols[i]
			result = col.shiftUp()
			if result.moved
				movedCols.push(i)
			if result.birthWordsCount > 0
				@completeWord = true
				@scoreBoard.addBirthWordCount(result.birthWordsCount)
		if @completeWord
			@scoreBoard.addMarkedStarCount(@markClear())
		if (movedCols.length > 0)
			addIndex = movedCols[Math.floor(Math.random() * movedCols.length)]
			@cols[addIndex].addDownside(@generator.nextKanaInfo())
		@updateState(movedCols.length > 0)
		@scoreBoard.calculateTurn()
		return (movedCols.length > 0)

	shiftDown: ->
		@scoreBoard.startTurn()
		@resetCells()
		movedCols = []
		for i in [0...@cols.length]
			col = @cols[i]
			result = col.shiftDown()
			if result.moved
				movedCols.push(i)
			if result.birthWordsCount > 0
				@completeWord = true
				@scoreBoard.addBirthWordCount(result.birthWordsCount)
		if @completeWord
			@scoreBoard.addMarkedStarCount(@markClear())
		if (movedCols.length > 0)
			addIndex = movedCols[Math.floor(Math.random() * movedCols.length)]
			@cols[addIndex].addUpside(@generator.nextKanaInfo())
		@updateState(movedCols.length > 0)
		@scoreBoard.calculateTurn()
		return (movedCols.length > 0)

	nextStepAvailable: ->
		# (1) 単語ができている
		if @completeWord
			return true
		# (2) 空セルがある
		# (3) 単語になる組み合わせがある
		for row in @rows
			if ! row.isInDeadlock()
				return true
		for col in @cols
			if ! col.isInDeadlock()
				return true
		return false

	updateState: (moved) ->
		nextAvailable = @nextStepAvailable()
		@state = KanaTable.STATE_MOVED
		if ! nextAvailable
			@state = KanaTable.STATE_GAMEOVER
		if ((! moved) && nextAvailable)
			@state = KanaTable.STATE_COULD_NOT_MOVE

	markClear: ->
		count = 0
		for row in @rows
			for cell in row.cells
				if cell.isCombined()
					if cell.x > 0 && row.cells[cell.x - 1].isStar()
						row.cells[cell.x - 1].markClear()
						count++
					if cell.x < @size - 1 && row.cells[cell.x + 1].isStar()
						row.cells[cell.x + 1].markClear()
						count++
					if cell.y > 0 && @rows[cell.y - 1].cells[cell.x].isStar()
						@rows[cell.y - 1].cells[cell.x].markClear()
						count++
					if cell.y < @size - 1 && @rows[cell.y + 1].cells[cell.x].isStar()
						@rows[cell.y + 1].cells[cell.x].markClear()
						count++
		return count

	resetCells: ->
		if @completeWord
			for row in @rows
				for cell in row.cells
					if cell.isCombined()
						cell.clear()
					if cell.isUnited()
						cell.setNeutral()
					if cell.willBeClear()
						cell.clear()
			@completeWord = false

KanaTable.STATE_MOVED = 'STATE_MOVED'
KanaTable.STATE_COULD_NOT_MOVE = 'STATE_COULD_NOT_MOVE'
KanaTable.STATE_GAMEOVER = 'STATE_GAMEOVER'

exports.KanaInfo = KanaInfo
exports.KanaTable = KanaTable
