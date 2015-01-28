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
	q[\synthdefs].do{|it ix|
		if( (it[\type] > 0) &&
			(it[\type] < 99) &&
			(q[\dspnames].includes(syndefname)==false),
			{q[\dspnames] = q[\dspnames].add(syndefname); q[\dspnames].postln})};
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
	argsStr.postln;
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
	if(q.includesKey(dictname),{
	synth = q[dictname][4];
	sdname = synth.defName;
	{q[dictname] = q[dictname].add( SynthDefAutogui(name:sdname, aSynth:synth, freeOnClose:false) )}.defer
	})
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
	if(q.includesKey(synthname), {
	rms = (q[synthname][2].getnSynchronous[0]);
	replyadr = NetAddr(msg[2].asString, msg[3].asInteger);
	replyadr.sendMsg("/rms", synthname, rms)
	})
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
q[\addsynthdefFunk].value(\ringmod, 1);

)


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
