module.exports = (grunt) ->
    grunt.initConfig
        #pkg: grunt.file.readJSON('package.json')
        coffee:
            files:
                src: ['js/app.coffee', 'js/soundMeter.coffee']
                dest: 'js/app.js'

    grunt.loadNpmTasks('grunt-contrib-coffee')

    grunt.registerTask('default', ['coffee'])
