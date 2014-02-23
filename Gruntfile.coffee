module.exports = (grunt) ->
	grunt.initConfig
		pkg: grunt.file.readJSON 'package.json'
		watch:
			app:
				files: [
					'src/coffee/*.coffee'
				]
				tasks: ['coffee']
		bower:
			install:
				options: 
					targetDir: './public/lib'
					layout: 'byComponent'
					install: true
					verbose: false
					cleanTargetDir: true
					cleanBowerDir: false
		browserify:
			app:
				files: [
					'public/script/main.js' : [
						'src/coffee/kotoawase.coffee'
					]
				]
				options:
					transform: ['coffeeify']
			tutorial:
				files: [
					'public/script/tutorial.js' : [
						'src/coffee/tutorial.coffee'
					]
				]
				options:
					transform: ['coffeeify']

	grunt.loadNpmTasks 'grunt-bower-task'
	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.loadNpmTasks 'grunt-browserify'
	grunt.registerTask 'default', ['watch']
	grunt.registerTask 'install', ['bower']
	return
