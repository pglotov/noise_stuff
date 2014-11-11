(function() {
  var app;

  app = angular.module('noiseAlert.app', ['soundMeter']);

  app.config([
    '$interpolateProvider', function($interpolateProvider) {
      $interpolateProvider.startSymbol('{[{');
      return $interpolateProvider.endSymbol('}]}');
    }
  ]);

  app.controller('noiseController', [
    '$scope', '$window', 'SoundMeter', function($scope, $window, SoundMeter) {
      var audioContext, constraints, e, errorCallback, successCallback;
      try {
        $window.AudioContext = $window.AudioContext || $window.webkitAudioContext;
        audioContext = new AudioContext();
      } catch (_error) {
        e = _error;
        alert('Web Audio API not supported.');
      }
      constraints = {
        audio: true,
        video: false
      };
      navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia;
      successCallback = function(stream) {
        var soundMeter;
        soundMeter = new SoundMeter(audioContext);
        soundMeter.connectToSource(stream);
        return setInterval(function() {
          $scope.instantVolume = soundMeter.instant.toFixed(2);
          $scope.noiseProgress = soundMeter.noiseProgress.toFixed(5);
          return $scope.topNoises = soundMeter.topNoises;
        }, 200);
      };
      errorCallback = function(error) {
        return console.log('navigator.getUserMedia error: ', error);
      };
      navigator.getUserMedia(constraints, successCallback, errorCallback);
      $scope.phoneNumber = '408';
      return $scope.threshold = 0.2;
    }
  ]);

}).call(this);

(function() {
  var app;

  app = angular.module('soundMeter').factory('NoiseDescriptor', [
    function(cumulativeVolume, timestamp) {
      this.cumulativeVolume = cumulativeVolume;
      return this.timestamp = timestamp;
    }
  ]).factory('SoundMeter', [
    'NoiseDescriptor', function(NoiseDescriptor) {
      var SoundMeter;
      SoundMeter = function(context) {
        var that;
        this.context = context;
        this.instant = 0.0;
        this.noiseProgress = 0;
        this.cumulativeVolume = 0;
        this.topNoises = [];
        this.script = context.createScriptProcessor(2048, 1, 1);
        that = this;
        return this.script.onaudioprocess = function(event) {
          var i, input, sum, _i, _ref;
          input = event.inputBuffer.getChannelData(0);
          sum = 0.0;
          for (i = _i = 0, _ref = input.length; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
            sum += input[i] * input[i];
          }
          that.instant = Math.sqrt(sum / input.length);
          if (that.instant > that.threshold) {
            that.noiseProgress += input.length / 2048;
            return that.cumulativeVolume += that.instant * input.length / 2048;
          } else {
            if (that.noiseProgress >= 10000) {
              that.topNoises.push_back(new NoiseDescriptor(that.cumulativeVolume, new Date()));
              that.topNoises.reverse(function(a, b) {
                return b.cumulativeVolume - a.cumulativeVolume;
              });
              if (that.topNoises.length > 3) {
                that.topNoises.pop();
              }
            }
            that.noiseProgress = 0;
            return that.cumulativeVolume = 0;
          }
        };
      };
      SoundMeter.prototype.connectToSource = function(stream) {
        console.log('SoundMeter connecting');
        this.mic = this.context.createMediaStreamSource(stream);
        this.mic.connect(this.script);
        return this.script.connect(this.context.destination);
      };
      SoundMeter.prototype.stop = function() {
        this.mic.disconnect();
        return this.script.disconnect();
      };
      return SoundMeter;
    }
  ]);

}).call(this);
