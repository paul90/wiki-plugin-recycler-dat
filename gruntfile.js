module.exports = function (grunt) {
  grunt.loadNpmTasks('grunt-browserify');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-mocha-test');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-git-authors');


  grunt.initConfig({
    // tidy-up before we start the build
    clean: ['client/recycler.js', 'client/recycler.js.map', 'test/test.js', 'test/test.js.map'],

    browserify: {
      plugin: {
        src: ['client/recycler.coffee'],
        dest: 'client/recycler.js',
        options: {
          transform: ['coffeeify'],
          browserifyOptions: {
            extentions: ".coffee"
          }
        }
      }
    },

    mochaTest: {
      test: {
        options: {
          reporter: 'spec',
          require: 'coffee-script/register'
        },
        src: ['test/test.coffee']
      }
    },


    watch: {
      all: {
        files: ['client/*.coffee', 'test/*.coffee'],
        tasks: ['build']
      }
    }
  });

  grunt.registerTask('build', ['clean', 'mochaTest', 'browserify']);
  grunt.registerTask('default', ['build']);

};
