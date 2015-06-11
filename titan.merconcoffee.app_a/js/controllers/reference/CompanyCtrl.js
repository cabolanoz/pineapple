/**
 * Created by cbolanos on 12/24/2014.
 */

angular.module("reference")
    .controller("CompanyCtrl", ["$scope", "$http", function($scope, $http) {
        var onRequestComplete = function (response) {
            $scope.companies = response.data.id;
            $scope.selectedItem = $scope.companies[0];
        };

        var onRequestFail = function (response) {

        };

        $http
            .get("http://localhost:3001/api/RefCompanies/findInternalCompanies")
            .then(onRequestComplete, onRequestFail);
    }]);