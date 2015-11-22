(
SynthDef(\vocoder,{
	/*arg pitch=60 ;*/
	var in, voc, freq, car, car1, car2, freq1, freq2, pitch=60, num;
	var scale = [60, 62, 64, 65, 67, 69, 71, 72, 74, 76];

	pitch = TIRand.kr(48, 72, Impulse.kr(5));
	freq = pitch.midicps;
	freq1 = (pitch+12).midicps;
	freq2 = (pitch-12).midicps;
	in=SoundIn.ar(0);
	car = Saw.ar(freq)*0.333;
	car1 = Saw.ar(freq1)*0.333;
	car2 = Saw.ar(freq2)*0.333;
	voc = Vocoder.ar( car+car1+car2, in, 70);
	Out.ar(1, voc);
}).add;
)

a = Synth(\vocoder);
a.set(\pitch, 60);
a.set(\pitch, 64);
a.set(\pitch, 67);