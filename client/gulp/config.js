var assets = __dirname + '/../../app/assets';

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
			'#{path}/angular-animate.js'
		].map(function(p) { return p.replace('#{path}', __dirname + '/../js/libs'); }),
		dest: assets + '/javascripts',
		build_name: 'client_vendors.js'
	},

	js_application: {
		src: {
			app: __dirname + '/../js/app/**/*.coffee',
			tpl: __dirname + '/../templates/**/*.html'
		},
		dest: assets + '/javascripts',
		build_name: 'client_app.js',
		module_name: 'TodoApp'
	},

	watch: {
		js_app: [
			__dirname + '/../js/app/**/*.coffee',
			__dirname + '/../templates/**/*.html'
		]
	}

};