MIDIClient.init;
MIDIIn.connectAll;

(
MIDIdef.noteOn(\noteOnTest, {
	arg vel, nn, chan, src;
	[vel, nn].postln;
	{
		var sig, env;
		sig = MdaPiano.ar(freq: nn.midicps, gate: 1, vel: 100, decay: 0.8, release: 0.8, hard: 0.8, velhard: 0.8, muffle: 0.8, velmuff: 0.8, velcurve: 0.8, stereo: 0.2, tune: 0.5, random: 0.1, stretch: 0.1, sustain: 0, mul: 1, add: 0);
		env = EnvGen.kr(Env.perc, doneAction:2);
		sig = sig * env * vel.linexp(1,127,0.01,0.3);
	}.play;
});
)

s.boot;









































