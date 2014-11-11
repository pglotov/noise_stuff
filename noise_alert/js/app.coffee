app = angular.module 'noiseAlert.app', ['message.resource']

app.config ['$interpolateProvider',
    ($interpolateProvider)->
        $interpolateProvider.startSymbol('{[{')
        $interpolateProvider.endSymbol('}]}')]

app.controller 'noiseController', ['$scope', '$interval', 'Message', ($scope, $interval, Message)->
    $scope.phoneNumber = '+14086275378'

    $scope.noiseData =
        instant: 0
        noiseProgress: 0
        cumulativeVolume: 0
        topNoises: []
        threshold: 0.2
        topNoisesChanged: false
    
    timeoutId = $interval (()->
        if $scope.noiseData.topNoisesChanged
            message = new Message
                text: "Top noises have changed"
                contacts: [$scope.phoneNumber]
            message.$send
                username: '4086275378'
                api_key: '0f2a9701964627b0317748402e33cffee97e77a7'
        $scope.noiseData.topNoisesChanged = false
        ),
        200
]
.config ['$resourceProvider', ($resourceProvider)->
  $resourceProvider.defaults.stripTrailingSlashes = false;
]
