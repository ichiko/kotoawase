KanaTable = require('./kana.coffee')
{KanaComparator, ComparatorList} = require('./compalator.coffee')

Vue::attach = (selector) -> $(selector).append @$el

$ ->
	compList = new ComparatorList()
	compList.push new KanaComparator('に', 'じ', '虹')
	compList.push new KanaComparator('し', 'ま', '島')

	content = new Vue
		template: '#kotoawase-table'
		data:
			kanaTable: new KanaTable(4, ['に', 'じ', 'か', 'し', 'ま'], compList)
			score: 0
			words: compList.toString()
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
