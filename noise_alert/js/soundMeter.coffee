
app = angular.module 'noiseAlert.app'
.directive 'soundMeter', [()->
    restrict: 'E'
    scope:
        threshold: '='
        noiseData: '='
        controller: ['$scope', '$window', ($scope, $window)->
            noiseData = $scope.noiseData
            noiseData.instant = 0.0;
            noiseData.noiseProgress = 0;
            noiseData.cumulativeVolume = 0;
            noiseData.topNoises = [];


            try
                $window.AudioContext = $window.AudioContext || $window.webkitAudioContext;
                $scope.context = new AudioContext();
            catch e
                alert('Web Audio API not supported.');

            $scope.script = $scope.context.createScriptProcessor(2048, 1, 1);

            $scope.script.onaudioprocess = (event)->
                input = event.inputBuffer.getChannelData(0)
                sum = 0.0
                for i in [0..input.length]
                    sum += input[i] * input[i]
                noiseData.instant = Math.sqrt(sum / input.length)

                if noiseData.instant > $scope.threshold
                    noiseData.noiseProgress += input.length / 2048;
                    noiseData.cumulativeVolume += that.instant * input.length / 2048;
                else
                    if noiseData.noiseProgress >= 10000
                        noiseData.topNoises.push_back
                            cumulativeVolume: noiseData.cumulativeVolume
                            timestamp: new Date()
                        noiseData.topNoises.reverse((a,b)-> b.cumulativeVolume - a.cumulativeVolume)
                        if noiseData.topNoises.length > 3
                            noiseData.topNoises.pop()
                    noiseData.noiseProgress = 0
                    noiseData.cumulativeVolume = 0

            $scope.connectToSource = (stream)->
                console.log('SoundMeter connecting');
                $scope.mic = $scope.context.createMediaStreamSource(stream);
                $scope.mic.connect(this.script);
                # necessary to make sample run, but should not be.
                $scope.script.connect($scope.context.destination);

            $scope.stop = ()->
                $scope.mic.disconnect();
                $scope.script.disconnect();

            $scope.constraints =
                audio: true
                video: false

            navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia;

            navigator.getUserMedia constraints, ((stream)->
                $scope.connectToSource(stream)),
                ((error)->console.log('navigator.getUserMedia error: ', error))
        ]
]
