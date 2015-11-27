b = Buffer.read(s, "/Volumes/JY_Archive 2/ExtractSamps/Bounces/kirk.L.aif");
c = Buffer.read(s, "/Volumes/JY_Archive 2/ExtractSamps/Bounces/pathetique.L.aif");
(
SynthDef(\spectralvocoder, {
	arg freeze = 0, mode = #[0,2,4,5,7,9,11], root=60, pchgrate=3,
	carbuf, modbuf, modamp=1, caramp=1;
	var bufA, bufB, chain1, chain2, out, car, mod;
	car = PlayBuf.ar(1, carbuf);
	mod = PlayBuf.ar(1, modbuf);
	bufA = LocalBuf.new(2048);
	bufB = LocalBuf.new(2048);
	chain1 = FFT(bufA, car*caramp); // to be filtered
	chain2 = FFT(bufB, mod*modamp);
	chain1 = PV_SpectralMap(chain1, chain2, 0.0, freeze, 1.8, 1);
	out = IFFT(chain1);
	Out.ar(0, out.dup);
}).add
)
a = Synth(\spectralvocoder, [\carbuf, c.bufnum, \modbuf, b.bufnum,\modamp, 100, \caramp, 5]);
a.set(\modamp, 100, \caramp, 1);
a.free;
