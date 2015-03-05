(
s.waitForBoot{

	SynthDef( \gh, {
		arg ibs=0, obs=0, amp=1, atk = 0.01, decay=0, sus=1, rel=0.1, crv = -2, gate=0,
		delayTime=2, damp=0, size=1, diff=0.707, feedback=0.9, modDepth=0.1, modFreq=2;
		var source, dsp, env;
		env = EnvGen.ar( Env.adsr(atk, decay, sus, rel, curve:crv), gate );
		source = SoundIn.ar(ibs);
		dsp = Greyhole.ar(source, delayTime, damp, size, diff, feedback, modDepth, modFreq);
		Out.ar(obs, dsp*amp*env);
	}).add;

	SynthDef(\guitarAmp, {
		arg ibs=0, obs=0, amp=1, atk = 0.01, decay=0, sus=1, rel=0.1, crv = -2, gate=0,amount=0.99;
		var source, dsp, env, amCoef;
		env = EnvGen.ar( Env.adsr(atk, decay, sus, rel, curve:crv), gate );
		source = SoundIn.ar(ibs);
		source = HPF.ar(source, 400)*5;
		//amount = 0.99;
		amCoef= 2*amount/(1-amount);
		dsp = MidEQ.ar(LPF.ar((1+amCoef)*source/(1+(amCoef*source.abs)), [3800, 3900])*0.5, 120, 0.7, 8);
		Out.ar(obs, dsp*amp*env);
	}).add;

	SynthDef( \rm, {
		arg ibs=0, obs=0, amp=1, atk = 0.01, decay=0, sus=1, rel=0.1, crv = -2, gate=0,
		rate = 0.2, modfreqlo=200, modfreqhi=1000, modamp=1;
		var source, dsp, env, mod;
		mod = SinOsc.ar( SinOsc.kr(rate).range(modfreqlo, modfreqhi) );
		env = EnvGen.ar( Env.adsr(atk, decay, sus, rel, curve:crv), gate );
		source = SoundIn.ar(ibs);
		dsp = DiodeRingMod.ar(source, mod*modamp);
		Out.ar(obs, dsp*amp*env);
	}).add;

	q = ();
	//Make effect by OSC
	OSCdef(\mkfx, {
		arg msg;
		var name, sdname, args_vals;
		name = msg[1].asSymbol;
		sdname = msg[2].asSymbol;
		sdname.postln;
		args_vals = msg.copyRange(3, msg.size-1);
		args_vals.do{|it, ix| if(ix.even, {args_vals[ix]=it.asSymbol}, {args_vals[ix]=it.asFloat})};
		q[name] = Synth(sdname, args_vals);
	}, "/mkfx");

	//Toggle effect on and off
	OSCdef(\togfx, {
		arg msg;
		var name, tog;
		tog = msg[2].asInteger;
		name = msg[1].asSymbol;
		q[name].set(\gate, tog);
	}, "/togfx");

	//Set FX Arguments
	OSCdef(\setfx, {
		arg msg;
		var name, args_vals;
		name = msg[1].asSymbol;
		if( q.includesKey(name), {
			args_vals = msg.copyRange(2, msg.size-1);
			args_vals.do{|it, ix| if(ix.even, {args_vals[ix]=it.asSymbol}, {args_vals[ix]=it.asFloat})};
			args_vals.do{|it ix| if( ix.odd,{ q[name].set(args_vals[ix-1], it) })};
		});
	}, "/setfx");

	//Free effect by OSC
	OSCdef(\killfx, {
		arg msg;
		var name;
		name = msg[1].asSymbol;
		q[name].free;
	}, "/killfx");

	//Map to Control Bus
	OSCdef(\maparg, {
		arg msg;
		var name, argname, busnum;
		name = msg[1].asSymbol;
		argname = msg[2].asSymbol;
		busnum = msg[3].asInteger;
		q[name].map(argname, ~kbs[busnum]);
	}, "/maparg");

}
)
