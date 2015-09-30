var gulp = require('gulp');
var concat = require('gulp-concat');
var coffee = require('gulp-coffee');
var merge2 = require('merge2');
var angularTemplates = require('gulp-angular-templatecache');
var config = require('../config').js_application;
var errorHandler = require('../utils/error_handler');

gulp.task('js:application', function() {
	var transformUrl = function(url) {
		return 'templates/' + url;
	};

	merge2(
		gulp.src(config.src.app).pipe(coffee({ bare: false }).on('error', errorHandler)),
		gulp.src(config.src.tpl).pipe(angularTemplates({ module: config.module_name, transformUrl: transformUrl }).on('error', errorHandler))
	)
	.pipe(concat(config.build_name))
	.on('error', errorHandler)
	.pipe(gulp.dest(config.dest));
});