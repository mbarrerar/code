(function(code) {
    code.controller('DashboardController',
        ["$scope",
            function($scope) {


                $scope.getRepositories = function() {
                    return [
                        {name: "One"},
                        {name: "Two"},
                        {name: "Three"}
                    ];
                };


            }]);
})(window.code);
