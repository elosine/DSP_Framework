


(
//Add everything to a dictionary
q = ();
/////////////////////////////////////////
//////  SYNTHDEFS ///////////////////////
/////////////////////////////////////////

q[\synthdefs] = ();
// q[\synthdefs] is a dictionary
// Each entry contains an array indexed by the synthdef name
// Item 0 is the actual synthdef
// Item 1 is a dictionary indexed by each of the argument names of the synthdef
// q[\addsyndef] is a function that uses SynthDesc to grab the argument names after the synthdef is added
// Each item in the argument dictionary is another array with 3 items defining the spec of the argument
// Item 0 is lo, item 1 is hi and item 2 is warp - can be \lin, \exp, or a number for curve

//function to pull control names and add to dictionary
q[\addsyndef] = {
	arg syndefname;
	var get, ctlnames;
	syndefname = syndefname.asSymbol;
	get = SynthDesc.read(SynthDef.synthDefDir ++ syndefname++".scsyndef");
	ctlnames = get.[syndefname.asSymbol].controlNames;
	ctlnames.do{ |it, ix| q[\synthdefs][syndefname][1][it] = Array.newClear(3) }
};

//Function: to add spec to args
q[\addsynthdefargsSpec] = {
	arg syndefname, argname, lo, hi, warp;
	q[\synthdefs][syndefname][1][argname][0] = lo;
	q[\synthdefs][syndefname][1][argname][1] = hi;
	q[\synthdefs][syndefname][1][argname][2] = warp;
};

//OSCdefs to poll and set and get synthdef arg specs:
//Poll synthdef args
//Send me: name of synthdef as msg[1]
q[\pollsyndefargs] = OSCdef(\pollsyndefargs,{
	arg msg, time, addr;
	var mailtoadr, args, argsStr="";
	mailtoadr = addr;
	args = q[\synthdefs][msg[1].asSymbol][1].keys.asArray;
	args.do{|it, ix| argsStr = if(ix==0,{argsStr=it},{argsStr=argsStr++"#"++it})};
	argsStr.postln;
	mailtoadr.sendMsg("/sdargs", argsStr);
}, "/getsdargs");

//Set SynthDef arg spec
//Send me: name of synthdef as msg[1]
//arg name as msg[2]
//lo, hi, warp as msg[3-5]
q[\setsdargspec] = OSCdef(\setsdargspec,{|msg|
	q[\addsynthdefargsSpec].value(msg[1].asSymbol, msg[2].asSymbol, msg[3].asFloat, msg[3].asFloat, msg[5])
}, "/setsdargspec");

//Get SynthDef arg spec
//Send me: name of synthdef as msg[1]
//arg name as msg[2]
q[\getsdargspec] = OSCdef(\getsdargspec,{
	arg msg, time, addr;
	var mailtoadr, args, argsStr="";
	mailtoadr = addr;
	args = q[\synthdefs][msg[1].asSymbol][1][msg[2].asSymbol];
	args.postln;
	args.do{|it, ix| argsStr = if(ix==0,{argsStr=it.asString},{argsStr=argsStr++"#"++it.asString})};
	argsStr.postln;
	mailtoadr.sendMsg("/sdargs", argsStr)
}, "/getsdargspec");

  //////////////////////
 //////SYNTHDEFS://////
//////////////////////

    ///////////////////////////////////////
   ////                              /////
  ////         \audioin_mono        /////
 ////                              /////
///////////////////////////////////////

//SynthDef to handle sound in and put it to a audio bus
//put in dictionary
q[\synthdefs][\audioin_mono] = [
	SynthDef( \audioin_mono, {
		arg ibs, obs, kbs, amp=1;
		var in, rms;
		in = SoundIn.ar(ibs)*amp;
		rms = Amplitude.kr(in).ampdb.linlin(-40.0, 0.0, 0.0, 1.0);
		Out.kr(kbs, rms); //send rms amplitude measure to a control bus
		Out.ar(obs, in)
	}).load,
	(), //Empty Dictionary to contain any Arg Specs
	() //Empty Dictionary for presets
];

//run function to add control names
q[\addsyndef].value(\audioin_mono);
//Run function(s) to add any specs to arguments
q[\addsynthdefargsSpec].value(\audioin_mono, \amp, 0.0, 1.0, \lin);

 /////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////
   ////                              /////
  ////         \audioOut_mono       /////
 ////                              /////
///////////////////////////////////////

//SynthDefs to handle Sound-Out to soundcard
q[\synthdefs][\audioOut_mono] = [
	SynthDef( \audioOut_mono, {
		arg ibs, obs, kbs, amp=1;
		var in, rms;
		in = In.ar(ibs)*amp;
		rms = Amplitude.kr(in).ampdb.linlin(-40.0, 0.0, 0.0, 1.0);
		Out.kr(kbs, rms); //send rms amplitude measure to a control bus
		Out.ar(obs, in)
	}).load,
	(), //Empty Dictionary to contain any Arg Specs
	() //Empty Dictionary for presets
];

//run function to add control names
q[\addsyndef].value(\audioOut_mono);
//Run function(s) to add any specs to arguments
q[\addsynthdefargsSpec].value(\audioOut_mono, \amp, 0.0, 1.0, \lin);

 /////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////
   ////                              /////
  ////         \audioOut_stereo     /////
 ////                              /////
///////////////////////////////////////

//SynthDefs to handle Sound-Out to soundcard
q[\synthdefs][\audioOut_stereo] = [
	SynthDef( \audioOut_stereo, {
		arg ibs, obs, kbs, amp=1;
		var in, rms;
		in = In.ar([ibs, ibs+1])*amp;
		rms = Amplitude.kr(in).ampdb.linlin(-40.0, 0.0, 0.0, 1.0);
		Out.kr(kbs, rms); //send rms amplitude measure to a control bus
		Out.ar(obs, in)
	}).load,
	(), //Empty Dictionary to contain any Arg Specs
	() //Empty Dictionary for presets
];

//run function to add control names
q[\addsyndef].value(\audioOut_stereo);
//Run function(s) to add any specs to arguments
q[\addsynthdefargsSpec].value(\audioOut_stereo, \amp, 0.0, 1.0, \lin);

 /////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////
   ////                              /////
  ////         \sineWlfo            /////
 ////                              /////
///////////////////////////////////////

q[\synthdefs][\sineWlfo] = [
	SynthDef(\sineWlfo, {
		arg obs, rate=0, freqlo=300, freqhi=300, amp=1;
		var sig, lfo;
		lfo = SinOsc.kr(rate).range(freqlo, freqhi);
		sig = SinOsc.ar(lfo);
		Out.ar(obs, sig*amp);
	}).load,
	(), //Empty Dictionary to contain any Arg Specs
	//Dictionary of presets that I enter manually, for clarity and persistance:
	//Each preset entry is another dictionary containing all arg names
	// as keys with arg value as data
	(
		\default: (
			rate:0,
			freqlo:300.0,
			freqhi:300.0,
			amp:1
		)
	)
];

//run function to add control names
q[\addsyndef].value(\sineWlfo);
//Run function(s) to add any specs to arguments
q[\addsynthdefargsSpec].value(\sineWlfo, \amp, 0.0, 1.0, \lin);
q[\addsynthdefargsSpec].value(\sineWlfo, \rate, 0.0, 100.0, \lin);
q[\addsynthdefargsSpec].value(\sineWlfo, \freqlo, 20.0, 20000.0, \exp);
q[\addsynthdefargsSpec].value(\sineWlfo, \freqhi, 20.0, 20000.0, \exp);

 /////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

 /////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////
   ////                              /////
  ////         \noiseBurst          /////
 ////                              /////
///////////////////////////////////////

q[\synthdefs][\noiseBurst] = [
	SynthDef(\noiseBurst, {
		arg obs, rate=1.0, atk=0.03, decay=0.75, amp=1;
		var sig;
		sig = PinkNoise.ar(0.5) * Decay2.ar( Impulse.ar(rate), atk, decay );
		Out.ar(obs, sig*amp);
	}).load,
	(), //Empty Dictionary to contain any Arg Specs
	//Dictionary of presets that I enter manually, for clarity and persistance:
	//Each preset entry is another dictionary containing all arg names
	// as keys with arg value as data
	(
		\default: (
			rate:1.0,
			atk:0.03,
			decay:0.75,
			amp:1
		)
	)
];

//run function to add control names
q[\addsyndef].value(\noiseBurst);
//Run function(s) to add any specs to arguments
q[\addsynthdefargsSpec].value(\noiseBurst, \amp, 0.0, 1.0, \lin);
q[\addsynthdefargsSpec].value(\noiseBurst, \rate, 0.05, 99.0, \lin);
q[\addsynthdefargsSpec].value(\noiseBurst, \atk, 0.0001, 5.0, \lin);
q[\addsynthdefargsSpec].value(\noiseBurst, \decay, 0.05, 13.0, \lin);

 /////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////
   ////                              /////
  ////         \ringmod             /////
 ////                              /////
///////////////////////////////////////

//SynthDefs to handle Sound-Out to soundcard
q[\synthdefs][\ringmod] = [
	SynthDef(\ringmod, {
		arg obs, kbs, carbus, modbus, amp=1;
		var rm, rms;
		rm = DiodeRingMod.ar(In.ar(carbus), In.ar(modbus));
		rms = Amplitude.kr(rm).ampdb.linlin(-40.0, 0.0, 0.0, 1.0);
		Out.kr(kbs, rms); //send rms amplitude measure to a control bus
		Out.ar(obs, rm*amp);
	}).load,
	(), //Empty Dictionary to contain any Arg Specs
	() //Empty Dictionary to contain arg presets
];

//run function to add control names
q[\addsyndef].value(\ringmod);
//Run function(s) to add any specs to arguments
q[\addsynthdefargsSpec].value(\ringmod, \amp, 0.0, 1.0, \lin);

 /////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////
   ////                              /////
  ////    \petalsOfResonance        /////
 ////                              /////
///////////////////////////////////////

q[\synthdefs][\petalsOfResonance] = [

	SynthDef("petalsOfResonance", {

		arg masteramp=0.5, inamp=1.0, ibs=0, obs=0, fund=200, firstPartial=2, bank2MidiOffset=0.25, spread=0.33, ringL1=7.75, ringL2=9.5, inputLen=1, trig=0;
		var	pAmp, partialTunedA, partialTunedB, input, output, outArrayA, outArrayA1, outArrayA2, outArray, inenv, ltdOutput, masterEnv, finalOut,
		p1a, p2a, p3a, p4a, p5a, p6a, p7a, p8a, p9a, p10a, p11a, p12a, p13a,
		p1b, p2b, p3b, p4b, p5b, p6b, p7b, p8b, p9b, p10b, p11b, p12b, p13b,
		resA1, resA2, resA3, resA4, resA5, resA6, resA7, resA8, resA9, resA10, resA11, resA12, resA13,
		resB1, resB2, resB3, resB4, resB5, resB6, resB7, resB8, resB9, resB10, resB11, resB12, resB13;

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

		input = In.ar(ibs);
		inenv = EnvGen.ar( Env.perc(0.02, inputLen, 1.0, -1), trig);
		input =  input * inamp * inenv;
		//input = PinkNoise.ar(0.5) * Decay2.ar(Impulse.ar(0.15), 0.15, 0.75);

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

		Out.ar(obs, ltdOutput*masteramp);

		}, [0.069]
	).load,

	(),
	//Dictionary of presets that I enter manually, for clarity and persistance:
	//Each preset entry is another dictionary containing all arg names
	// as keys with arg value as data
	(
		\default: (
			masteramp:0.5,
			inamp:1.0,
			fund:200,
			firstPartial:2,
			bank2MidiOffset:0.25,
			spread:0.33,
			ringL1:7.75,
			ringL2:9.5,
			inputLen:1,
			trig:0
		)
	)
];

q[\addsyndef].value(\petalsOfResonance);

q[\addsynthdefargsSpec].value(\petalsOfResonance, \masteramp, 0.0, 1.0, \lin);
q[\addsynthdefargsSpec].value(\petalsOfResonance, \inamp, 0.0, 7.0, \lin);
q[\addsynthdefargsSpec].value(\petalsOfResonance, \fund, 20.0, 20000.0, \exp);
q[\addsynthdefargsSpec].value(\petalsOfResonance, \firstPartial, 1.0, 99.0, \lin); //first partial to make a filter, eg. if fund is 50 and firstPartial is 5, the filters will be at 250, 300, 350, etc.
q[\addsynthdefargsSpec].value(\petalsOfResonance, \bank2MidiOffset, -36.0, 36.0, \lin); //tuning offset for second bank of resonators in midi note values
q[\addsynthdefargsSpec].value(\petalsOfResonance, \spread, 0.0, 3.0, \lin); //?
q[\addsynthdefargsSpec].value(\petalsOfResonance, \ringL1, 0.0, 60.0, \lin); //lower end of ring range in seconds. synthdef will choose randomly between ringL1 and ringL2
q[\addsynthdefargsSpec].value(\petalsOfResonance, \ringL2, 0.0, 60.0, \lin); //higher end of ring range in seconds.
q[\addsynthdefargsSpec].value(\petalsOfResonance, \inputLen, 0.0, 60.0, \lin); // controls duration of envelope on input
q[\addsynthdefargsSpec].value(\petalsOfResonance, \trig, 0.0, 1.0, \lin); //trigger for input envelope

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////   END SYNTH DEFS    ///////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
)

//Create 3 Groups: ins from soundcard, DSP,  and outs to soundcard
q[\insgrp] = Group.new(s);
q[\dspgrp1] = Group.after(q[\insgrp]);
q[\dspgrp2] = Group.after(q[\insgrp]);
q[\dspgrp3] = Group.after(q[\insgrp]);
q[\dspgrp4] = Group.after(q[\insgrp]);
q[\dspgrp5] = Group.after(q[\insgrp]);
q[\dspgrp6] = Group.after(q[\insgrp]);
q[\dspgrp7] = Group.after(q[\insgrp]);
q[\dspgrp8] = Group.after(q[\insgrp]);
q[\dspgrp9] = Group.after(q[\insgrp]);
q[\dspgrp10] = Group.after(q[\insgrp]);
q[\outsgrp] = Group.after(q[\dspgrp]);


/////////////////////////////////////////////////////////
////  AUDIO IN //////////////////////////////////////////
/////////////////////////////////////////////////////////

//OSCdef: \mkaudioindef
//msg[1]= Dictonary name for Sound-In conglomerate
//msg[2] = Sound in Channel
//1) Adds an array to dictionary under the name in msg[1]
//2) Create a private audio bus to send the audio in to in slot [0]
//3) Create a control bus to send the amplitude measurement/metering to in slot [1]
//4) Create a audio-in synth in slot [2]

q[\mkaudioindef] = OSCdef(\mkaudioin,{ |msg|
	var obs, kbs;
	obs = Bus.audio(s, 1); //private audio bus for sound in
	kbs = Bus.control(s, 1); //control bus for amplitude measurement/metering
	q[msg[1].asSymbol] = [
		obs,
		kbs,
		Synth(\audioin_mono, [\ibs, msg[2].asInteger, \obs, obs, \kbs, kbs], q[\insgrp]), //synth to take audio in and route to private audio bus
	]
}, "/mkaudioin");

/////////////////////////////////////////////////////////
////  AUDIO OUT /////////////////////////////////////////
/////////////////////////////////////////////////////////

//OSCdef: \mkaudioOutdef
//msg[1]= Dictonary name for Sound-Out conglomerate
//msg[2] = Sound Out Channel
//1) Adds an array to dictionary under the name in msg[1]
//3) Create a control bus to send the amplitude measurement/metering to in slot [0]
//4) Create a Audio-Out synth in slot [2]

//Def for mono out
q[\mkaudioOutdef_m] = OSCdef(\mkaudioOut_m,{ |msg|
	var kbs;
	kbs = Bus.control(s, 1); //control bus for amplitude measurement/metering
	q[msg[1].asSymbol] = [
		kbs,
		"placeholder",
		Synth(\audioOut_mono, [\obs, msg[2].asInteger, \kbs, kbs], q[\outsgrp]),
	]
}, "/mkaudioOut_m");

//Def for stereo out
q[\mkaudioOutdef_s] = OSCdef(\mkaudioOut_s,{ |msg|
	var kbs;
	kbs = Bus.control(s, 2); //control bus for amplitude measurement/metering
	q[msg[1].asSymbol] = [
		kbs,
		"placeholder",
		Synth(\audioOut_stereo, [\obs, msg[2].asInteger, \kbs, kbs], q[\outsgrp]),
	]
}, "/mkaudioOut_s");

//OSCdef: /routeout - to choose a private audio bus to route out to soundcard
//msg[1] = name of in conglermate to send out
//msg[2] = name of out conglermate
//msg[3] = out channel number
q[\routeoutdef] = OSCdef(\routeout, { |msg| q[msg[2].asSymbol][2].set(\ibs, q[msg[1].asSymbol][0], \obs, msg[3].asInteger)}, "/routeout");

/////////////////////////////////////////////////////////
////  SET AMP ///////////////////////////////////////////
/////////////////////////////////////////////////////////
//msg[1] = dictionary name to set
//msg[2] = amp value
//synth should always be [2] in dictionary array
q[\setampdef] = OSCdef(\setamp, {|msg| q[msg[1].asSymbol][2].set(\amp, msg[2].asFloat)}, "/setamp");

/////////////////////////////////////////////////////////
////  SIGNALS & DSP ////
/////////////////////////////////////////////////////////
//For Each synthdef make dictionary entry under synthdef name
//an array with slot [0]: synthdef
//and slot [1] an array with:
//[names of all arguments...]

//MAKE SIGNAL
//Add array to dictionary under name msg[1]:
//0) audio out bus
//1) place holder (no inbus)
//2) synth
//msg[1] dictionary name
//msg[2] synth name
//msg[3].. list of args-value pairs
q[\mksigdef] = OSCdef(\mksig, {|msg|
	var argsvals = msg.copyRange(3, msg.size);
	var obs = Bus.audio(s);
	argsvals.do{|it, ix| if(ix.even, {argsvals[ix]=it.asSymbol}, {argsvals[ix]=it.asFloat})};
	argsvals = argsvals++[\obs, obs];
	q[msg[1].asSymbol] = [
		obs,
		"placeholder",
		Synth(msg[2].asSymbol, argsvals, q[\insgroup]);
	];
}, "/mksig");

//MAKE DSP
//Add array to dictionary under name msg[1]:
//0) audio out bus
//1) control bus
//2) synth
//msg[1] dictionary name
//msg[2] synth name
//msg[3] group name
//msg[4].. list of args-value pairs
q[\mkdspdef_m] = OSCdef(\mkdsp_m, {|msg|
	var argsvals = msg.copyRange(4, msg.size);
	var obs = Bus.audio(s);
	var kbs = Bus.control(s);
	argsvals.do{|it, ix| if(ix.even, {argsvals[ix]=it.asSymbol}, {argsvals[ix]=it.asFloat})};
	argsvals = argsvals++[\obs, obs, \kbs, kbs];
	q[msg[1].asSymbol] = [
		obs,
		kbs,
		Synth(msg[2].asSymbol, argsvals, q[msg[3].asSymbol]);
	];
}, "/mkdsp_m");
//Set Synth Def
//msg[1] = dictionary name
//msg[2...] = arg-val pairs
q[\setsynthdef] = OSCdef(\setsynth, {|msg|
	var argsvals = msg.copyRange(2, msg.size);
	argsvals.do{|it, ix| if(ix>0, {q[msg[1].asSymbol][2].set(argsvals[ix-1].asSymbol, it.asFloat) })};
}, "/setsynth");
//Set RingMod Def
//msg[1] = dictionary name
//msg[2] = dict name for carrier synth
//msg[3] = dict name for mod synth
q[\setrmdef] = OSCdef(\setrm, {|msg|
	q[msg[1].asSymbol][2].set(\carbus, q[msg[2].asSymbol][0], \modbus, q[msg[3].asSymbol][0])
}, "/setrm");

)

//PERSISTANCE
Archive.global.put(\DSPframework, q);

//NEXT:

// Sig adder & DSP adder
// Way to store and recall synthdef specific arg presets with persistance
// Make a step-by-step osc msg protocol and what it does:
//// sig - dsp - out
//// live in - dsp - out
// Prototype in Processing
// Fix/Tighten Up any Issues
// Test with presets and make new ones
// Auto-Gui in Processing???


a = NetAddr("localhost", 57120);
a.sendMsg("/mkaudioin", "mic1", 0);
a.sendMsg("/mkaudioOut_m", "out1", 0);
a.sendMsg("/routeout", "mic1", "out1", 1);
a.sendMsg("/setamp", "out1", 0);
a.sendMsg("/mksig", "sine1", "sineWlfo", "rate", 0.1, "freqlo", 200, "freqhi", 1000);
a.sendMsg("/setsynth", "sine1", "amp", 0);
a.sendMsg("/routeout", "sine1", "out1", 1);
a.sendMsg("/setsynth", "sine1", "rate", 0.1, "freqhi", 350);
a.sendMsg("/mkdsp_m", "rm1", "ringmod", "dspgrp4");
a.sendMsg("/setrm", "rm1", "mic1", "sine1");
a.sendMsg("/routeout", "rm1", "out1", 1);
a.sendMsg("/setsynth", "sine1", "rate", 3.3, "freqlo", 10, "freqhi", 30);

//In synth Dictionary
//Creates an audio bus
//creates Monitoring to control bus
//creates control bus
//pull model processing or other will send an osc msg and get a response with controlbus val
//control amp
//add ringmod
//add to archive and make standalone
//easy way to add effects
//easy way to add controllers
//how to kill everything
//add all old effects
//kill synths and everything in an operator
//stereo dsp def
//way to map args to control busses and controlers
//more signals
//custom glitch noise ones
//adapt funky level meter
//make an impulse signal with the pink noise from convolution

//DO THIS WITH petals of resonance
//MAKE A FUNCTION THAT WILL STORE A SYNTHDEF WITH ITS ARGUMENTS AND RANGES AND SPEC
//////Add Specs when adding synth def as meta data with control spec
//Get arg names and specs and default value and store in dictionary


//CLEAN UP AND ADD SYNTHDEFS ONE AT A TIME, MAKE THIS DOCUMENT AN ARCHIVE OF SYNTHDEFS
//MAKE A TEST GUI

//set up control busses for each arg of each synth when instanciting them
//make dictionary of all oscdef addresses and their args and any callbacks

//Way of capturing nice synthdef settings
//Make running Appendix: All SynthDef Names, All OSC addresses, All Dictionary Entries
/*
DICTIONARY ENTRIES:

q[\synthdefs] = ();
// q[\synthdefs] is a dictionary
// Each entry contains an array indexed by the synthdef name
// Item 0 is the actual synthdef
// Item 1 is a dictionary indexed by each of the argument names of the synthdef
// q[\addsyndef] is a function that uses SynthDesc to grab the argument names after the synthdef is added
// Each item in the argument dictionary is another array with 3 items defining the spec of the argument
// Item 0 is lo, item 1 is hi and item 2 is warp - can be \lin, \exp, or a number for curve

q[\addsyndef]
//function to pull control names and add to dictionary

q[\addsynthdefargsSpec]
//Function: to add spec to args

q[\pollsyndefargs]
//OSCdef to poll synthdef argss - \pollsyndefargs
"/getsdargs"
//Send me: name of synthdef as msg[1]

q[\setsdargspec]
//OSCdef to Set SynthDef arg spec - \setsdargspec
"/setsdargspec"
//Send me: name of synthdef as msg[1]
//arg name as msg[2]
//lo, hi, warp as msg[3-5]

q[\getsdargspec]
//OSCdef to Get SynthDef arg spec - \getsdargspec
"/getsdargspec"
//Send me: name of synthdef as msg[1]
//arg name as msg[2]

q[\mkaudioindef]
//OSCdef to set up an audio in - \mkaudioin
"/mkaudioin"
//msg[1]= Dictonary name for Sound-In conglomerate
//msg[2] = Sound in Channel
//1) Adds an array to dictionary under the name in msg[1]
//2) Create a private audio bus to send the audio in to in slot [0]
//3) Create a control bus to send the amplitude measurement/metering to in slot [1]
//4) Create a audio-in synth in slot [2]

q[\mkaudioOutdef_m]
//OSCdef to make an mono audio out - \mkaudioOutdef_m
"/mkaudioOut_m"
//msg[1]= Dictonary name for Sound-Out conglomerate
//msg[2] = Sound Out Channel
//1) Adds an array to dictionary under the name in msg[1]
//3) Create a control bus to send the amplitude measurement/metering to in slot [0]
//4) Create a Audio-Out synth in slot [2]

q[\mkaudioOutdef_s]
//OSCdef to make an stereo audio out - \mkaudioOutdef_s
"/mkaudioOut_s"
//msg[1]= Dictonary name for Sound-Out conglomerate
//msg[2] = Sound Out Channel
//1) Adds an array to dictionary under the name in msg[1]
//3) Create a control bus to send the amplitude measurement/metering to in slot [0]
//4) Create a Audio-Out synth in slot [2]

q[\routeoutdef]
//OSCdef to choose a private audio bus to route out to soundcard - /routeout
"/routeout"
//msg[1] = name of in conglermate to send out
//msg[2] = name of out conglermate
//msg[3] = out channel number

q[\insgrp] = Group.new(s);
q[\dspgrp1] = Group.after(q[\insgrp]);
q[\dspgrp2] = Group.after(q[\insgrp]);
q[\dspgrp3] = Group.after(q[\insgrp]);
q[\dspgrp4] = Group.after(q[\insgrp]);
q[\dspgrp5] = Group.after(q[\insgrp]);
q[\dspgrp6] = Group.after(q[\insgrp]);
q[\dspgrp7] = Group.after(q[\insgrp]);
q[\dspgrp8] = Group.after(q[\insgrp]);
q[\dspgrp9] = Group.after(q[\insgrp]);
q[\dspgrp10] = Group.after(q[\insgrp]);
q[\outsgrp] = Group.after(q[\dspgrp]);


SYNTHDEFS:
\audioin_mono
\audioOut_mono
\audioOut_stereo
\petalsOfResonance
\sineWlfo
\ringmod
*/
