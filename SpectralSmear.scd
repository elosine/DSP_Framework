(
b = Buffer.alloc(s,2048,1);

SynthDef("help-magSmear2", {
	arg out=0, buf, sweeprate=0.1;
    var in, chain;
	    in = SoundIn.ar(0);
    chain = FFT(buf, in);
	    chain = PV_MagSmear(chain, SinOsc.kr(sweeprate).range(0, 90));
    Out.ar(out, 0.5 * IFFT(chain).dup);
}).play(s,[\out, 0, \buf, b.bufnum]);
)