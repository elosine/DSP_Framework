//https://dl.dropboxusercontent.com/u/1500031/grainEnv.zip
~ebufs = SoundFile.collectIntoBuffers("/Users/jyang/Dropbox/grainEnv/*");

~ebufs[8]
(
SynthDef(\dsp13, {
	arg grdur1=0.05, envbuf1= -1, ibs=0, obs=0, grate1=5, grdur2=0.05, envbuf2= -1, grate2=5, sr=3000, br=10, rez=0.4, gamp1=1, gamp2=1;
	var source, grain1, grain2, grain3, sig, grtr1,grtr2;
	grtr1 = Impulse.kr(grate1);
	grtr2 = Impulse.kr(grate2);
	source = SoundIn.ar(ibs);
	source = Greyhole.ar(source, 0.0, feedback:0.4);
	grain1 = GrainIn.ar(1, grtr1, grdur1, source, envbufnum:envbuf1);
	grain1 = Decimator.ar(grain1, sr, br);
	grain2 = GrainIn.ar(1, grtr2, grdur2, source, envbufnum:envbuf2);
	grain2 = DynKlank.ar(`[ [52+12, 53+12, 54+12, 57+12, 58+12, 59+12, 60+12, 63+12, 64+12, 52, 53, 54, 57, 58, 59, 60, 63, 64].midicps, (1.0/18)!18, rez!18  ], grain2 );
	sig = Mix.ar([grain1*gamp1, grain2*gamp2]);
	Out.ar(obs, sig);
}).add;
)


a = Synth(\dsp13);
a.set(\grate1, 7, \gdur1, 0.09, \envbuf1, ~ebufs[8], \envbuf2, ~ebufs[0], \gdur2, 0.04, \grate2, 8, \br, 13, \sr, 3000, \rez, 0.4, \gamp1, 4, \gamp2, 0.2);
a.free;
s.meter