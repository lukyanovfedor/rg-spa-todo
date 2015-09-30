var gulp = require('gulp'),
	config = require('../config').watch;

gulp.task('watch', function() {
	gulp.watch(config.js_app, ['js:application']);
});