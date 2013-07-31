(function() {
  var TreeMap, TreeMapToString, root, suggest, suggestionTree, transverse, _ref, _ref1,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  _ref = require('./suggest'), TreeMap = _ref.TreeMap, suggest = _ref.suggest, suggestionTree = _ref.suggestionTree, transverse = _ref.transverse, root = _ref.root;

  TreeMapToString = (function(_super) {
    __extends(TreeMapToString, _super);

    function TreeMapToString() {
      _ref1 = TreeMapToString.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    TreeMapToString.constructor = function() {
      return this.i = 0;
    };

    TreeMapToString.getSpaces = function() {
      var num;
      return ((function() {
        var _i, _ref2, _results;
        _results = [];
        for (num = _i = 1, _ref2 = this.i; 1 <= _ref2 ? _i <= _ref2 : _i >= _ref2; num = 1 <= _ref2 ? ++_i : --_i) {
          _results.push(' ');
        }
        return _results;
      }).call(this)).join('');
    };

    TreeMapToString.alternatives = function(root, alternatives) {
      var res;
      this.i = this.i + 1;
      res = '(' + this.getSpaces() + alternatives.join(' | ') + ')';
      this.i = this.i - 1;
      return res;
    };

    TreeMapToString.tuple = function(root, key, value) {
      var res;
      this.i = this.i + 1;
      res = '(' + key + ': ' + value + ')';
      this.i = this.i - 1;
      return res;
    };

    TreeMapToString.multiple = function(root, element) {
      var res;
      this.i = this.i + 1;
      res = '[' + this.getSpaces() + element + ']';
      this.i = this.i - 1;
      return res;
    };

    TreeMapToString.primitiveAlternatives = function(root, alternatives) {
      var i, res;
      this.i = this.i + 1;
      res = '(' + this.getSpaces() + alternatives.join(' | ') + ')';
      i = this.i - 1;
      return res;
    };

    TreeMapToString.postponedExecution = function(root, promise) {
      return promise;
    };

    TreeMapToString.node = function(root) {
      return root.constructor.name;
    };

    TreeMapToString.string = function(root) {
      return root;
    };

    return TreeMapToString;

  })(TreeMap);

  describe('Tree Mapping', function() {
    return it('should be able be used while transversing the tree', function(done) {
      var mappedTree;
      mappedTree = transverse(TreeMapToString, root);
      return done();
    });
  });

  describe('suggest', function() {
    it('should handle "title"', function(done) {
      suggest(suggestionTree, 0, ['title']);
      return done();
    });
    return it('should work with resources', function(done) {
      suggest(suggestionTree, 0, ['/hello', '/this', '/{is}', '/a', '/resource']);
      return done();
    });
  });

}).call(this);

/*
//@ sourceMappingURL=test.js.map
*/