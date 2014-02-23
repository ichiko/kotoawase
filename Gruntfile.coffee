module.exports = (grunt) ->
	grunt.initConfig
		pkg: grunt.file.readJSON 'package.json'
		watch:
			app:
				files: [
					'src/coffee/*.coffee'
				]
				tasks: ['build']
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
					'src/js/main.js' : [
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
						'src/js/main.js'
					]
				]
				options:
					sourceMap: true
			release:
				files: [
					'public/script/main.min.js' : [
						'src/js/main.js'
					]
				]

	grunt.loadNpmTasks 'grunt-bower-task'
	grunt.loadNpmTasks 'grunt-browserify'
	grunt.loadNpmTasks 'grunt-contrib-uglify'
	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.registerTask 'default', ['watch']
	grunt.registerTask 'install', ['bower']
	grunt.registerTask 'build', ['browserify:app', 'uglify:app']
	grunt.registerTask 'release', ['browserify:app', 'uglify:release']
	return
