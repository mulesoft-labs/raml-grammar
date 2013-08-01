module.exports = function(grunt) {

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    simplemocha: {
      all: ['test/test.coffee']
    },
    watch: {
      files: ['<%= coffee.files %>'],
      tasks: ['browserify', 'simplemocha']
    },
    browserify: {
      options: {
        transform: ['coffeeify']
      },
      'dist/suggest.js': ['src/main.coffee', 'src/suggestion.coffee']
    }
  });

  grunt.loadNpmTasks('grunt-coffeeify');
  grunt.loadNpmTasks('grunt-simple-mocha');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-browserify');

  grunt.registerTask('default', ['browserify', 'simplemocha']);

};
