/**
 * Created by cbolanos on 12/23/2014.
 */

angular.module("titan")
    .controller("MainCtrl", function($translate, $scope) {
        $scope.currentDt = new Date();

        $scope.changeLanguage = function(languageKey) {
            $translate.use(languageKey);
        };
    });