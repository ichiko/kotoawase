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
		coffee:
			app:
				options:
					join: true
				files: [
					'public/script/main.js': ['src/coffee/kana.coffee', 'src/coffee/kotoawase.coffee']
				]
			all:
				files: [
					expand: true
					cwd: 'src/coffee'
					src: ['**/*.coffee']
					dest: 'public/script'
					ext: '.js'
				]

	grunt.loadNpmTasks 'grunt-bower-task'
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.registerTask 'default', ['watch']
	grunt.registerTask 'install', ['bower']
	return
