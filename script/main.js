(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){

},{}],2:[function(require,module,exports){
var KanaComparationRuleList, KanaComparator, KanaComparisionResult;

KanaComparator = (function() {
  function KanaComparator(kana_a, kana_b, type, result) {
    this.kana_a = kana_a;
    this.kana_b = kana_b;
    this.type = type;
    this.result = result;
  }

  KanaComparator.prototype.isCombineRule = function() {
    return this.type === KanaComparator.TYPE_COMBINE;
  };

  KanaComparator.prototype.toString = function() {
    return this.result + '(' + this.kana_a + this.kana_b + ')';
  };

  return KanaComparator;

})();

KanaComparator.TYPE_COMBINE = 'TYPE_COMBINE';

KanaComparator.TYPE_UNION = 'TYPE_UNION';

KanaComparator.TYPE_DISAPPEAR = 'TYPE_DISAPPEAR';

KanaComparisionResult = (function() {
  function KanaComparisionResult(type, kana) {
    this.type = type;
    this.kana = kana;
  }

  KanaComparisionResult.prototype.isNewWord = function() {
    return this.type === KanaComparator.TYPE_COMBINE;
  };

  KanaComparisionResult.prototype.isUnitedKana = function() {
    return this.type === KanaComparator.TYPE_UNION;
  };

  return KanaComparisionResult;

})();

KanaComparationRuleList = (function() {
  function KanaComparationRuleList() {
    this.list = [];
  }

  KanaComparationRuleList.prototype.addCombineRule = function(kana_a, kana_b, result) {
    return this.list.push(new KanaComparator(kana_a, kana_b, KanaComparator.TYPE_COMBINE, result));
  };

  KanaComparationRuleList.prototype.addUnionRule = function(kana) {
    return this.list.push(new KanaComparator(kana, kana, KanaComparator.TYPE_UNION, kana));
  };

  KanaComparationRuleList.prototype.addDisappearRule = function(kana) {
    return this.list.push(new KanaComparator(kana, kana, KanaComparator.TYPE_DISAPPEAR, ''));
  };

  KanaComparationRuleList.prototype.compare = function(kana_a, kana_b) {
    var cmp, _i, _len, _ref;
    _ref = this.list;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      cmp = _ref[_i];
      if ((kana_a === cmp.kana_a && kana_b === cmp.kana_b) || (kana_a === cmp.kana_b && kana_b === cmp.kana_a)) {
        return new KanaComparisionResult(cmp.type, cmp.result);
      }
    }
    return false;
  };

  KanaComparationRuleList.prototype.toString = function() {
    var cmp, str, _i, _len, _ref;
    str = "";
    _ref = this.list;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      cmp = _ref[_i];
      if (str.length !== 0) {
        str += ', ';
      }
      str += cmp.toString();
    }
    return str;
  };

  return KanaComparationRuleList;

})();

module.exports = KanaComparationRuleList;


},{}],3:[function(require,module,exports){
var KanaCell, KanaColumn, KanaGroup, KanaInfo, KanaRow, KanaTable, Kana_Empty, LOOP_MAX, ShiftResult,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Kana_Empty = '　';

LOOP_MAX = 50;

KanaInfo = (function() {
  function KanaInfo(kana, styleClass) {
    this.kana = kana;
    this.styleClass = styleClass;
  }

  KanaInfo.createAsDefault = function() {
    return new KanaInfo(KanaInfo.DefaultKana, KanaInfo.DefaultStyleClass);
  };

  return KanaInfo;

})();

KanaInfo.DefaultKana = Kana_Empty;

KanaInfo.DefaultStyleClass = 'kana-neutral';

KanaCell = (function() {
  function KanaCell(x, y, kanaInfo) {
    this.x = x;
    this.y = y;
    this.kana = kanaInfo.kana;
    this.style = kanaInfo.styleClass;
    this.combined = false;
    this.united = false;
  }

  KanaCell.prototype.isEmpty = function() {
    return this.kana === Kana_Empty;
  };

  KanaCell.prototype.combine = function() {
    return this.combined = true;
  };

  KanaCell.prototype.isCombined = function() {
    return this.combined;
  };

  KanaCell.prototype.unite = function() {
    return this.united = true;
  };

  KanaCell.prototype.isUnited = function() {
    return this.united;
  };

  KanaCell.prototype.setKanaInfo = function(kanaInfo) {
    this.kana = kanaInfo.kana;
    return this.style = kanaInfo.styleClass;
  };

  KanaCell.prototype.setNeutral = function() {
    this.combined = false;
    return this.united = false;
  };

  KanaCell.prototype.clear = function() {
    this.combined = false;
    this.united = false;
    this.kana = KanaInfo.DefaultKana;
    return this.style = KanaInfo.DefaultStyleClass;
  };

  return KanaCell;

})();

ShiftResult = (function() {
  function ShiftResult(moved, birthWordsCount) {
    this.moved = moved;
    this.birthWordsCount = birthWordsCount;
  }

  return ShiftResult;

})();

KanaGroup = (function() {
  function KanaGroup(size) {
    this.size = size;
  }

  KanaGroup.prototype.push = function(cell) {
    this.cells || (this.cells = []);
    if (this.cells.length < this.size) {
      return this.cells.push(cell);
    }
  };

  KanaGroup.prototype.shiftForward = function() {
    var i, moved, result, wordCount, _i, _ref;
    moved = false;
    wordCount = 0;
    for (i = _i = 0, _ref = this.size - 1; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      if (this.cells[i].isEmpty()) {
        if (!this.cells[i + 1].isEmpty()) {
          this.swap(this.cells[i], this.cells[i + 1]);
          moved = true;
        }
      } else {
        result = this.comparator.compare(this.cells[i].kana, this.cells[i + 1].kana);
        if (result) {
          if (result.isNewWord()) {
            this.cells[i].clear();
            this.cells[i + 1].clear();
            this.cells[i].kana = result.kana;
            this.cells[i].combine();
          } else if (result.isUnitedKana()) {
            this.cells[i + 1].clear();
            this.cells[i].kana = result.kana;
            this.cells[i].unite();
          }
          moved = true;
          wordCount++;
        }
      }
    }
    return new ShiftResult(moved, wordCount);
  };

  KanaGroup.prototype.shiftBack = function() {
    var i, j, moved, result, wordCount, _i, _ref;
    moved = false;
    wordCount = 0;
    for (i = _i = 1, _ref = this.size; 1 <= _ref ? _i < _ref : _i > _ref; i = 1 <= _ref ? ++_i : --_i) {
      j = this.size - i;
      if (this.cells[j].isEmpty()) {
        if (!this.cells[j - 1].isEmpty()) {
          this.swap(this.cells[j], this.cells[j - 1]);
          moved = true;
        }
      } else {
        result = this.comparator.compare(this.cells[j].kana, this.cells[j - 1].kana);
        if (result) {
          if (result.isNewWord()) {
            this.cells[j].clear();
            this.cells[j - 1].clear();
            this.cells[j].kana = result.kana;
            this.cells[j].combine();
          } else if (result.isUnitedKana()) {
            this.cells[j - 1].clear();
            this.cells[j].kana = result.kana;
            this.cells[j].unite();
          }
          moved = true;
          wordCount++;
        }
      }
    }
    return new ShiftResult(moved, wordCount);
  };

  KanaGroup.prototype.setHeadCell = function(kanaInfo) {
    return this.cells[0].setKanaInfo(kanaInfo);
  };

  KanaGroup.prototype.setTailCell = function(kanaInfo) {
    return this.cells[this.size - 1].setKanaInfo(kanaInfo);
  };

  KanaGroup.prototype.swap = function(cell_a, cell_b) {
    var tmp;
    tmp = cell_a.kana;
    cell_a.kana = cell_b.kana;
    cell_b.kana = tmp;
    tmp = cell_a.completed;
    cell_a.completed = cell_b.completed;
    cell_b.completed = tmp;
    tmp = cell_a.style;
    cell_a.style = cell_b.style;
    return cell_b.style = tmp;
  };

  KanaGroup.prototype.isInDeadlock = function() {
    var cell, cell_b, i, _i, _ref;
    for (i = _i = 0, _ref = this.cells.length - 1; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      cell = this.cells[i];
      if (cell.isEmpty()) {
        return false;
      }
      cell_b = this.cells[i + 1];
      if (this.comparator.compare(cell.kana, cell_b.kana)) {
        return false;
      }
    }
    return true;
  };

  return KanaGroup;

})();

KanaRow = (function(_super) {
  __extends(KanaRow, _super);

  function KanaRow(size, comparator) {
    this.size = size;
    this.comparator = comparator;
    KanaRow.__super__.constructor.call(this, this.size);
  }

  KanaRow.prototype.shiftLeft = function() {
    return this.shiftForward();
  };

  KanaRow.prototype.shiftRight = function() {
    return this.shiftBack();
  };

  KanaRow.prototype.addLeftside = function(kanaInfo) {
    return this.setHeadCell(kanaInfo);
  };

  KanaRow.prototype.addRightside = function(kanaInfo) {
    return this.setTailCell(kanaInfo);
  };

  return KanaRow;

})(KanaGroup);

KanaColumn = (function(_super) {
  __extends(KanaColumn, _super);

  function KanaColumn(size, comparator) {
    this.size = size;
    this.comparator = comparator;
    KanaColumn.__super__.constructor.call(this, this.size);
  }

  KanaColumn.prototype.shiftUp = function() {
    return this.shiftForward();
  };

  KanaColumn.prototype.shiftDown = function() {
    return this.shiftBack();
  };

  KanaColumn.prototype.addUpside = function(kanaInfo) {
    return this.setHeadCell(kanaInfo);
  };

  KanaColumn.prototype.addDownside = function(kanaInfo) {
    return this.setTailCell(kanaInfo);
  };

  return KanaColumn;

})(KanaGroup);

KanaTable = (function() {
  function KanaTable(size, kanaInfoList, comparator) {
    var cell, i, j, row, _i, _j, _k, _ref, _ref1, _ref2;
    this.size = size;
    this.kanaInfoList = kanaInfoList;
    this.comparator = comparator;
    this.rows = [];
    this.cols = [];
    for (i = _i = 0, _ref = this.size; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      this.cols.push(new KanaColumn(this.size, this.comparator));
    }
    for (i = _j = 0, _ref1 = this.size; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
      row = new KanaRow(this.size, this.comparator);
      for (j = _k = 0, _ref2 = this.size; 0 <= _ref2 ? _k < _ref2 : _k > _ref2; j = 0 <= _ref2 ? ++_k : --_k) {
        cell = new KanaCell(j, i, KanaInfo.createAsDefault());
        row.push(cell);
        this.cols[j].push(cell);
      }
      this.rows.push(row);
    }
    this.initialize();
  }

  KanaTable.prototype.initialize = function() {
    var cell, count, i, index, kanaCount, x, y, _results;
    this.score = 0;
    this.tick = 0;
    this.completeWord = false;
    this.state = KanaTable.STATE_MOVED;
    kanaCount = Math.floor(this.size * this.size / 3);
    count = 0;
    i = 0;
    _results = [];
    while (count < kanaCount) {
      if (i > LOOP_MAX) {
        break;
      }
      index = Math.floor(Math.random() * this.size * this.size);
      x = index % this.size;
      y = (index - x) / this.size;
      cell = this.rows[y].cells[x];
      if (cell.isEmpty()) {
        cell.setKanaInfo(this.getRandomKanaInfo());
        count++;
      }
      _results.push(i++);
    }
    return _results;
  };

  KanaTable.prototype.getRandomKanaInfo = function() {
    return this.kanaInfoList[Math.floor(Math.random() * this.kanaInfoList.length)];
  };

  KanaTable.prototype.shiftLeft = function() {
    var addIndex, i, movedRows, result, row, _i, _ref;
    this.resetCells();
    movedRows = [];
    for (i = _i = 0, _ref = this.rows.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      row = this.rows[i];
      result = row.shiftLeft();
      if (result.moved) {
        movedRows.push(i);
      }
      if (result.birthWordsCount > 0) {
        this.completeWord = true;
        this.score += result.birthWordsCount;
      }
    }
    if (movedRows.length > 0) {
      addIndex = movedRows[Math.floor(Math.random() * movedRows.length)];
      this.rows[addIndex].addRightside(this.getRandomKanaInfo());
      this.tick++;
    }
    this.updateState(movedRows.length > 0);
    return movedRows.length > 0;
  };

  KanaTable.prototype.shiftRight = function() {
    var addIndex, i, movedRows, result, row, _i, _ref;
    this.resetCells();
    movedRows = [];
    for (i = _i = 0, _ref = this.rows.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      row = this.rows[i];
      result = row.shiftRight();
      if (result.moved) {
        movedRows.push(i);
      }
      if (result.birthWordsCount > 0) {
        this.completeWord = true;
        this.score += result.birthWordsCount;
      }
    }
    if (movedRows.length > 0) {
      addIndex = movedRows[Math.floor(Math.random() * movedRows.length)];
      this.rows[addIndex].addLeftside(this.getRandomKanaInfo());
      this.tick++;
    }
    this.updateState(movedRows.length > 0);
    return movedRows.length > 0;
  };

  KanaTable.prototype.shiftUp = function() {
    var addIndex, col, i, movedCols, result, _i, _ref;
    this.resetCells();
    movedCols = [];
    for (i = _i = 0, _ref = this.cols.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      col = this.cols[i];
      result = col.shiftUp();
      if (result.moved) {
        movedCols.push(i);
      }
      if (result.birthWordsCount > 0) {
        this.completeWord = true;
        this.score += result.birthWordsCount;
      }
    }
    if (movedCols.length > 0) {
      addIndex = movedCols[Math.floor(Math.random() * movedCols.length)];
      this.cols[addIndex].addDownside(this.getRandomKanaInfo());
      this.tick++;
    }
    this.updateState(movedCols.length > 0);
    return movedCols.length > 0;
  };

  KanaTable.prototype.shiftDown = function() {
    var addIndex, col, i, movedCols, result, _i, _ref;
    this.resetCells();
    movedCols = [];
    for (i = _i = 0, _ref = this.cols.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      col = this.cols[i];
      result = col.shiftDown();
      if (result.moved) {
        movedCols.push(i);
      }
      if (result.birthWordsCount > 0) {
        this.completeWord = true;
        this.score += result.birthWordsCount;
      }
    }
    if (movedCols.length > 0) {
      addIndex = movedCols[Math.floor(Math.random() * movedCols.length)];
      this.cols[addIndex].addUpside(this.getRandomKanaInfo());
      this.tick++;
    }
    this.updateState(movedCols.length > 0);
    return movedCols.length > 0;
  };

  KanaTable.prototype.nextStepAvailable = function() {
    var col, row, _i, _j, _len, _len1, _ref, _ref1;
    if (this.completeWord) {
      return true;
    }
    _ref = this.rows;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      row = _ref[_i];
      if (!row.isInDeadlock()) {
        return true;
      }
    }
    _ref1 = this.cols;
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      col = _ref1[_j];
      if (!col.isInDeadlock()) {
        return true;
      }
    }
    return false;
  };

  KanaTable.prototype.updateState = function(moved) {
    var nextAvailable;
    nextAvailable = this.nextStepAvailable();
    this.state = KanaTable.STATE_MOVED;
    if (!nextAvailable) {
      this.state = KanaTable.STATE_GAMEOVER;
    }
    if ((!moved) && nextAvailable) {
      return this.state = KanaTable.STATE_COULD_NOT_MOVE;
    }
  };

  KanaTable.prototype.resetCells = function() {
    var cell, row, _i, _j, _len, _len1, _ref, _ref1;
    if (this.completeWord) {
      _ref = this.rows;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        row = _ref[_i];
        _ref1 = row.cells;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          cell = _ref1[_j];
          if (cell.isCombined()) {
            cell.clear();
          }
          if (cell.isUnited()) {
            cell.setNeutral();
          }
        }
      }
      return this.completeWord = false;
    }
  };

  return KanaTable;

})();

KanaTable.STATE_MOVED = 'STATE_MOVED';

KanaTable.STATE_COULD_NOT_MOVE = 'STATE_COULD_NOT_MOVE';

KanaTable.STATE_GAMEOVER = 'STATE_GAMEOVER';

exports.KanaInfo = KanaInfo;

exports.KanaTable = KanaTable;


},{}],4:[function(require,module,exports){
var KEYCODE_DOWN, KEYCODE_LEFT, KEYCODE_RIGHT, KEYCODE_UP, KanaComparationRuleList, KanaInfo, KanaTable, displayRule, fs, template, _ref;

fs = require('fs');

template = "<div align=\"center\">\n\n<div class=\"panel {{messageState}}\">\n\t<div class=\"panel-body\">\n\t\t{{message}}\n\t</div>\n</div>\n\n<div class=\"play-panel\">\n\t<div class=\"info-panel text-left\">\n\t\t<p class=\"text-center info-heading\">言葉</p>\n\t\t<ul>\n\t\t\t<li v-repeat=\"ruleList\">{{toString()}}</li>\n\t\t</ul>\n\t\t<p class=\"text-center info-heading visible-xs\">スコア</p>\n\t\t<p class=\"text-center visible-xs\">{{score}}点 / {{tick}}手</p>\n\t</div>\n\t<div class=\"kana-panel\">\n\t\t<table class=\"kana-table\" style=\"border: 0px;\">\n\t\t\t<tr v-repeat=\"kanaTable.rows\" data-index='{{$index}}'>\n\t\t\t\t<td v-repeat=\"cells\">\n\t\t\t\t\t<div class=\"{{ 'btn btn-default ' + (isCombined() ? 'cell-combined' : ( isUnited() ? 'cell-united' : ''))}}\">\n\t\t\t\t\t\t<span class=\"{{ 'kana-common ' + (isCombined() ? 'kana-combined' : style ) }}\">{{kana}}</span>\n\t\t\t\t\t</div>\n\t\t\t\t</td>\n\t\t\t</tr>\n\t\t</table>\n\t</div>\n</div>\n\n<div class=\"clear hidden-xs\">\n\t<p class=\"text-center\">スコア： <strong>{{score}}点 / {{tick}}手</strong></p>\n\t<table class=\"command-table\">\n\t\t<tr>\n\t\t\t<td class=\"command-column\">\n\t\t\t\t<button type=\"button\" class=\"btn btn-default command\"\n\t\t\t\t\tv-on='touchstart: shiftLeft, click: shiftLeft'>←</button>\n\t\t\t</td>\n\t\t\t<td class=\"command-column\">\n\t\t\t\t<button type=\"button\" class=\"btn btn-default command\"\n\t\t\t\t\tv-on='touchstart: shiftUp, click: shiftUp'>↑</button>\n\t\t\t\t<p></p>\n\t\t\t\t<button type=\"button\" class=\"btn btn-default command\"\n\t\t\t\t\tv-on='touchstart: shiftDown, click: shiftDown'>↓</button>\n\t\t\t</td>\n\t\t\t<td class=\"command-column\">\n\t\t\t\t<button type=\"button\" class=\"btn btn-default command\"\n\t\t\t\t\tv-on='touchstart: shiftRight, click: shiftRight'>→</button>\n\t\t\t</td>\n\t\t</tr>\n\t</table>\n</div>\n\n<div class=\"visible-xs\">\n\t<table class=\"command-table\">\n\t\t<tr>\n\t\t\t<td class=\"command-column\">\n\t\t\t\t<button type=\"button\" class=\"btn btn-default command\"\n\t\t\t\t\tv-on='touchstart: shiftLeft, click: shiftLeft'>←</button>\n\t\t\t</td>\n\t\t\t<td class=\"command-column\">\n\t\t\t\t<button type=\"button\" class=\"btn btn-default command\"\n\t\t\t\t\tv-on='touchstart: shiftUp, click: shiftUp'>↑</button>\n\t\t\t\t<p></p>\n\t\t\t\t<button type=\"button\" class=\"btn btn-default command\"\n\t\t\t\t\tv-on='touchstart: shiftDown, click: shiftDown'>↓</button>\n\t\t\t</td>\n\t\t\t<td class=\"command-column\">\n\t\t\t\t<button type=\"button\" class=\"btn btn-default command\"\n\t\t\t\t\tv-on='touchstart: shiftRight, click: shiftRight'>→</button>\n\t\t\t</td>\n\t\t</tr>\n\t</table>\n</div>\n\n</div>\n";

_ref = require('./kana.coffee'), KanaInfo = _ref.KanaInfo, KanaTable = _ref.KanaTable;

KanaComparationRuleList = require('./compalator.coffee');

KEYCODE_LEFT = 37;

KEYCODE_UP = 38;

KEYCODE_RIGHT = 39;

KEYCODE_DOWN = 40;

Vue.prototype.attach = function(selector) {
  return $(selector).append(this.$el);
};

displayRule = function(ruleList) {
  var cmp, list, _i, _len, _ref1;
  list = [];
  _ref1 = ruleList.list;
  for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
    cmp = _ref1[_i];
    if (cmp.isCombineRule()) {
      list.push(cmp);
    }
  }
  return list;
};

$(function() {
  var content, kanaInfoList, ruleList;
  kanaInfoList = [];
  kanaInfoList.push(new KanaInfo('に', 'kana1'));
  kanaInfoList.push(new KanaInfo('じ', 'kana2'));
  kanaInfoList.push(new KanaInfo('か', 'kana3'));
  kanaInfoList.push(new KanaInfo('し', 'kana4'));
  kanaInfoList.push(new KanaInfo('ま', 'kana5'));
  ruleList = new KanaComparationRuleList();
  ruleList.addCombineRule('に', 'じ', '虹');
  ruleList.addCombineRule('し', 'ま', '島');
  content = new Vue({
    template: template,
    data: {
      kanaTable: new KanaTable(4, kanaInfoList, ruleList),
      score: 0,
      tick: 0,
      ruleList: displayRule(ruleList),
      message: '左右上下に移動して、隣あった文字で下記の言葉を作ってください。',
      messageState: 'panel-default'
    },
    methods: {
      shiftUp: function(e) {
        e.preventDefault();
        this.$data.kanaTable.shiftUp();
        this.updateMessage();
        this.$data.score = this.$data.kanaTable.score;
        return this.$data.tick = this.$data.kanaTable.tick;
      },
      shiftDown: function(e) {
        e.preventDefault();
        this.$data.kanaTable.shiftDown();
        this.updateMessage();
        this.$data.score = this.$data.kanaTable.score;
        return this.$data.tick = this.$data.kanaTable.tick;
      },
      shiftLeft: function(e) {
        e.preventDefault();
        this.$data.kanaTable.shiftLeft();
        this.updateMessage();
        this.$data.score = this.$data.kanaTable.score;
        return this.$data.tick = this.$data.kanaTable.tick;
      },
      shiftRight: function(e) {
        e.preventDefault();
        this.$data.kanaTable.shiftRight();
        this.updateMessage();
        this.$data.score = this.$data.kanaTable.score;
        return this.$data.tick = this.$data.kanaTable.tick;
      },
      updateMessage: function() {
        switch (this.$data.kanaTable.state) {
          case KanaTable.STATE_MOVED:
            this.$data.message = '　';
            return this.$data.messageState = "panel-default";
          case KanaTable.STATE_COULD_NOT_MOVE:
            this.$data.message = 'その方向には移動できません。';
            return this.$data.messageState = 'panel-primary';
          case KanaTable.STATE_GAMEOVER:
            this.$data.message = 'ゲームオーバーです。';
            return this.$data.messageState = 'panel-danger';
        }
      }
    }
  });
  content.attach('#stage');
  return $('body').keydown(function(e) {
    switch (e.keyCode) {
      case KEYCODE_LEFT:
        return content.shiftLeft(e);
      case KEYCODE_UP:
        return content.shiftUp(e);
      case KEYCODE_RIGHT:
        return content.shiftRight(e);
      case KEYCODE_DOWN:
        return content.shiftDown(e);
    }
  });
});


},{"./compalator.coffee":2,"./kana.coffee":3,"fs":1}]},{},[4])