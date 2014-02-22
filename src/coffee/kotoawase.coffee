Vue::attach = (selector) -> $(selector).append @$el

Kana_Empty = '　'

class KanaCell
	constructor: (@x, @y, @kana) ->
		@completed = false
	isEmpty: ->
		return (@kana == Kana_Empty)
	complete: ->
		@completed = true
	isCompleted: ->
		return @completed

class KanaRow
	constructor: (@size, @comparator) ->
	push: (cell) ->
		@row or= []
		if (@row.length < @size)
			@row.push cell

	shiftLeft: ->
		count = 0
		for i in [0...@size - 1]
			if (@row[i].isEmpty())
				tmp = @row[i].kana
				@row[i].kana = @row[i+1].kana
				@row[i+1].kana = tmp
			else
				result = @comparator.compare(@row[i].kana, @row[i+1].kana)
				if (result)
					@row[i].kana = result
					@row[i].kana = Kana_Empty
					count++
		return count

	shiftRight: ->
		count = 0
		for i in [1...@size]
			j = @size - i
			if (@row[j].isEmpty())
				tmp = @row[j].kana
				@row[j].kana = @row[j-1].kana
				@row[j-1].kana = tmp
			else
				result = @comparator.compare(@row[j].kana, @row[j-1].kana)
				if (result)
					@row[j].kana = result
					@row[j-1].kana = Kana_Empty
					count++
		return count

class KanaColumn
	constructor: (@size, @comparator) ->
	push: (cell) ->
		@col or= []
		if (@col.length < @size)
			@col.push cell

	shiftUp: ->
		count = 0
		for i in [0...@size - 1]
			if (@col[i].isEmpty())
				tmp = @col[i].kana
				@col[i].kana = @col[i+1].kana
				@col[i+1].kana = tmp
			else
				result = @comparator.compare(@col[i].kana, @col[i+1].kana)
				if (result)
					@col[i].kana = result
					@col[i].kana = Kana_Empty
					count++
		return count

	shiftDown: ->
		count = 0
		for i in [1...@size]
			j = @size - i
			if (@col[j].isEmpty())
				tmp = @col[j].kana
				@col[j].kana = @col[j-1].kana
				@col[j-1].kana = tmp
			else
				result = @comparator.compare(@col[j].kana, @col[j-1].kana)
				if (result)
					@col[j].kana = result
					@col[j-1].kana = Kana_Empty
					count++
		return count


class KanaTable
	# @param size size of table
	# @param kana array of Hiragana
	constructor: (@size, @kana, @comparator) ->
		@initialize()

	initialize: ->
		@score = 0
		@completeWord = false

		@table = []
		@rows = []
		@cols = []

		for i in [0...@size]
			@cols.push new KanaColumn(@size, @comparator)

		for i in [0...@size]
			row = new KanaRow(@size, @comparator)
			for j in [0...@size]
				cell =  new KanaCell(i, j, @getRandomKana())
				row.push cell
				@cols[j].push cell
			@table.push row
			@rows.push row

	getRandomKana: ->
		if (Math.floor(Math.random() * 3) != 1)
			return Kana_Empty
		return @kana[Math.floor(Math.random() * @kana.length)]

	shiftLeft: ->
		for row in @rows
			count = row.shiftLeft()
			if count > 0
				@completeWord = true

	shiftRight: ->
		for row in @rows
			count = row.shiftRight()
			if count > 0
				@completeWord = true

	shiftUp: ->
		for col in @cols
			count = col.shiftUp()
			if count > 0
				@completeWord = true

	shiftDown: ->
		for col in @cols
			count = col.shiftDown()
			if count > 0
				@completeWord = true


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

$ ->
	compList = new ComparatorList()
	compList.push new KanaComparator('に', 'じ', '虹')

	content = new Vue
		template: '#kotoawase-table'
		data:
			kanaTable: new KanaTable(4, ['に', 'じ', 'か', 'し', 'ま'], compList)
			score: 0
		methods:
			shiftUp: ->
				@$data.kanaTable.shiftUp()
				@$data.score = @$data.kanaTable.score
			shiftDown: ->
				@$data.kanaTable.shiftDown()
				@$data.score = @$data.kanaTable.score
			shiftLeft: ->
				@$data.kanaTable.shiftLeft()
				@$data.score = @$data.kanaTable.score
			shiftRight: ->
				@$data.kanaTable.shiftRight()
				@$data.score = @$data.kanaTable.score

	content.attach 'body'
