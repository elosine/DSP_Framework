/*
2 ins - live in
make a separate processor for sample player/recorder
1 effects bus
pass thru synthdef
*/
(
~g0 = Group.new(s);
~g1 = Group.after(~g0);
~ab = Bus.audio(s);
//buffer for freeze
~fb = Buffer.alloc(s, s.sampleRate*2);
~eb = SoundFile.collectIntoBuffers("/Volumes/Ute/Freeze/grainEnv/" ++ "*");

SynthDef(\micin, {
	arg ibs=0, obs=0, atk=0.01, rel=0.1, crv= -3, gate=1;
	var env, in;
	env = EnvGen.ar(Env.asr(atk, 1, rel, crv), gate);
	in = SoundIn.ar(ibs);
	Out.ar(obs, in*env);
}).add;

// DSP
SynthDef(\amplify,{
	arg ibs, obs=0, gate=1, amp=1;
	var env;
	env = EnvGen.ar(Env.asr(releaseTime:0.1),gate, doneAction:2);
	Out.ar(obs, In.ar(ibs)*env*amp);
}).add;

//ringmod
SynthDef(\rm,{
	arg buf, ibs, obs=0, inamp=1, amp=1, mix=0.5, bend=1, lf1f=0.2, gate=1,
	atk=0.01, rel=0.8, crv= -4;
	var in, dfreq, hasFreq, damp, mod, rm, lf1, env;
	env = EnvGen.ar(Env.asr(atk,1,rel,crv),gate, doneAction:2);
	in = In.ar(ibs);
	in = in*inamp;
	# dfreq, hasFreq = Tartini.kr(in);
	damp = Amplitude.kr(in);
	lf1 = LFTri.kr(lf1f)*bend;
	mod = SinOsc.ar( (dfreq.cpsmidi+lf1).midicps )*damp;
	rm = DiodeRingMod.ar(in, mod);
	Out.ar(obs, rm*amp*env);
}).add;

//freeze

SynthDef(\icy_live, {
	arg ibs, obs=0,buf=0, envbuf = -1, pitchshift=1, winsz=0.8, overlaps=40, resettrig=0, startpos=0.0, endpos=1.0, rand=0.1, ratemin=1.0, ratemax=0.00001, indur=1, ingate=1, dur=5, rel=1.2, crv = -6;
	var sig, ix, krate, in, writehead, whenv, durenv;
	durenv = EnvGen.ar(Env.linen(0.01, dur, rel, curve: crv),1,doneAction:2);
	writehead = Phasor.ar(0, BufRateScale.kr(buf), 0, BufFrames.kr(buf));
	whenv = EnvGen.ar(Env.linen(0.0, indur, 0.0), ingate);
	in = BufWr.ar(SoundIn.ar(ibs), buf, writehead*whenv);
	krate = \rate.kr(1, 0.05).linlin(0.0, 1.0, ratemin, ratemax);
	ix = Phasor.kr(resettrig, ((1.0/ControlRate.ir)/(BufFrames.kr(buf)/SampleRate.ir))*krate, startpos, endpos);
	sig = Warp1.ar(1, buf, ix, pitchshift, winsz, envbuf, overlaps,rand);
	Out.ar(obs, sig*durenv);
}).add;
)

//start live mic
s.sendMsg(\s_new, \micin, 5000, 0, ~g0.nodeID, \obs, ~ab.index);
//amplify
s.sendMsg(\s_new, \amplify, 5001, 0, ~g1.nodeID, \ibs, ~ab.index);
s.sendMsg(\n_set, 5001, \gate, 0);//amplify off
//ringmod
s.sendMsg(\s_new, \rm, 5002, 0, ~g1.nodeID, \ibs, ~ab.index, \bend, 5, \lf1f, 0.2, \inamp, 2, \rel, 0.8);
s.sendMsg(\n_set, 5002, \gate, 0); //rm off
//freeze
s.sendMsg(\s_new, \icy_live, 5003, 0, ~g1.nodeID, \buf, ~fb.bufnum, \winsz, 0.6, \overlaps, 17, \rand, 0.2, \envbuf, ~eb[3], \dur, 4, \indur, 2, \rate, 0.97, \rel, 2, \crv, -6 );










