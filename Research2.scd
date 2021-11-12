f= {2.postln};
f.value();
f = {69 + ( 12 * log( 220/440 ) / log(2) )};
f.value



//calculate midi notes of a frequency

f = { arg freq;69 + ( 12 * log( freq/440 ) / log(2) )}
f.value(440);
69.midicps;

f.(440);


a = Array.fill(5, {arg i; (i+1)*11});


m = Scale.minor.degrees;

x = m ++ [12];

n = m.choose;

y = m.scramble;

~rev = y.mirror;

(
Pbind(
	\note, Pseq(y, inf),
).play;

Pbind(
	\note, Pseq(~rev, inf);
).play;
)

f = { Array.fill(5, { 10.rand }) };
f.value;
a = Array.fill(10, f.value);
a = Array.fill(10, { f.value });
a[0]
a[1]

l = List.new;
l.add(100.rand)

a = Dictionary.new;
a.put(\key,  "value");
a.at(\key);
a.getPairs;
a.findKeyForValue("value");

b = [\C, 60, \Cs, 61, \D, 62, \Ds, 63];
x = b.indexOf(\D);
b[(x+1)]
b[x]

b = Dictionary.new
b.put(\major, [ 0, 2, 4, 5, 7, 9, 11 ]);
b.put(\minor, [ 0, 2, 3, 5, 7, 8, 10 ]);
b[\minor];

Array.openHelpFile // get the documentation of the Array class
Array.dumpInterface // get the interface or the methods of the Array class
Array.dumpFullInterface // get the methods of Array’s superclasses as well.


a = Array.new;
a = a ++ [1, 2]
a.stutter(10);
a.envirPairs(1);
a.madd(2, 100);

////////////////////////////////////////////////////////CONDITIONALS///////////////////////////////////////////////////

if( true, { "condition is TRUE".postln;}, {"condition is FALSE".postln;});
if( false, { "condition is TRUE".postln;}, {"condition is FALSE".postln;});
if(1+1==2, {"1 + 1 = 2 !!!".postln}, {"What is going on here?".postln;});


if((3 < 4) && (true != false), {"TRUE".postln;}, {"FALSE".postln});

(
a = 5.rand;
a.postln;
switch (a,
	0, {"a is zero".postln;},
	1, {"a is one".postln;},
	2, {"a is two".postln;},
	3, {"a is three".postln},
	{"a is greater than 3".postln})  // else
)

(
a = 5.rand;
case
	{a == 0} {"a is zero".postln}
    {a == 1} {"a is one".postln}
    {a == 2} {"a is two".postln}
    {a == 3} {"a is three".postln}
);

///////////////////////////////////////////////////////////ITERATION/////////////////////////////////////////////////////

10.do({ "SCRAMBLE THIS 10 TIMES".scramble.postln; })

(
var counter = 0;
10.do({
	counter = counter + 1;
	"counter is now: ".post;
	counter.postln;
})
)


.do({arg counter; counter.postln;});
// you can call this argument whatever you want:
.do({arg num; num.postln;});
// and the typical convention is to use the character "i" (for iteration):
.do({arg i; i.postln;});

(
p = List.new;
10000.do({arg i;
	if(i.isPrime, {p.add(i)});
});
Post << p;
)


(
[11,22,33,44].do({arg item, counter;
	item.post; " is in the aray at slot: ".post; counter.postln;
});
)

for(startValue, endValue, function); // this is the syntax
for(100, 130, { arg i; i = i+10; i.postln; }) // example

forBy(startValue, endValue, stepValue, function); // the syntax
forBy(100, 130, 4, { arg i; i = i+10; i.postln; }) // example

while (testFunc, bodyFunc); // syntax
(
i = 0;
while ({ i < 30 }, { i = i + 1; i.postln; });
)

{SinOsc.ar(440*SinOsc.kr(1), 0, 1)}.play

(
{
	// we create a slow oscillator in control rate
	a = SinOsc.kr(1);
	// the output of 'a' is used to multiply the frequency of a saw wave
	// resulting in a frequency from 440 to 660. Why?
	b = Saw.ar(220*(a+2), 0.5);
	// and here we use 'a' to control amplitude (from -0.5 to 0.5)
	c = Saw.ar(110, a*0.5);
	// we add b and c, and use a to control the filter cutoff frequency
	// we simply added a .range method to a so it now outputs
	// values between 100 and 2000 at 1 Hz
	d = LPF.ar(b+c, a.range(100, 2000));
	Out.ar(0, Pan2.ar(d, 0));
}.play
)


UGen.browse


(
SynthDef(\mysaw, { arg freq=440, amp=0.2, pan=0, cutoff=880, rq=0.3;
	var signal, filter, panned, env;
	env = Env.perc(0.01, 1).kr(2);
	signal = Saw.ar(freq, 0.2*env);
	filter = RLPF.ar(signal, cutoff, rq);
	panned = Pan2.ar(filter, pan);
	panned = panned;
	Out.ar(0, panned);
}).add;
)

x = Synth(\mysaw);

(
Pbind(
	\instrument, \mysaw,
	\note, Pseq([0,2,3,5,7], inf),
	\dur, Pseq([0.5], inf)
).play;
)


//////////////////////////////////////////////////Proxyspace/////////////////////////////////////////////////////////////////

p= ProxySpace.push(s.boot)
~signal.play;
~signal.fadeTime_(2) // fading in and out in 2 secs
~signal= {SinOsc.ar(400, 0, 1)!2}
~signal= {SinOsc.ar([400, 404], 0, LFNoise0.kr(4))}
~signal= {Saw.ar([400, 404], LFNoise0.kr(4))}
~signal= {Saw.ar([400, 404], Pulse.ar(2))}
~signal= {Saw.ar([400, 404], Pulse.ar(Line.kr(1, 30, 20)))}
~signal= {LFSaw.ar([400, 404], LFNoise0.kr(4))}
~signal= {Pulse.ar([400, 404], LFNoise0.kr(4))}
~signal= {Blip.ar([400, 404], 12, Pulse.ar(2))}
~signal= {Blip.ar([400, 404], 24, LFNoise0.kr(4))}
~signal= {Blip.ar([400, 404], 4, LFNoise0.kr(4))}
~signal= {Blip.ar([400, 404], MouseX.kr(4, 40), LFNoise0.kr(4))}
~signal= {Blip.ar([200, 204], 5, Pulse.ar(1))}
// now let's try to add some effects

~signal[1] = \filter -> {arg sig; (sig*0.6)+FreeVerb.ar(sig, 0.85, 0.86, 0.3)}; // reverb
~signal[2] = \filter -> {arg sig; sig + AllpassC.ar(sig, 1, 0.15, 1.3)}; // delay
~signal[3] = \filter -> {arg sig; (sig * SinOsc.ar(2.1, 0, 5.44, 0))*0.5}; // tremolo

~signal[1] = nil;
~signal[2] = nil;
~signal[3] = nil;




p = ProxySpace.push(s.boot);
~blipper = { |freq=20, nHarm=30, amp=0.1| Blip.ar(freq, nHarm, amp)!2 };
~blipper.play;
~lfo = { MouseX.kr(10, 100, 1) };
~blipper.map(\freq, ~lfo);
~blipper.set(\nHarm, 50)
~lfn = { LFDNoise3.kr(15, 30, 40) };
~blipper.map(\nHarm, ~lfn);
~lfn = 30;
~blipper.set(\nHarm, 50);


////////////////////////////////////NDEF, they are similar to synthdef but use proxyspace and can be changed on the fly/////

Ndef(\sound).play;
Ndef(\sound).fadeTime = 1;
Ndef(\sound, { SinOsc.ar([600, 635], 0, SinOsc.kr(2).max(0) * 0.2) });
Ndef(\sound, { SinOsc.ar([600, 635] * 3, 0, SinOsc.kr(2 * 3).max(0) * 0.2) });
Ndef(\sound, { SinOsc.ar([600, 635] * 2, 0, SinOsc.kr(2 * 3).max(0) * 0.2) });
Ndef(\sound, Pbind(\dur, 0.17, \freq, Pfunc({ rrand(300, 700) })) );
Ndef(\lfo, { LFNoise1.kr(3, 400, 800) });
Ndef(\sound).map(\freq, Ndef(\lfo));
Ndef(\sound, { arg freq; SinOsc.ar([600, 635] + freq, 0, SinOsc.kr(2 * 3).max(0) * 0.2) });
Ndef(\lfo, { LFNoise1.kr(300, 400, 800) });
Ndef.clear; //clear all Ndefs


///////////////////////////////////////////7Tasks, Routines, forks and loops///////////////////////////////////////////////

(
Routine({
	inf.do({arg i;
		"iteration: ".post; i.postln;
		0.25.wait;
	})
}).play
)

// This could also be written as:
(
fork{
	inf.do({arg i;
		"iteration: ".post; i.postln;
		0.25.wait;
	})
}
)


(
r = Routine.new({
	10.do({ arg a;
		a.postln;
		1.wait;
	});
	0.5.wait;
	"routine finished!".postln;
});
)

SystemClock.play(r); // and then we run it
r.reset // we have to reset the routine to start it again:
AppClock.play(r); // here we tell AppClock to play routine r
r.play(AppClock) // or we can use this syntax
r.stop; // stop the routine
r.play; // try to start the routine again... It won't work.

// Tasks are pausable processes

(
t = Task({
	inf.do({arg i;
		"iteration is: ".post; i.postln;
		0.25.wait;
	})
});
)

t.play;
t.pause;
t.resume;
t.stop;
t.play;
t.reset;

/* Let’s make some music with a Task. We can put some note values into an array and then ask a Task to
loop through that array, repeating the melody we make. First we create a SynthDef that we would like to
use for this piece of music: */

(
SynthDef(\name, {
	arg freq=333, amp=0.4, pan=0.0, dur=0.41; //the arguments
	var signal, env;
	env = EnvGen.ar(Env.perc(0.001, dur), doneAction:2); //doneAction gets rid of the synth
	signal = LFTri.ar(freq, 0, amp) * env; //the envelope multiplies the signal
	signal= Pan2.ar(signal, pan);
	Out.ar(0, signal);
}).add;
)

// And here we create a composition to play it:


(
m = ([ 0, 1, 5, 6, 10, 12 ]+48).midicps;
m = m.scramble; // try to re-evaluate only this line
t = Task({
	inf.do({arg i;
		Synth(\name, [\freq, m.wrapAt(i)]);
		0.25.wait;
	})
});
t.play;
)

// create a loop to scramble m

(
f = Task({
	inf.do({arg i;
		m=m.scramble;
		"SCRAMBLING".postln;
		4.8.wait;
	})
});
f.play;
)

// same as

f = fork{
	inf.do({arg i;
		m = m.scramble;
		"SCRAMBLING".postln;
		4.8.wait; // why did I choose 4.8 second wait.
	})
}


////////////////////////////////////////////////////PATTERNS////////////////////////////////////////////////////////////

().play; // run this Event and we observe the posting of default arguments
Pbind().play; // the event arguments are used in the Pbind.


// the synthdef has the conventional 'freq' and 'amp' arguments, but also our own 'cutoff'
(
SynthDef(\patsynth1, { arg out=0, freq=440, amp=0.1, pan=0, cutoff=1000, gate = 1;
	var signal = MoogFF.ar( Saw.ar(freq, amp), cutoff, 3);
	var env = EnvGen.kr(Env.adsr(), gate, doneAction: 2);
	Out.ar(out, Pan2.ar(signal, pan, env) );
}).add;
)
// we play our 'patsynth1' instrument, and control the cutoff parameter
Pbind(\instrument, \patsynth1, \freq, 100, \cutoff, 300, \amp, 0.6).play;
// try this as well:
Pbind(\instrument, \patsynth1, \freq, 100, \cutoff, 3000, \amp, 0.6).play;

Pbind(\instrument, \patsynth1, \freq, 100, \amp, 0.6, \dur, 0.5).play;
Pbind(\instrument, \patsynth1, \freq, 100, \amp, 0.6, \dur, 0.5, \sustain, 0.1).play;


// here we format it differently, into pairs of keys and values
(
Pbind(
	\instrument, \patsynth1,
	\freq, Pseq([100, 200, 120, 180], inf), // sequencing frequency
	\amp, 0.6,
	\dur, 0.5
).play;
)

// we can use list patterns for values to any keys:
(
Pbind(
	\instrument, \patsynth1,
	\freq, Prand([100, 200, 120, 180], inf),
	\amp, Pseq([0.3, 0.6], inf),
	\dur, Pseq([0.125, 0.25, 0.5, 0.25], inf),
).play;
)
(
Pbind(
	\instrument, \patsynth1,
	\freq, Pseq([100, 200, 120, 180], inf),
	\cutoff, Pseq([1000, 2000, 3000], inf), // only 3 items in the list - it loops
	\amp, Pseq([0.3, 0.6], inf),
	\dur, Pseq([0.125, 0.25, 0.5, 0.25], inf),
).play;
)

// here we put a pattern into a variable "a"
(
a = Pdef.new(\example1,
	Pbind(\instrument, \patsynth1, // using our sine synthdef
		\freq, Pseq([220, 440, 660, 880], inf), // freq arg
		\dur, Pseq([0.25, 0.5, 0.25, 0.5], inf); // dur arg
	)
);
)
a.play;
a.pause;
a.resume;
// but we don't need to:
(
Pdef(\example2,
	Pbind(\instrument, \patsynth1, // using our sine synthdef
		\freq, Pseq.new([720, 770, 990, 880], inf), // freq arg
		\dur, Pseq.new([0.25, 0.5, 0.25, 0.5], inf); // dur arg
	)
);
)
Pdef(\example2).play;
Pdef(\example2).pause;
Pdef(\example2).resume;
// Now, let's play them both together with a bit of timeshift
(
Pdef(\example1).quant_([2, 0, 0]);
Pdef(\example2).quant_([2, 0.5, 1]); // offset by half a beat
Pdef(\example1).play;
Pdef(\example2).play;
)
// and without stopping we redefine the example1 pattern:
(
Pdef(\example1,
	Pbind(\instrument, \patsynth1, // using our sine synthdef
		\freq, Pseq.new([                        // Pseq.new is the same as Pseq?
			Pseq.new([220, 440, 660, 880], 4),
			Pseq.new([220, 440, 660, 880], 4) * 1.5], // transpose the melody
		inf),
		\dur, Pseq.new([0.25, 0.125, 0.125, 0.25, 0.5], inf); // dur arg
	)
);
)


/////////////////////////////////////////////////TEMPOCLOCK///////////////////////////////////////////////////////

t = TempoClock.new;
t.tempo = 1; // 1 beat per second = 60bpm
t.sched(4, { arg beat, sec; [beat, sec].postln; }); // wait for 4 beats (4 secs);

/* You will note that the beat is a fractional number. This is because the beat returns the appropriate beat
time of the clock’s thread. If you prefer to have the beats in whole numbers, you can use the schedAbs
method */

t = TempoClock.new;
t.tempo = 4; // we make the tempo 240 bpm (240/60 = 4)
t.schedAbs(4, { arg beat, sec; [beat, sec].postln; }); // wait for 4 beats (1 sec);

//If we would like to schedule the function repeatedly, we add a number representing the next beat at the end of the function.

t = TempoClock.new;
t.tempo = 1;
t.schedAbs(0, { arg beat, sec; [beat, sec].postln; 1});

t = TempoClock.new;
t.tempo = 1;
t.schedAbs(0, { arg beat, sec; [beat, sec].postln; 1}); //Post beat, sec in 0 beats = immediately, wait 1 beat and do again
t.schedAbs(0, { arg beat, sec; "_Scramble_".scramble.postln; 0.5}); //wait 0.5 beats and do it again

(
t = TempoClock.new;
t.tempo = 1;
(
t.schedAbs(0, {arg beat, sec;
	{SinOsc.ar(rrand(100.0, 1000.0)!2, 0.0, 0.1*EnvGen.ar(Env.new([0, 1, 0], [0.01, t.tempo], curve:0), doneAction: 2))}.play; 1})
)
)


// We can try to make some rhythmic pattern with the tempoclock now. Let us just use a simple synth like the one we had above, but now we call it ‘clocksynth’.


// our synth
(
SynthDef(\clocksynth, { arg out=0, freq=440, amp=0.5, pan=0, cutoff=1000, gate = 1;
	var signal = MoogFF.ar( Saw.ar(freq, amp), cutoff, 3);
	var env = EnvGen.kr(Env.perc(), gate, doneAction: 2);
	Out.ar(out, Pan2.ar(signal, pan, env) );
}).add;
)
// the clock
t = TempoClock.new;
t.tempo = 2;
(
t.schedAbs(0, { arg beat, sec;
	Synth(\clocksynth, [\freq, 440]);
	if(beat%4==0, { Synth(\clocksynth, [\freq, 440/4, \amp, 1]); });
	if(beat%2==0, { Synth(\clocksynth, [\freq, 440*4, \amp, 1]); });
	1});
)

// Yet another trick to play sounds in SuperCollider is to use “fork” and schedule a pattern through looping.
// If you look at the source of .fork (by hitting Cmd+I) you will see that it is essentially a Routine (like
// above), but it is making our lives easier by wrapping it up in a method of Function.

(
var clock, waitTime;
waitTime = 2;
clock = TempoClock(2, 0);
{ // a fork
	"starting the program".postln;
	{ // and we fork again (play 10 sines)
		10.do({|i|
			Synth(\clocksynth, [\freq, 1000+(rand(1000))]);
			"synth nr : ".post; i.postln;
			(waitTime/10).wait; // wait for 100 milliseconds
		});
		"end of 1st fork".postln;
	}.fork(clock);
	waitTime.wait;
	"finished waiting, now we play the 2nd fork".postln;
	{ // and now we play another fork where the frequency is lower
		20.do({|i|
			Synth(\clocksynth, [\freq, 100+(rand(1000))]);
			"synth nr : ".post; i.postln;
			(waitTime/10).wait;
		});
		"end of 2nd fork".postln;
	}.fork(clock);
	"end of the program".postln;
}.fork(clock);
)


////////////////////////////////////////////////////////GUI//////////////////////////////////////////////////////////////////

(
SynthDef(\simpleSynth, {|freq, amp|
	var signal, harmonics;
	harmonics = 16;
	signal = Mix.fill(harmonics, {arg i; SinOsc.ar(freq*(i+1), 1.0.rand, amp
		* harmonics.reciprocal/(i+1)) }); Out.ar(0, signal ! 2); }).add;
)

(
var synth, win, freqsl, ampsl;
// create a GUI window
win = Window.new("simpleSynth", Rect(100, 100, 300, 90), false).front;
// and place the frequency and amplitude sliders in the window
StaticText.new(win, Rect(10,10, 160, 20)).font_(Font("Helvetica", 9)).string_("freq");
freqsl = Slider.new(win, Rect(40,10, 160, 24)).value_(1.0.rand)
.action_({arg sl; synth.set(\freq, sl.value*1000;) });
StaticText.new(win, Rect(10,46, 160, 20)).font_(Font("Helvetica", 9)).string_("amp");
ampsl = Slider.new(win, Rect(40,46, 160, 24)).value_(1.0.rand)
.action_({arg sl; synth.set(\amp, sl.value) });
// a button to start and stop the synth. If the button value is 1 we start it, else stop it
Button.new(win, Rect(220, 10, 60, 60)).states_([["create"], ["kill"]])
.action_({arg butt;
	if(butt.value == 1, {
		// the synth is created with freq and amp values from the sliders
		synth = Synth(\simpleSynth, [\freq, freqsl.value*1000, \amp, ampsl.value]);
	},{
		synth.free;
	});
});
)




////////////////////////////////////////////////////////////////////////////////////////////////////// NOTES


{SinOsc.ar([880,880])}.play

(
x = {
	var sig, rmod;
	sig = Pan2.ar(SinOsc.ar(freq: 880.0, phase: 0.0, mul: 0.5, add: 0.0)) //The basic sin function
	rmod = sig * SinOsc.ar(700);                                                              //Which we modulate here
}.play;
)


(
x = {
	var sig, rmod;
	sig = SinOsc.ar([800, 800]);
	rmod = sig * SinOsc.ar(700);
}.play;
)




(
x = {
	var sig, rmod;
	sig = SinOsc.ar([800, 800]);                  //The basic sin function
	rmod = sig * SinOsc.ar(700);                //Which we modulate with another Sinus wave at 700hz
}.play;
)

(
x = {
	var freq = 20000;
	SinOsc.ar([freq,freq], mul: 0.1);
}.play
)

x.set(\freq, 500);


~sample = Buffer.readChannel(s, "/home/nikolas/.local/share/SuperCollider/Recordings/guitar.aiff");

(
Routine({
	inf.do({arg i;
		~sample.play;
		8.5.wait;
	})
}).play
)
