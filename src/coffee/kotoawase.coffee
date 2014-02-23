fs = require('fs')
template = fs.readFileSync(__dirname + '/../templates/kanaTable.html')

KanaTable = require('./kana.coffee')
{KanaComparator, ComparatorList} = require('./compalator.coffee')

Vue::attach = (selector) -> $(selector).append @$el

Message_Empty = '　'

$ ->
	compList = new ComparatorList()
	compList.push new KanaComparator('に', 'じ', '虹')
	compList.push new KanaComparator('し', 'ま', '島')

	content = new Vue
		template: template
		data:
			kanaTable: new KanaTable(4, ['に', 'じ', 'か', 'し', 'ま'], compList)
			score: 0
			tick: 0
			words: compList.toString()
			message: '左右上下に移動して、隣あった文字で下記の言葉を作ってください。'
			messageState: 'panel-default'
		methods:
			shiftUp: ->
				@$data.kanaTable.shiftUp()
				@updateMessage()
				@$data.score = @$data.kanaTable.score
				@$data.tick = @$data.kanaTable.tick
			shiftDown: ->
				@$data.kanaTable.shiftDown()
				@updateMessage()
				@$data.score = @$data.kanaTable.score
				@$data.tick = @$data.kanaTable.tick
			shiftLeft: ->
				@$data.kanaTable.shiftLeft()
				@updateMessage
				@$data.score = @$data.kanaTable.score
				@$data.tick = @$data.kanaTable.tick
			shiftRight: ->
				@$data.kanaTable.shiftRight()
				@updateMessage()
				@$data.score = @$data.kanaTable.score
				@$data.tick = @$data.kanaTable.tick
			updateMessage: ->
				switch @$data.kanaTable.state
					when KanaTable.STATE_MOVED
						@$data.message = '　'
						@$data.messageState = "panel-default"
					when KanaTable.STATE_COULD_NOT_MOVE
						@$data.message = 'その方向には移動できません。'
						@$data.messageState = 'panel-primary'
					when KanaTable.STATE_GAMEOVER
						@$data.message = 'ゲームオーバーです。'
						@$data.messageState = 'panel-danger'

	content.attach '#stage'
