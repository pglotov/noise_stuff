app = angular.module 'noiseAlert.app', []


app.config ['$interpolateProvider',
     ($interpolateProvider)->
        $interpolateProvider.startSymbol('{[{')
        $interpolateProvider.endSymbol('}]}')]

app.controller 'noiseController', ['$scope', '$window', ($scope, $window)->
    $scope.phoneNumber = '408'
    $window.noiseAlert =
        threshold: 0.2
    $scope.window = $window
]
