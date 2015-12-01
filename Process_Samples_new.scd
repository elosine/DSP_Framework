
(
s.waitForBoot{
	fork{
		var g0 = Group.new(s);
		var g1 = Group.after(g0);
		var g2 = Group.after(g1);
		var sampbus = Bus.audio(s,1);
		var buf = SoundFile.collectIntoBuffers("/Users/jyang/GitHub/DSP_Framework/samples/*",s);
		//Sample Index
		var ixabus = Bus.audio(s);
		var ixkbus = Bus.control(s)
		//SYNTHDEFS//
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
			env = EnvGen.ar(Env.asr(releaseTime:0.01, curve:0),gate);
			idx = In.ar(idxbus);
			sig = BufRd.ar(1, buf, idx);
			Out.ar(obs, sig*env);
		}).add;
		// OSC DEFS //
		OSCdef(\loadsamp, { |msg|
			var num = msg[1].asInteger;
			//free previous
			s.sendMsg(\b_free, 100);
			s.sendMsg(\n_free, 3000);
			s.sendMsg(\n_free, 4000);
			//Make new
			s.sendMsg(\b_alloc, 100, buf[num].numFrames); //allocate a buffer for the index synth
			s.sendMsg(\s_new, \bufidx, 3000, 0, g0.nodeID, \buf, 100, \bus, ixabus.index, \kbus, ixkbus.index);
			s.sendMsg(\s_new, \bufpl, 4000, 0, g1.nodeID, \idxbus, ixabus.index, \buf, buf[num].bufnum);
		}, "/loadsamp");
	}//end fork
}//end s.waitForBoot
)


//RESTART
GOAL ONE SAMPLE THAT YOU CAN CHANGE
A COUPLE OF EFFECTS
AND SOME SORT OF ARGUMENT MANIPULATION - DIALS FADERS
