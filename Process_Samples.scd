
(
s.waitForBoot{
	fork{
		var wff;
		var numscr = 3;
		var scrbus = {Bus.audio(s,1)}!numscr;
		var obs = [0, 1, 0];
		var iMicIdx = 2000;
		var tapdelbuf = {Buffer.alloc(s, s.sampleRate*4)}!numscr;
		//Get Buffers
		var buf = SoundFile.collectIntoBuffers("/Users/jyang/GitHub/DSP_Framework/samples/*",s);
		////VARIABLES////
		var numbufs = buf.size;
		var ixabus = Bus.audio(s);
		var ixkbus = Bus.control(s);
		var g0 = Group.new();
		var g1 = Group.after(g0);
		var g2 = Group.after(g1);
		var proc = NetAddr("127.0.0.1", 12321);
		var kbus = {Bus.control(s,1)}!3;
		////SYNTHDEFS////
		SynthDef(\bufidx,{
			arg buf, spd=1, bus, start=0.0, end=1.0, kbus;
			var indexer, indexnorm;
			//create an audio rate indexer using the Phasor object
			indexer = Phasor.ar(0, BufRateScale.kr(buf)*spd, start*BufFrames.kr(buf), end*BufFrames.kr(buf));
			//normalize the index
			indexnorm = indexer.linlin(0.0, BufFrames.kr(buf), 0.0, 1.0);
			//send the index out to both a control and audio rate bus
			Out.ar(bus, indexer);
			Out.kr(kbus, indexnorm);
		}).add;
		SynthDef(\bufpl, {
			arg idxbus, obs=0, buf, gate=1;
			var idx, sig, env;
			env = EnvGen.ar(Env.asr(releaseTime:0.01, curve:0),gate, doneAction:2);
			idx = In.ar(idxbus);
			sig = BufRd.ar(1, buf, idx);
			Out.ar(obs, sig*env);
		}).add;
		////EFFECTS///
		SynthDef(\amplify, {
			arg ibs=0, obs=0, amp=1, gate=1;
			var sig, env;
			env = EnvGen.ar(Env.asr(releaseTime:0.08), gate, doneAction:2);
			sig = In.ar(ibs);
			Out.ar(obs, sig*amp);
		}).add;
		////OSCDEFs////
		OSCdef(\amplify, {
			arg msg;
			var pl = msg[1].asInteger;
			var mode = msg[2].asInteger;
			pl.postln;
			if(mode==1,
				{
					s.sendMsg(\s_new, \amplify, 3000+pl, 0, g1.nodeID, \ibs, scrbus[pl].index, \obs, obs[pl]);
					//s.sendMsg(\n_map, 3000+pl, \amp, kbus[0].index);
				},
				{ s.sendMsg(\n_set, 3000+pl, \gate, 0) }
			);
		}, "/Amplify");
		OSCdef( \getix,{
			ixkbus.get({|val| proc.sendMsg("/ix", val.asFloat)})
		}, "/getix");
		OSCdef(\getwf, { |msg|
			var ip = msg[1].asString;
			var port = msg[2].asInteger;
			var numpx = msg[3].asInteger;
			var bufnum = msg[4].asInteger;
			var dest = NetAddr(ip, port);
			wff.value(bufnum, numpx, dest);
		}, "/getwf");
		OSCdef(\loadsamp, { |msg|
			fork{
				var num = msg[1].asInteger;
				//free previous
				s.sendMsg(\n_set, 11000, \gate, 0);
				0.05.wait;
				s.sendMsg(\n_free, 12000);
				//Make new
				s.sendMsg(\s_new, \bufidx, 12000, 0, g0.nodeID, \buf, buf[num].bufnum, \bus, ixabus.index, \kbus, ixkbus.index);
				s.sendMsg(\s_new, \bufpl, 11000, 0, g1.nodeID, \obs, scrbus[3].index, \idxbus, ixabus.index, \buf, buf[num].bufnum);
		}}, "/loadsamp");
		OSCdef(\stopsamp, {
			//free previous
			s.sendMsg(\n_set, 4000, \gate, 0);
			0.05.wait;
			s.sendMsg(\n_free, 3000);
		}, "/stopsamp");

		//Waveform Function
		wff = { |bufnum numpx dest|
			var bufarray, sampsize, resamp, resampArray, ct;
			buf[bufnum].loadToFloatArray( action:{
				arg array;
				var bufarray, sampsize, resamp, resampArray, ct;
				bufarray = array.copyRange(0, array.size-1);
				sampsize = numpx;
				resamp = (bufarray.size/sampsize).round;
				resampArray = Array.newClear(sampsize+1);
				ct = 0;
				bufarray.do{ |it, ix| if( ix%resamp == 0,{
					resampArray[ct]=it.asFloat;
					ct = ct+1;
				})};
				resampArray = resampArray.insert(0, "/sbuf");
				dest.sendBundle(0.0, resampArray);
			} );
		} //end wff function
	}//end fork
}//end s.waitForBoot
)
n = NetAddr("127.0.0.1", 57120);
n.sendMsg("/Amplify", 2, 1);
a = {Bus.audio(s, 1)}!3;
a[.index