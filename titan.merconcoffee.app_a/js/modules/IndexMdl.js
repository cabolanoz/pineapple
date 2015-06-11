/**
 * Created by cbolanos on 12/26/2014.
 */

(function() {
    var app = angular.module(
        "titan",
        [
            "ngRoute",
            "pascalprecht.translate",
            "reference",
            "ui.bootstrap"
        ]);

    /**
     * Initializing elastic search
     */
    app
        .directive('elasticSearch', ['$timeout', function($timeout) {
            return {
                link: function($scope, element, attrs) {
                    $timeout(function() {
                        new UISearch( document.getElementById( 'sb-search' ) );
                    }, 0, false);
                }
            };
        }])
        .directive('dynamicTime', ['$interval', 'dateFilter', function($interval, dateFilter) {
            return function($scope, element, attrs) {
                function updateTime() {
                    element.text(dateFilter(new Date(), 'hh:mm a'));
                }

                $scope.$watch(attrs.dynamicTime, function() {
                    updateTime();
                });

                $interval(updateTime, 1000);
            }
        }]);
}());