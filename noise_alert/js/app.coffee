app = angular.module 'noiseAlert.app', []

app.config ['$interpolateProvider',
    ($interpolateProvider)->
        $interpolateProvider.startSymbol('{[{')
        $interpolateProvider.endSymbol('}]}')]

app.controller 'noiseController', ['$scope', '$window', 'SoundMeter', ($scope, $window, SoundMeter)->
    try
        $window.AudioContext = $window.AudioContext || $window.webkitAudioContext;
        audioContext = new AudioContext();
    catch e
        alert('Web Audio API not supported.');

    constraints =
        audio: true
        video: false

    navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia

    successCallback = (stream)->
        soundMeter = new SoundMeter(audioContext);
        soundMeter.connectToSource(stream);

        setInterval(()->
            $scope.instantVolume = soundMeter.instant.toFixed(2)
            $scope.noiseProgress = soundMeter.noiseProgress.toFixed(5)
            $scope.topNoises = soundMeter.topNoises
        , 200);

    errorCallback = (error)->
        console.log('navigator.getUserMedia error: ', error);

    navigator.getUserMedia(constraints, successCallback, errorCallback);

    $scope.phoneNumber = '408'
    $scope.threshold = 0.2
]
