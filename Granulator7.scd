


{PlayBuf.ar(1, c.bufnum)}.play
c = Buffer.alloc(s, b.numFrames, 1);

(


~genvs = SoundFile.collectIntoBuffers("/home/ddmi/Documents/grainEnv/*");
b = Buffer.read(s,"/home/ddmi/Documents/flute2.WAV");

SynthDef(\sampGH, {
	arg ibuf, obuf, del=0.1, damp=0, sz=1, dif=0.7, fb=0.7, md=0.1, mf=2, inamp=0.8, amp=0.8;
	var ph, in, out;
	ph = Phasor.ar( 0, BufRateScale.kr(ibuf), 0, BufFrames.kr(ibuf) );
	in = BufRd.ar(1, ibuf, ph);
	in = Greyhole.ar(in*inamp, del, damp, sz, dif, fb, md, mf);
	out = BufWr.ar(in.sum*amp, obuf, ph);
	//Out.ar(0, in);
}).add;

SynthDef(\grainy, {
	arg gdur=1, gdur2=1, grate=1, grate2=1, gspd=1, gspd2=1, mrate=1, start=0, end=1, buf, envbuf, envbuf2, scrub=0, amp=0.85;
	var gfreq, gfreq2, mph, gr, gr2, sig;
	gfreq = 1.0/grate;
	gfreq2 = 1.0/grate2;
	mph = Phasor.ar( 0, (1.0/BufFrames.kr(buf))*mrate, start, end );
	mph = (mph+scrub)%1;
	gr = GrainBuf.ar(1, Impulse.ar(gfreq),gdur, buf, gspd, mph,envbufnum:envbuf);
	gr2 = GrainBuf.ar(1, Impulse.ar(gfreq2),gdur2, buf, gspd2, mph,envbufnum:envbuf2);
	sig = Mix.ar([gr, gr2]);
	Out.ar(0, sig*amp);
}).add;
)

e = Synth(\sampGH, [\ibuf, b.bufnum, \obuf, c.bufnum]);
e.set(\inamp, 0.3);
e.set(\fb, 0.5, \del, 0.2, \dif, 0.9, \sz, 0.3, \damp, 0.5);
a = Synth(\grainy, [\buf, c.bufnum]);
a.set(\buf, b.bufnum);
a.set(\mrate, -1.0, \grate, 0.8975, \gdur, 0.79, \gspd,0.8, \envbuf, ~genvs[0].bufnum, \scrub, 0.0, \amp, 0.5, \grate2, 0.7749, \gdur2, 0.88, \gspd2, 0.8, \envbuf2, ~genvs[8].bufnum);
a.free
s.meter



(
SynthDef("mix-buffer", { arg stereoBuf, monoBuf, amp = 1;
        var sig;

        sig = PlayBuf.ar( 2, stereoBuf, loop: 0, doneAction: 2 );
        RecordBuf.ar( sig.sum * amp, monoBuf, loop: 0 );

}).send(s);
) 