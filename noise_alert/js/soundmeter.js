/*
 *  Copyright (c) 2014 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree.
 */

'use strict';

// Meter class that generates a number correlated to audio volume.
// The meter class itself displays nothing, but it makes the
// instantaneous and time-decaying volumes available for inspection.
// It also reports on the fraction of samples that were at or near
// the top of the measurement range.


function NoiseDesciptor(cumulativeVolume, timestamp){
  this.cumulativeVolume = cumulativeVolume;
  this.datetime = datetime;
}

function SoundMeter(context) {
  this.context = context;
  this.instant = 0.0;
  this.slow = 0.0;
  this.clip = 0.0;

  this.noiseProgress = 0;
  this.cumulativeVolume = 0;

  this.topNoises = [];

  this.script = context.createScriptProcessor(2048, 1, 1);
  var that = this;

  this.script.onaudioprocess = function(event) {
    var input = event.inputBuffer.getChannelData(0);
    var i;
    var sum = 0.0;
    for (i = 0; i < input.length; ++i) {
      sum += input[i] * input[i];
    }

    that.instant = Math.sqrt(sum / input.length);

    if (that.instant > window.noiseAlert.threshold) {
      this.noiseProgress += input.length / 2048;
      this.cumulativeVolume += that.instant * input.length / 2048;
    } else {
      if (this.noiseProgress >= 10000) {
        this.topNoises.push_back(new NoiseDescriptor(this.cumulativeVolume, new Date()));
        this.topNoises.reverse(function(a,b) {return b.cumulativeVolume - a.cumulativeVolume});
        if (this.topNoises.length > 3)
          this.topNoises.pop();
      }
      this.noiseProgress = 0;
      this.cumulativeVolume = 0;
    }
  };
}

SoundMeter.prototype.connectToSource = function(stream) {
  console.log('SoundMeter connecting');
  this.mic = this.context.createMediaStreamSource(stream);
  this.mic.connect(this.script);
  // necessary to make sample run, but should not be.
  this.script.connect(this.context.destination);
};

SoundMeter.prototype.stop = function() {
  this.mic.disconnect();
  this.script.disconnect();
};
