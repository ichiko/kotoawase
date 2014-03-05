module.exports = (grunt) ->
	grunt.initConfig
		pkg: grunt.file.readJSON 'package.json'
		watch:
			app:
				files: [
					'src/coffee/*.coffee'
					'src/templates/*.html'
				]
				tasks: ['coffee:app', 'browserify:app']
			css:
				files: [
					'src/sass/*.scss'
				]
				tasks: ['sass']
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
						'src/js/kotoawase.js'
					]
				]
				options:
					transform: ['brfs']
			spec:
				files: [
					'spec/js/generator.spec.js' : ['spec/coffee/generator.spec.coffee']
				]
				options:
					transform: ['coffeeify']
		coffee:
			app:
				expand: true
				cwd: 'src/coffee'
				src: ['*.coffee']
				dest: 'src/js/'
				ext: '.js'
		sass:
			dist:
				expand: true
				cwd:  'src/sass/'
				src:  ['*.scss']
				dest: 'public/stylesheets'
				ext:  '.css'
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
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-sass'
	grunt.loadNpmTasks 'grunt-contrib-uglify'
	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.registerTask 'default', ['watch']
	grunt.registerTask 'install', ['bower']
	grunt.registerTask 'pre-spec', ['coffee:app', 'browserify:spec']
	grunt.registerTask 'build', ['browserify:app', 'uglify:app']
	return
