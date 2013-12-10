;(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var EmptySuggestor, Suggestor, UnionSuggestor, makeMethodGroupSuggestor, makeMethodSuggestor, methodBodySuggestor, namedParameterGroupSuggestor, namedParameterSuggestor, noopSuggestor, protocolsSuggestor, requestBodySuggestor, resourceBasicSuggestor, resourceFallback, resourceSuggestor, resourceTypeGroupSuggestor, resourceTypeSuggestor, responseBodyGroupSuggestor, responseBodyMimetypeSuggestor, responseGroupSuggestor, responseSuggestor, rootSuggestor, scalarSuggestor, securitySchemeTypeSuggestor, securitySchemesGroupSuggestor, securitySchemesSettingSuggestor, securitySchemesSuggestor, suggestorForPath, traitAdditions, traitGroupSuggestor, traitSuggestor, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Suggestor = (function() {
  function Suggestor(suggestors, options) {
    this.suggestors = suggestors;
    if (options == null) {
      options = {};
    }
    this.fallback = options.fallback, this.metadata = options.metadata, this.isScalar = options.isScalar;
    if (this.isScalar == null) {
      this.isScalar = false;
    }
    if (this.metadata == null) {
      this.metadata = {};
    }
    if (this.fallback == null) {
      this.fallback = function() {};
    }
  }

  Suggestor.prototype.suggestorFor = function(key) {
    var suggestors;
    suggestors = this.suggestors.filter(function(suggestor) {
      return suggestor[0] === key || suggestor[0] + '?' === key && suggestor[1].metadata.canBeOptional;
    });
    if (suggestors.length > 0) {
      return suggestors[0][1];
    } else {
      return this.fallback(key);
    }
  };

  Suggestor.prototype.suggestions = function() {
    var suggestions, suggestor, _i, _len, _ref;
    suggestions = {};
    _ref = this.suggestors;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      suggestor = _ref[_i];
      suggestions[suggestor[0]] = {
        metadata: suggestor[1].metadata
      };
    }
    return suggestions;
  };

  return Suggestor;

})();

EmptySuggestor = (function(_super) {
  __extends(EmptySuggestor, _super);

  function EmptySuggestor(options) {
    EmptySuggestor.__super__.constructor.call(this, [], options);
  }

  EmptySuggestor.prototype.suggestorFor = function(key) {
    return this;
  };

  return EmptySuggestor;

})(Suggestor);

UnionSuggestor = (function(_super) {
  __extends(UnionSuggestor, _super);

  function UnionSuggestor() {
    _ref = UnionSuggestor.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  UnionSuggestor.prototype.suggestorFor = function(key) {
    var suggestor, _i, _len, _ref1;
    _ref1 = this.suggestors;
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      suggestor = _ref1[_i];
      if (suggestor = suggestor.suggestorFor(key)) {
        return suggestor;
      }
    }
    return this.fallback(key);
  };

  UnionSuggestor.prototype.suggestions = function() {
    var key, suggestions, suggestor, suggestorSuggestions, value, _i, _len, _ref1;
    suggestions = {};
    _ref1 = this.suggestors;
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      suggestor = _ref1[_i];
      suggestorSuggestions = suggestor.suggestions();
      for (key in suggestorSuggestions) {
        value = suggestorSuggestions[key];
        suggestions[key] = value;
      }
    }
    return suggestions;
  };

  return UnionSuggestor;

})(Suggestor);

noopSuggestor = new EmptySuggestor;

scalarSuggestor = new EmptySuggestor({
  isScalar: true
});

resourceFallback = function(key) {
  if (/^\//.test(key)) {
    return resourceSuggestor;
  }
};

namedParameterSuggestor = new Suggestor([['default', scalarSuggestor], ['description', scalarSuggestor], ['displayName', scalarSuggestor], ['enum', scalarSuggestor], ['example', scalarSuggestor], ['maximum', scalarSuggestor], ['maxLength', scalarSuggestor], ['minimum', scalarSuggestor], ['minLength', scalarSuggestor], ['pattern', scalarSuggestor], ['required', scalarSuggestor], ['type', scalarSuggestor]]);

namedParameterGroupSuggestor = new Suggestor([], {
  fallback: function(key) {
    return namedParameterSuggestor;
  }
});

responseBodyMimetypeSuggestor = new Suggestor([['schema', noopSuggestor], ['example', noopSuggestor]]);

responseBodyGroupSuggestor = new Suggestor([['application/json', responseBodyMimetypeSuggestor], ['application/x-www-form-urlencoded', responseBodyMimetypeSuggestor], ['application/xml', responseBodyMimetypeSuggestor], ['multipart/form-data', responseBodyMimetypeSuggestor]]);

responseSuggestor = new Suggestor([['body', responseBodyGroupSuggestor], ['description', scalarSuggestor]]);

responseGroupSuggestor = new Suggestor([], {
  fallback: function(key) {
    if (/\d{3}/.test(key)) {
      return responseSuggestor;
    }
  }
});

requestBodySuggestor = new Suggestor([], {
  fallback: function() {
    return namedParameterGroupSuggestor;
  }
});

methodBodySuggestor = new Suggestor([['application/json', noopSuggestor], ['application/x-www-form-urlencoded', requestBodySuggestor], ['application/xml', noopSuggestor], ['multipart/form-data', requestBodySuggestor]]);

protocolsSuggestor = new Suggestor([['HTTP', noopSuggestor], ['HTTPS', noopSuggestor]]);

makeMethodSuggestor = function(optional) {
  if (optional == null) {
    optional = false;
  }
  return new Suggestor([['body', methodBodySuggestor], ['headers', namedParameterGroupSuggestor], ['is', noopSuggestor], ['protocols', protocolsSuggestor], ['queryParameters', namedParameterGroupSuggestor], ['responses', responseGroupSuggestor], ['securedBy', noopSuggestor]], {
    metadata: {
      category: 'methods',
      canBeOptional: optional
    }
  });
};

makeMethodGroupSuggestor = function(optional) {
  var method, methodSuggestor;
  if (optional == null) {
    optional = false;
  }
  methodSuggestor = makeMethodSuggestor(optional);
  return new Suggestor((function() {
    var _i, _len, _ref1, _results;
    _ref1 = ['get', 'post', 'put', 'delete', 'head', 'patch', 'trace', 'connect', 'options'];
    _results = [];
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      method = _ref1[_i];
      _results.push([method, methodSuggestor]);
    }
    return _results;
  })());
};

resourceBasicSuggestor = new Suggestor([['baseUriParameters', namedParameterGroupSuggestor], ['description', scalarSuggestor], ['displayName', scalarSuggestor], ['is', scalarSuggestor], ['securedBy', scalarSuggestor], ['type', scalarSuggestor], ['uriParameters', namedParameterGroupSuggestor]]);

resourceSuggestor = new UnionSuggestor([resourceBasicSuggestor, makeMethodGroupSuggestor()], {
  fallback: resourceFallback,
  metadata: {
    id: 'resource'
  }
});

traitAdditions = new Suggestor([['displayName', noopSuggestor], ['usage', noopSuggestor]]);

traitSuggestor = new UnionSuggestor([traitAdditions, makeMethodSuggestor()]);

resourceTypeSuggestor = new UnionSuggestor([resourceBasicSuggestor, makeMethodGroupSuggestor(true), new Suggestor([['usage', noopSuggestor]])]);

securitySchemesSettingSuggestor = new Suggestor([['requestTokenUri', noopSuggestor], ['authorizationUri', noopSuggestor], ['tokenCredentialsUri', noopSuggestor], ['accessTokenUri', noopSuggestor], ['scopes', noopSuggestor], ['authorizationGrants', noopSuggestor]]);

securitySchemeTypeSuggestor = new Suggestor([['OAuth 1.0', noopSuggestor], ['OAuth 2.0', noopSuggestor], ['Basic Authentication', noopSuggestor], ['Digest Authentication', noopSuggestor]]);

securitySchemesSuggestor = new Suggestor([['description', noopSuggestor], ['type', securitySchemeTypeSuggestor], ['settings', securitySchemesSettingSuggestor]]);

traitGroupSuggestor = new Suggestor([], {
  fallback: function() {
    return traitSuggestor;
  }
});

resourceTypeGroupSuggestor = new Suggestor([], {
  fallback: function() {
    return resourceTypeSuggestor;
  }
});

securitySchemesGroupSuggestor = new Suggestor([], {
  fallback: function() {
    return securitySchemesSuggestor;
  }
});

rootSuggestor = new Suggestor([['baseUri', scalarSuggestor], ['baseUriParameters', namedParameterGroupSuggestor], ['documentation', noopSuggestor], ['mediaType', noopSuggestor], ['protocols', protocolsSuggestor], ['resourceTypes', resourceTypeGroupSuggestor], ['schemas', noopSuggestor], ['securedBy', noopSuggestor], ['securitySchemes', securitySchemesGroupSuggestor], ['title', scalarSuggestor], ['traits', traitGroupSuggestor], ['version', scalarSuggestor]], {
  fallback: resourceFallback
});

suggestorForPath = function(path) {
  var suggestor;
  if (!path) {
    path = [];
  }
  suggestor = rootSuggestor;
  while (suggestor && path.length) {
    suggestor = suggestor.suggestorFor(path.shift());
  }
  return suggestor;
};

this.suggestRAML = function(path) {
  var suggestor;
  suggestor = (suggestorForPath(path)) || noopSuggestor;
  return {
    suggestions: suggestor.suggestions(),
    metadata: suggestor.metadata,
    isScalar: suggestor.isScalar
  };
};

if (typeof window !== 'undefined') {
  window.suggestRAML = this.suggestRAML;
}


},{}]},{},[1])
;