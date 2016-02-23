'use strict';

module.exports = function (grunt) {
  require('load-grunt-tasks')(grunt);

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    browserify: {
      options: {
        browserifyOptions: {
          extensions: ['.coffee'],
          standalone: 'RAML.Grammar',
          transform:  ['coffeeify']
        }
      },

      'dist/suggest.js': ['src/suggestor.coffee']
    },

    simplemocha: {
      options: {
        bail:      true,
        reporter:  'spec',
        ui:        'bdd',
        useColors: true
      },

      all: ['test/_setup.coffee', 'test/*.test.coffee']
    },

    watch: {
      files: ['src/**/*.coffee', 'test/**/*.coffee'],
      tasks: ['test']
    }
  });

  grunt.registerTask('test', [
    'simplemocha'
  ]);

  grunt.registerTask('build', [
    'browserify'
  ]);

  grunt.registerTask('default', [
    'test',
    'build'
  ]);
};
