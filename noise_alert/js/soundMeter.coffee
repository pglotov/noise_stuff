
app = angular.module 'noiseAlert.app'
.factory 'NoiseDescriptor', [()->
    NoiseDescriptor = (cumulativeVolume, timestamp)->
        this.cumulativeVolume = cumulativeVolume
        this.timestamp = timestamp

    NoiseDescriptor
]
.factory 'SoundMeter', ['NoiseDescriptor', (NoiseDescriptor)->
    SoundMeter = (context)->
        this.context = context;
        this.instant = 0.0;

        this.noiseProgress = 0;
        this.cumulativeVolume = 0;

        this.topNoises = [];

        this.script = context.createScriptProcessor(2048, 1, 1);
        that = this;

        this.script.onaudioprocess = (event)->
            input = event.inputBuffer.getChannelData(0)
            sum = 0.0
            for i in [0..input.length]
                sum += input[i] * input[i]
            that.instant = Math.sqrt(sum / input.length)

            if that.instant > that.threshold
                that.noiseProgress += input.length / 2048;
                that.cumulativeVolume += that.instant * input.length / 2048;
            else
                if that.noiseProgress >= 10000
                    that.topNoises.push_back(new NoiseDescriptor(that.cumulativeVolume, new Date()))
                    that.topNoises.reverse((a,b)-> b.cumulativeVolume - a.cumulativeVolume)
                    if that.topNoises.length > 3
                        that.topNoises.pop()
                that.noiseProgress = 0
                that.cumulativeVolume = 0

    SoundMeter.prototype.connectToSource = (stream)->
        console.log('SoundMeter connecting');
        this.mic = this.context.createMediaStreamSource(stream);
        this.mic.connect(this.script);
        # necessary to make sample run, but should not be.
        this.script.connect(this.context.destination);

    SoundMeter.prototype.stop = ()->
        this.mic.disconnect();
        this.script.disconnect();

    SoundMeter
]
