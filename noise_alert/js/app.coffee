app = angular.module 'noiseAlert.app', []


app.config ['$interpolateProvider',
     ($interpolateProvider)->
        $interpolateProvider.startSymbol('{[{')
        $interpolateProvider.endSymbol('}]}')]

app.controller 'noiseController', ['$scope', ($scope)->
    $scope.phoneNumber = '408'
    $window.noiseAlert =
        threshold: 0.2

]
