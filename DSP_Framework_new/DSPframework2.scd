
n = NetAddr("localhost", 57120);
n.sendMsg(\init);
( //SoundPetal performance
n.sendMsg(\mkfx, \pet1, \petalsOfResonance, \gate, 1, \inamp, 8.0, \ringL1, 13, \ringL2, 21, \fd, 113, \spread, 1.8, \bank2MidiOffset, 1.7, \firstPartial, 2, \obs,1, \re1, 7, \atk, 7);
n.sendMsg(\mkfx, \pet1, \petalsOfResonance, \gate, 1, \inamp, 8.0, \ringL1, 13, \ringL2, 21, \fund, 80, \spread, 0.47, \bank2MidiOffset, 0.83, \firstPartial, 1, \obs,1, \re1, 7, \atk, 7);
)
n.sendMsg(\togfx, \pet1, 0); n.sendMsg(\togfx, \pet2, 0);
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

			///////////////////////////////////////
			////                              /////
			////    \petalsOfResonance        /////
			////                              /////
			///////////////////////////////////////
			SynthDef("petalsOfResonance", {
				arg ibs=0, obs=0, atk = 0.01, decay=0, sus=1, rel=0.1, crv = -2, gate=0, kbs, masteramp= -6, inamp=1.0, firstPartial=2, bank2MidiOffset=0.25, spread=0.33, ringL1=7.75, ringL2=9.5;
				var	pAmp, partialTunedA, partialTunedB, output, rms, outArrayA, outArrayA1, outArrayA2, outArray, ltdOutput, masterEnv, finalOut,
				p1a, p2a, p3a, p4a, p5a, p6a, p7a, p8a, p9a, p10a, p11a, p12a, p13a,
				p1b, p2b, p3b, p4b, p5b, p6b, p7b, p8b, p9b, p10b, p11b, p12b, p13b,
				resA1, resA2, resA3, resA4, resA5, resA6, resA7, resA8, resA9, resA10, resA11, resA12, resA13,
				resB1, resB2, resB3, resB4, resB5, resB6, resB7, resB8, resB9, resB10, resB11, resB12, resB13,
				env, input, fund;
				fund = \fd.kr(100, 8.1);

				pAmp = -40.dbamp;

				//Two functions to create two sets of partials
				partialTunedA = 	{
					arg partialNum;
					var freq, freqMidi, tuner, freqTunedMidi, freqTuned;
					//firstPartial allows you to start the series at a higher partial than the fund
					//the fund and spread work together (maybe redundantly)
					//to determine the space between each partial
					freq = fund *( firstPartial + (spread*partialNum) );
					freqMidi = freq.cpsmidi;
					//constantly shifting tuner for each partial
					//so the sound is constantly shifting
					tuner = SinOsc.kr(rrand(0.07, 0.013), 0, 0.5);
					freqTunedMidi = freqMidi + tuner;
					freqTuned = freqTunedMidi.midicps;
				};

				partialTunedB = 	{
					arg partialNum;
					var freq, freqMidi, tuner, freqTunedMidi, freqTuned;
					freq = fund *( firstPartial + (spread*partialNum) );
					freqMidi = freq.cpsmidi;
					tuner = SinOsc.kr(rrand(0.07, 0.013), 0, 0.5);
					freqTunedMidi = freqMidi + tuner + bank2MidiOffset;
					freqTuned = freqTunedMidi.midicps;
				};

				p1a= partialTunedA.value(0);
				p2a= partialTunedA.value(1);
				p3a= partialTunedA.value(2);
				p4a= partialTunedA.value(3);
				p5a= partialTunedA.value(4);
				p6a= partialTunedA.value(5);
				p7a= partialTunedA.value(6);
				p8a= partialTunedA.value(7);
				p9a= partialTunedA.value(8);
				p10a= partialTunedA.value(9);
				p11a= partialTunedA.value(10);
				p12a= partialTunedA.value(11);
				p13a= partialTunedA.value(12);

				p1b= partialTunedB.value(0);
				p2b= partialTunedB.value(1);
				p3b= partialTunedB.value(2);
				p4b= partialTunedB.value(3);
				p5b= partialTunedB.value(4);
				p6b= partialTunedB.value(5);
				p7b= partialTunedB.value(6);
				p8b= partialTunedB.value(7);
				p9b= partialTunedB.value(8);
				p10b= partialTunedB.value(9);
				p11b= partialTunedB.value(10);
				p12b= partialTunedB.value(11);
				p13b= partialTunedB.value(12);

				env = EnvGen.ar( Env.adsr(atk, decay, sus, rel, curve:crv), gate );
				input = SoundIn.ar(ibs);
				input =  input * inamp * env;

				//Form 13 resonators for each bank/spectrum
				resA1 = DynKlank.ar(`[[p1a], nil, [rrand(ringL1, ringL2)]], input);
				resA2 = DynKlank.ar(`[[p2a], nil, [rrand(ringL1, ringL2)]], input);
				resA3 = DynKlank.ar(`[[p3a], nil, [rrand(ringL1, ringL2)]], input);
				resA4 = DynKlank.ar(`[[p4a], nil, [rrand(ringL1, ringL2)]], input);
				resA5 = DynKlank.ar(`[[p5a], nil, [rrand(ringL1, ringL2)]], input);
				resA6 = DynKlank.ar(`[[p6a], nil, [rrand(ringL1, ringL2)]], input);
				resA7 = DynKlank.ar(`[[p7a], nil, [rrand(ringL1, ringL2)]], input);
				resA8 = DynKlank.ar(`[[p8a], nil, [rrand(ringL1, ringL2)]], input);
				resA9 = DynKlank.ar(`[[p9a], nil, [rrand(ringL1, ringL2)]], input);
				resA10 = DynKlank.ar(`[[p10a], nil, [rrand(ringL1, ringL2)]], input);
				resA11 = DynKlank.ar(`[[p11a], nil, [rrand(ringL1, ringL2)]], input);
				resA12 = DynKlank.ar(`[[p12a], nil, [rrand(ringL1, ringL2)]], input);
				resA13 = DynKlank.ar(`[[p13a], nil, [rrand(ringL1, ringL2)]], input);

				resB1 = DynKlank.ar(`[[p1b], nil, [rrand(ringL1, ringL2)]], input);
				resB2 = DynKlank.ar(`[[p2b], nil, [rrand(ringL1, ringL2)]], input);
				resB3 = DynKlank.ar(`[[p3b], nil, [rrand(ringL1, ringL2)]], input);
				resB4 = DynKlank.ar(`[[p4b], nil, [rrand(ringL1, ringL2)]], input);
				resB5 = DynKlank.ar(`[[p5b], nil, [rrand(ringL1, ringL2)]], input);
				resB6 = DynKlank.ar(`[[p6b], nil, [rrand(ringL1, ringL2)]], input);
				resB7 = DynKlank.ar(`[[p7b], nil, [rrand(ringL1, ringL2)]], input);
				resB8 = DynKlank.ar(`[[p8b], nil, [rrand(ringL1, ringL2)]], input);
				resB9 = DynKlank.ar(`[[p9b], nil, [rrand(ringL1, ringL2)]], input);
				resB10 = DynKlank.ar(`[[p10b], nil, [rrand(ringL1, ringL2)]], input);
				resB11 = DynKlank.ar(`[[p11b], nil, [rrand(ringL1, ringL2)]], input);
				resB12 = DynKlank.ar(`[[p12b], nil, [rrand(ringL1, ringL2)]], input);
				resB13 = DynKlank.ar(`[[p13b], nil, [rrand(ringL1, ringL2)]], input);

				//Make an array of resonators and scramble them up
				outArrayA = [ resA1*pAmp, resA2*pAmp, resA3*pAmp, resA4*pAmp, resA5*pAmp, resA6*pAmp, resA7*pAmp, resA8*pAmp, resA9*pAmp, resA10*pAmp,
					resA11*pAmp, resA12*pAmp, resA13*pAmp, resB1*pAmp, resB2*pAmp, resB3*pAmp, resB4*pAmp, resB5*pAmp, resB6*pAmp, resB7*pAmp,
					resB8*pAmp, resB9*pAmp, resB10*pAmp, resB11*pAmp, resB12*pAmp, resB13*pAmp ].scramble;

				//For Stereo or Multichannel
				//outArrayA1 = outArrayA.copyRange(0, (outArrayA.size/2).asInteger);
				//outArrayA2 = outArrayA.copyRange((outArrayA.size/2).asInteger, outArray.size);
				//outArrayA1 = Mix.ar(outArrayA1);
				//outArrayA2 = Mix.ar(outArrayA2);

				//Mixes resonators to a mono channel
				outArrayA = Mix.ar(outArrayA);

				ltdOutput = Limiter.ar(outArrayA, 0.98, 0.01);
				ltdOutput = ltdOutput*masteramp.dbamp;

				rms = Amplitude.kr(ltdOutput).ampdb.linlin(-80.0, 0.0, 0.0, 1.0);
				Out.kr(kbs, rms); //send rms amplitude measure to a control bus

				Out.ar(obs, ltdOutput);

				},
				metadata: (
					specs: (
						masteramp: ControlSpec(-120.0, 18, \lin, default: -6.0, units: "db"),
						inamp: ControlSpec(-120.0, 18, \lin, default: 0.0, units: "db"),
						fund: ControlSpec(20, 20000, \exp, 0, 440, units: " Hz"),
						firstPartial: ControlSpec(0, 99, \lin, default: 0, units: "partial"),
						bank2MidiOffset: ControlSpec(-36.0, 36.0, \lin, default: 0, units: "midioffset"),
						spread: ControlSpec(0, 12, \lin, default: 1, units: "spread"),
						ringL1: ControlSpec(0.1, 49, \lin, default: 5, units: "seconds"),
						ringL2: ControlSpec(0.1, 49, \lin, default: 9, units: "seconds")
					)
				)
			).add;


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
				name = msg[1].asSymbol;
				if( dict.includesKey(name), {
					args_vals = msg.copyRange(2, msg.size-1);
					args_vals.do{|it, ix| if(ix.even, {args_vals[ix]=it.asSymbol}, {args_vals[ix]=it.asFloat})};
					args_vals.do{|it ix| if( ix.odd,{ dict[name].set(args_vals[ix-1], it) })};
				});
				args_vals.postln;
			}, "/setfx");

			//Free effect by OSC
			OSCdef(\killfx, {
				arg msg;
				var name;
				name = msg[1].asSymbol;
				dict[name].free;
			}, "/killfx");

			//OSC def for Convolution Reverb
			OSCdef(\mkireverb,{
				arg msg;
				var name, irnum;
				name = msg[1].asSymbol;
				irnum = msg[2].asInteger;

				fork{
					SynthDef(\convrev_live, {
						arg ibs=0, obs=0, amp=1, atk = 0.01, decay=0, sus=1, rel=0.1, crv = -2, gate=0, sourcegain=1;
						var source, dsp, env;
						env = EnvGen.ar( Env.adsr(atk, decay, sus, rel, curve:crv), gate );
						source = SoundIn.ar(ibs);
						dsp = ~irconvs[irnum].ar(source*sourcegain, leak: 0.1);
						Out.ar(obs, dsp*amp*env);
					}).add;

					0.01.wait;

					dict[name] = Synth(\convrev_live, [\gate, 1]);
				}
			}, "/mkireverb");

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


//way to send multiple messages




n.sendMsg(\mkireverb, \ir2, 1);
n.sendMsg(\killfx, \ir2)
n.sendMsg(\setfx, \ir2, \sourcegain, 7.0);
n.sendMsg(\mkfx, \pet1, \petalsOfResonance, \gate, 1, \inamp, 8.0, \ringL1, 13, \ringL2, 21, \fd, 113, \spread, 1.8, \bank2MidiOffset, 1.7, \firstPartial, 2, \obs,1, \re1, 7);
n.sendMsg(\setfx, \pet1, \inamp, 8.0, \ringL1, 13, \ringL2, 21, \fd, 113, \spread, 1.8, \bank2MidiOffset, 1.7, \firstPartial, 2, \obs,1, \re1, 7);
n.sendMsg(\mkfx, \pet2, \petalsOfResonance, \gate, 1);
n.sendMsg(\setfx, \pet2, \inamp, 8.0, \ringL1, 13, \ringL2, 21, \fund, 80, \spread, 0.47, \bank2MidiOffset, 0.83, \firstPartial, 1, \obs,1, \re1, 7);
n.sendMsg(\togfx, \pet1, 0); n.sendMsg(\togfx, \pet2, 0);
n.sendMsg(\togfx, \pet1, 1); n.sendMsg(\togfx, \pet2, 1);

