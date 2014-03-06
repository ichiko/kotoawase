fs = require('fs')
template = fs.readFileSync(__dirname + '/../templates/kanaTable.html')

KanaGenerator = require('./generator')
{KanaInfo, KanaTable} = require('./kana')
KanaComparationRuleList = require('./compalator')

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

	console.log kanaInfoList
	console.log star

	ruleList = new KanaComparationRuleList()
	ruleList.addCombineRule('あ', 'い', '愛')
	ruleList.addCombineRule('あ', 'お', '青')
	ruleList.addCombineRule('い', 'え', '家')
	ruleList.addCombineRule('お', 'う', '王')
	ruleList.addCombineRule('う', 'え', '上')
	ruleList.addCombineRule('お', 'い', '甥')
	# 同じ文字をひとつにするルール
	#ruleList.addUnionRule('に')
	#ruleList.addUnionRule('じ')
	#ruleList.addUnionRule('か')
	#ruleList.addUnionRule('し')
	#ruleList.addUnionRule('ま')

	tableSize = 4

	#generator = KanaGenerator.CreateRandomGenerator(tableSize)
	#generator.initialize(kanaInfoList)
	#
	# init = [
	# 	[kanaInfoList[0], undefined, undefined, undefined],
	# 	[undefined, kanaInfoList[1], undefined, undefined],
	# 	[undefined, undefined, kanaInfoList[3], undefined],
	# 	[undefined, undefined, kanaInfoList[4], undefined]
	# ]
	# array = [
	# 	kanaInfoList[4], kanaInfoList[3], kanaInfoList[2],
	# 	kanaInfoList[1], kanaInfoList[0]
	# ]
	# generator = KanaGenerator.CreateStaticGenerator(tableSize)
	# generator.initialize(init, array)

	generator = KanaGenerator.CreatePeriodicStarGenerator(tableSize)
	generator.initialize(kanaInfoList, kanaInfoList.length + 1, star)

	content = new Vue
		template: template
		data:
			kanaTable: new KanaTable(tableSize, generator, ruleList)
			score: 0
			tick: 0
			ruleList: displayRule(ruleList)
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
				content.shiftLeft(e)
			when KEYCODE_UP
				content.shiftUp(e)
			when KEYCODE_RIGHT
				content.shiftRight(e)
			when KEYCODE_DOWN
				content.shiftDown(e)
	)
