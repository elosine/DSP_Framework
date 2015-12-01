~buf[0].numFrames

(
s.waitForBoot{
	fork{
		var wff;
		//Get Buffers
		var ~buf = SoundFile.collectIntoBuffers("/Users/jyang/GitHub/DSP_Framework/samples/*",s);
		////VARIABLES////
		var numbufs = buf.size;
		var ixsynths = Array.newClear(numbufs);
		var ixbufs = Array.newClear(numbufs);
		numbufs.do{|ix| ixbufs[ix] = Buffer.alloc(s, buf[ix].numFrames, 1)};
		ixabuses = {Bus.audio(s)}!(numbufs);
		ixkbuses = {Bus.control(s)}!(numbufs);
		ixgr = Group.new();
		ingr = Group.after(~ixgr);
		ogr = Group.after(~ingr);
		proc = NetAddr("127.0.0.1", 12321);
		////SYNTHDEFS////
		SynthDef(\bufidx,{
			arg buf, spd=1, bus, numbts=1.0, start=0.0, end=1.0, kbus;
			var indexer, indexnorm;
			//create an audio rate indexer using the Phasor object
			indexer = Phasor.ar(trig:0, rate:BufRateScale.kr(buf)*spd, start:start*BufFrames.kr(buf), end:end*BufFrames.kr(buf));
			//normalize the index
			indexnorm = indexer.linlin(0.0, BufFrames.kr(buf), 0.0, numbts);
			//send the index out to both a control and audio rate bus
			Out.ar(bus, indexer);
			Out.kr(kbus, indexnorm);
		}).add;
		SynthDef(\bufrec, {
			arg ich=0, idxbus, buf, gate=1;
			var in, idx, env;
			env = EnvGen.ar(Env.asr(releaseTime:0.01, curve:0),gate, doneAction:2);
			idx = In.ar(idxbus);
			in = SoundIn.ar(ich);
			BufWr.ar(in*env, buf, idx);
		}).add;
		SynthDef(\bufpl, {
			arg idxbus, obs=0, buf, gate=1;
			var idx, sig, env;
			env = EnvGen.ar(Env.asr(releaseTime:0.01, curve:0),gate);
			idx = In.ar(idxbus);
			sig = BufRd.ar(1, buf, idx);
			Out.ar(obs, sig*env);
		}).add;
		////OSCDEFs////
		OSCdef( \getix,{
			arg msg;
			var num = msg[1].asInteger;
			ixkbuses[num].get({arg val; proc.sendMsg("/trix", num, val.asFloat)});
		}, "/getix");
		OSCdef(\getwf, { |msg|
			var ip = msg[1].asString;
			var port = msg[2].asInteger;
			var numpx = msg[3].asInteger;
			var bufnum = msg[4].asInteger;
			var dest = NetAddr(ip, port);
			wff.value(bufnum, numpx, dest);
		}, "/getwf");

		//Waveform Function
		wff = { |bufnum numpx dest|
			var bufarray, sampsize, resamp, resampArray, ct;
			buf[bufnum].loadToFloatArray( action:{
				arg array;
				var bufarray, sampsize, resamp, resampArray, ct;
				bufarray = array.copyRange(0, array.size-1);
				sampsize = numpx;
				resamp = (bufarray.size/sampsize).round;
				resampArray = Array.newClear(sampsize+2);
				ct = 0;
				bufarray.do{ |it, ix| if( ix%resamp == 0,{
					resampArray[ct]=it.asFloat;
					ct = ct+1;
				})};
				resampArray = resampArray.insert(0, bufnum.asInteger);
				resampArray = resampArray.insert(0, "/sbuf");
				dest.sendBundle(0.0, resampArray);
			} );
		};
		0.1.wait;
		(numbufs).do{ |ix|
			ixsynths[ix] = Synth(\bufidx, [\buf, ixbufs[ix].bufnum, \bus, ixabuses[ix], \kbus, ixkbuses[ix]], ixgr) };

	}//end fork
}//end s.waitForBoot
)
