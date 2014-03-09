fs = require('fs')
template = fs.readFileSync(__dirname + '/../templates/kanaTable.html')

KanaGenerator = require('./generator')
ScoreBoard = require('./scoreboard')
{KanaInfo, KanaTable} = require('./kana')
KanaComparationRuleList = require('./compalator')

ScoreBoard.DEBUG = true

KEYCODE_LEFT = 37
KEYCODE_UP = 38
KEYCODE_RIGHT = 39
KEYCODE_DOWN = 40

Vue::attach = (selector) -> $(selector).append @$el

displayRule = (ruleList) ->
	list = []
	for cmp in ruleList.list
		if cmp.isCombineRule()
			list.push cmp
	return list

$ ->
	kanaInfoList = []
	kanaInfoList.push KanaInfo.Create('あ', 'kana1')
	kanaInfoList.push KanaInfo.Create('い', 'kana2')
	kanaInfoList.push KanaInfo.Create('う', 'kana3')
	kanaInfoList.push KanaInfo.Create('え', 'kana4')
	kanaInfoList.push KanaInfo.Create('お', 'kana5')
	star = KanaInfo.CreateAsStar('★', 'kana6')

	ruleList = new KanaComparationRuleList()
	ruleList.addCombineRule('あ', 'い', '愛')
	ruleList.addCombineRule('あ', 'お', '青')
	ruleList.addCombineRule('い', 'え', '家')
	ruleList.addCombineRule('お', 'う', '王')
	ruleList.addCombineRule('う', 'え', '上')
	ruleList.addCombineRule('お', 'い', '甥')

	tableSize = 4

	generator = KanaGenerator.CreatePeriodicStarGenerator(tableSize)
	generator.initialize(kanaInfoList, kanaInfoList.length + 1, star)

	scoreBoard = new ScoreBoard()
	kanaTable = new KanaTable(tableSize, generator, scoreBoard, ruleList)

	content = new Vue
		template: template
		data:
			kanaTable: kanaTable
			nextKana: kanaTable.getNextKanaInfo()
			scoreBoard: scoreBoard
			ruleList: displayRule(ruleList)
			message: '左右上下に動かして、ひらがな2文字で下記の言葉を作ってください。'
			messageState: 'panel-default'
		methods:
			shiftUp: (e) ->
				e.preventDefault()
				@$data.kanaTable.shiftUp()
				@update()
			shiftDown: (e) ->
				e.preventDefault()
				@$data.kanaTable.shiftDown()
				@update()
			shiftLeft: (e) ->
				e.preventDefault()
				@$data.kanaTable.shiftLeft()
				@update()
			shiftRight: (e) ->
				e.preventDefault()
				@$data.kanaTable.shiftRight()
				@update()
			update: ->
				@updateProperties()
				@updateMessage()
			updateProperties: ->
				@$data.nextKana = @$data.kanaTable.getNextKanaInfo()
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
				content.shiftLeft(e)
			when KEYCODE_UP
				content.shiftUp(e)
			when KEYCODE_RIGHT
				content.shiftRight(e)
			when KEYCODE_DOWN
				content.shiftDown(e)
	)
