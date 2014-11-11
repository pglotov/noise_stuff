(function() {
  var app;

  app = angular.module('noiseAlert.app', ['message.resource']);

  app.config([
    '$interpolateProvider', function($interpolateProvider) {
      $interpolateProvider.startSymbol('{[{');
      return $interpolateProvider.endSymbol('}]}');
    }
  ]);

  app.controller('noiseController', [
    '$scope', '$interval', 'Message', function($scope, $interval, Message) {
      var TopNoises, timeoutId;
      $scope.phoneNumber = '+14086275378';
      TopNoises = (function() {
        function TopNoises(max_size) {
          this.max_size = max_size;
          this.storage = [];
          this.changed = false;
        }

        TopNoises.prototype.push = function(newEntry) {
          var popedEntry;
          this.storage.push(newEntry);
          this.storage.sort(function(a, b) {
            return b.cumulativeVolume - a.cumulativeVolume;
          });
          if (this.storage.length > this.max_size) {
            popedEntry = this.storage.pop();
            if (popedEntry !== newEntry) {
              return this.changed = true;
            }
          } else {
            return this.changed = true;
          }
        };

        TopNoises.prototype.clear = function() {
          return this.changed = false;
        };

        return TopNoises;

      })();
      $scope.noiseData = {
        instant: 0,
        progress: 0,
        cumulativeVolume: 0,
        threshold: 0.2,
        topNoises: new TopNoises(3)
      };
      return timeoutId = $interval((function() {
        var instant, message, noiseProgress;
        noiseProgress = noiseData.progress;
        instant = noiseData.instant;
        if ($scope.noiseData.topNoises.changed) {
          message = new Message({
            text: "Top noises have changed",
            contacts: [$scope.phoneNumber]
          });
          message.$send({
            username: '4086275378',
            api_key: '0f2a9701964627b0317748402e33cffee97e77a7'
          });
          return $scope.noiseData.topNoises.clear();
        }
      }), 200);
    }
  ]).config([
    '$resourceProvider', function($resourceProvider) {
      return $resourceProvider.defaults.stripTrailingSlashes = false;
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
            try {
              $window.AudioContext = $window.AudioContext || $window.webkitAudioContext;
              $scope.context = new AudioContext();
            } catch (_error) {
              e = _error;
              alert('Web Audio API not supported.');
            }
            $scope.script = $scope.context.createScriptProcessor(2048, 1, 1);
            $scope.script.onaudioprocess = function(event) {
              var input, newEntry, sum, val, _i, _len;
              input = event.inputBuffer.getChannelData(0);
              sum = 0.0;
              for (_i = 0, _len = input.length; _i < _len; _i++) {
                val = input[_i];
                sum += val * val;
              }
              noiseData.instant = Math.sqrt(sum / input.length);
              if (noiseData.instant >= noiseData.threshold) {
                noiseData.progress += input.length / 2048;
                return noiseData.cumulativeVolume += noiseData.instant * input.length / 2048;
              } else {
                if (noiseData.progress >= 12) {
                  newEntry = {
                    cumulativeVolume: noiseData.cumulativeVolume,
                    timestamp: new Date()
                  };
                  noiseData.topNoises.push(newEntry);
                  noiseData.progress = 0;
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

(function() {
  var app;

  app = angular.module('message.resource', ['ngResource']).factory('Message', [
    '$resource', function($resource) {
      return $resource('http://cors-anywhere.herokuapp.com/https://api.sendhub.com/v1/messages/', null, {
        send: {
          method: 'POST'
        }
      });
    }
  ]);

}).call(this);
