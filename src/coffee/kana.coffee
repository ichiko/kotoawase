# usage
# KanaTable = require('path/to/file')

Kana_Empty = '　'
LOOP_MAX = 50

class KanaCell
	constructor: (@x, @y, @kana) ->
		@completed = false
	isEmpty: ->
		return (@kana == Kana_Empty)
	complete: ->
		@completed = true
	isCompleted: ->
		return @completed
	clear: ->
		@completed = false
		@kana = Kana_Empty
	color: ->
		if @completed
			return 'orange'
		else
			return 'non'

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
					tmp = @cells[i].kana
					@swap(@cells[i], @cells[i+1])
					moved = true
				# else
				#	moved = false
			else
				result = @comparator.compare(@cells[i].kana, @cells[i+1].kana)
				if (result)
					@cells[i].kana = result
					@cells[i].complete()
					@cells[i+1].kana = Kana_Empty
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
					tmp = @cells[j].kana
					@swap(@cells[j], @cells[j-1])
					moved = true
				# else
				#	moved = false
			else
				result = @comparator.compare(@cells[j].kana, @cells[j-1].kana)
				if (result)
					@cells[j].kana = result
					@cells[j].complete()
					@cells[j-1].kana = Kana_Empty
					moved = true
					wordCount++
		return new ShiftResult(moved, wordCount)

	setHeadCell: (kana) ->
		@cells[0].kana = kana

	setTailCell: (kana) ->
		@cells[@size-1].kana = kana

	swap: (cell_a, cell_b) ->
		tmp = cell_a.kana
		cell_a.kana = cell_b.kana
		cell_b.kana = tmp
		tmp = cell_a.completed
		cell_a.completed = cell_b.completed
		cell_b.completed = tmp

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

	addLeftside: (kana) ->
		@setHeadCell(kana)

	addRightside: (kana) ->
		@setTailCell(kana)

class KanaColumn extends KanaGroup
	constructor: (@size, @comparator) ->
		super @size

	shiftUp: ->
		return @shiftForward()

	shiftDown: ->
		return @shiftBack()

	addUpside: (kana) ->
		@setHeadCell(kana)

	addDownside: (kana) ->
		@setTailCell(kana)

class KanaTable
	# @param size size of table
	# @param kana array of Hiragana
	constructor: (@size, @kana, @comparator) ->
		@rows = []
		@cols = []

		for i in [0...@size]
			@cols.push new KanaColumn(@size, @comparator)

		for i in [0...@size]
			row = new KanaRow(@size, @comparator)
			for j in [0...@size]
				cell =  new KanaCell(j, i, Kana_Empty)
				row.push cell
				@cols[j].push cell
			@rows.push row
		@initialize()

	initialize: ->
		@score = 0
		@tick = 0
		@completeWord = false
		@state = KanaTable.STATE_MOVED

		kanaCount = Math.floor(@size * @size / 3)
		count = 0
		i = 0
		while (count < kanaCount)
			if (i > LOOP_MAX)
				break
			index = Math.floor(Math.random() * @size * @size)
			x = index % @size
			y = (index - x) / @size
			cell = @rows[y].cells[x]
			if (cell.isEmpty())
				cell.kana = @getRandomKana()
				count++
			i++

	getRandomKana: ->
		return @kana[Math.floor(Math.random() * @kana.length)]

	# shiftLeft/shiftRight/shiftUp/shiftDown
	# @return true/false 移動が発生したか
	shiftLeft: ->
		@dropWordCell()
		movedRows = []
		for i in [0...@rows.length]
			row = @rows[i]
			result = row.shiftLeft()
			if result.moved
				movedRows.push(i)
			if result.birthWordsCount > 0
				@completeWord = true
				@score += result.birthWordsCount
		@updateState(movedRows.length > 0)
		if (movedRows.length == 0)
			return false
		else
			addIndex = movedRows[Math.floor(Math.random() * movedRows.length)]
			@rows[addIndex].addRightside(@getRandomKana())
			@tick++
			return true

	shiftRight: ->
		@dropWordCell()
		movedRows = []
		for i in [0...@rows.length]
			row = @rows[i]
			result = row.shiftRight()
			if result.moved
				movedRows.push(i)
			if result.birthWordsCount > 0
				@completeWord = true
				@score += result.birthWordsCount
		@updateState(movedRows.length > 0)
		if (movedRows.length == 0)
			return false
		else
			addIndex = movedRows[Math.floor(Math.random() * movedRows.length)]
			@rows[addIndex].addLeftside(@getRandomKana())
			@tick++
			return true

	shiftUp: ->
		@dropWordCell()
		movedCols = []
		for i in [0...@cols.length]
			col = @cols[i]
			result = col.shiftUp()
			if result.moved
				movedCols.push(i)
			if result.birthWordsCount > 0
				@completeWord = true
				@score += result.birthWordsCount
		@updateState(movedCols.length > 0)
		if (movedCols.length == 0)
			return false
		else
			addIndex = movedCols[Math.floor(Math.random() * movedCols.length)]
			@cols[addIndex].addDownside(@getRandomKana())
			@tick++
			return true

	shiftDown: ->
		@dropWordCell()
		movedCols = []
		for i in [0...@cols.length]
			col = @cols[i]
			result = col.shiftDown()
			if result.moved
				movedCols.push(i)
			if result.birthWordsCount > 0
				@completeWord = true
				@score += result.birthWordsCount
		@updateState(movedCols.length > 0)
		if (movedCols.length == 0)
			return false
		else
			addIndex = movedCols[Math.floor(Math.random() * movedCols.length)]
			@cols[addIndex].addUpside(@getRandomKana())
			@tick++
			return true

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
		if (! moved && nextAvailable)
			@state = KanaTable.STATE_COULD_NOT_MOVE

	dropWordCell: ->
		if @completeWord
			for row in @rows
				for cell in row.cells
					if cell.isCompleted()
						cell.clear()
			@completeWord = false

KanaTable.STATE_MOVED = 'STATE_MOVED'
KanaTable.STATE_COULD_NOT_MOVE = 'STATE_COULD_NOT_MOVE'
KanaTable.STATE_GAMEOVER = 'STATE_GAMEOVER'

module.exports = KanaTable
