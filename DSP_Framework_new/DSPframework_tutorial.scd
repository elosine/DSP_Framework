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

//CREATE A MANUAL WORKFLOW
a = Synth(\ghole, [\gate, 1]); //Create an instance of the synth/effect
a.set(\gate, 0); //off
a.set(\gate, 1); //back on
a.free; //kill synth


q = ();
//Make  effect by OSC
OSCdef(\mkfx, {
	arg msg;
	var name, sdname, args_vals;
	name = msg[1].asSymbol;
	sdname = msg[2].asSymbol;
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
	if( q.includesKey(name), {
		args_vals = msg.copyRange(1, msg.size-1);
		args_vals.do{|it, ix| if(ix.even, {args_vals[ix]=it.asSymbol}, {args_vals[ix]=it.asFloat})};
		q[name].set(args_vals);
	});
}, "/setfx");

//Free effect by OSC
OSCdef(\killfx, {
	arg msg;
	var name;
	name = msg[1].asSymbol;
	q[name].free;
}, "/killfx");


//TRY IT FROM SC
n = NetAddr("localhost", 57120);
n.sendMsg("/mkfx", \s1, \gh, \gate, 1, \delayTime, 0.5, \decay, 0.4 ); //creates greyhole effect
n.sendMsg("/togfx", \s1, 0);  //toggles effect off
n.sendMsg("/togfx", \s1, 1); //toggles effect on
n.sendMsg("/killfx", \s1); //kills effect

//TRY IT FROM SOMEWHERE ELSE







