'use strict';
var Main = require('./output/Main/index')

if(module.hot) {
  document.getElementById('content').innerHTML = ''
  Main.main(window.appState)()

	module.hot.accept(function(err) {
		if(err) {
			console.error("Cannot apply hot update", err);
		}
	});
}
else {
  Main.main()()
}
