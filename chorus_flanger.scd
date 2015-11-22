(
//0.013 maxdelay - flanger
//0.03 maxdelay - chorus
SynthDef(\flanger_chorus, { arg out=0, in=0, delay=0.03, maxdelay = 0.3, depth=0.08, rate=0.06, fdbk=0.0, decay=0.0;

	var input, maxrate, dsig, mixed, local;
	maxdelay = 0.030;
	maxrate = 10.0;
	input = SoundIn.ar(in, 1);
	local = LocalIn.ar(1);
	dsig = AllpassL.ar( // the delay (you could use AllpassC (put 0 in decay))
		input + (local * fdbk),
		maxdelay * 2,
		LFPar.kr( // very similar to SinOsc (try to replace it) - Even use LFTri
			rate * maxrate,
			0,
			depth * maxdelay,
			delay * maxdelay),
		decay);
	mixed = input + dsig;
	LocalOut.ar(mixed);
	Out.ar([out, out+1], mixed);
}).add;
)
a = Synth(\flanger);