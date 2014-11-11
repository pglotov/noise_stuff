app = angular.module 'noiseAlert.app', []

app.config ['$interpolateProvider',
    ($interpolateProvider)->
        $interpolateProvider.startSymbol('{[{')
        $interpolateProvider.endSymbol('}]}')]

app.controller 'noiseController', ['$scope', '$interval', ($scope, $interval)->
    $scope.phoneNumber = '408'
    $scope.threshold = 0.2

    $scope.noiseData =
        instant: 0
        noiseProgress: 0
        cumulativeVolume: 0
        topNoises: []

    
    timeoutId = $interval $scope.apply, 200
]
