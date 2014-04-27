// spec/javascripts/vote.conf.js
module.exports = function(config) {
  config.set({
    basePath: '../..',
    frameworks: ['jasmine'],
    autoWatch: true,
    preprocessors: {
      '**/*.coffee': 'coffee'
    },

    files: [
      'app/assets/javascripts/angular.js',
      'app/assets/javascripts/angular-route.js',
      'spec/javascripts/lib/angular-mocks.js',
      'app/assets/javascripts/main.js.coffee',
      'app/assets/javascripts/angular/controllers/RoomIndexCtrl.js.coffee',
      'app/assets/javascripts/angular/*',
      'spec/javascripts/*_spec.js.coffee'
    ],

    proxies: {
      '/': 'http://localhost:3000'
    }
  });
}