
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

class KanaGroup
	constructor: ->
	swap: (a, b) ->
		tmp = a.kana
		a.kana = b.kana
		b.kana = tmp
		tmp = a.completed
		a.completed = b.completed
		b.completed = tmp

class KanaRow extends KanaGroup
	constructor: (@size, @comparator) ->
		super
	push: (cell) ->
		@row or= []
		if (@row.length < @size)
			@row.push cell

	shiftLeft: ->
		count = 0
		for i in [0...@size - 1]
			if (@row[i].isEmpty())
				tmp = @row[i].kana
				@swap(@row[i], @row[i+1])
			else
				result = @comparator.compare(@row[i].kana, @row[i+1].kana)
				if (result)
					@row[i].kana = result
					@row[i].complete()
					@row[i+1].kana = Kana_Empty
					count++
		return count

	shiftRight: ->
		count = 0
		for i in [1...@size]
			j = @size - i
			if (@row[j].isEmpty())
				tmp = @row[j].kana
				@swap(@row[j], @row[j-1])
			else
				result = @comparator.compare(@row[j].kana, @row[j-1].kana)
				if (result)
					@row[j].kana = result
					@row[j].complete()
					@row[j-1].kana = Kana_Empty
					count++
		return count

class KanaColumn extends KanaGroup
	constructor: (@size, @comparator) ->
		super
	push: (cell) ->
		@col or= []
		if (@col.length < @size)
			@col.push cell

	shiftUp: ->
		count = 0
		for i in [0...@size - 1]
			if (@col[i].isEmpty())
				tmp = @col[i].kana
				@swap(@col[i], @col[i+1])
			else
				result = @comparator.compare(@col[i].kana, @col[i+1].kana)
				if (result)
					@col[i].kana = result
					@col[i].complete()
					@col[i+1].kana = Kana_Empty
					count++
		return count

	shiftDown: ->
		count = 0
		for i in [1...@size]
			j = @size - i
			if (@col[j].isEmpty())
				tmp = @col[j].kana
				@swap(@col[j], @col[j-1])
			else
				result = @comparator.compare(@col[j].kana, @col[j-1].kana)
				if (result)
					@col[j].kana = result
					@col[j].complete()
					@col[j-1].kana = Kana_Empty
					count++
		return count


class KanaTable
	# @param size size of table
	# @param kana array of Hiragana
	constructor: (@size, @kana, @comparator) ->
		@table = []
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
			@table.push row
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
			cell = @table[y].row[x]
			if (cell.isEmpty())
				cell.kana = @getRandomKana()
				count++
			i++

	getRandomKana: ->
		return @kana[Math.floor(Math.random() * @kana.length)]

	shiftLeft: ->
		for row in @rows
			count = row.shiftLeft()
			if count > 0
				@completeWord = true
				@score += count

	shiftRight: ->
		for row in @rows
			count = row.shiftRight()
			if count > 0
				@completeWord = true
				@score += count

	shiftUp: ->
		for col in @cols
			count = col.shiftUp()
			if count > 0
				@completeWord = true
				@score += count

	shiftDown: ->
		for col in @cols
			count = col.shiftDown()
			if count > 0
				@completeWord = true
				@score += count

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
