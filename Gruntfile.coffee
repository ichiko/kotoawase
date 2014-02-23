module.exports = (grunt) ->
	grunt.initConfig
		pkg: grunt.file.readJSON 'package.json'
		watch:
			app:
				files: [
					'src/coffee/*.coffee'
				]
				tasks: ['browserify:app']
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
		uglify:
			options:
				mangle:
					except: ['Vue']
			app:
				files: [
					'public/script/main.min.js' : [
						'public/script/main.js'
					]
				]
				options:
					sourceMap: true

	grunt.loadNpmTasks 'grunt-bower-task'
	grunt.loadNpmTasks 'grunt-browserify'
	grunt.loadNpmTasks 'grunt-contrib-uglify'
	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.registerTask 'default', ['watch']
	grunt.registerTask 'install', ['bower']
	grunt.registerTask 'build', ['browserify:app', 'uglify:app']
	return
