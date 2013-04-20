(function(window, angular) {
    'use strict';

    var code = angular.module('code', [
        'ngSanitize',
        'ngResource'
    ]);

    code.config(['$httpProvider', '$locationProvider', '$routeProvider',
        function($httpProvider, $locationProvider, $routeProvider) {
            // $locationProvider.html5Mode(false).hashPrefix('!');
            $locationProvider.html5Mode(true).hashPrefix('!');

            // Setting up CSRF tokens for POST, PUT and DELETE requests
            var document = window.document;
            var tokenElement = document.querySelector('meta[name=csrf-token]');
            if (tokenElement && tokenElement.content) {
                $httpProvider.defaults.headers.post['X-CSRF-Token'] = tokenElement.content;
                $httpProvider.defaults.headers.put['X-CSRF-Token'] = tokenElement.content;
            }

            $routeProvider.
                when('/', {
                    templateUrl: '/assets/dashboard.html',
                    controller: 'DashboardController'
                })
        }]);

    code.isEmpty = function(value) {
        return angular.isUndefined(value) || value === '' || value === null || value !== value;
    };

    window.code = code;

})(window, window.angular);
