(function(f){if(typeof exports==="object"&&typeof module!=="undefined"){module.exports=f()}else if(typeof define==="function"&&define.amd){define([],f)}else{var g;if(typeof window!=="undefined"){g=window}else if(typeof global!=="undefined"){g=global}else if(typeof self!=="undefined"){g=self}else{g=this}(g.RAML || (g.RAML = {})).Grammar = f()}})(function(){var define,module,exports;return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var noopSuggestor, suggestor08, suggestor10;

noopSuggestor = require('./suggestorXX').noopSuggestor;

suggestor08 = require('./suggestor08');

suggestor10 = require('./suggestor10');

module.exports.suggestRAML = function(path, version, fragment) {
  var suggestor;
  if (path == null) {
    path = [];
  }
  if (version == null) {
    version = '0.8';
  }
  if (fragment == null) {
    fragment = 'ApiDefinition';
  }
  suggestor = {
    '0.8': suggestor08,
    '1.0': suggestor10
  }[version];
  if (!suggestor) {
    throw new Error('unsupported version: ' + version);
  }
  suggestor = suggestor[fragment];
  if (!suggestor) {
    throw new Error('unsupported fragment: ' + fragment);
  }
  while (suggestor && path.length) {
    suggestor = suggestor.suggestorFor(path.shift());
  }
  if (!suggestor) {
    suggestor = noopSuggestor;
  }
  return {
    suggestions: suggestor.suggestions(),
    metadata: suggestor.metadata
  };
};


},{"./suggestor08":2,"./suggestor10":3,"./suggestorXX":4}],2:[function(require,module,exports){
var EmptySuggestor, SuggestionItem, Suggestor, UnionSuggestor, describedBySuggestor, dynamicResource, makeMethodGroupSuggestor, makeMethodSuggestor, methodBodySuggestor, namedParameterGroupSuggestor, namedParameterSuggestor, noopSuggestor, protocolsSuggestor, requestBodySuggestor, resourceBasicSuggestor, resourceFallback, resourceSuggestor, resourceTypeGroupSuggestor, resourceTypeSuggestor, responseBodyGroupSuggestor, responseBodyMimetypeSuggestor, responseGroupSuggestor, responseSuggestor, rootDocumentationSuggestor, securitySchemeTypeSuggestor, securitySchemesGroupSuggestor, securitySchemesSettingSuggestor, securitySchemesSuggestor, traitAdditions, traitGroupSuggestor, traitSuggestor;

EmptySuggestor = require('./suggestorXX').EmptySuggestor;

SuggestionItem = require('./suggestorXX').SuggestionItem;

Suggestor = require('./suggestorXX').Suggestor;

UnionSuggestor = require('./suggestorXX').UnionSuggestor;

noopSuggestor = require('./suggestorXX').noopSuggestor;

namedParameterSuggestor = new Suggestor([
  new SuggestionItem('description', noopSuggestor, {
    category: 'docs'
  }), new SuggestionItem('displayName', noopSuggestor, {
    category: 'docs'
  }), new SuggestionItem('example', noopSuggestor, {
    category: 'docs'
  }), new SuggestionItem('default', noopSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('enum', noopSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('maximum', noopSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('maxLength', noopSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('minimum', noopSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('minLength', noopSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('pattern', noopSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('required', noopSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('type', noopSuggestor, {
    category: 'parameters'
  })
]);

namedParameterGroupSuggestor = new EmptySuggestor(function(key) {
  return namedParameterSuggestor;
});

responseBodyMimetypeSuggestor = new Suggestor([
  new SuggestionItem('schema', noopSuggestor, {
    category: 'schemas'
  }), new SuggestionItem('example', noopSuggestor, {
    category: 'docs'
  })
]);

responseBodyGroupSuggestor = new Suggestor([
  new SuggestionItem('application/json', responseBodyMimetypeSuggestor, {
    category: 'body'
  }), new SuggestionItem('application/x-www-form-urlencoded', responseBodyMimetypeSuggestor, {
    category: 'body'
  }), new SuggestionItem('application/xml', responseBodyMimetypeSuggestor, {
    category: 'body'
  }), new SuggestionItem('multipart/form-data', responseBodyMimetypeSuggestor, {
    category: 'body'
  })
]);

responseSuggestor = new Suggestor([
  new SuggestionItem('body', responseBodyGroupSuggestor, {
    category: 'responses'
  }), new SuggestionItem('description', noopSuggestor, {
    category: 'docs'
  })
]);

responseGroupSuggestor = new EmptySuggestor(function(key) {
  if (/\d{3}/.test(key)) {
    return responseSuggestor;
  }
});

requestBodySuggestor = new EmptySuggestor(function() {
  return namedParameterGroupSuggestor;
});

methodBodySuggestor = new Suggestor([
  new SuggestionItem('application/json', noopSuggestor, {
    category: 'body'
  }), new SuggestionItem('application/x-www-form-urlencoded', requestBodySuggestor, {
    category: 'body'
  }), new SuggestionItem('application/xml', noopSuggestor, {
    category: 'body'
  }), new SuggestionItem('multipart/form-data', requestBodySuggestor, {
    category: 'body'
  })
]);

protocolsSuggestor = new Suggestor([
  new SuggestionItem('HTTP', noopSuggestor, {
    isText: true
  }), new SuggestionItem('HTTPS', noopSuggestor, {
    isText: true
  })
], null, {
  isList: true
});

makeMethodSuggestor = function() {
  return new Suggestor([
    new SuggestionItem('description', noopSuggestor, {
      category: 'docs'
    }), new SuggestionItem('body', methodBodySuggestor, {
      category: 'body'
    }), new SuggestionItem('protocols', protocolsSuggestor, {
      category: 'root'
    }), new SuggestionItem('baseUriParameters', namedParameterGroupSuggestor, {
      category: 'parameters'
    }), new SuggestionItem('headers', namedParameterGroupSuggestor, {
      category: 'parameters'
    }), new SuggestionItem('queryParameters', namedParameterGroupSuggestor, {
      category: 'parameters'
    }), new SuggestionItem('responses', responseGroupSuggestor, {
      category: 'responses'
    }), new SuggestionItem('securedBy', noopSuggestor, {
      category: 'security'
    })
  ]);
};

makeMethodGroupSuggestor = function(optional) {
  var method, methodSuggestor;
  if (optional == null) {
    optional = false;
  }
  methodSuggestor = new UnionSuggestor([
    makeMethodSuggestor(), new Suggestor([
      new SuggestionItem('is', noopSuggestor, {
        category: 'traits and types'
      })
    ])
  ]);
  return new Suggestor((function() {
    var i, len, ref, results;
    ref = ['options', 'get', 'head', 'post', 'put', 'delete', 'trace', 'connect', 'patch'];
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      method = ref[i];
      results.push(new SuggestionItem(method, methodSuggestor, {
        category: 'methods',
        canBeOptional: optional
      }));
    }
    return results;
  })());
};

resourceBasicSuggestor = new Suggestor([
  new SuggestionItem('description', noopSuggestor, {
    category: 'docs'
  }), new SuggestionItem('displayName', noopSuggestor, {
    category: 'docs'
  }), new SuggestionItem('securedBy', noopSuggestor, {
    category: 'security'
  }), new SuggestionItem('type', noopSuggestor, {
    category: 'traits and types'
  }), new SuggestionItem('is', noopSuggestor, {
    category: 'traits and types'
  })
]);

resourceFallback = function(key) {
  if (/^\//.test(key)) {
    return resourceSuggestor;
  }
};

dynamicResource = new SuggestionItem('<resource>', resourceSuggestor, {
  category: 'resources',
  dynamic: true
});

resourceSuggestor = new UnionSuggestor([
  resourceBasicSuggestor, makeMethodGroupSuggestor(), new Suggestor([
    new SuggestionItem('baseUriParameters', namedParameterGroupSuggestor, {
      category: 'parameters'
    }), new SuggestionItem('uriParameters', namedParameterGroupSuggestor, {
      category: 'parameters'
    }), dynamicResource
  ])
], resourceFallback);

traitAdditions = new Suggestor([
  new SuggestionItem('displayName', noopSuggestor, {
    category: 'docs'
  }), new SuggestionItem('usage', noopSuggestor, {
    category: 'docs'
  })
]);

traitSuggestor = new UnionSuggestor([traitAdditions, makeMethodSuggestor()]);

resourceTypeSuggestor = new UnionSuggestor([
  resourceBasicSuggestor, makeMethodGroupSuggestor(true), new Suggestor([
    new SuggestionItem('baseUriParameters', namedParameterGroupSuggestor, {
      category: 'parameters',
      canBeOptional: true
    }), new SuggestionItem('uriParameters', namedParameterGroupSuggestor, {
      category: 'parameters',
      canBeOptional: true
    }), new SuggestionItem('usage', noopSuggestor, {
      category: 'docs'
    })
  ])
]);

securitySchemesSettingSuggestor = new Suggestor([
  new SuggestionItem('accessTokenUri', noopSuggestor, {
    category: 'security'
  }), new SuggestionItem('authorizationGrants', noopSuggestor, {
    category: 'security'
  }), new SuggestionItem('authorizationUri', noopSuggestor, {
    category: 'security'
  }), new SuggestionItem('requestTokenUri', noopSuggestor, {
    category: 'security'
  }), new SuggestionItem('scopes', noopSuggestor, {
    category: 'security'
  }), new SuggestionItem('tokenCredentialsUri', noopSuggestor, {
    category: 'security'
  })
]);

securitySchemeTypeSuggestor = new Suggestor([
  new SuggestionItem('OAuth 1.0', noopSuggestor, {
    category: 'security'
  }), new SuggestionItem('OAuth 2.0', noopSuggestor, {
    category: 'security'
  }), new SuggestionItem('Basic Authentication', noopSuggestor, {
    category: 'security'
  }), new SuggestionItem('Digest Authentication', noopSuggestor, {
    category: 'security'
  })
]);

describedBySuggestor = new Suggestor([
  new SuggestionItem('headers', namedParameterGroupSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('queryParameters', namedParameterGroupSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('responses', responseGroupSuggestor, {
    category: 'responses'
  })
]);

securitySchemesSuggestor = new Suggestor([
  new SuggestionItem('description', noopSuggestor, {
    category: 'docs'
  }), new SuggestionItem('describedBy', describedBySuggestor, {
    category: 'security'
  }), new SuggestionItem('type', securitySchemeTypeSuggestor, {
    category: 'security'
  }), new SuggestionItem('settings', securitySchemesSettingSuggestor, {
    category: 'security'
  })
]);

traitGroupSuggestor = new EmptySuggestor(function() {
  return traitSuggestor;
});

resourceTypeGroupSuggestor = new EmptySuggestor(function() {
  return resourceTypeSuggestor;
});

securitySchemesGroupSuggestor = new EmptySuggestor(function() {
  return securitySchemesSuggestor;
});

rootDocumentationSuggestor = new Suggestor([
  new SuggestionItem('content', noopSuggestor, {
    category: 'docs'
  }), new SuggestionItem('title', noopSuggestor, {
    category: 'docs'
  })
], null, {
  isList: true
});

module.exports = {
  ApiDefinition: new Suggestor([
    new SuggestionItem('baseUriParameters', namedParameterGroupSuggestor, {
      category: 'parameters'
    }), new SuggestionItem('baseUri', noopSuggestor, {
      category: 'root'
    }), new SuggestionItem('mediaType', noopSuggestor, {
      category: 'root'
    }), new SuggestionItem('protocols', protocolsSuggestor, {
      category: 'root'
    }), new SuggestionItem('title', noopSuggestor, {
      category: 'root'
    }), new SuggestionItem('version', noopSuggestor, {
      category: 'root'
    }), new SuggestionItem('documentation', rootDocumentationSuggestor, {
      category: 'docs'
    }), new SuggestionItem('schemas', noopSuggestor, {
      category: 'schemas'
    }), new SuggestionItem('securedBy', noopSuggestor, {
      category: 'security'
    }), new SuggestionItem('securitySchemes', securitySchemesGroupSuggestor, {
      category: 'security'
    }), new SuggestionItem('resourceTypes', resourceTypeGroupSuggestor, {
      category: 'traits and types'
    }), new SuggestionItem('traits', traitGroupSuggestor, {
      category: 'traits and types'
    }), dynamicResource
  ], resourceFallback)
};


},{"./suggestorXX":4}],3:[function(require,module,exports){
var EmptySuggestor, SuggestionItem, Suggestor, UnionSuggestor, apiDefinitionSuggestor, describedBySuggestor, documentationItemSuggestor, dynamicResource, extensionSuggestor, librarySuggestor, makeMethodGroupSuggestor, makeMethodSuggestor, methodBodySuggestor, namedParameterGroupSuggestor, namedParameterSuggestor, noopSuggestor, overlaySuggestor, protocolsSuggestor, requestBodySuggestor, resourceBasicSuggestor, resourceFallback, resourceSuggestor, resourceTypeGroupSuggestor, resourceTypeSuggestor, responseBodyGroupSuggestor, responseBodyMimetypeSuggestor, responseGroupSuggestor, responseSuggestor, rootDocumentationSuggestor, securitySchemeTypeSuggestor, securitySchemesGroupSuggestor, securitySchemesSettingSuggestor, securitySchemesSuggestor, traitAdditions, traitGroupSuggestor, traitSuggestor, xmlSuggestor;

EmptySuggestor = require('./suggestorXX').EmptySuggestor;

SuggestionItem = require('./suggestorXX').SuggestionItem;

Suggestor = require('./suggestorXX').Suggestor;

UnionSuggestor = require('./suggestorXX').UnionSuggestor;

noopSuggestor = require('./suggestorXX').noopSuggestor;

xmlSuggestor = new Suggestor([
  new SuggestionItem('attribute', noopSuggestor, {
    category: 'docs'
  }), new SuggestionItem('name', noopSuggestor, {
    category: 'docs'
  }), new SuggestionItem('namespace', noopSuggestor, {
    category: 'docs'
  }), new SuggestionItem('prefix', noopSuggestor, {
    category: 'docs'
  }), new SuggestionItem('wrapped', noopSuggestor, {
    category: 'docs'
  })
]);

namedParameterSuggestor = new Suggestor([
  new SuggestionItem('description', noopSuggestor, {
    category: 'docs'
  }), new SuggestionItem('displayName', noopSuggestor, {
    category: 'docs'
  }), new SuggestionItem('example', noopSuggestor, {
    category: 'docs'
  }), new SuggestionItem('examples', noopSuggestor, {
    category: 'docs'
  }), new SuggestionItem('additionalProperties', noopSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('default', noopSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('discriminator', noopSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('discriminatorValue', noopSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('enum', noopSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('facets', noopSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('fileTypes', noopSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('format', noopSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('items', noopSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('maximum', noopSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('maxItems', noopSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('maxLength', noopSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('maxProperties', noopSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('minimum', noopSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('minItems', noopSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('minLength', noopSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('minProperties', noopSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('multipleOf', noopSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('pattern', noopSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('properties', noopSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('required', noopSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('schema', noopSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('type', noopSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('uniqueItems', noopSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('xml', xmlSuggestor, {
    category: 'parameters'
  })
]);

namedParameterGroupSuggestor = new EmptySuggestor(function(key) {
  return namedParameterSuggestor;
});

responseBodyMimetypeSuggestor = new Suggestor([
  new SuggestionItem('schema', noopSuggestor, {
    category: 'schemas'
  }), new SuggestionItem('example', noopSuggestor, {
    category: 'docs'
  })
]);

responseBodyGroupSuggestor = new Suggestor([
  new SuggestionItem('application/json', responseBodyMimetypeSuggestor, {
    category: 'body'
  }), new SuggestionItem('application/x-www-form-urlencoded', responseBodyMimetypeSuggestor, {
    category: 'body'
  }), new SuggestionItem('application/xml', responseBodyMimetypeSuggestor, {
    category: 'body'
  }), new SuggestionItem('multipart/form-data', responseBodyMimetypeSuggestor, {
    category: 'body'
  })
]);

responseSuggestor = new Suggestor([
  new SuggestionItem('body', responseBodyGroupSuggestor, {
    category: 'responses'
  }), new SuggestionItem('description', noopSuggestor, {
    category: 'docs'
  })
]);

responseGroupSuggestor = new EmptySuggestor(function(key) {
  if (/\d{3}/.test(key)) {
    return responseSuggestor;
  }
});

requestBodySuggestor = new EmptySuggestor(function() {
  return namedParameterGroupSuggestor;
});

methodBodySuggestor = new Suggestor([
  new SuggestionItem('application/json', noopSuggestor, {
    category: 'body'
  }), new SuggestionItem('application/x-www-form-urlencoded', requestBodySuggestor, {
    category: 'body'
  }), new SuggestionItem('application/xml', noopSuggestor, {
    category: 'body'
  }), new SuggestionItem('multipart/form-data', requestBodySuggestor, {
    category: 'body'
  })
]);

protocolsSuggestor = new Suggestor([
  new SuggestionItem('HTTP', noopSuggestor, {
    isText: true
  }), new SuggestionItem('HTTPS', noopSuggestor, {
    isText: true
  })
], null, {
  isList: true
});

makeMethodSuggestor = function() {
  return new Suggestor([
    new SuggestionItem('description', noopSuggestor, {
      category: 'docs'
    }), new SuggestionItem('body', methodBodySuggestor, {
      category: 'body'
    }), new SuggestionItem('protocols', protocolsSuggestor, {
      category: 'root'
    }), new SuggestionItem('baseUriParameters', namedParameterGroupSuggestor, {
      category: 'parameters'
    }), new SuggestionItem('headers', namedParameterGroupSuggestor, {
      category: 'parameters'
    }), new SuggestionItem('queryParameters', namedParameterGroupSuggestor, {
      category: 'parameters'
    }), new SuggestionItem('responses', responseGroupSuggestor, {
      category: 'responses'
    }), new SuggestionItem('securedBy', noopSuggestor, {
      category: 'security'
    })
  ]);
};

makeMethodGroupSuggestor = function(optional) {
  var method, methodSuggestor;
  if (optional == null) {
    optional = false;
  }
  methodSuggestor = new UnionSuggestor([
    makeMethodSuggestor(), new Suggestor([
      new SuggestionItem('is', noopSuggestor, {
        category: 'traits and types'
      })
    ])
  ]);
  return new Suggestor((function() {
    var i, len, ref, results;
    ref = ['options', 'get', 'head', 'post', 'put', 'delete', 'trace', 'connect', 'patch'];
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      method = ref[i];
      results.push(new SuggestionItem(method, methodSuggestor, {
        category: 'methods',
        canBeOptional: optional
      }));
    }
    return results;
  })());
};

resourceBasicSuggestor = new Suggestor([
  new SuggestionItem('description', noopSuggestor, {
    category: 'docs'
  }), new SuggestionItem('displayName', noopSuggestor, {
    category: 'docs'
  }), new SuggestionItem('securedBy', noopSuggestor, {
    category: 'security'
  }), new SuggestionItem('type', noopSuggestor, {
    category: 'traits and types'
  }), new SuggestionItem('is', noopSuggestor, {
    category: 'traits and types'
  })
]);

resourceFallback = function(key) {
  if (/^\//.test(key)) {
    return resourceSuggestor;
  }
};

dynamicResource = new SuggestionItem('<resource>', resourceSuggestor, {
  category: 'resources',
  dynamic: true
});

resourceSuggestor = new UnionSuggestor([
  resourceBasicSuggestor, makeMethodGroupSuggestor(), new Suggestor([
    new SuggestionItem('baseUriParameters', namedParameterGroupSuggestor, {
      category: 'parameters'
    }), new SuggestionItem('uriParameters', namedParameterGroupSuggestor, {
      category: 'parameters'
    }), dynamicResource
  ])
], resourceFallback);

traitAdditions = new Suggestor([
  new SuggestionItem('displayName', noopSuggestor, {
    category: 'docs'
  }), new SuggestionItem('usage', noopSuggestor, {
    category: 'docs'
  })
]);

traitSuggestor = new UnionSuggestor([traitAdditions, makeMethodSuggestor()]);

resourceTypeSuggestor = new UnionSuggestor([
  resourceBasicSuggestor, makeMethodGroupSuggestor(true), new Suggestor([
    new SuggestionItem('baseUriParameters', namedParameterGroupSuggestor, {
      category: 'parameters',
      canBeOptional: true
    }), new SuggestionItem('uriParameters', namedParameterGroupSuggestor, {
      category: 'parameters',
      canBeOptional: true
    }), new SuggestionItem('usage', noopSuggestor, {
      category: 'docs'
    })
  ])
]);

securitySchemesSettingSuggestor = new Suggestor([
  new SuggestionItem('accessTokenUri', noopSuggestor, {
    category: 'security'
  }), new SuggestionItem('authorizationGrants', noopSuggestor, {
    category: 'security'
  }), new SuggestionItem('authorizationUri', noopSuggestor, {
    category: 'security'
  }), new SuggestionItem('requestTokenUri', noopSuggestor, {
    category: 'security'
  }), new SuggestionItem('scopes', noopSuggestor, {
    category: 'security'
  }), new SuggestionItem('tokenCredentialsUri', noopSuggestor, {
    category: 'security'
  })
]);

securitySchemeTypeSuggestor = new Suggestor([
  new SuggestionItem('OAuth 1.0', noopSuggestor, {
    category: 'security'
  }), new SuggestionItem('OAuth 2.0', noopSuggestor, {
    category: 'security'
  }), new SuggestionItem('Basic Authentication', noopSuggestor, {
    category: 'security'
  }), new SuggestionItem('Digest Authentication', noopSuggestor, {
    category: 'security'
  })
]);

describedBySuggestor = new Suggestor([
  new SuggestionItem('headers', namedParameterGroupSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('queryParameters', namedParameterGroupSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('responses', responseGroupSuggestor, {
    category: 'responses'
  })
]);

securitySchemesSuggestor = new Suggestor([
  new SuggestionItem('description', noopSuggestor, {
    category: 'docs'
  }), new SuggestionItem('describedBy', describedBySuggestor, {
    category: 'security'
  }), new SuggestionItem('type', securitySchemeTypeSuggestor, {
    category: 'security'
  }), new SuggestionItem('settings', securitySchemesSettingSuggestor, {
    category: 'security'
  })
]);

traitGroupSuggestor = new EmptySuggestor(function() {
  return traitSuggestor;
});

resourceTypeGroupSuggestor = new EmptySuggestor(function() {
  return resourceTypeSuggestor;
});

securitySchemesGroupSuggestor = new EmptySuggestor(function() {
  return securitySchemesSuggestor;
});

documentationItemSuggestor = new Suggestor([
  new SuggestionItem('content', noopSuggestor, {
    category: 'docs'
  }), new SuggestionItem('title', noopSuggestor, {
    category: 'docs'
  })
]);

rootDocumentationSuggestor = new Suggestor([
  new SuggestionItem('content', noopSuggestor, {
    category: 'docs'
  }), new SuggestionItem('title', noopSuggestor, {
    category: 'docs'
  })
], null, {
  isList: true
});

apiDefinitionSuggestor = new Suggestor([
  new SuggestionItem('baseUri', noopSuggestor, {
    category: 'root'
  }), new SuggestionItem('baseUriParameters', namedParameterGroupSuggestor, {
    category: 'parameters'
  }), new SuggestionItem('documentation', rootDocumentationSuggestor, {
    category: 'docs'
  }), new SuggestionItem('mediaType', noopSuggestor, {
    category: 'root'
  }), new SuggestionItem('protocols', protocolsSuggestor, {
    category: 'root'
  }), new SuggestionItem('resourceTypes', resourceTypeGroupSuggestor, {
    category: 'traits and types'
  }), new SuggestionItem('schemas', noopSuggestor, {
    category: 'schemas'
  }), new SuggestionItem('securedBy', noopSuggestor, {
    category: 'security'
  }), new SuggestionItem('securitySchemes', securitySchemesGroupSuggestor, {
    category: 'security'
  }), new SuggestionItem('title', noopSuggestor, {
    category: 'root'
  }), new SuggestionItem('traits', traitGroupSuggestor, {
    category: 'traits and types'
  }), new SuggestionItem('types', namedParameterGroupSuggestor, {
    category: 'traits and types'
  }), new SuggestionItem('uses', noopSuggestor, {
    category: 'docs'
  }), new SuggestionItem('version', noopSuggestor, {
    category: 'root'
  }), dynamicResource
], resourceFallback);

librarySuggestor = new Suggestor([
  new SuggestionItem('resourceTypes', resourceTypeGroupSuggestor, {
    category: 'traits and types'
  }), new SuggestionItem('schemas', noopSuggestor, {
    category: 'schemas'
  }), new SuggestionItem('securitySchemes', securitySchemesGroupSuggestor, {
    category: 'security'
  }), new SuggestionItem('traits', traitGroupSuggestor, {
    category: 'traits and types'
  }), new SuggestionItem('types', namedParameterGroupSuggestor, {
    category: 'traits and types'
  }), new SuggestionItem('usage', noopSuggestor, {
    category: 'docs'
  }), new SuggestionItem('uses', noopSuggestor, {
    category: 'docs'
  })
]);

overlaySuggestor = new UnionSuggestor([
  apiDefinitionSuggestor, new Suggestor([
    new SuggestionItem('extends', noopSuggestor, {
      category: 'docs'
    })
  ])
]);

extensionSuggestor = new UnionSuggestor([
  apiDefinitionSuggestor, new Suggestor([
    new SuggestionItem('extends', noopSuggestor, {
      category: 'docs'
    })
  ])
]);

module.exports = {
  ApiDefinition: apiDefinitionSuggestor,
  DataType: namedParameterSuggestor,
  DocumentationItem: documentationItemSuggestor,
  Extension: extensionSuggestor,
  Library: librarySuggestor,
  Overlay: overlaySuggestor,
  ResourceType: resourceTypeSuggestor,
  SecurityScheme: securitySchemesSuggestor,
  Trait: traitSuggestor
};


},{"./suggestorXX":4}],4:[function(require,module,exports){
var EmptySuggestor, SuggestionItem, Suggestor, UnionSuggestor,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

SuggestionItem = (function() {
  function SuggestionItem(key1, suggestor1, metadata) {
    this.key = key1;
    this.suggestor = suggestor1;
    this.metadata = metadata != null ? metadata : {};
  }

  SuggestionItem.prototype.matches = function(key) {
    return this.key === key || this.metadata.canBeOptional && this.key + '?' === key;
  };

  return SuggestionItem;

})();

Suggestor = (function() {
  function Suggestor(items, fallback1, metadata) {
    this.items = items;
    this.fallback = fallback1;
    this.metadata = metadata != null ? metadata : {};
    if (this.fallback == null) {
      this.fallback = function() {};
    }
  }

  Suggestor.prototype.suggestorFor = function(key) {
    var matchingItems;
    matchingItems = this.items.filter(function(item) {
      return item.matches(key);
    });
    if (matchingItems.length > 0) {
      return matchingItems[0].suggestor;
    } else {
      return this.fallback(key);
    }
  };

  Suggestor.prototype.suggestions = function() {
    var i, item, len, ref, suggestions;
    suggestions = {};
    ref = this.items;
    for (i = 0, len = ref.length; i < len; i++) {
      item = ref[i];
      suggestions[item.key] = {
        metadata: item.metadata
      };
    }
    return suggestions;
  };

  return Suggestor;

})();

EmptySuggestor = (function(superClass) {
  extend(EmptySuggestor, superClass);

  function EmptySuggestor(fallback) {
    EmptySuggestor.__super__.constructor.call(this, [], fallback);
  }

  return EmptySuggestor;

})(Suggestor);

UnionSuggestor = (function() {
  function UnionSuggestor(suggestors, fallback1) {
    this.suggestors = suggestors;
    this.fallback = fallback1;
    if (this.fallback == null) {
      this.fallback = function() {};
    }
  }

  UnionSuggestor.prototype.suggestorFor = function(key) {
    var i, len, ref, suggestor;
    ref = this.suggestors;
    for (i = 0, len = ref.length; i < len; i++) {
      suggestor = ref[i];
      if (suggestor = suggestor.suggestorFor(key)) {
        return suggestor;
      }
    }
    return this.fallback(key);
  };

  UnionSuggestor.prototype.suggestions = function() {
    var i, key, len, ref, suggestions, suggestor, suggestorSuggestions, value;
    suggestions = {};
    ref = this.suggestors;
    for (i = 0, len = ref.length; i < len; i++) {
      suggestor = ref[i];
      suggestorSuggestions = suggestor.suggestions();
      for (key in suggestorSuggestions) {
        value = suggestorSuggestions[key];
        suggestions[key] = value;
      }
    }
    return suggestions;
  };

  return UnionSuggestor;

})();

module.exports.SuggestionItem = SuggestionItem;

module.exports.Suggestor = Suggestor;

module.exports.EmptySuggestor = EmptySuggestor;

module.exports.UnionSuggestor = UnionSuggestor;

module.exports.noopSuggestor = new EmptySuggestor();


},{}]},{},[1])(1)
});