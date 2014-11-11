app = angular.module 'noiseAlert.app', []


app.config ['$interpolateProvider',
     ($interpolateProvider)->
        $interpolateProvider.startSymbol('{[{')
        $interpolateProvider.endSymbol('}]}')]

app.controller 'noiseController', ['$scope', ($scope)->
    $scope.phoneNumber = '408'    
    $scope.threshold = threshold: 0.2

    navigator.getUserMedia constraints,
        (stream)->
            # Put variables in global scope to make them available to the browser console.
            window.stream = stream
            $scope.soundMeter = window.soundMeter = new SoundMeter window.audioContext, $scope.threshold
            $scope.soundMeter.connectToSource(stream);

            setInterval ()->
                instantMeter.value = instantValueDisplay.innerText = soundMeter.instant.toFixed(2)
                slowMeter.value = slowValueDisplay.innerText = soundMeter.slow.toFixed(2)
                clipMeter.value = clipValueDisplay.innerText = soundMeter.clip
                noiseCountMeter.value = noiseCountDisplay.innerText = soundMeter.noiseCount
            , 200
        ,(error)->console.log('navigator.getUserMedia error: ', error)
]
