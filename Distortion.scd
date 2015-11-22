
SynthDef(\distort, {
	arg ibs=0, obs=0, thresh=0.1;
	var in, amount, amCoef,sig;
	in = SoundIn.ar(ich);
	sig = Compander.ar(in, in,thresh,10,1,0.01,0.01); //gate
	sig = HPF.ar(sig, 400)*5;
	amount = 0.99;
	amCoef = 2*amount/(1-amount);
	sig = MidEQ.ar(LPF.ar((1+amCoef)*sig/(1+(amCoef*sig.abs)), [3800, 3900])*0.5, 120, 0.7, 8);
	Out.ar(obs, sig);
}).add;

