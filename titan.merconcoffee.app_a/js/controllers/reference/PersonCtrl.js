/**
 * Created by cbolanos on 12/24/2014.
 */

angular.module("reference").controller("PersonCtrl", ["$scope", "$http", function($scope, $http) {
    var onRequestComplete = function (response) {
        $scope.people = response.data.id;
        $scope.selectedItem = $scope.people[0];
    };

    var onRequestFail = function (response) {

    };

    $http
        .get("http://localhost:3001/api/RefPeople/findOperator")
        .then(onRequestComplete, onRequestFail);
}]);