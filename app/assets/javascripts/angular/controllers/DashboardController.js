(function(code) {
    code.controller('DashboardController', ["$scope", "Repository", function($scope, Repository) {

        $scope.repositories = Repository.query();

        $scope.getRepositories = function() {
            return $scope.repositories;
        };

    }]);
})(window.code);
