// a Buffer for the UGens to use, one second at the current sample rate
s.options.memSize_(65536 * 4);
s.reboot;
(
b = Buffer.alloc(s, s.sampleRate*2, 1);

// write a signal into a delay, tap it at mutiple times
SynthDef(\tap, {
	arg buffer, delaytimes = #[0.2, 0.4, 0.55, 0.75, 0.95, 1.15, 1.3], amps = #[0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8];
	var source, tapPhase, sig, d1,d2,d3,d4,d5,d6;
	source = SoundIn.ar(0);
	tapPhase = DelTapWr.ar(buffer, source);
	#d1, d2, d3, d4, d5, d6 = DelTapRd.ar(buffer, tapPhase,
		delaytimes,      // tap times
		4,                      // no interp
		amps         // muls for each tap
	);
	sig = Mix.ar([source, d1, d2, d3, d4, d5, d6]);
	//sig = JPverb.ar(sig);
	Out.ar(1, sig)
}).add;

SynthDef(\mtap, {
	arg buffer, delaytimes = #[0.4, 0.6, 0.8, 1.2, 1.4, 1.6, 1.8], amps = #[1, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4], panrate=3;
	var source, sig;
	source = SoundIn.ar(0);
	sig = MultiTap.ar(delaytimes, amps, source, bufnum:buffer);
	sig = Pan2.ar(sig, SinOsc.kr(panrate));
	//sig = JPverb.ar(sig, 1.5, 0.8, 1, 0.707, 0, 0);
	Out.ar(0, sig)
}).add;
)

x = Synth(\mtap, [\buffer, b, \delaytimes, [0.1,0.2,0.3,0.4,0.5,0.6,0.7]] );
x = Synth(\mtap, [\buffer, b, \delaytimes, [0.4, 0.6, 0.8, 1.2, 1.4, 1.6, 1.8]] );
x = Synth(\mtap, [\buffer, b, \delaytimes, [0.2, 0.4, 0.55, 0.7, 0.9, 1.1, 1.25]] );

x.free;
b.free;

{

	Tartini.ar
	Vocoder.ar(Saw.ar(SinOsc.kr(0.2).range(100, 300),4),SoundIn.ar(0),56)
}.play;

(
a= SynthDef("testtartini",{arg infreq=440;
    var in, freq, hasFreq, out;

	    in=SoundIn.ar(0);

    # freq, hasFreq = Tartini.kr(in);

    //freq.poll;
	out = Vocoder.ar( Saw.ar((freq.cpsmidi+12).midicps )+Saw.ar((freq.cpsmidi+7).midicps )+Saw.ar((freq.cpsmidi+24).midicps ), in, 56);

	    Out.ar(1,out*0.5);
}).play(s);
)





