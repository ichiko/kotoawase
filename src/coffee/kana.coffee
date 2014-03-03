# usage
# {KanaInfo, KanaTable} = require('path/to/file')

Kana_Empty = '　'
LOOP_MAX = 50

class KanaInfo
	constructor: (@kana, @styleClass) ->

	@CreateAsDefault: ->
		return new KanaInfo(KanaInfo.DefaultKana, KanaInfo.DefaultStyleClass)

KanaInfo.DefaultKana = Kana_Empty
KanaInfo.DefaultStyleClass = 'kana-neutral'

class KanaCell
	constructor: (@x, @y, kanaInfo) ->
		@kana = kanaInfo.kana
		@style = kanaInfo.styleClass
		@combined = false
		@united = false
	isEmpty: ->
		return (@kana == KanaInfo.DefaultKana)
	combine: ->
		@combined = true
	isCombined: ->
		return @combined
	unite: ->
		@united = true
	isUnited: ->
		return @united
	setKanaInfo: (kanaInfo) ->
		@kana = kanaInfo.kana
		@style = kanaInfo.styleClass
	setNeutral: ->
		@combined = false
		@united = false
	clear: ->
		@combined = false
		@united = false
		@kana = KanaInfo.DefaultKana
		@style = KanaInfo.DefaultStyleClass

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

	# 手詰まりか
	# いずれの条件も満さない場合に真
	#  (1) 配列内に空きがある
	#  (2) 言葉になる組合せがある
	isInDeadlock: ->
		for i in [0...@cells.length - 1]
			cell = @cells[i]
			if (cell.isEmpty())
				return false
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
	constructor: (@size, @generator, @comparator) ->
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
		@tick = 0
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
		@resetCells()
		movedRows = []
		for i in [0...@rows.length]
			row = @rows[i]
			result = row.shiftLeft()
			if result.moved
				movedRows.push(i)
			if result.birthWordsCount > 0
				@completeWord = true
				@score += result.birthWordsCount
		if (movedRows.length > 0)
			addIndex = movedRows[Math.floor(Math.random() * movedRows.length)]
			@rows[addIndex].addRightside(@generator.nextKanaInfo())
			@tick++
		@updateState(movedRows.length > 0)
		return (movedRows.length > 0)


	shiftRight: ->
		@resetCells()
		movedRows = []
		for i in [0...@rows.length]
			row = @rows[i]
			result = row.shiftRight()
			if result.moved
				movedRows.push(i)
			if result.birthWordsCount > 0
				@completeWord = true
				@score += result.birthWordsCount
		if (movedRows.length > 0)
			addIndex = movedRows[Math.floor(Math.random() * movedRows.length)]
			@rows[addIndex].addLeftside(@generator.nextKanaInfo())
			@tick++
		@updateState(movedRows.length > 0)
		return (movedRows.length > 0)

	shiftUp: ->
		@resetCells()
		movedCols = []
		for i in [0...@cols.length]
			col = @cols[i]
			result = col.shiftUp()
			if result.moved
				movedCols.push(i)
			if result.birthWordsCount > 0
				@completeWord = true
				@score += result.birthWordsCount
		if (movedCols.length > 0)
			addIndex = movedCols[Math.floor(Math.random() * movedCols.length)]
			@cols[addIndex].addDownside(@generator.nextKanaInfo())
			@tick++
		@updateState(movedCols.length > 0)
		return (movedCols.length > 0)

	shiftDown: ->
		@resetCells()
		movedCols = []
		for i in [0...@cols.length]
			col = @cols[i]
			result = col.shiftDown()
			if result.moved
				movedCols.push(i)
			if result.birthWordsCount > 0
				@completeWord = true
				@score += result.birthWordsCount
		if (movedCols.length > 0)
			addIndex = movedCols[Math.floor(Math.random() * movedCols.length)]
			@cols[addIndex].addUpside(@generator.nextKanaInfo())
			@tick++
		@updateState(movedCols.length > 0)
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

	resetCells: ->
		if @completeWord
			for row in @rows
				for cell in row.cells
					if cell.isCombined()
						cell.clear()
					if cell.isUnited()
						cell.setNeutral()
			@completeWord = false

KanaTable.STATE_MOVED = 'STATE_MOVED'
KanaTable.STATE_COULD_NOT_MOVE = 'STATE_COULD_NOT_MOVE'
KanaTable.STATE_GAMEOVER = 'STATE_GAMEOVER'

exports.KanaInfo = KanaInfo
exports.KanaTable = KanaTable
