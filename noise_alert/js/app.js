(function() {
  var app;

  app = angular.module('noiseAlert.app', []);

  app.config([
    '$interpolateProvider', function($interpolateProvider) {
      $interpolateProvider.startSymbol('{[{');
      return $interpolateProvider.endSymbol('}]}');
    }
  ]);

  app.controller('noiseController', [
    '$scope', '$interval', function($scope, $interval) {
      var timeoutId;
      $scope.phoneNumber = '408';
      $scope.noiseData = {
        instant: 0,
        noiseProgress: 0,
        cumulativeVolume: 0,
        topNoises: [],
        threshold: 0.2
      };
      return timeoutId = $interval($scope.apply, 200);
    }
  ]);

}).call(this);

(function() {
  var app;

  app = angular.module('noiseAlert.app').directive('soundMeter', [
    function() {
      return {
        restrict: 'E',
        scope: {
          threshold: '=',
          noiseData: '='
        },
        controller: [
          '$scope', '$window', function($scope, $window) {
            var e, noiseData;
            noiseData = $scope.noiseData;
            noiseData.instant = 0.0;
            noiseData.noiseProgress = 0;
            noiseData.cumulativeVolume = 0;
            noiseData.topNoises = [];
            try {
              $window.AudioContext = $window.AudioContext || $window.webkitAudioContext;
              $scope.context = new AudioContext();
            } catch (_error) {
              e = _error;
              alert('Web Audio API not supported.');
            }
            $scope.script = $scope.context.createScriptProcessor(2048, 1, 1);
            $scope.script.onaudioprocess = function(event) {
              var input, sum, val, _i, _len;
              input = event.inputBuffer.getChannelData(0);
              sum = 0.0;
              for (_i = 0, _len = input.length; _i < _len; _i++) {
                val = input[_i];
                sum += val * val;
              }
              noiseData.instant = Math.sqrt(sum / input.length);
              if (noiseData.instant > noiseThreshold.threshold) {
                noiseData.noiseProgress += input.length / 2048;
                return noiseData.cumulativeVolume += noiseData.instant * input.length / 2048;
              } else {
                if (noiseData.noiseProgress >= 10000) {
                  noiseData.topNoises.push_back({
                    cumulativeVolume: noiseData.cumulativeVolume,
                    timestamp: new Date()
                  });
                  noiseData.topNoises.reverse(function(a, b) {
                    return b.cumulativeVolume - a.cumulativeVolume;
                  });
                  if (noiseData.topNoises.length > 3) {
                    noiseData.topNoises.pop();
                  }
                  noiseData.noiseProgress = 0;
                  return noiseData.cumulativeVolume = 0;
                }
              }
            };
            $scope.connectToSource = function(stream) {
              console.log('SoundMeter connecting');
              $scope.mic = $scope.context.createMediaStreamSource(stream);
              $scope.mic.connect($scope.script);
              return $scope.script.connect($scope.context.destination);
            };
            $scope.stop = function() {
              $scope.mic.disconnect();
              return $scope.script.disconnect();
            };
            $scope.constraints = {
              audio: true,
              video: false
            };
            navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia;
            return navigator.getUserMedia($scope.constraints, (function(stream) {
              return $scope.connectToSource(stream);
            }), (function(error) {
              return console.log('navigator.getUserMedia error: ', error);
            }));
          }
        ]
      };
    }
  ]);

}).call(this);
