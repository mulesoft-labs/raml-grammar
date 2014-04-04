'use strict';

module.exports = function (grunt) {
  require('load-grunt-tasks')(grunt);

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    browserify: {
      options: {
        transform: ['coffeeify'],
        bundleOptions: {
          standalone: 'RAML.Grammar'
        }
      },

      'dist/suggest.js': ['src/suggestor.coffee']
    },

    simplemocha: {
      options: {
        useColors: true,
        ui:        'bdd',
        reporter:  'spec'
      },

      all: ['test/suggestor.coffee']
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
