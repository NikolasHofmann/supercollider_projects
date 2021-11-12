(
z = {
	arg freq=440, amp=0.125;
	var sig;
	sig = Pan2.ar(SinOsc.ar(freq) * amp);
}.play;
)


z.set(\freq, 330);
z.set(\freq, 440);
z.set(\freq, 495);
z.set(\freq, 550);
z.set(\freq, (440-(45/2)));
z.set(\amp, 0.125);
z.set(\freq, 660, \amp, 1);
z.set(\amp, 0.125, \freq, 550);
z.set(\amp, 0.125, \freq, 495);
z.free;


(
z = {
	arg noiseHz = 4;
	var freq, amp, sig;
	freq = LFNoise0.kr(noiseHz).exprange(200,1000);
	amp = LFNoise1.kr(8).exprange(0.1, 1);
	sig = Pan2.ar((SinOsc.ar(freq)*amp), 0.0, 0.7);
}.play;
)

z.set(\noiseHz, 20);
z.set(\noiseHz, exprand(4, 200));

z.free;


(
z = {
	arg noiseHz = 8;
	var freq, amp, sig;
	freq = LFNoise0.kr(noiseHz).exprange(200,1000);
	amp = LFNoise1.kr(8).exprange(0.1, 1);
	sig = Pan2.ar((SinOsc.ar(freq)*amp), 0.0, 0.7);
}.play;
)



(
SynthDef.new(\sineTest, {
	arg noiseHz = 8;
	var freq, amp, sig;
	freq = LFNoise0.kr(noiseHz).exprange(200,1000);
	amp = LFNoise1.kr(8).exprange(0.1, 1);
	sig = Pan2.ar(SinOsc.ar(freq) * amp);
	Out.ar(0, sig);
}).add;
)

x = Synth.new(\sineTest, [\noiseHz, 128]);

x.set(\noiseHz, 43);
x.set(\noiseHz, 2);
x.set(\noiseHz, 18);
x.set(\noiseHz, 36);
x.set(\noiseHz, 2000);
x.set(\noiseHz, 400);


x.free;



(
SynthDef.new(\pulseTest, {
	arg ampHz=4, fund=40, maxPartial=4, width=0.5;
	var amp1, amp2, freq1, freq2, sig1, sig2;
	amp1 = LFPulse.kr(ampHz, 0, 0.12) * 0.75;
	amp2 = LFPulse.kr(ampHz, 0.5, 0.12) * 0.75;
	freq1 = LFNoise0.kr(4).exprange(fund, fund*maxPartial).round(fund);
	freq2 = LFNoise0.kr(4).exprange(fund, fund*maxPartial).round(fund);
	freq1 = freq1 * LFPulse.kr(8, add:1);
	freq2 = freq2 * LFPulse.kr(6, add:1);
	sig1 = Pulse.ar(freq1, width, amp1);
	sig2 = Pulse.ar(freq2, width, amp2);
	sig1 = FreeVerb.ar(sig1, 0.7, 0.8, 0.25);
	sig2 = FreeVerb.ar(sig2, 0.7, 0.8, 0.25);
	Out.ar(0, sig1);
	Out.ar(1, sig2);
}).add;
)

y = Synth.new(\pulseTest);

y.set(\width, 0.1)

y.free;




MIDIClient.init;
MIDIIn.connectAll;

(
MIDIdef.noteOn(\noteOnTest, {
	arg vel, nn, chan, src;
	[vel, nn].postln;
	~notes[nn] = Synth.new(
		\tone,
		[
			\freq, nn.midicps,
			\amp, vel.lineexp(1,127,0.01,0.3),
			\gate, 1,
			\bend, ~bend.linlin(0,16383,-2,2),
		]
	);
});

MIDIdef.noteOff(\noteOffTest, {
	arg vel, nn;
	[vel, nn].postln;
	~notes[nn].set(\gate, 0);
	~notes[nn] = nil;
});

MIDIdef.bend(\bendTest, {
	arg val, chan, src;
	[val, chan, scr].postln;
	~bend = val;
	~notes.do{arg synth; synth.set(\bend, val.linlin(0,16383,-2,2))};
}, chan:0);
)

nil.set(\freq, 880

(
SynthDef.new(\tone, {
	arg freq=440, amp=0.3, gate=0;
	var sig, env;
	sig = LFTri.ar(freq)!2;
	env = EnvGen.kr(Env.adsr, gate, doneAction:2);
	sig = sig * env * amp;
	Out.ar(0, sig);
}).add;
)


x = Synth.new(\tone, [\gate, 1]);
x.set(\gate, 0);

~notes = Array.newClear(128);

(
var number;
number = 3.cubed;
)





