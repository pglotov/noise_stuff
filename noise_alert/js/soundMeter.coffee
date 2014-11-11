
app = angular.module 'noiseAlert.app'
.directive 'soundMeter', [()->
    restrict: 'E'
    scope:
        threshold: '='
        noiseData: '='
    controller: ['$scope', '$window', ($scope, $window)->
        noiseData = $scope.noiseData

        try
            $window.AudioContext = $window.AudioContext || $window.webkitAudioContext;
            $scope.context = new AudioContext();
        catch e
            alert('Web Audio API not supported.');

        $scope.script = $scope.context.createScriptProcessor(2048, 1, 1);

        $scope.script.onaudioprocess = (event)->
            input = event.inputBuffer.getChannelData(0)
            sum = 0.0
            for val in input
                sum += val * val
            noiseData.instant = Math.sqrt(sum / input.length)

            if noiseData.instant > noiseData.threshold
                noiseData.noiseProgress += input.length / 2048
                noiseData.cumulativeVolume += noiseData.instant * input.length / 2048
            else
                if noiseData.noiseProgress >= 12
                    newEntry =
                        cumulativeVolume: noiseData.cumulativeVolume
                        timestamp: new Date()

                noiseData.topNoises.push newEntry
                noiseData.noiseProgress = 0
                noiseData.cumulativeVolume = 0

        $scope.connectToSource = (stream)->
            console.log('SoundMeter connecting');
            $scope.mic = $scope.context.createMediaStreamSource(stream);
            $scope.mic.connect($scope.script);
            # necessary to make sample run, but should not be.
            $scope.script.connect($scope.context.destination);

        $scope.stop = ()->
            $scope.mic.disconnect();
            $scope.script.disconnect();

        $scope.constraints =
            audio: true
            video: false

        navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia;

        navigator.getUserMedia $scope.constraints, ((stream)->
            $scope.connectToSource(stream)),
            ((error)->console.log('navigator.getUserMedia error: ', error))
    ]
]
