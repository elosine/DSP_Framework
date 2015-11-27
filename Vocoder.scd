(
SynthDef(\vocoder,{
	arg prate=3, mode = #[0,2,4,5,7,9,11], root=60, mix=0.8;
	var in, voc, freq, car, car1, car2, freq1, freq2, pitch;
	pitch = TChoose.kr(Impulse.kr(prate),mode)+root;
	freq = pitch.midicps;
	freq1 = (pitch+12).midicps;
	freq2 = (pitch-12).midicps;
	in=SoundIn.ar(0);
	car = Saw.ar(freq)*0.333;
	car1 = Saw.ar(freq1)*0.333;
	car2 = Saw.ar(freq2)*0.333;
	//voc = Vocoder.ar( car+car1+car2, in, 56);
	voc = Vocoder.ar( car, in, 56);
	Out.ar(1, (voc*mix)+(in*(1-mix)));
}).add;
)

a = Synth(\vocoder);
a.set(\mode, [0,1,2,3,4,5,6], \root, 60); //chromatic
a.set(\mode, [0,2,3,5,7,9,11], \root, 48, \pchgrate, 15); //melodic minor
a.set(\mode, [0,3,5,6,7,10,12], \root, 35, \pchgrate, 5, \mix, 1); //blues
a.set(\mode, [0,4,7,10,9,11,5], \root, 51, \pchgrate, 2); //Dominant Bebop
a.set(\mode, [0,2,3,5,7,9,10], \root, 71, \pchgrate, 2); //Dorian
a.set(\mode, [0,2,4,5,7,9,11], \root, 36); //major