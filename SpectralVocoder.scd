
(
SynthDef(\spectralvocoder, {
	arg freeze = 0, mode = #[0,2,4,5,7,9,11], root=60, pchgrate=3;
	var bufA, bufB, chain1, chain2, out, freq;
	freq = (TChoose.kr(Impulse.kr(pchgrate), mode)+root).midicps;
	bufA = LocalBuf.new(2048);
	bufB = LocalBuf.new(2048);
	chain1 = FFT(bufA, LFSaw.ar( freq )); // to be filtered
	chain2 = FFT(bufB, SoundIn.ar(0)*10);
	chain1 = PV_SpectralMap(chain1, chain2, 0.0, freeze, 2.4, 1);
	out = IFFT(chain1);
	Out.ar(0, out.dup);
}).add
)
a = Synth(\spectralvocoder);
a.set(\mode, [0,1,2,3,4,5,6], \root, 60); //chromatic
a.set(\mode, [0,2,3,5,7,9,11], \root, 48, \pchgrate, 15); //melodic minor
a.set(\mode, [0,3,5,6,7,10,12], \root, 70, \pchgrate, 5); //blues
a.set(\mode, [0,4,7,10,9,11,5], \root, 51, \pchgrate, 2); //Dominant Bebop
a.set(\mode, [0,2,3,5,7,9,10], \root, 71, \pchgrate, 5); //Dorian
a.set(\mode, [0,2,4,5,7,9,11], \root, 36); //major
a.free;
