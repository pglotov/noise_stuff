app = angular.module 'noiseAlert.app', ['message.resource']

app.config ['$interpolateProvider',
    ($interpolateProvider)->
        $interpolateProvider.startSymbol('{[{')
        $interpolateProvider.endSymbol('}]}')]

app.controller 'noiseController', ['$scope', '$interval', 'Message', ($scope, $interval, Message)->
    $scope.phoneNumber = '+14086275378'

    class TopNoises
        constructor: (max_size)->
            @max_size = max_size
            @storage = []
            @changed = false

        push: (newEntry)->
            @storage.push newEntry
            @storage.sort((a,b)-> b.cumulativeVolume - a.cumulativeVolume)
            if @storage.length > @max_size
                popedEntry = @storage.pop()
                if popedEntry != newEntry
                    @changed = true
            else
                @changed = true                        
        clear: ()->
            @changed = false


    $scope.noiseData =
        instant: 0
        progress: 0
        cumulativeVolume: 0
        threshold: 0.2
        topNoises: new TopNoises(3)    

    timeoutId = $interval (()->
        noiseProgress = $scope.noiseData.progress
        instant = $scope.noiseData.instant
        if $scope.noiseData.topNoises.changed
            message = new Message
                text: "Top noises have changed"
                contacts: [$scope.phoneNumber]
            message.$send
                username: '4086275378'
                api_key: '0f2a9701964627b0317748402e33cffee97e77a7'
            $scope.noiseData.topNoises.clear()
        ),
        200
]
.config ['$resourceProvider', ($resourceProvider)->
  $resourceProvider.defaults.stripTrailingSlashes = false;
]
