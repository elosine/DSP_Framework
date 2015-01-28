/*
WORK THROUGH PRACTICAL EXAMPLES WITH PROCESSING
     MAKE A LIVE-IN PATCH

*/



(
//Add everything to a dictionary
q = ();

   /////////////////////////////////////////////////
  //////////////  q[\synthdefs] ///////////////////
 /////////////////////////////////////////////////
q[\synthdefs] = ();
q[\dspnames] = Array.newClear(0);
// q[\synthdefs] is a dictionary
// Each entry contains a dictionary indexed by the synthdef name

   /////////////////////////////////////////////////
  ///////////  q[\addsynthdefFunk] ////////////////
 /////////////////////////////////////////////////
//function to pull control names and add to dictionary
q[\addsynthdefFunk] = {
	arg syndefname, type;
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
	q[\synthdefs][syndefname][\type] = type;
	//uses controlNames to make a dictionary \defaults with argname/defaultvalue dictionaries
	get.[syndefname].controls.do{|it ix| q[\synthdefs][syndefname][\defaults][it.name]= it.defaultValue};
	//Creates a spec for each arg with dummy \lo, \hi, and \warp values
	specs.keys.asArray.do{ |it, ix|
		q[\synthdefs][syndefname][\specs][it] = (
			\minval:specs[it].minval,
			\maxval:specs[it].maxval,
			\warp:specs[it].warp,
			\step:specs[it].step,
			\default:specs[it].default,
			\units:specs[it].units
		);
	};
	//updates the array under q[\dspnames] to add the names of any dsp
	q[\synthdefs].do{|it ix| if( (it[\type] > 0) && (it[\type] < 99), {q[\dspnames] = q[\dspnames].add(syndefname)})};
};

    ////////////////////////////////////////////////////////////
   /////////  q[\getdspnamesDef]
  /////////  OSCmsg: /getdspnames()
 /////////   Returns to Requester: /dspnames (single string of all dsp synthdef names delimited by #)
/////////////////////////////////////////////////////////////
q[\getdspnamesDef] = OSCdef(\getdspnames,{
	arg msg;
	var argsStr="", mailtoadr;
	mailtoadr = NetAddr(msg[1].asString, msg[2].asInteger);
	q[\dspnames].do{|it ix| if(ix==0, {argsStr = it}, {argsStr="#"++argsStr})};
	mailtoadr.sendMsg("/dspnames", argsStr);
}, "/getdspnames");

    ////////////////////////////////////////////////////////////
   /////////  q[\getsynthdefargsDef]
  /////////  OSCmsg: /getsdargs(synthdef name)
 /////////   Returns to Requester: /sdargs/(name of synthdef)(single string of all args delimited by #)
/////////////////////////////////////////////////////////////
q[\getsynthdefargsDef] = OSCdef(\getsdargs,{
	arg msg, time, addr;
	var mailtoadr, args, sdname, argsStr="";
	mailtoadr = addr;
	sdname = msg[1].asSymbol;
	args = q[\synthdefs][sdname][\args];
	//Creates single string with the # as delimiter
	args.do{|it, ix| argsStr = if(ix==0,{argsStr=it},{argsStr=argsStr++"#"++it})};
	mailtoadr.sendMsg("/sdargs/"++sdname, argsStr);
}, "/getsdargs");

     ///////////////////////////////////////////////////////////////////////////////////////////
    /////////  q[\getsynthdefargsdefaultDef]
   ////////////////////////////////////////////////////////////////////////////////////////////
  /////////  OSCmsg: /getsdargdefault(synthdef name, arg name)
 /////////   Returns to Requester: /sdargdefault(val)
/////////////////////////////////////////////////////////////////////////////////////////////
q[\getsynthdefargsdefaultDef] = OSCdef(\getsdargdefault,{
	arg msg, time, addr;
	var mailtoadr, val, argname;
	mailtoadr = addr;
	argname = msg[2].asSymbol;
	val = q[\synthdefs][msg[1].asSymbol][\defaults][argname];
	mailtoadr.sendMsg("/sdargdefault/"++argname, val);
}, "/getsdargdefault");

    ////////////////////////////////////////////////////////////
   /////////  q[\getsynthdefspecDef]
  /////////  OSCmsg: /getsdspec(synthdef name, arg name)
/////////   Returns to Requester: /sdspec/(name of synthdef)/(name of arg) (single string of arg/val pairs delimited by #)
/////////////////////////////////////////////////////////////
q[\getsynthdefspecDef] = OSCdef(\getsdspec,{
	arg msg, time, addr;
	var mailtoadr, specs, sdname, argname, argsStr="";
	mailtoadr = addr;
	sdname = msg[1].asSymbol;
	argname = msg[2].asSymbol;
	specs = q[\synthdefs][sdname][\specs][argname];
	argsStr = \minval++"#"++specs[\minval].asString++"#"++
	\maxval++"#"++specs[\maxval].asString++"#"++
	\step++"#"++specs[\step].asString++"#"++
	\default++"#"++specs[\default].asString++"#"++
	\untis++"#"++specs[\units].asString;
	//("/sdspecs/"++sdname++argname).postln;
	mailtoadr.sendMsg("/sdspec/"++sdname++"/"++argname, argsStr);
}, "/getsdspec");

     ///////////////////////////////////////////////////////////////////////////////////////////
    /////////  q[\setpresetDef]
   ////////////////////////////////////////////////////////////////////////////////////////////
  /////////  OSCmsg: /setpreset(synth dictionary name, preset name)
 /////////
/////////////////////////////////////////////////////////////////////////////////////////////
q[\setpresetDef] = OSCdef(\setpreset,{
	arg msg;
	var syndictname, autogui, sdname, presetname, psdict;
	presetname = msg[2].asSymbol;
	syndictname = msg[1].asSymbol;
	autogui = q[syndictname][5];
	sdname = q[syndictname][4].defName.asSymbol;
	q[\synthdefs][sdname][\presets].put(presetname, ());
	psdict = q[\synthdefs][sdname][\presets][presetname];
		//autogui.guiArr.do{|it ix| {psdict[it[4].string].postln }.defer};
autogui.guiArr.do{|it ix| {psdict[it[4].string.asSymbol] = it[3].value}.defer};
}, "/setpreset");



     ///////////////////////////////////////////////////////////////////////////////////////////
    /////////  q[\mkautoguiDef]
   ////////////////////////////////////////////////////////////////////////////////////////////
  /////////  OSCmsg: /mkautogui(synth dictionary name)
 /////////
/////////////////////////////////////////////////////////////////////////////////////////////
q[\mkautoguiDef] = OSCdef( \mkautogui, { |msg|
	var dictname, sdname, synth, ag;
	dictname = msg[1].asSymbol;
	synth = q[dictname][4];
	sdname = synth.defName;
	{q[dictname] = q[dictname].add( SynthDefAutogui(name:sdname, aSynth:synth, freeOnClose:false) )}.defer
},
	"/mkautogui");


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
	var ibs, obs, kbs;
	ibs = msg[2].asInteger;
	obs = Bus.audio(s, 1); //private audio bus for sound in
	kbs = Bus.control(s, 1); //control bus for amplitude measurement/metering
	q[msg[1].asSymbol] = [
		ibs,
		obs,
		kbs,
		q[\g0],
		Synth(\audioin_mono, [\ibs, ibs, \obs, obs, \kbs, kbs], q[\g0]), //synth to take audio in and route to private audio bus
	];
}, "/mkaudioin");

/////////////////////////////////////////////////////////
////  AUDIO OUT /////////////////////////////////////////
/////////////////////////////////////////////////////////

//OSCdef: \mkaudioOutdef
//SynthMaking Template [msg]: 1=name, 2=group/slot, 3+(optional args);
//Dictionary: 0=ibs, 1=obs, 2=kbs, 3=group/slot, 4=synth
//msg[1]= Dictonary name for Sound-Out conglomerate
//msg[2] = Sound Out Channel
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

//OSCdef to grab rms amplitude value from control bus
//msg[1] = synth dictionary name
//msg[2] = ip
//msg[3] = port
//Sends back a msg to ip, port with this oscaddr - /rms(synthname, rms)
q[\getrmsdef] = OSCdef(\getrms, {|msg|
	var rms, replyadr, synthname, replyname;
	synthname = msg[1].asSymbol;
	rms = (q[synthname][2].getnSynchronous[0]);
	replyadr = NetAddr(msg[2].asString, msg[3].asInteger);
	replyadr.sendMsg("/rms", synthname, rms);
}, "/getrms");

//OSCdef: /route - to choose a private audio bus to route out to soundcard
//msg[1] = name of operator sound comming from
//msg[2] = name of operator sound going to
q[\routedef] = OSCdef(\route, { |msg| msg.postln; q[msg[2].asSymbol][4].set(\ibs, q[msg[1].asSymbol][1]) }, "/route");

//OSCdef: /unroute - to choose a private audio bus to route out to soundcard
//msg[1] = name of operator sound going to
q[\unroutedef] = OSCdef(\unroute, { |msg| q[msg[1].asSymbol][4].set(\ibs, nil) }, "/unroute");


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


    ///////////////////////////////////////////
   ////                                  /////
  ////       REGISTER SYNTH DEFS        /////
 ////                                  /////
///////////////////////////////////////////
//Second argument is for type: 0=source, 99=out, 1-98=dsp,etc.
q[\addsynthdefFunk].value(\audioin_mono, 0);
q[\addsynthdefFunk].value(\audioOut_mono, 99);
q[\addsynthdefFunk].value(\petalsOfResonance, 1);

)

q[\mic1][5].guiArr

//RESUME HERE//////
//make a button in processing to get auto gui
a.sendMsg("/mkautogui", "mic1"); // /mkaudioin, name of operator, in channel
a.sendMsg("/mkautogui", "dsp1"); // /mkaudioin, name of operator, in channel
//recall presets from processing
a.sendMsg("/setpreset", "dsp1", "testeroni"); // /mkaudioin, name of operator, in channel
a.sendMsg("/setpreset", "dsp1", "bell_y02"); // /mkaudioin, name of operator, in channel
//MAKE PERSISTANCE AND PRESET RECALL AND SET SYNTH
a.sendMsg("/setpreset", "mic1", "testeroni");
q[\synthdefs][\petalsOfResonance][\presets][\bell_y02].writeArchive("/Volumes/Ute/SuperCollider Standalone/bell_y02.txt");
f = Object.readArchive("/Volumes/Ute/SuperCollider Standalone/bell_y02.txt")
f[\ringL1]

//Make an audio in and get feedback
a = NetAddr("127.0.0.1", 57120);
s.meter;
s.queryAllNodes;
a.sendMsg("/mkautogui", "mic1"); // /mkaudioin, name of operator, in channel
n = NetAddr("localhost", 57120);
OSCdef(\teet, {|msg| msg.postln }, "/dspnames");
a.sendMsg("/getdspnames");

e = SynthDesc.read(SynthDef.synthDefDir ++ "petalsOfResonance.scsyndef");


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
a.sendMsg("/mkautogui", "mic1"); // /mkaudioin, name of operator, in channel
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
