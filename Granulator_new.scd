


{PlayBuf.ar(1, c.bufnum)}.play
c = Buffer.alloc(s, b.numFrames, 1);

(


~genvs = SoundFile.collectIntoBuffers("/Volumes/Ute/Freeze/grainEnv/" ++ "*");
b = Buffer.read(s,"/home/ddmi/Documents/flute2.WAV");
c = Buffer.read(s, "/Volumes/JY_Archive 2/ExtractSamps/Bounces/shanai_1.L.aif");
d = Buffer.read(s, "/Users/jyang/GitHub/superimposition/monosamples/harp9Gs3SOFT.aif");
e = Buffer.read(s, "/Users/jyang/GitHub/superimposition/monosamples/barisax.L.aif");

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
	mrate=1, start=0, end=1, buf, scrub=0, amp=0.85, gate=1, gate2=1,
	atk=1.5, rel=3, crv=0;
	var sig, env2, envmain;
	var gfreq, mph, gr;
	var gfreq2, mph2, gr2;
	var gfreq3, mph3, gr3;
	var gfreq4, mph4, gr4;
	envmain = EnvGen.ar(Env.asr(atk,1,rel,crv), gate, doneAction:2);
	env2 = EnvGen.ar(Env.asr(atk,1,rel,crv), gate2);
	gfreq = 1.0/grate;
	gfreq2 = 1.0/grate2;
	gfreq3 = 1.0/grate3;
	gfreq4 = 1.0/grate4;
	mph = Phasor.ar( 0, (1.0/BufFrames.kr(buf))*mrate, start, end );
	mph = (mph+scrub)%1;
	mph2 = (mph+0.25)%1;
	mph3 = (mph+0.5)%1;
	mph4 = (mph+0.75)%1;
	gr = GrainBuf.ar(1, Impulse.ar(gfreq),gdur, buf, gspd, mph,envbufnum:envbuf);
	gr2 = GrainBuf.ar(1, Impulse.ar(gfreq2),gdur2, buf, gspd2, mph,envbufnum:envbuf2);
	gr3 = GrainBuf.ar(1, Impulse.ar(gfreq3),gdur3, buf, gspd3, mph,envbufnum:envbuf3);
	gr4 = GrainBuf.ar(1, Impulse.ar(gfreq4),gdur4, buf, gspd4, mph,envbufnum:envbuf4);
	sig = Mix.ar([gr*0.25, gr2*0.25, gr3*0.25, gr4*0.25]);
	Out.ar(0, sig*amp*envmain*env2);
}).add;
)

(
a = Synth(\grainy, [
	\buf, c.bufnum, \mrate, 1, \scrub, 0.0, \amp, 0.5,
	\grate, 0.08, \gdur, 0.3, \gspd,1, \envbuf, ~genvs[5].bufnum,
	\grate2, 0.1, \gdur2, 0.3, \gspd2, 1, \envbuf2, ~genvs[5].bufnum,
	\grate3, 0.1, \gdur3, 0.3, \gspd3, 1, \envbuf3, ~genvs[5].bufnum,
	\grate4, 0.1, \gdur4, 0.3, \gspd4, 1, \envbuf4, ~genvs[5].bufnum
]);
)
(
a.set(
	\buf, e.bufnum, \mrate, -0.03, \scrub, 0.0, \amp, 0.8, \gate2, 1,
	\grate, 0.08, \gdur, 0.1, \gspd,1, \envbuf, ~genvs[6].bufnum,
	\grate2, 0.07, \gdur2, 0.4, \gspd2, 1, \envbuf2, ~genvs[6].bufnum,
	\grate3, 0.06, \gdur3, 0.7, \gspd3, 1, \envbuf3, ~genvs[6].bufnum,
	\grate4, 0.05, \gdur4, 0.5, \gspd4, 1, \envbuf4, ~genvs[6].bufnum
);
)
a.set(\gate2, 0);
a.set(\gate2, 1);
(
a.set(
	\buf, e.bufnum, \mrate, 15.03, \scrub, 0.0, \amp, 0.8, \gate2, 1,
	\grate, 0.1, \gdur, 0.83, \gspd,1, \envbuf, ~genvs[6].bufnum,
	\grate2, 0.41, \gdur2, 0.74, \gspd2, 1, \envbuf2, ~genvs[6].bufnum,
	\grate3, 0.13, \gdur3, 0.87, \gspd3, 1, \envbuf3, ~genvs[6].bufnum,
	\grate4, 0.08, \gdur4, 0.42, \gspd4, 1, \envbuf4, ~genvs[6].bufnum
);
)
a.set(\gate2, 0);
a.set(\gate2, 1);
(
a.set(
	\buf, d.bufnum, \mrate, -0.02, \scrub, 0.0, \amp, 1, \gate2, 1,
	\grate, 0.13, \gdur, 0.34, \gspd,1, \envbuf, ~genvs[3].bufnum,
	\grate2, 0.673, \gdur2, 0.35, \gspd2, 1, \envbuf2, ~genvs[8].bufnum,
	\grate3, 0.71, \gdur3, 0.52, \gspd3, 1, \envbuf3, ~genvs[3].bufnum,
	\grate4, 0.1435, \gdur4, 0.27, \gspd4, 1, \envbuf4, ~genvs[8].bufnum
);
)
a.set(\gate2, 0);
a.set(\gate2, 1);

a.set(\gate, 0);


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