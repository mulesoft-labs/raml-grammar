module.exports = function(grunt) {

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    coffee: {
      options: {
        sourceMap: true
      },
      compile: {
        files: {
          'dist/suggest.js': ['src/main.coffee', 'src/suggestion.coffee'],
          'dist/test.js': 'test/*.coffee'
          
        }
      }
    },
    simplemocha: {
      all: ['dist/test.js']
    },
    watch: {
      files: ['<%= coffee.files %>'],
      tasks: ['coffee', 'simplemocha']
    }
  });

  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-simple-mocha');
  grunt.loadNpmTasks('grunt-contrib-watch');

  grunt.registerTask('default', ['coffee', 'simplemocha']);

};
