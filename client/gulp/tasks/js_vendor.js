var gulp = require('gulp');
var concat = require('gulp-concat');
var config = require('../config').js_vendor;
var errorHandler = require('../utils/error_handler');

gulp.task('js_vendor', function() {
	gulp
		.src(config.src)
		.pipe(concat(config.build_name))
		.on('error', errorHandler)
		.pipe(gulp.dest(config.dest));
});