(
var init, exit;
//Initialization Sequence
init = {
	var dict, impulses, irpaths;

	//FOR CONVOLUTION REVERB
	irpaths = PathName.new(String.scDir +/+ "sounds/impulses/").files;
	~irconvs = Array.newClear(irpaths.size);

	s.options.memSize = 245760; //increases server memory

	s.waitForBoot{
		fork{
			//////////////////////////////////////
			1.postln;
			//////////////////////////////////////

			//Convolution Reverb
			irpaths.do{|it ix| ~irconvs[ix] = EZConv(it.fullPath); it.fullPath.postln};

			0.5.wait;

			//////////////////////////////////////
			2.postln;
			//////////////////////////////////////

			//INSPECT Convolution Reverb
			~irconvs.do{|it| it.numChannels; it.irSpectrum};
			0.5.wait;

			//////////////////////////////////////
			3.postln;
			//////////////////////////////////////

			//Add SynthDefs
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

			SynthDef(\convrev_live, {
				arg ibs=0, obs=0, amp=1, atk = 0.01, decay=0, sus=1, rel=0.1, crv = -2, gate=0, sourcegain=1, irnum=0;
				var source, dsp, env;
				env = EnvGen.ar( Env.adsr(atk, decay, sus, rel, curve:crv), gate );
				source = SoundIn.ar(ibs);
				dsp = ~irconvs[0].ar(source*sourcegain, leak: 0.1);
				Out.ar(obs, dsp*amp*env);
			}).add;

			0.1.wait;

			//////////////////////////////////////
			4.postln;
			//////////////////////////////////////
			dict = ();
			//Make effect by OSC
			OSCdef(\mkfx, {
				arg msg;
				var name, sdname, args_vals;
				name = msg[1].asSymbol;
				sdname = msg[2].asSymbol;
				args_vals = msg.copyRange(3, msg.size-1);
				args_vals.do{|it, ix| if(ix.even, {args_vals[ix]=it.asSymbol}, {args_vals[ix]=it.asFloat})};
				dict[name] = Synth(sdname, args_vals);
			}, "/mkfx");

			//Toggle effect on and off
			OSCdef(\togfx, {
				arg msg;
				var name, tog;
				tog = msg[2].asInteger;
				name = msg[1].asSymbol;
				dict[name].set(\gate, tog);
			}, "/togfx");

			//Set FX Arguments
			OSCdef(\setfx, {
				arg msg;
				var name, args_vals;
				if( dict.includesKey(name), {
					args_vals = msg.copyRange(1, msg.size-1);
					args_vals.do{|it, ix| if(ix.even, {args_vals[ix]=it.asSymbol}, {args_vals[ix]=it.asFloat})};
					dict[name].set(args_vals);
				});
			}, "/setfx");

			//Free effect by OSC
			OSCdef(\killfx, {
				arg msg;
				var name;
				name = msg[1].asSymbol;
				dict[name].free;
			}, "/killfx");

			//OSC def for Convolution Reverb
			O

			//////////////////////////////////////
			5.postln;
			//////////////////////////////////////
			//GUI
			{

			}.defer
		}
	};
	s.meter;

	//Exit Sequence
	exit = {
		fork{
			1.postln;

			0.1.wait;

			2.postln;

			0.1.wait;

			3.postln;

			0.1.wait;

		}
	};

};
//Initialization OSCified
//// Using this, you can initialize remotely
OSCdef( \init, {init.value}, "/init" );
//Exit OSCified
//// Using this, you can exit remotely
OSCdef( \exit, {exit.value}, "/exit" );

)

~init.value
n = NetAddr("localhost", 57120);
n.sendMsg(\init);

//PLAY
a = Synth(\convrev_live, [\gate, 1]);
a.set(\gain, 1.0, \sourcegain, 2, \spd, -0.1);
a.free;

//RESET YOUR IMPULSE
~cr.free; ~cr=nil;
(
//IR PATH
~irpath = "/Users/jyang/Dropbox/supercollider/Concepts and Utilities/ConvolutionReverb/HamiltonMausoleum_stereo.wav";
~cr = EZConv(~irpath);
)
(
//INSPECT
~cr.numChannels;
~cr.irSpectrum;
)

s.meter


