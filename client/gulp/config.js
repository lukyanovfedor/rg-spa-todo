var destFolder = __dirname + '/../build';

module.exports = {
	js_vendor: {
		src: [
			'#{path}/moment.js',
			'#{path}/angular.js',
			'#{path}/angular-cookie.js',
			'#{path}/angular-ui-router.js',
			'#{path}/angular-ngprogress.js',
			'#{path}/angular-resource.js',
			'#{path}/angular-token-auth.js',
			'#{path}/angular-ui-bootstrap.js',
			'#{path}/angular-form-errors.js',
			'#{path}/angular-animate.js',
			'#{path}/angular-ngsortable.js',
			'#{path}/angular-messages.js'
		].map(function(p) { return p.replace('#{path}', __dirname + '/../src/libs'); }),
		dest: destFolder,
		build_name: 'client_vendors.js'
	},

	js_application: {
		src: {
			app: __dirname + '/../src/app/**/*.coffee',
			tpl: __dirname + '/../src/templates/**/*.html'
		},
		dest: destFolder,
		build_name: 'client_app.js',
		module_name: 'TodoApp'
	},

	watch: {
		js_app: [
			__dirname + '/../src/app/**/*.coffee',
			__dirname + '/../src/templates/**/*.html'
		]
	}
};