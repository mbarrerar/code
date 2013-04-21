(function(code) {
    code.controller('DashboardController', ["$scope", "Repository", function($scope, Repository) {

        $scope.repositories = Repository.query();

        $scope.getRepositories = function() {
            return $scope.repositories;
        };

        $scope.tabs = [
            {name: "All", active: true},
            {name: "You Own", active: false},
            {name: "You Administer", active: false},
            {name: "You Can Commit", active: false},
            {name: "You Can Read", active: false}
        ];

        $scope.activeTab = function() {
            var tabs = $scope.tabs;

            for (var i = 0; i < tabs.length; i++) {
                if (tabs[i].active) {
                    return tabs[i];
                }
            }

            return null;
        };

        $scope.changeTab = function(clickedTab) {
            angular.forEach($scope.tabs, function(tab) {
                tab.active = (tab == clickedTab);
            });
        };


    }]);
})(window.code);
