/*
EXIT PROTOCAL:
GET RID OF GROUPS AND SYNTHS
FREE ALL OSCDEFS
q = ();
FREE AUDIO AND CONTROL BUSSES
*/
(
//Add everything to a dictionary
q = ();

//GROUPS: q[\g0]=ins; q[\g1-10]=DSP; q[\g99]=outs
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

q[\synthdefs] = ();
q[\synths] = ();
q[\dspnames] = Array.newClear(0);

   /////////////////////////////////////////////////
  ///////////  q[\addsynthdefFunk] ////////////////
 /////////////////////////////////////////////////
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
			{q[\dspnames] = q[\dspnames].add(syndefname)})};
};

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
   /////////  q[\getdspnamesDef]                                                                           /////
  /////////  OSCmsg: /getdspnames()                                                                       /////
 /////////   Returns to Requester: /dspnames (single string of all dsp synthdef names delimited by #)    /////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
q[\getdspnamesDef] = OSCdef(\getdspnames,{
	arg msg;
	var argsStr="", mailtoadr;
	mailtoadr = NetAddr(msg[1].asString, msg[2].asInteger);
	q[\dspnames].do{|it ix|
		if(ix!=(q[\dspnames].size-1),
			{argsStr = argsStr ++ it ++ "#"},
			{argsStr = argsStr ++ it })};
	mailtoadr.sendMsg("/dspnames", argsStr);
}, "/getdspnames");

    /////////////////////////////////////////////////////////////////////////////////////
   /////////    q[\setpresetDef]                                            ////////////
  /////////////////////////////////////////////////////////////////////////////////////
 /////////     OSCmsg: /setpreset(synth dictionary name, preset name)     ////////////
/////////////////////////////////////////////////////////////////////////////////////
q[\setpresetDef] = OSCdef(\setpreset,{
	arg msg;
	var syndictname, autogui, sdname, presetname, psdict;
	presetname = msg[2].asSymbol;
	syndictname = msg[1].asSymbol;
	autogui = q[syndictname][5];
	sdname = q[syndictname][4].defName.asSymbol;
	q[\synthdefs][sdname][\presets].put(presetname, ());
	psdict = q[\synthdefs][sdname][\presets][presetname];
	autogui.guiArr.do{|it ix| {psdict[it[4].string.asSymbol] = it[3].value}.defer};
}, "/setpreset");

    ////////////////////////////////////////////////////////////////////////////
   /////////         q[\mkautoguiDef]                                //////////
  ////////////////////////////////////////////////////////////////////////////
 /////////       OSCmsg: /mkautogui(synth dictionary name)         //////////
////////////////////////////////////////////////////////////////////////////
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

    //////////////////////////////////////////////////////////////////////////////////
   ////  SYNTH ARRAY TEMPLATE:                                                   ////
  ////   q[<dict name for synth>] =                                             ////
 ////    [0:inbus, 1:outbus, 2:controlbus for amplitude, 3:group, 4:synth]     ////
//////////////////////////////////////////////////////////////////////////////////

    /////////////////////////////////////////////////////////////////////////////////////////////
   /////////         q[\mkaudioinDef]                                                 //////////
  /////////////////////////////////////////////////////////////////////////////////////////////
 /////////       OSCmsg: /mkaudioin(synth dictionary name, sound in ch num)         //////////
/////////////////////////////////////////////////////////////////////////////////////////////
q[\mkaudioinDef] = OSCdef(\mkaudioin,{ |msg|
	var ibs, obs, kbs, name;
	name = msg[1].asSymbol;
	if(q.includesKey(name) == false, {
		ibs = msg[2].asInteger;
		obs = Bus.audio(s, 1); //private audio bus for sound in
		kbs = Bus.control(s, 1); //control bus for amplitude measurement/metering
		q[name] = [
			ibs,
			obs,
			kbs,
			q[\g0],
			Synth(\audioin_mono, [\ibs, ibs, \obs, obs, \kbs, kbs], q[\g0]), //synth to take audio in and route to private audio bus
	]})
}, "/mkaudioin");

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
   //////         q[\mkaudioOutDef_m]        q[\mkaudioOutDef_s]                                    //////
  ///////////////////////////////////////////////////////////////////////////////////////////////////////
 //////    OSCmsg: /audioOut_mono  /audioOut_stereo(synth dictionary name, sound out ch num)      //////
///////////////////////////////////////////////////////////////////////////////////////////////////////
q[\mkaudioOutDef_m] = OSCdef(\mkaudioOut_m,{ |msg|
	var ibs, obs, kbs, name;
	name = msg[1].asSymbol;
	if(q.includesKey(name) == false, {
	ibs = 999;
	obs = msg[2].asInteger;
	kbs = Bus.control(s, 1); //control bus for amplitude measurement/metering
	q[name] = [
		ibs,
		obs,
		kbs,
		q[\g99],
		Synth(\audioOut_mono, [\ibs, ibs, \obs, obs, \kbs, kbs], q[\g99]),
	]})
}, "/mkaudioOut_m");

q[\mkaudioOutDef_s] = OSCdef(\mkaudioOut_s,{ |msg|
	var ibs, obs, kbs, name;
	name = msg[1].asSymbol;
	if(q.includesKey(name) == false, {
	ibs = 999;
	obs = msg[2].asInteger;
	kbs = Bus.control(s, 1); //control bus for amplitude measurement/metering
	q[name] = [
		ibs,
		obs,
		kbs,
		q[\g99],
		Synth(\audioOut_stereo, [\ibs, ibs, \obs, obs, \kbs, kbs], q[\g99]),
	]})
}, "/mkaudioOut_s");

    ////////////////////////////////////////////////////////////////////////////////////
   /////////  q[\getrmsDef]                                                       /////
  /////////  OSCmsg: /getrms(synth dictionary name, ip, port)                    /////
 /////////   Returns to Requester: /rms (synth dictionary name, rms value)      /////
////////////////////////////////////////////////////////////////////////////////////
q[\getrmsDef] = OSCdef(\getrms, {|msg|
	var rms, replyadr, synthname, replyname;
	synthname = msg[1].asSymbol;
	if(q.includesKey(synthname), {
	rms = (q[synthname][2].getnSynchronous[0]);
	replyadr = NetAddr(msg[2].asString, msg[3].asInteger);
	replyadr.sendMsg("/rms", synthname, rms)
	})
}, "/getrms");

     ///////////////////////////////////////////////////////////////////////////////////////
    //////         q[\routeDef]   q[\unrouteDef]                                       ////
   ///////////////////////////////////////////////////////////////////////////////////////
  //////       OSCmsg: /route(synth dict name of source, synth dict name of dest)    ////
 //////       OSCmsg: /unroute(synth dict name of dest)                             ////
///////////////////////////////////////////////////////////////////////////////////////
q[\routeDef] = OSCdef(\route, { |msg|
	if( (q.includesKey(msg[2].asSymbol)) && (q.includesKey(msg[1].asSymbol)), {
		q[msg[2].asSymbol][4].set(\ibs, q[msg[1].asSymbol][1])
})}, "/route");
q[\unrouteDef] = OSCdef(\unroute, { |msg|
	if(q.includesKey(msg[1].asSymbol), {
	q[msg[1].asSymbol][4].set(\ibs, nil)
})}, "/unroute");

     ///////////////////////////////////////////////////////////////////////////////
    ////    q[\mkdspDef_m]                                                     ////
   ///////////////////////////////////////////////////////////////////////////////
  ////   OSCmsg: /mkdsp_m(synth dictionary name, group num, synthdef name,   ////
 ////   dictionary name of source, list of arg/value pairs...)              ////
///////////////////////////////////////////////////////////////////////////////
q[\mkdspDef_m] = OSCdef(\mkdsp_m, {|msg|
	var argsvals, ibs, obs, kbs, group, dictname, sourcename, sdname;
	dictname = msg[1].asSymbol;
	sourcename = msg[4].asSymbol;
	sdname = msg[3].asSymbol;
	if( (q.includesKey(dictname) == false) && (q.includesKey(sourcename)) && (q[\dspnames].includes(sdname)),{
	argsvals = msg.copyRange(5, msg.size);
	ibs = q[sourcename][1];
	obs = Bus.audio(s);
	kbs = Bus.control(s);
	group = q[ ("g"++msg[2]).asSymbol ];
	argsvals.do{|it, ix| if(ix.even, {argsvals[ix]=it.asSymbol}, {argsvals[ix]=it.asFloat})};
	argsvals = argsvals++[\obs, obs, \kbs, kbs, \ibs, ibs];
	q[dictname] = [
		ibs,
		obs,
		kbs,
		group,
		Synth(sdname, argsvals, group);
	]})
}, "/mkdsp_m");

     ////////////////////////////////////////////////////////
    ////    q[\freesynthDef]                            ////
   ////////////////////////////////////////////////////////
  ////   OSCmsg: /freesynth(synth dictionary name)    ////
/////////////////////////////////////////////////////////
q[\freesynthDef] = OSCdef(\freesynth, {|msg|
	var name;
	name = msg[1].asSymbol;
	if(q.includesKey(name),{
		q[name][4].free;
		q[name][2].free;
		q[name][1].free;
		q[name][0].free;
		q.removeAt(name);
	})
}, "/freesynth");

    ///////////////////////////////////////////
   ////                                  /////
  ////       REGISTER SYNTH DEFS        /////
 ////                                  /////
///////////////////////////////////////////
//Second argument is for type: 0=source, 99=out, 1=dsp.
q[\addsynthdefFunk].value(\audioin_mono, 0);
q[\addsynthdefFunk].value(\audioOut_mono, 99);
q[\addsynthdefFunk].value(\petalsOfResonance, 1);
q[\addsynthdefFunk].value(\ringmod, 1);

)

//RESUME HERE//////
//PRESETS//PERSISTANCE//
//recall presets from processing
a.sendMsg("/setpreset", "dsp1", "testeroni"); // /mkaudioin, name of operator, in channel
a.sendMsg("/setpreset", "dsp1", "bell_y02"); // /mkaudioin, name of operator, in channel
//MAKE PERSISTANCE AND PRESET RECALL AND SET SYNTH
a.sendMsg("/setpreset", "mic1", "testeroni");
q[\synthdefs][\petalsOfResonance][\presets][\bell_y02].writeArchive("/Volumes/Ute/SuperCollider Standalone/bell_y02.txt");
f = Object.readArchive("/Volumes/Ute/SuperCollider Standalone/bell_y02.txt")
f[\ringL1]

s.queryAllNodes
q
