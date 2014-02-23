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
			message: '左右上下に移動して、隣あった文字で下記の言葉を作ってください。'
		methods:
			shiftUp: ->
				@$data.message = ''
				moved = @$data.kanaTable.shiftUp()
				nextAvailable = @$data.kanaTable.nextStepAvailable()
				if ! nextAvailable
					@$data.message = 'ゲームオーバーです。'
				if (! moved && nextAvailable)
					@$data.message = 'その方向には移動できません。'
				@$data.score = @$data.kanaTable.score
			shiftDown: ->
				@$data.message = ''
				moved = @$data.kanaTable.shiftDown()
				nextAvailable = @$data.kanaTable.nextStepAvailable()
				if ! nextAvailable
					@$data.message = 'ゲームオーバーです。'
				if (! moved && nextAvailable)
					@$data.message = 'その方向には移動できません。'
				@$data.score = @$data.kanaTable.score
			shiftLeft: ->
				@$data.message = ''
				moved = @$data.kanaTable.shiftLeft()
				nextAvailable = @$data.kanaTable.nextStepAvailable()
				if ! nextAvailable
					@$data.message = 'ゲームオーバーです。'
				if (! moved && nextAvailable)
					@$data.message = 'その方向には移動できません。'
				@$data.score = @$data.kanaTable.score
			shiftRight: ->
				@$data.message = ''
				moved = @$data.kanaTable.shiftRight()
				nextAvailable = @$data.kanaTable.nextStepAvailable()
				if ! nextAvailable
					@$data.message = 'ゲームオーバーです。'
				if (! moved && nextAvailable)
					@$data.message = 'その方向には移動できません。'
				@$data.score = @$data.kanaTable.score

	content.attach 'body'
