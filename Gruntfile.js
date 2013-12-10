'use strict';

module.exports = function (grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    browserify: {
      options: {
        transform: ['coffeeify']
      },
      'dist/suggest.js': ['src/suggestor.coffee']
    },

    simplemocha: {
      options: {
        useColors: true,
        ui: 'bdd',
        reporter: 'spec'
      },
      all: ['test/suggestor.coffee']
    },

    watch: {
      files: ['src/**/*.coffee', 'test/**/*.coffee'],
      tasks: ['test']
    }
  });

  grunt.loadNpmTasks('grunt-browserify');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-simple-mocha');

  grunt.registerTask('test',    ['simplemocha']);
  grunt.registerTask('build',   ['test', 'browserify']);
  grunt.registerTask('default', ['build']);
};
