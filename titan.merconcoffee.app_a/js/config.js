/**
 * Created by cbolanos on 12/26/2014.
 */

(function() {
    var app = angular.module("titan");

    /*
    * Routes Configuration
    * */
    app.config(function($routeProvider) {
        $routeProvider
            .when("/", {
                templateUrl: "views/dashboard.html",
                controller: "MainCtrl"
            })
            /*
            * Shipping Manager Routes
            * */
            .when("/shippingmanager", {
                templateUrl: "views/traffic/shippingmanager/index.html",
                controller: "ShippingManagerCtrl"
            })
            .when("/shippingmanager/new", {
                templateUrl: "views/traffic/shippingmanager/new.html",
                controller: "ShippingManagerCtrl"
            })
            /**
             * User Accesses Routes
             */
            .when("/useraccesses", {
                templateUrl: "views/it/useraccesses/index.html",
                controller: "UserAccessesCtrl"
            })
    });

    /**
     * Languages Configuration
     */
    app.config(function($translateProvider) {
        $translateProvider
            .translations("enUS", {
                WELCOME: "Welcome",
                SEARCH: "Search",
                SHIPPING_MANAGER: "Shipping Manager",
                TRANSFER_MANAGER: "Transfer Manager",
                NEW_ITINERARY: "New Itinerary",
                // For Navigation Menu
                MNU_ALL: "All",
                MNU_TRAFFIC: "Traffic",
                MNU_IT: "IT",
                MNU_FINANCE: "Finance",
                MNU_POSITION: "Position",
                MNU_ACCOUNTING: "Accounting",
                MNU_MISCELLANEOUS: "Miscellaneous"
            })
            .translations("esNI", {
                WELCOME: "Bienvenido",
                SEARCH: "Buscar",
                SHIPPING_MANAGER: "Manejador de Embarques",
                TRANSFER_MANAGER: "Manejador de Transferencias",
                NEW_ITINERARY: "Nuevo Itinerario",
                // For Navigation Menu
                MNU_ALL: "Todo",
                MNU_TRAFFIC: "Tráfico",
                MNU_IT: "IT",
                MNU_FINANCE: "Finanzas",
                MNU_POSITION: "Posición",
                MNU_ACCOUNTING: "Contabilidad",
                MNU_MISCELLANEOUS: "Misceláneos"
            })
            .translations("viVN", {
                WELCOME: "Chào mừng",
                SEARCH: "Tìm kiếm",
                SHIPPING_MANAGER: "Quản lý vận tải",
                TRANSFER_MANAGER: "chuyển quản lý",
                NEW_ITINERARY: "hành trình mới",
                // For Navigation Menu
                MNU_ALL: "Tất cả",
                MNU_TRAFFIC: "Giao thông",
                MNU_IT: "IT",
                MNU_FINANCE: "Tài chánh",
                MNU_POSITION: "Vị trí",
                MNU_ACCOUNTING: "Kế toán",
                MNU_MISCELLANEOUS: "Hỗn hợp"
            });
        $translateProvider.preferredLanguage('enUS');
    });

}());