//Sample trigger
//Ensure to replace the link to the sample with the path to where-ever you save the file
~s1 = Buffer.read(s, "/Users/jyang/GitHub/superimposition/ConvolutionReverb/breakingglass.wav");
//This synth is used to play and control playback of the sample
(
SynthDef(\samplescrub, {
	arg gate=1, rel=0.7, buf, startpos=0, rate=1, amp=5, inamp=1.0;
	var source, sig, env, samp;
	env = EnvGen.ar(Env.asr(releaseTime:rel), gate, doneAction:2);
	source = SoundIn.ar(0)*inamp;
	samp = PlayBuf.ar(1, buf, rate:rate, startPos:startpos, loop:1);
	sig = samp*Amplitude.kr(source);
	Out.ar(0, sig*env*amp);
}).add;
)

a = Synth(\samplescrub, [\buf, ~s1]);
a.set(\inamp, 3);