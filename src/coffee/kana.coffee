
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
		@completeWord = false

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

	shiftLeft: ->
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
			@rows[addIndex].addRightside(@getRandomKana())

	shiftRight: ->
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
			@rows[addIndex].addLeftside(@getRandomKana())

	shiftUp: ->
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
			@cols[addIndex].addDownside(@getRandomKana())

	shiftDown: ->
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
			@cols[addIndex].addUpside(@getRandomKana())

class KanaComparator
	constructor: (@kana_a, @kana_b, @result) ->

class ComparatorList
	constructor: ->
		@list = []
	push: (comp) ->
		@list.push comp
	compare: (kana_a, kana_b) ->
		for cmp in @list
			if ( (kana_a == cmp.kana_a && kana_b == cmp.kana_b) || (kana_a == cmp.kana_b && kana_b == cmp.kana_a) )
				return cmp.result
		return false
	toString: ->
		str = ""
		for cmp in @list
			if str.length != 0
				str += ', '
			str += cmp.result
		return str