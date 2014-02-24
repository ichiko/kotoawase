fs = require('fs')
template = fs.readFileSync(__dirname + '/../templates/kanaTable.html')

{KanaInfo, KanaTable} = require('./kana.coffee')
KanaComparationRuleList = require('./compalator.coffee')

KEYCODE_LEFT = 37
KEYCODE_UP = 38
KEYCODE_RIGHT = 39
KEYCODE_DOWN = 40

Vue::attach = (selector) -> $(selector).append @$el

formatRuleList = (ruleList) ->
	str = ''
	for cmp in ruleList.list
		if cmp.isCombineRule()
			if str.length != 0
				str += ', '
			str += cmp.toString()
	return str

$ ->
	kanaInfoList = []
	kanaInfoList.push new KanaInfo('に', 'kana1')
	kanaInfoList.push new KanaInfo('じ', 'kana2')
	kanaInfoList.push new KanaInfo('か', 'kana3')
	kanaInfoList.push new KanaInfo('し', 'kana4')
	kanaInfoList.push new KanaInfo('ま', 'kana5')

	ruleList = new KanaComparationRuleList()
	ruleList.addCombineRule('に', 'じ', '虹')
	ruleList.addCombineRule('し', 'ま', '島')
	ruleList.addUnionRule('に')
	ruleList.addUnionRule('じ')
	ruleList.addUnionRule('か')
	ruleList.addUnionRule('し')
	ruleList.addUnionRule('ま')

	content = new Vue
		template: template
		data:
			kanaTable: new KanaTable(4, kanaInfoList, ruleList)
			score: 0
			tick: 0
			words: formatRuleList(ruleList)
			message: '左右上下に移動して、隣あった文字で下記の言葉を作ってください。'
			messageState: 'panel-default'
		methods:
			shiftUp: (e) ->
				e.preventDefault()
				@$data.kanaTable.shiftUp()
				@updateMessage()
				@$data.score = @$data.kanaTable.score
				@$data.tick = @$data.kanaTable.tick
			shiftDown: (e) ->
				e.preventDefault()
				@$data.kanaTable.shiftDown()
				@updateMessage()
				@$data.score = @$data.kanaTable.score
				@$data.tick = @$data.kanaTable.tick
			shiftLeft: (e) ->
				e.preventDefault()
				@$data.kanaTable.shiftLeft()
				@updateMessage()
				@$data.score = @$data.kanaTable.score
				@$data.tick = @$data.kanaTable.tick
			shiftRight: (e) ->
				e.preventDefault()
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

	$('body').keydown( (e) ->
		switch e.keyCode
			when KEYCODE_LEFT
				content.shiftLeft()
			when KEYCODE_UP
				content.shiftUp()
			when KEYCODE_RIGHT
				content.shiftRight()
			when KEYCODE_DOWN
				content.shiftDown()
	)
