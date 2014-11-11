app = angular.module 'noiseAlert.app', []


app.config ['$interpolateProvider',
     ($interpolateProvider)->
        $interpolateProvider.startSymbol('{[{')
        $interpolateProvider.endSymbol('}]}')]

app.controller 'noiseController', ['$scope', '$window', ($scope, $window)->
    $scope.phoneNumber = '408'
    $scope.threshold = 0.2
    $window.noiseAlert =
        threshold: $scope.threshold
    $scope.$watch 'threshold', (newValue)->
        $window.noiseAlert.threshold = newValue

    $scope.$watch (()->$window.noiseAlert),
        ((newValue)->),
        true
]
