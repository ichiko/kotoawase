# usage
# KanaComparationRuleList = require('path/to/file')

class KanaComparator
	constructor: (@kana_a, @kana_b, @type, @result) ->
	isCombineRule: ->
		return (@type == KanaComparator.TYPE_COMBINE)
	toString: ->
		return @result + '(' + @kana_a + @kana_b + ')'

KanaComparator.TYPE_COMBINE = 'TYPE_COMBINE'
KanaComparator.TYPE_UNION = 'TYPE_UNION'
KanaComparator.TYPE_DISAPPEAR = 'TYPE_DISAPPEAR'

class KanaComparisionResult
	constructor: (@type, @kana) ->
	# 言葉が生成されたか
	isNewWord: ->
		return (@type == KanaComparator.TYPE_COMBINE)
	# 重ねてひとつのカナになったか
	isUnitedKana: ->
		return (@type == KanaComparator.TYPE_UNION)

class KanaComparationRuleList
	constructor: ->
		@list = []

	# 文字を重ねて言葉になる
	addCombineRule: (kana_a, kana_b, result) ->
		@list.push new KanaComparator(kana_a, kana_b, KanaComparator.TYPE_COMBINE, result)
	# 同じ文字を重ねるとひとつになる
	addUnionRule: (kana) ->
		@list.push new KanaComparator(kana, kana, KanaComparator.TYPE_UNION, kana)
	# 同じ文字を重ねると消える
	addDisappearRule: (kana) ->
		@list.push new KanaComparator(kana, kana, KanaComparator.TYPE_DISAPPEAR, '')

	compare: (kana_a, kana_b) ->
		for cmp in @list
			if ( (kana_a == cmp.kana_a && kana_b == cmp.kana_b) || (kana_a == cmp.kana_b && kana_b == cmp.kana_a) )
				return new KanaComparisionResult(cmp.type, cmp.result)
		return false

	toString: ->
		str = ""
		for cmp in @list
			if str.length != 0
				str += ', '
			str += cmp.toString()
		return str

module.exports = KanaComparationRuleList
