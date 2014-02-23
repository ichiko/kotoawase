# usage
# {KanaComparator, ComparatorList} = require('path/to/file')

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

exports.KanaComparator = KanaComparator
exports.ComparatorList = ComparatorList