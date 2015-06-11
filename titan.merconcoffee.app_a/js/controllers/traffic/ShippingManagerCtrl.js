/**
 * Created by cbolanos on 12/23/2014.
 */

angular.module("titan")
    .controller("ShippingManagerCtrl", function($scope, $http) {
        var onRequestComplete = function (response) {
            $scope.itineraries = response.data.id;
        };

        var onRequestFail = function (response) {

        };

        $http
            .get("http://localhost:3001/api/OpsItineraries/findFirstTenWithRelatedModel")
            .then(onRequestComplete, onRequestFail);
    })
    .directive('dropDown', ['$timeout', function($timeout) {
        return {
            link: function($scope, element, attrs) {
                $timeout(function() {
                    new SelectFx(document.getElementById( 'txtInternalCompany' ));
                    new SelectFx(document.getElementById( 'txtOperatorName' ));
                }, 500, false);
            }
        };
    }]);