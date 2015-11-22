
(
SynthDef(\spectralvocoder, {
	arg freeze = 0, mode = #[1,3,5,6,8,10,12], root=60, pchgrate=3;
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
a.set(\mode, [1,2,3,4,5,6,7], \root, 60); //chromatic
a.set(\mode, [1,3,4,6,8,10,12], \root, 48, \pchgrate, 15); //melodic minor
a.set(\mode, [1,4,6,7,8,11,13], \root, 70, \pchgrate, 5); //blues
a.set(\mode, [1,5,8,11,10,12,6], \root, 51, \pchgrate, 2); //Dominant Bebop
a.set(\mode, [1,3,4,6,8,10,11], \root, 71, \pchgrate, 2); //Dorian
a.set(\mode, [1,3,5,6,8,10,12], \root, 36); //major
a.free;
