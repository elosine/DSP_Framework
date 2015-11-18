


{PlayBuf.ar(1, c.bufnum)}.play
c = Buffer.alloc(s, b.numFrames, 1);

(


~genvs = SoundFile.collectIntoBuffers("/Volumes/Ute/Freeze/grainEnv/" ++ "*");
b = Buffer.read(s,"/home/ddmi/Documents/flute2.WAV");
c = Buffer.read(s, "/Volumes/JY_Archive 2/ExtractSamps/Bounces/shanai_1.L.aif");

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
	arg gdur=1, grate=1, gspd=1, envbuf,
	gdur2=1, grate2=1, gspd2=1,  envbuf2,
	gdur3=1, grate3=1, gspd3=1,  envbuf3,
	gdur4=1, grate4=1, gspd4=1,  envbuf4,
	mrate=1, start=0, end=1, buf, scrub=0, amp=0.85, gate=1;
	var sig, env;
	var gfreq, mph, gr;
	var gfreq2, mph2, gr2;
	var gfreq2, mph2, gr2;
	var gfreq2, mph2, gr2;
	env = EnvGen.ar(Env.asr(), gate, doneAction:2);
	gfreq = 1.0/grate;
	gfreq2 = 1.0/grate2;
	mph = Phasor.ar( 0, (1.0/BufFrames.kr(buf))*mrate, start, end );
	mph = (mph+scrub)%1;
	mph2 = (mph+0.25)%1;
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
a.set(\mrate, 1, \grate, 0.1, \gdur, 0.3, \gspd,1, \envbuf, ~genvs[5].bufnum, \scrub, 0.0, \amp, 0.5, \grate2, 0.1, \gdur2, 0.3, \gspd2, 1, \envbuf2, ~genvs[5].bufnum);
a.free
s.meter



(
SynthDef("mix-buffer", { arg stereoBuf, monoBuf, amp = 1;
        var sig;

        sig = PlayBuf.ar( 2, stereoBuf, loop: 0, doneAction: 2 );
        RecordBuf.ar( sig.sum * amp, monoBuf, loop: 0 );

}).send(s);
) 