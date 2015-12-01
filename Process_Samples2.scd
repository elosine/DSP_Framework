
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
		SynthDef(\setbus,{
			arg bus;
			var val = \val.kr(0.0, 0.08);
			Out.kr(bus, val);
		}).add;
		////EFFECTS///
		SynthDef(\amplify, {
			arg ibs=0, obs=0, amp=1, gate=1;
			var sig, env;
			env = EnvGen.ar(Env.asr(releaseTime:0.08), gate, doneAction:2);
			sig = In.ar(ibs);
			Out.ar(obs, sig*amp);
		}).add;
		SynthDef(\multitap, {
			arg ibs = 0, obs=0, buf, panrate=3,
			delaytimes = #[0.4, 0.6, 0.8, 1.2, 1.4, 1.6, 1.8],
			amps = #[0.9, 0.8, 0.7,0.6,0.5,0.5,0.4], gate=1;
			var source, sig, env, amp;
			amp = \amp.kr(0.85, 0.05);
			env = EnvGen.ar(Env.asr(releaseTime:1), gate, doneAction:2);
			source = In.ar(ibs);
			sig = MultiTap.ar( delaytimes, amps, source, bufnum:buf );
			sig  = Pan2.ar( sig, SinOsc.kr(panrate) );
			Out.ar(obs, sig*env*amp);
		}).add;
		SynthDef(\spectralvocoder, {
			arg ibs, obs=0, freeze = 0, mode = #[0,2,4,5,7,9,11], root=60, pchgrate=3, gate=1;
			var bufA, bufB, chain1, chain2, out, freq, amp, env;
			amp = \amp.kr(0.85, 0.05);
			env = EnvGen.ar(Env.asr(0.01, 1, 0.1),gate, doneAction:2);
			freq = (TChoose.kr(Impulse.kr(pchgrate), mode)+root).midicps;
			bufA = LocalBuf.new(2048);
			bufB = LocalBuf.new(2048);
			chain1 = FFT(bufA, LFSaw.ar( freq )); // to be filtered
			chain2 = FFT(bufB, In.ar(ibs)*10);
			chain1 = PV_SpectralMap(chain1, chain2, 0.0, freeze, 2.4, 1);
			out = IFFT(chain1);
			Out.ar(obs, out.dup*env*amp);
		}).add;
		////OSCDEFs////
		OSCdef(\amplify, {
			arg msg;
			var pl = msg[1].asInteger;
			var mode = msg[2].asInteger;
			pl.postln;
			if(mode==1,
				{
					s.sendMsg(\s_new, \amplify, 3000+pl, 0, g2.nodeID, \ibs, scrbus[pl].index, \obs, obs[pl]);
					s.sendMsg(\n_map, 3000+pl, \amp, kbus[0].index);
				},
				{ s.sendMsg(\n_set, 3000+pl, \gate, 0) }
			);
		}, "/Amplify");
		OSCdef(\mtap1, {
			arg msg;
			var pl = msg[1].asInteger;
			var mode = msg[2].asInteger;
			if(mode==1,
				{
					tapdelbuf[pl].free;
					tapdelbuf[pl] = Buffer.alloc(s, s.sampleRate*4);
					s.sendMsg(\s_new, \multitap, 4000+pl, 0, g2.nodeID, \ibs, scrbus[pl].index, \obs, obs[pl],
						\buf, tapdelbuf[pl], \panrate, 3, \delaytimes, [0.4, 0.6, 0.8, 1.2, 1.4, 1.6, 1.8]);
					s.sendMsg(\n_map, 4000+pl, \amp, kbus[0].index);
					s.sendMsg(\n_map, 4000+pl, \panrate, kbus[1].index);
				},
				{ s.sendMsg(\n_set, 4000+pl, \gate, 0) }
			);
		}, "/MultiTap1");
		OSCdef(\spectralvocoder, {
			arg msg;
			var pl = msg[1].asInteger;
			var mode = msg[2].asInteger;
			pl.postln;
			if(mode==1,
				{
					s.sendMsg(\s_new, \spectralvocoder, 5000+pl, 0, g2.nodeID, \ibs, scrbus[pl].index, \obs, obs[pl]);
					s.sendMsg(\n_map, 5000+pl, \amp, kbus[0].index);
					s.sendMsg(\n_map, 5000+pl, \root, kbus[1].index);
					s.sendMsg(\n_map, 5000+pl, \pchgrate, kbus[2].index);
				},
				{ s.sendMsg(\n_set, 5000+pl, \gate, 0) }
			);
		}, "/spectralvocoder");
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
				s.sendMsg(\s_new, \bufpl, 11000, 0, g1.nodeID, \obs, scrbus[2].index, \idxbus, ixabus.index, \buf, buf[num].bufnum);
		}}, "/loadsamp");
		OSCdef(\stopsamp, {
			//free previous
			s.sendMsg(\n_set, 4000, \gate, 0);
			0.05.wait;
			s.sendMsg(\n_free, 3000);
		}, "/stopsamp");
		OSCdef(\slider, {|msg|
			var bus = msg[1].asInteger;
			var val = msg[2].asFloat;
			kbus[bus].setSynchronous(val);
		}, "/slider");

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
		}; //end wff function
		0.1.wait;
		s.sendMsg(\s_new, \setbus, 20000, 0, g0.nodeID, \bus, 999);
	}//end fork
}//end s.waitForBoot
)
n = NetAddr("127.0.0.1", 57120);
n.sendMsg("/Amplify", 2, 1);
n.sendMsg("/Amplify", 2, 0);
n.sendMsg("/MultiTap1", 2, 1);
n.sendMsg("/MultiTap1", 2, 0);
n.sendMsg("/spectralvocoder", 2, 1);
n.sendMsg("/spectralvocoder", 2, 0);








