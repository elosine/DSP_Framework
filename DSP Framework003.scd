/*
CONTINUE ON WITH REVAMP
USE SC TO MAKE AUTOGUIS TO ADJUST SYNTHDEFS

*/



(
//Add everything to a dictionary
q = ();

   /////////////////////////////////////////////////
  //////////////  q[\synthdefs] ///////////////////
 /////////////////////////////////////////////////
q[\synthdefs] = ();
// q[\synthdefs] is a dictionary
// Each entry contains a dictionary indexed by the synthdef name

   /////////////////////////////////////////////////
  ///////////  q[\addsynthdefFunk] ////////////////
 /////////////////////////////////////////////////
//function to pull control names and add to dictionary
q[\addsynthdefFunk] = {
	arg syndefname;
	var get, ctlnames, specs, warp;
	syndefname = syndefname.asSymbol; //just a percausion probably redundant internally
	q[\synthdefs][syndefname] = ();
	//Use SynthDesc to make a dictionary of arg names - ctlnames
	get = SynthDesc.read(SynthDef.synthDefDir ++ syndefname++".scsyndef");
	ctlnames = get.[syndefname].controlNames;
	specs = get[syndefname].metadata[\specs];
	//store args in dictionary
	q[\synthdefs][syndefname][\args] = ctlnames; //Array of argument names
	//Create empty dictionaries to store synthdef values
	q[\synthdefs][syndefname][\defaults] = ();
	q[\synthdefs][syndefname][\specs] = ();
	q[\synthdefs][syndefname][\presets] = ();
	//uses controlNames to make a dictionary \defaults with argname/defaultvalue dictionaries
	get.[syndefname].controls.do{|it ix| q[\synthdefs][syndefname][\defaults][it.name]= it.defaultValue};
	//Creates a spec for each arg with dummy \lo, \hi, and \warp values

	specs.keys.asArray.do{ |it, ix|
		q[\synthdefs][syndefname][\specs][it] = (
			\min:specs[it].minval,
			\max:specs[it].minval,
			\warp:specs[it].warp,
			\step:specs[it].step,
			\default:specs[it].default,
			\units:specs[it].units
		);
	}

};

    ////////////////////////////////////////////////////////////
   /////////  q[\getsynthdefargsDef]
  /////////  OSCmsg: /getsdargs(synthdef name)
 /////////   Returns to Requester: /sdargs(single string of all args delimited by #)
/////////////////////////////////////////////////////////////
q[\getsynthdefargsDef] = OSCdef(\getsdargs,{
	arg msg, time, addr;
	var mailtoadr, args, argsStr="";
	mailtoadr = addr;
	args = q[\synthdefs][msg[1].asSymbol][\args];
	//Creates single string with the # as delimiter
	args.do{|it, ix| argsStr = if(ix==0,{argsStr=it},{argsStr=argsStr++"#"++it})};
	mailtoadr.sendMsg("/sdargs", argsStr);
}, "/getsdargs");

)
q[\addsynthdefFunk].value(\petalsOfResonance);
q[\synthdefs][\petalsOfResonance][\specs][\fund][\warp]
//RESUME HERE////// specs(get), args(get), defaults(get), presets(get/set)

     ///////////////////////////////////////////////////////////////////////////////////////////
    /////////  q[\getsynthdefargsDef]
   ////////////////////////////////////////////////////////////////////////////////////////////
  /////////  OSCmsg: /getsdargs(synthdef name)
 /////////   Returns to Requester: /sdargs(single string of all args delimited by #)
/////////////////////////////////////////////////////////////////////////////////////////////
q[\getsynthdefargsDef] = OSCdef(\getsdargs,{
	arg msg, time, addr;
	var mailtoadr, args, argsStr="";
	mailtoadr = addr;
	args = q[\synthdefs][msg[1].asSymbol][\args];
	//Creates single string with the # as delimiter
	args.do{|it, ix| argsStr = if(ix==0,{argsStr=it},{argsStr=argsStr++"#"++it})};
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
		rms = Amplitude.kr(in).ampdb.linlin(-80.0, 0.0, 0.0, 1.0);
		Out.kr(kbs, rms); //send rms amplitude measure to a control bus
		Out.ar(obs, in)
	}, metadata: (specs: (cutoff: \freq, volume: \amp))).add;).load,
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
		rms = Amplitude.kr(in).ampdb.linlin(-80.0, 0.0, 0.0, 1.0);
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
		rms = Amplitude.kr(in).ampdb.linlin(-80.0, 0.0, 0.0, 1.0);
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
		arg obs, kbs, rate=0, freqlo=300, freqhi=300, amp=1;
		var sig, lfo, rms;
		lfo = SinOsc.kr(rate).range(freqlo, freqhi);
		sig = SinOsc.ar(lfo);
		sig = sig*amp;
		rms = Amplitude.kr(sig).ampdb.linlin(-80.0, 0.0, 0.0, 1.0);
		Out.kr(kbs, rms); //send rms amplitude measure to a control bus
		Out.ar(obs, sig);
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
		arg obs, kbs, rate=1.0, atk=0.03, decay=0.75, amp=1;
		var sig, rms;
		sig = PinkNoise.ar(0.5) * Decay2.ar( Impulse.ar(rate), atk, decay );
		sig = sig*amp;
		rms = Amplitude.kr(sig).ampdb.linlin(-80.0, 0.0, 0.0, 1.0);
		Out.kr(kbs, rms); //send rms amplitude measure to a control bus
		Out.ar(obs, sig);
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
		rms = Amplitude.kr(rm).ampdb.linlin(-80.0, 0.0, 0.0, 1.0);
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

		arg masteramp=0.5, inamp=1.0, ibs=0, obs=0, kbs, fund=200, firstPartial=2, bank2MidiOffset=0.25, spread=0.33, ringL1=7.75, ringL2=9.5, inputLen=1;
		var	pAmp, partialTunedA, partialTunedB, input, output, rms, outArrayA, outArrayA1, outArrayA2, outArray, inenv, ltdOutput, masterEnv, finalOut,
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
		inenv = EnvGen.ar( Env.perc(0.02, inputLen, 1.0, -1), \t_tr.kr(0, 0.0001));
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
		ltdOutput = ltdOutput*masteramp;

		rms = Amplitude.kr(ltdOutput).ampdb.linlin(-80.0, 0.0, 0.0, 1.0);
		Out.kr(kbs, rms); //send rms amplitude measure to a control bus

		Out.ar(obs, ltdOutput);

		}, metadata
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
			t_tr:0
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
q[\addsynthdefargsSpec].value(\petalsOfResonance, \t_tr, 0.0, 1.0, \lin); //trigger for input envelope

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////   END SYNTH DEFS    ///////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////


//Create 3 Groups: ins from soundcard, DSP,  and outs to soundcard
q[\g0] = Group.new(s);
q[\g1] = Group.after(q[\g0]);
q[\g2] = Group.after(q[\g1]);
q[\g3] = Group.after(q[\g2]);
q[\g4] = Group.after(q[\g3]);
q[\g5] = Group.after(q[\g4]);
q[\g6] = Group.after(q[\g5]);
q[\g7] = Group.after(q[\g6]);
q[\g8] = Group.after(q[\g7]);
q[\g9] = Group.after(q[\g8]);
q[\g10] = Group.after(q[\g9]);
q[\g99] = Group.after(q[\g10]);


/////////////////////////////////////////////////////////
////  AUDIO IN //////////////////////////////////////////
/////////////////////////////////////////////////////////
//OSCdef: \mkaudioindef
//SynthMaking Template [msg]: 1=name, 2=group/slot, 3+(optional args); Dictionary: 0=ibs, 1=obs, 2=kbs, 3=group/slot, 4=synth
//msg[1]= Dictonary name for Sound-In conglomerate
//msg[2] = Sound in Channel
//1) Adds an array to dictionary under the name in msg[1]
//2) Create a private audio bus to send the audio in to in slot [0]
//3) Create a control bus to send the amplitude measurement/metering to in slot [1]
//4) Create a audio-in synth in slot [2]

q[\mkaudioindef] = OSCdef(\mkaudioin,{ |msg|
	var ibs, obs, kbs, slot;
	ibs = msg[2].asInteger;
	obs = Bus.audio(s, 1); //private audio bus for sound in
	kbs = Bus.control(s, 1); //control bus for amplitude measurement/metering
	q[msg[1].asSymbol] = [
		ibs,
		obs,
		kbs,
		q[\g0],
		Synth(\audioin_mono, [\ibs, ibs, \obs, obs, \kbs, kbs], q[\g0]), //synth to take audio in and route to private audio bus
	]
}, "/mkaudioin");

/////////////////////////////////////////////////////////
////  AUDIO OUT /////////////////////////////////////////
/////////////////////////////////////////////////////////

//OSCdef: \mkaudioOutdef
//SynthMaking Template [msg]: 1=name, 2=group/slot, 3+(optional args);
//Dictionary: 0=ibs, 1=obs, 2=kbs, 3=group/slot, 4=synth
//msg[1]= Dictonary name for Sound-Out conglomerate
//msg[3] = Sound Out Channel
//1) Adds an array to dictionary under the name in msg[1]
//3) Create a control bus to send the amplitude measurement/metering to in slot [0]
//4) Create a Audio-Out synth in slot [2]

//Def for mono out
q[\mkaudioOutdef_m] = OSCdef(\mkaudioOut_m,{ |msg|
	var ibs, obs, kbs;
	ibs = 999;
	obs = msg[2].asInteger;
	kbs = Bus.control(s, 1); //control bus for amplitude measurement/metering
	q[msg[1].asSymbol] = [
		ibs,
		obs,
		kbs,
		q[\g99],
		Synth(\audioOut_mono, [\ibs, ibs, \obs, obs, \kbs, kbs], q[\g99]),
	]
}, "/mkaudioOut_m");

//Def for stereo out
q[\mkaudioOutdef_s] = OSCdef(\mkaudioOut_s,{ |msg|
	var ibs, obs, kbs;
	ibs = 999;
	obs = msg[2].asInteger;
	kbs = Bus.control(s, 1); //control bus for amplitude measurement/metering
	q[msg[1].asSymbol] = [
		ibs,
		obs,
		kbs,
		q[\g99],
		Synth(\audioOut_stereo, [\ibs, ibs, \obs, obs, \kbs, kbs], q[\g99]),
	]
}, "/mkaudioOut_s");

//OSCdef: /route - to choose a private audio bus to route out to soundcard
//msg[1] = name of operator sound comming from
//msg[2] = name of operator sound going to
q[\routedef] = OSCdef(\route, { |msg| q[msg[2].asSymbol][4].set(\ibs, q[msg[1].asSymbol][1]) }, "/route");

//OSCdef: /unroute - to choose a private audio bus to route out to soundcard
//msg[1] = name of operator sound going to
q[\unroutedef] = OSCdef(\unroute, { |msg| q[msg[1].asSymbol][4].set(\ibs, nil) }, "/unroute");

/////////////////////////////////////////////////////////
////  SET AMP ///////////////////////////////////////////
/////////////////////////////////////////////////////////
//msg[1] = dictionary name to set
//msg[2] = amp value
//synth should always be [4] in dictionary array
q[\setampdef] = OSCdef(\setamp, {|msg| q[msg[1].asSymbol][4].set(\amp, msg[2].asFloat)}, "/setamp");

/////////////////////////////////////////////////////////
////  SIGNALS & DSP ////
/////////////////////////////////////////////////////////
//For Each synthdef make dictionary entry under synthdef name
//an array with slot [0]: synthdef
//and slot [1] an array with:
//[names of all arguments...]

//MAKE SIGNAL
//msg[1] dictionary name
//msg[2] synth name
//msg[3].. list of args-value pairs
q[\mksigdef] = OSCdef(\mksig, {|msg|
	var argsvals = msg.copyRange(3, msg.size);
	var obs = Bus.audio(s);
	var kbs = Bus.control(s, 1); //control bus for amplitude measurement/metering
	argsvals.do{|it, ix| if(ix.even, {argsvals[ix]=it.asSymbol}, {argsvals[ix]=it.asFloat})};
	argsvals = argsvals++[\obs, obs];
	q[msg[1].asSymbol] = [
		nil,
		obs,
		kbs,
		q[\g0],
		Synth(msg[2].asSymbol, argsvals, q[\g0]);
	];
}, "/mksig");

//MAKE DSP
//msg[1] dictionary name
//msg[2] group name
//msg[3] synth name
//msg[4] dictionary name of source
//msg[5].. list of args-value pairs
q[\mkdspdef_m] = OSCdef(\mkdsp_m, {|msg|
	var argsvals = msg.copyRange(5, msg.size);
	var ibs = q[ msg[4].asSymbol ][1];
	var obs = Bus.audio(s);
	var kbs = Bus.control(s);
	var group = q[ ("g"++msg[2]).asSymbol ];
	argsvals.do{|it, ix| if(ix.even, {argsvals[ix]=it.asSymbol}, {argsvals[ix]=it.asFloat})};
	argsvals = argsvals++[\obs, obs, \kbs, kbs, \ibs, ibs];
	q[msg[1].asSymbol] = [
		msg[4].asSymbol,
		obs,
		kbs,
		group,
		Synth(msg[3].asSymbol, argsvals, group);
	];
}, "/mkdsp_m");

  /////////////////////////////
 //////  SET SYNTH ARGS //////
/////////////////////////////

//Set Synth Args
//msg[1] = dictionary name
//msg[2...] = arg-val pairs
q[\setsynthdef] = OSCdef(\setsynth, {
	arg msg
	var argsvals = msg.copyRange(2, msg.size); //makes a new array with only the arg-val pairs
	argsvals.do{|it, ix| if(ix>0, { q[msg[1].asSymbol][4].set(argsvals[ix-1].asSymbol, it.asFloat) })};
}, "/setsynth");

//WAY TO SET INS AND OUTS BY NAME
//// ALWAYS GRAB FROM A NAMED-SYNTH OUT BUS [1]
//WORK ON RING MOD OSCDEF

//Set RingMod Def
//msg[1] = dictionary name
//msg[2] = dict name for carrier synth
//msg[3] = dict name for mod synth
q[\setrmdef] = OSCdef(\setrm, {|msg|
	q[msg[1].asSymbol][2].set(\carbus, q[msg[2].asSymbol][0], \modbus, q[msg[3].asSymbol][0])
}, "/setrm");


//OSCdef to grab rms amplitude value from control bus
//msg[1] = synth dictionary name
//msg[2] = ip
//msg[3] = port
//Sends back a msg to ip, port with this oscaddr - /rms/(synthname)
q[\getrmsdef] = OSCdef(\getrms, {|msg|
	var rms, replyadr, synthname, replyname;
	synthname = msg[1].asSymbol;
	rms = (q[synthname][2].getnSynchronous[0]);
	rms.postln;
	replyadr = NetAddr(msg[2].asString, msg[3].asInteger);
	replyname = ("/rms/"++synthname).asString;
	replyadr.sendMsg(replyname, rms);
}, "/getrms");

)

//PERSISTANCE
Archive.global.put(\DSPframework, q);

//NEXT:

// Make a step-by-step osc msg protocol and what it does in SC with examples:
//// sig - dsp - out
//// live in - dsp - out
// Prototype in Processing
// Fix/Tighten Up any Issues
// Test with presets and make new ones
// Auto-Gui in Processing???


a = NetAddr("127.0.0.1", 57120);
s.meter;
s.queryAllNodes;
a.sendMsg("/mkaudioin", "mic1", 0); // /mkaudioin, name of operator, in channel
a.sendMsg("/mkaudioOut_m", "out1", 0); // /mkaudioOut_m, name of operator, out channel
a.sendMsg("/route", "mic1", "out1"); // /route, name of in operator, name of out operator
a.sendMsg("/unroute", "out1"); // /unroute, name of out operator

a.sendMsg("/mkdsp_m", "petals", 4, "petalsOfResonance", "mic1");
// /mkdsp_m, name of out operator, group num, synthdef name, in source, arg/val pairs
a.sendMsg("/route", "petals", "out1"); // /route, name of in operator, name of out operator
a.sendMsg("/setsynth", "petals", "t_tr", 1.0, "inputLen", 4); // /setsynth, name of operator, arg/val pairs...

//Test get RMS
a.sendMsg("/getrms", \petals, "127.0.0.1", 57120);
OSCdef(\testrms, {|msg| }, "/rms/petals");

Routine{100.do{ a.sendMsg("/getrms", \petals, "127.0.0.1", 57120); 0.1.wait}}.play;
q[\petals][2].getnSynchronous;

//Add to git hub
//Get Amplitude
//Get Current Arg

msg[1] dictionary name
msg[2] group name
msg[3] synth name
msg[4] dictionary name of source
msg[5].. list of args-value pairs

a.sendMsg("/mksig", "sine1", "sineWlfo", "rate", 0.1, "freqlo", 200, "freqhi", 1000);
a.sendMsg("/setsynth", "sine1", "amp", 0);
a.sendMsg("/routeout", "sine1", "out1", 1);
a.sendMsg("/setsynth", "sine1", "rate", 0.1, "freqhi", 350);
a.sendMsg("/mkdsp_m", "rm1", "ringmod", "dspgrp4");
a.sendMsg("/setrm", "rm1", "mic1", "sine1");
a.sendMsg("/routeout", "rm1", "out1", 1);
a.sendMsg("/setsynth", "sine1", "rate", 3.3, "freqlo", 10, "freqhi", 30);

/*
OSC Defs

/mkaudioin
msg[1]= Dictonary name for Sound-In conglomerate
msg[2] = Sound in Channel

/mkaudioOut_m or /mkaudioOut_s
msg[1]= Dictonary name for Sound-Out conglomerate
msg[2] = Sound Out Channel

/route
msg[1] = name of grabbing conglermate
msg[2] = name of conglermate grabbing from

/mksig
msg[1] dictionary name
msg[2] synth name
msg[3].. list of args-value pairs

/mkdsp_m
msg[1] dictionary name
msg[2] group name
msg[3] synth name
msg[4] dictionary name of source
msg[5].. list of args-value pairs

/setsynth
msg[1] = dictionary name
msg[2...] = arg-val pairs

/getsdargs
name of synthdef as msg[1]

/setsdargspec
name of synthdef as msg[1]
arg name as msg[2]
lo, hi, warp as msg[3-5]

/getsdargspec
name of synthdef as msg[1]
arg name as msg[2]

*/

/*

if dictionary entry exsists, do not create new one and send a msg

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
\noiseBurst
*/
