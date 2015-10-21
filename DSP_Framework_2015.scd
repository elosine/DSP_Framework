~nb = 7;
~g = Array.newClear(~nb);
~nb.do{|ix| if(ix==0,{~g[ix]=Group.new(s)}, {~g[ix]=Group.after(ix-1)})};
~ab = {Bus.audio(s)}!~nb;
~cb = {Bus.control(s, 4)}!~nb;

//Inputs SynthDefs
SynthDef(\micin, {
	arg ibs=0, obs=0, atk=0.01, rel=0.1, crv= -3;
	var env, in;
	env = EnvGen.ar(Env.asr(atk, 1, rel, crv), gate);
	in = SoundIn.ar(ibs);
	Out.ar(obs, in*env);
}).add;

//develop some killer dsp

(
b = SoundFile.collectIntoBuffers("/Users/jyang/GitHub/DSP_Framework/samples/*");
SynthDef(\rm,{
	arg buf, inamp=1, amp=1, mix=0.5, bend=1, lf1f=0.2;
	var in, dfreq, hasFreq, damp, mod, rm, lf1;
	in = PlayBuf.ar(2, buf, trigger:\t_tr.kr(1,0));
	in = in*inamp;
	# dfreq, hasFreq = Tartini.kr(in);
	//freq.poll;
	damp = Amplitude.kr(in);
	//damp.poll;
	lf1 = LFTri.kr(lf1f)*bend;
	//mod = SinOsc.ar( (dfreq.cpsmidi+(bend*damp)).midicps )*damp;
	mod = SinOsc.ar( (dfreq.cpsmidi+lf1).midicps )*damp;
	rm = DiodeRingMod.ar(in, mod);
	//rm = Mix.ar([in*(1.0-mix), mod*mix]);
	Out.ar(0, rm*amp);
}).add;
)
a = Synth(\rm, [\buf, b[0],\t_tr, 1, \inamp, 4, \mix, 0.6, \amp, 2, \bend, 1, \lf1f, 0.1]);
a.set(\t_tr, 1, \inamp, 4, \mix, 0.6, \amp, 2, \bend, 1, \lf1f, 0.1);
a.set(\buf, b[1], \t_tr, 1);
a.set(\buf, b[2], \t_tr, 1);
a.set(\buf, b[3], \t_tr, 1);
a.set(\buf, b[4], \t_tr, 1);
a.set(\buf, b[5], \t_tr, 1);
a.set(\buf, b[6], \t_tr, 1);
a.set(\buf, b[7], \t_tr, 1);

Qitch

