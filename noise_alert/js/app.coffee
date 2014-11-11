app = angular.module 'noiseAlert.app', ['message.resource']

app.config ['$interpolateProvider',
    ($interpolateProvider)->
        $interpolateProvider.startSymbol('{[{')
        $interpolateProvider.endSymbol('}]}')]

app.controller 'noiseController', ['$scope', '$interval', 'Message', ($scope, $interval, Message)->
    $scope.phoneNumber = '+14086275378'

    class TopNoises
        constructor: (size)->
            @size = size
            @storage = []
            @topNoisesChanged = false

        push: (newEntry)->
            @storage.push newEntry
            @storage.sort((a,b)-> b.cumulativeVolume - a.cumulativeVolume)
            if @storage.length > @size
                popedEntry = @storage.pop()
                if popedEntry != newEntry
                    @topNoisesChanged = true
            else
                @topNoisesChanged = true                        
        clear: ()->
            @topNoisesChaged = false


    $scope.noiseData =
        instant: 0
        noiseProgress: 0
        cumulativeVolume: 0
        threshold: 0.2
        topNoises: new TopNoises(3)    

    timeoutId = $interval (()->
        if $scope.noiseData.topNoisesChanged
            message = new Message
                text: "Top noises have changed"
                contacts: [$scope.phoneNumber]
            message.$send
                username: '4086275378'
                api_key: '0f2a9701964627b0317748402e33cffee97e77a7'
            $scope.noiseData.clear()
        ),
        200
]
.config ['$resourceProvider', ($resourceProvider)->
  $resourceProvider.defaults.stripTrailingSlashes = false;
]
