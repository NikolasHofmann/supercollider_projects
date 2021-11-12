//single line comment


/*
multi line comment
*/

/*how to make sound?
Make sure server is running with "Server.local.boot;". I solved this by adding a automation for booting the server in
the startup file.

If everything on the right bottom corner is green we are good to go.

*/

//Sound input, ar([0,0]) is needed for for multichannel expansion, with ar(0) the signal would be only on the left side
// can also be written as ar(0!2)

x = {SoundIn.ar([0,0])}.play;    // a-z are reserved global variables, otherwise we can define global vars with ~varibale

x.free;

//Signal processing, example of a ring modulator

(
x = {
	var sig, rmod;
	sig = SoundIn.ar([0,0]);
	rmod = sig * SinOsc.ar(700);
	//(sig + rmod) *0.5;
}.play;
)

x.free;

//How to create a FreqScope to further understand what is happening during ring modulation?
//For this we need to understand a little about gui to be able to have the window always on top
(
w = Window.new;
w.alwaysOnTop = true;  // alternate syntax: w.alwaysOnTop_(true); which allows for a concatenation of several methods
w.front;    // sets visibility to true and brings it to the front most position.
)

w.bounds;
/* "w.bounds;" returns the size and position of the window. We can shape these variables and when we want to create the
window in the future we can create it in that position like this: "w = Window.new("window_title", Rect(3471.0, 146.0, 369.0, 231.0)
*/

//So we can create the window like this:
(
w = Window.new("FreqScope", Rect.new(3500.0, 183.0, 369.0, 231.0));
w.alwaysOnTop = true;
w.front;
)

w.close; // or click x

Window.allWindows;

Window.closeAll;

//How to create a FreqScope

(
w = Window("Freq Scope", Rect(3500.0, 184.0, 369.0, 231.0)); // width should be 511
f = FreqScopeView(w, w.view.bounds);  //"w.view is the container view that occupies the whole area of the window
f.active_(true); // turn it on the first time;
f.freqMode = 0; // 0=linear, 1 = logarithmic
f.dbRange_(200);
w.onClose_({ f.kill }); // you must have this
w.alwaysOnTop = true;
w.front;
)

// How to create an oscilloscope, alternatively we can use the message ".scope" on a ugen

(
b = Window("Osc Scope", Rect(3474.0, 450.0, 366.0, 250.0));
k = Stethoscope.new(s, numChannels: 1, index: 0, bufsize: 4096, zoom: 1.0, rate: 'audio', view: b);
b.onClose_({ k.kill }); // you must have this
b.alwaysOnTop = true;
b.front;
)

Window.closeAll;

// test the scopes

{Pan2.ar(SinOsc.ar(freq: 880.0, phase: 0.0, mul: 0.5, add: 0.0))}.play

{Pan2.ar(SinOsc.ar(freq: 1200.0, phase: 0.0, mul: 0.5, add: 0.0))}.play

//use the scopes to see how ring modulation looks like

(
x = {
	var sig, rmod;
	sig = SinOsc.ar(freq: 880.0, phase: 0.0, mul: 0.5, add: 0.0);
	rmod = sig * SinOsc.ar(700);
	//(sig + rmod) *0.5;
}.play;
)

//->>> conclusion: This is useful for signal processing and understanding of effects applied to the signal

//how to apply a delay effect?
(
x = {
	var sig, echo;
	sig = SoundIn.ar([0,0]);
	/*Combdelay with delaytime that is controlled by a sin osc of 1hz that fluctuates in a range of values with min 0.1 second and max 0.4 second delay. "exprange" means that we get many small and big values and fewer values in between.*/
	echo = CombL.ar(sig, 0.5, SinOsc.kr(1).exprange(0.1,0.4), 3);
	sig = XFade2.ar(sig, echo, -0.5); //Mixing the two signals, at (sig, echo, 1) we hear only the delay.
}.play;
)

/*using multichannel expansion
by changing the argument for out SinOsc control oscillator to an array like [0.32,0.3] we can define a different value for the left and for the right channel for an interesting stereo effect
*/
(
x = {
	var sig, echo;
	sig = SoundIn.ar([0,0]);
	echo = CombL.ar(sig, 0.5, SinOsc.kr([0.32,0.3]).exprange(0.1,0.4), 10);
	sig = XFade2.ar(sig, echo, -0.5);
}.play;
)


//How to record sound?
Server.default.record; //shows the path and name of the recording
Server.default.stopRecording;


//How to play a sample:

~sample = Buffer.readChannel(s,"/home/nikolas/.local/share/SuperCollider/Recordings/SC_211012_205713.aiff");
~sample.play;

//->>> conclusion: Created a recording with a interesting stereo effect.

// How to record only microphone In bus while playing another sound

//first add the mic Synth
(
SynthDef.new(\mic, {
	arg in=0, out=0;
	var sig;
	sig = SoundIn.ar([in!2]);
	Out.ar(out, sig);
}).add;
)

//Then these
~delBus = Bus.audio(s, 2;)
~micSynth = Synth(\mic, [\in, 0, \out, ~delBus]);

//activate interfering noise
{Pan2.ar(SinOsc.ar(freq: 440.0, phase: 0.0, mul: 0.1, add: 0.0))}.play

Server.default.record("/home/nikolas/.local/share/SuperCollider/Recordings/bus_recording.aiff", ~delBus);
Server.default.stopRecording;

~sample2 = Buffer.readChannel(s,"/home/nikolas/.local/share/SuperCollider/Recordings/bus_recording.aiff");
~sample2.play;

//->>> Conclusion: With this method we can record any part of the arrangement and/or any number of inputs independently.


// how to loop?


x = {SoundIn.ar([0,0])}.play;

Server.default.record("/home/nikolas/.local/share/SuperCollider/Recordings/guitar.aiff");

Server.default.record.stopRecording;

~sample = Buffer.readChannel(s, "/home/nikolas/.local/share/SuperCollider/Recordings/guitar.aiff");
~sample.play.loop;

t = Task({ { ~sample.play; 8.5.wait;}.loop });
t.start;
t.stop;

// Bb for saxophone intonation practice
{Pan2.ar(SinOsc.ar(233.08, mul: 0.8))}.play;


//////

s.plotTree;

(
x = {
	var sig, env;
	env = XLine.kr(1, 0.01, 1, doneAction:0);
	sig = Pulse.ar(ExpRand(30,500), mul: 0.3) * env;
};

{Pan2.ar(x)}.play;
)


play({Pan2.ar(SinOsc.ar(XLine.kr(200,17000,10),0,0.1))});


/// additive synthesis Figure 1.1 from the Supercollider book

(
play({
	var sines = 5, speed = 6;
	Mix.fill(sines,
		{arg x;
			Pan2.ar(
				SinOsc.ar(x+1*100,
					mul: max(0,
						LFNoise1.kr(speed) +
						Line.kr(1, -1, 30)
					)
                ), rand2(1.0))})/sines})
)

/* Figure 1.1 illustrates additive synthesis (in which individual sine waves are summes) in a way that is audibly apparent in the actual sound; rich, complex, yet you hear the individual frequencies emerge as the whole sound fades in or out. It shows how this method, impossible (or at least difficult) on many software or hardware synths, can be accomplished with just a dozen lines of code in SuperCollider. Andm finally, it shows how quickly, with strategic changes, you can layer sounds that evolve from a few undulating tones to something very complex. -The Supercollider Book
*/


//general learning

exprand(1.0, 100.0) ! 10;

thisThread.randSeed = 665; {rand(10.0)} ! 10;

dup("echo", 20);
round([3.141, 5.92, 3], 0.01);
round(dup({exprand(1, 10)}, 100), 0.1);


{Pan2.ar((SinOsc.ar(440, mul: 1)))}.play;

{Pan2.ar((SinOsc.ar(440+(440*(1/12)))))}.play;

440+(440*(2/12))

x = {Pan2.ar(SinOsc.ar(LFNoise1.kr(2000, 1760), mul:0.1))}.play;

x.play;

[3, 50, 1].sort

{Pan2.ar(SinOsc.ar(69.midicps))}.play;
{Pan2.ar(SinOsc.ar(76.midicps))}.play;

{Pan2.ar(SinOsc.ar(67.midicps))}.play;

392.cpsmidi

{100.rand}.dup(50)

1000.0.rand.round(0.01).post

1000.0.rand.round(0.01).postln

5 + 10 * 4

[0, 2, 4, 5, 6, 7, 9, 11].postln.rotate.postln.rotate.postln.rotate.postln.rotate.postln´

[60,62,64,67,69].midicps.round(0.1)

exprand(1,1000.0)
{exprand(1,1000.0)}

dup(rand(1000.0),5) //duplicates the random number
dup({rand(1000.0)},5) //duplicates the function of getting a random number, thus creating different numbers

{LFNoise0.ar}.play
{Pan2.ar(LFNoise0.ar(500))}.scope

{100.rand}.dup(100).sort.reverse.plot
x = {100.rand}.dup(100)
x.plot
x.reverse.plot

{Blip.ar(25,LFNoise0.kr(5, 12, 14),0.3)}.play
{Blip.ar(25,LFNoise0.kr([10,20],12,14),0.3)}.play //freq argument is array -> multichannel expansion

/* Multichannel expansion illustrates one of the ways in which SC is both powerful and economical. Simply adding an aray gives you multiple channels, whereas in a graphical patching language like Max or PD, you would have to duplicate all of the objects and patch cords by hand. -The SuperCollider Book */


{PMOsc.ar([69.midicps,73.midicps])}.play //PMOsc = Phase Modulation Oscillator
{PMOsc.ar([76.midicps,76.midicps])}.play

{PMOsc.ar([440,440],550,7)}.play

//MouseY, MouseX track the cursor and assign values between the indicated min and max. Interactive!
{PMOsc.ar([440,440], MouseY.kr(1,550,1), MouseX.kr(1,15,1), mul:0.1)}.play

//mouse x and y control pitch in range of two octaves
{PMOsc.ar([MouseY.kr(57.midicps,81.midicps,1),MouseX.kr(57.midicps,81.midicps,1)],mul:0.3)}.play


// lets make a playable instrument out of the first example

MIDIClient.init;
MIDIIn.connectAll;

(
MIDIdef.noteOn(\noteOnTest, {
	arg vel, nn, chan, src;
	[vel, nn].postln;
	{
		var sig, env;
		sig = {PMOsc.ar([nn.midicps,nn.midicps], MouseY.kr(1,550,1), MouseX.kr(1,15,1),mul:0.3)
			+ SinOsc.ar([nn.midicps,nn.midicps])};
		env = EnvGen.kr(
				Env.new(
            		levels: [0, 1, 0.5, 0],
            		times: [0.01, 0.01, 0.01],
            		releaseNode: 2 // sustains at level 0.5 until gate is closed
        		),
        		gate: Trig.kr(Impulse.kr(3), dur: 0.3),
				doneAction: 2
			  );
		sig = sig * env * vel.linexp(1,127,0.1,1);
	}.play;
});
)


/////

{SinOsc.ar([440,440], mul:MouseX.kr(0,1.0))}.scope //here we control the amplitude with mouseX


//We can also modify parameters with a automated process, for example Line.kr


//one octave glissando, left right mirrored
{PMOsc.ar(carfreq: [Line.kr(69.midicps, 81.midicps, 10),Line.kr(81.midicps, 69.midicps, 10)])}.play


//Syntax issue: Why does the first example work but the second doesnt?

{PMOsc.ar([440,440], Line.kr(600, 900,5), 3, 0, 0.1)}.play

{PMOsc.ar(carfreq: [440,440], modfreq: Line.kr(600, 900,5), 3, 0, 0.1)}.

//Answer: if we specify the arguments using keywords, we have to use keywords for all arguments like so:
//Using automation we have build a very interestingly evolving sound in just a few lines of code.

(
{PMOsc.ar(
	carfreq: [Line.kr(440, 880, 10),Line.kr(440, 880, 10)],
	modfreq: [Line.kr(600, 900,20)],
	pmindex: Line.kr(0, 100, 30),
	modphase: 0,
	mul:0.2
	)
}.scope.play
)

//we can even spice it up with some multichannel expansion on the modfreq. So there is going to be a different modfreq automation between the left and the right channel. Very interesting.

(
{PMOsc.ar(
	carfreq: [Line.kr(440, 880, 10),Line.kr(440, 880, 10)],
	modfreq: [Line.kr(600, 900,20),Line.kr(500, 2200,20)],
	pmindex: Line.kr(0, 100, 30),
	modphase: 0,
	mul:0.2
	)
}.scope.play
)




//Blip is a Band Limited Impulse generator. All harmonics have equal amplitude

{Blip.ar([300,300], 10)}.play //10 harmonics on top of 300hz
{Blip.ar([300,300], Line.kr(0, 10, 10))}.play //the same but they come in one by one over the course of 10 seconds


(
{Pan2.ar(
	Blip.ar(
		TRand.kr(100, 1000, SinOsc.kr(1)) //generates random values between 100 and 1000 whenever the trigger (SinOsc)
		                                  //changes from nonpositive to positive values, so 1 time per second
	)
)}.play
)


(
{
	Pan2.ar(
		Blip.ar(
			TRand.kr(//frequency of VCO
				100, 1000, // range
				Impulse.kr(Line.kr(1,20,60))), //trigger. Impulse frequency increases from 1 to 20 over 60 seconds
			                                   //which triggers new random frequencies faster over time
			TRand.kr( //number of harmonics or VCF
				1,10, //range
				Impulse.kr(Line.kr(1,20,60))), //trigger number of harmonics also increases over time
			Linen.kr( //mul, or amplitude, VCA
				Impulse.kr(Line.kr(1,20,60)), // trigger that shapes the mul (or envelope) of the sounds generated by
				                              // Blip. We achieve this by assigning the same trigger automation as to the
				                              // sound shaping arguments
				0, //attack
				0.5, //sustain level
				1/Line.kr(1,20,60)) // level back to 0 trigger in exactly the time between the current and the next event
			                        // for example at 60 seconds we have 20 events per second so the time until the next
			                        // event has to be 1/20 seconds
		)
	)
}.scope.play
)




//using variables


(
{
	Pan2.ar(
		r = MouseX.kr(1/3,10);
		SinOsc.ar(mul:Linen.kr(Impulse.kr(r),0,1,1/r))
	)
}.play
)

//using variables 2

(
// run this first
p = {//make p equal to this function
	Pan2.ar(
		r = Line.kr(1,20,60); //rate
		// r = LFTri.kr(1/10)*3+7;
		t = Impulse.kr(r); //trigger
		// t = Dust.kr(r);
		e = Linen.kr(t, 0, 0.5, 1/r); // envelope uses r and t
		f = TRand.kr(1, 10, t); // triggered random also uses t
		// f = e + 1 * 4;
		Blip.ar(f*100, f, e) //f and e used in Blip
	)
}.play
)


(
{
	r = Impulse.kr(Line.kr(1,20,15));
	c = TRand.kr(100, 5000, r);
	m = TRand.kr(100, 5000, r);
	PMOsc.ar([c, c], m, Line.kr(1, 12, 10))*0.3
}.play
)

(
{   // declare variables
	var rate = 4, carrier, modRatio, env;
	carrier = LFNoise0.kr(rate) * 500 + 700;
	modRatio = MouseX.kr(1, 2.0);
	env = Linen.kr(attackTime: 1/rate, releaseTime: 0);
	//modulator expressed as  ratio, therefore timbre
	PMOsc.ar(
		carfreq: [carrier,carrier],
		modfreq: carrier*modRatio,
		pmindex: Line.kr(0,20,20),
		mul: env)*0.3
}.play
)


//// SynthDef

{SinOsc.ar()}.play //generates a temp_number synth with name and outbut bus 0 (left)

SynthDef("sine", {Out.ar(0, SinOsc.ar)}).play  //create a synthdef and play immediately
SynthDef("sine", {Out.ar(1, SinOsc.ar)}).play  //same for right channel




// or like this

(
SynthDef("one_tone_only", {
	var out, freq = 440;
	out = SinOsc.ar(freq);
	Out.ar(0, out)
}).add // this makes sure that SuperCollider knows about this SynthDef
)
// then use it to create a running Synth
Synth("one_tone_only");

/*Here the frequency can not be changed once the synthdef is running. To do so we must use arguments*/

(
SynthDef("different_tones", {
	arg freq = 440; //declare an argument and give it a default value
	var out;
	out = SinOsc.ar(freq)*0.3;
	Out.ar(0, [out,out])
}).play
)

Synth("different_tones", ["freq", 550]);
Synth("different_tones", [\freq, 660]);  // same as "freq"
Synth("different_tones", [\freq, 880]);
// If no argument is specified, defaults are used (440)
Synth("different_tones");

// by using variables we can create multiple instances and control each of them independently

a = Synth("different_tones", [\freq, 64.midicps]);
b = Synth("different_tones", [\freq, 67.midicps]);
c = Synth("different_tones", [\freq, 72.midicps]);
a.set(\freq, 65.midicps);
c.set(\freq, 71.midicps);
a.set("freq", 64.midicps);
c.set("freq", 72.midicps);
a.free;
b.free;
c.free;



(
//run this first
SynthDef("PMCrotale", {
	arg midi = 60, tone = 3, art = 1, amp = 0.8, pan = 0;
	var env, out, mod, freq;

	freq = midi.midicps;
	env = Env.perc(0, art);
	mod = 5 + (1/IRand(2, 6));

	out = PMOsc.ar(freq, mod*freq,
		pmindex: EnvGen.kr(env, timeScale: art, levelScale: tone),
		mul: EnvGen.kr(env, timeScale: art, levelScale: 0.3));

	out = Pan2.ar(out, pan);

	out = out * EnvGen.kr(env, timeScale: 1.3*art,
		levelScale: Rand(0.1, 0.5), doneAction:2);
	Out.ar(0, out); //Out.ar(bus, out);

}).add;
)

//Then run this a bunch of times:

Synth("PMCrotale", ["midi", rrand(48,72).round(1), "tone", rrand(1, 6)])


/////// loading a sample

~huston = Buffer.read(s, "/home/nikolas/.local/share/SuperCollider/Recordings/SC_211012_205713.aiff");
~chooston = Buffer.read(s, "/home/nikolas/.local/share/SuperCollider/Recordings/SC_211012_205713.aiff");

{PlayBuf.ar(2, ~huston)}.play; // humber of channels and buffer.
//looping, also cutting the silence in the beginning
{PlayBuf.ar(2, ~huston, rate: 1, loop:1, startPos: 4.4*48000)}.play;
//backwards playback
{PlayBuf.ar(2, ~huston, rate: -1, loop:1, startPos: 4.4*48000)}.play;

//how to access information about the sample?
[~huston.bufnum, ~huston.numChannels, ~huston.path, ~huston.numFrames]; //numFrames gives the length of the sample(devide by sample rate (in my vase 48000) to get seconds


// storing the cut version of our sample
~huston_cut = [2, ~huston, startPos: 4.4*48000]; //doesnt work -> rate: bad input

~huston_cut = [2, ~huston, 1.0, 1.0, 4.4*48000]; //workaround


{PlayBuf.ar(*~huston_cut)}.play;   //same as (~huston_cut[0], ~huston_cut[1], ...) WORKS!

( // phasing
{
	var rate, trigger, frames;
	frames = ~huston.numFrames;

	rate = [1, 1.01];
	trigger = Impulse.kr(rate);   // frequency: 1, phase offset 1.01/cycle
	PlayBuf.ar(2, ~huston, 1, trigger, frames * Line.kr(0,1,60)) * //staring position 0 going up until end
	/*so it starts playing at position 0 with the defined envelop
	*/
	EnvGen.kr(Env.linen(0.01, 0.96, 0.01), trigger) * rate;
}.play;
)







( // speed and direction change
{
	var speed, direction;
	speed = LFNoise0.kr(12) * 0.2 + 1;
	direction = LFClipNoise.kr(1/3);
	PlayBuf.ar(2, ~huston, (speed * direction), startPos: 48000*5, loop:1);
}.play
)


/// A little "randomized" compositon from a recorded flute sample alongside with a algorithmic stereo effect
/// LFClipNoise randomly generates values 1 or -1 at given rate, effectively randomly reversing playback

{PlayBuf.ar(2, ~huston, rate: LFClipNoise.kr(5000), loop:1, startPos: 4.4*48000)}.play;











// I was wondering what exactly LFNoise0 did. This example illustrates that it generates random values smaller
// then 1
{Pan2.ar(SinOsc.ar(440), -1)}.play;
{Pan2.ar(SinOsc.ar(440)*LFNoise0.ar(2),1)}.scope.play;

/* Another fun instrument. Mouse X controls Sin pitch within one octave, Mouse Y
   controls pitch and velocity of random pitch changes within that same octave
*/
{Pan2.ar(SinOsc.ar(MouseX.kr(69.midicps,81.midicps)))}.play;
{Pan2.ar(SinOsc.ar(MouseY.kr(69.midicps,81.midicps)*LFNoise0.ar(MouseY.kr(3,20))))}.scope.play








/*
How to use Bus, from the SuperCollider book:

What if you want to use 1 control on both PlayBufs? Similarily, what if you would like to switch between
several controls with either PlayBuf, applying them independently? What if you want to apply 2 controls at the same time?
Building seperate synths for each of those possibilities is inefficient and limits you to those designs. Better to create the sources and controls as modules (like vintage modular synths) and connect them using buses (like virtual patch cords). For control rate signals, we will use control buses. To connect them we use Out.kr and In.kr. The arguments for Out and In are the bus number (anything up to 4096) and the number of channels. So to connect an output to an input, you would use the same bus number: Out.kr(1950, 2 SomeControl.kr), then SinOsc.ar(In.kr(1950, 2)).
*/

( //if these havent been used they will hold 0
~kbus1 = Bus.control;
~kbus2 = Bus.control;
{
	var speed, direction;
	speed = In.kr(~kbus1, 2) * 0.2 +1;
	direction = In.kr(~kbus2);
	PlayBuf.ar(2, ~chooston, (speed * direction), loop: 1);
}.play;
)
// now start the controls
(
{Out.kr(~kbus1, LFNoise0.kr(12))}.play;


{Out.kr(~kbus2, LFClipNoise.kr(1/4))}.play;
)

// Now start the second buffer with the same control input buses,
// but send it to the right channel using Out.ar(1 etc.

(
{
	var speed, direction;
	speed = In.kr(~kbus1, 2) * 0.2 + 1;
	direction = In.kr(~kbus2);
	Out.ar(1, PlayBuf.ar(2, ~huston, (speed * direction), loop:1));
}.play;
)





///// How do buses work?

// SinOsc for reference
{SinOsc.ar(340)}.play;
{SinOsc.ar(440)}.play;
{SinOsc.ar(540)}.play;

(
~kbus3 = Bus.control;
~kbus4 = Bus.control;
)
//run these one at a time, turn down speakers!

// SinOsc starts at 0, then adds 100 then 0, then subtracts 100 over 1 second
(
{Out.kr(~kbus3, SinOsc.kr(1).scope("out3") * 100)}.play;
{Out.ar(0, SinOsc.ar(In.kr(~kbus3) + 440).scope("left"))}.play;
)

// LFPulse is either 1 or 0, so it adds 200, then 0 over 1/3 second
(
{Out.kr(~kbus4, LFPulse.kr(1/3).scope("out4") * 200)}.play;
{Out.ar(0, SinOsc.ar(In.kr(~kbus4) + 440).scope("left"))}.play;
)

//Together they sound really funny!
(
{Out.kr(~kbus3, SinOsc.kr(1).scope("out3") * 100)}.play;
{Out.kr(~kbus4, LFPulse.kr(1/3).scope("out4") * 200)}.play;
{Out.ar(0, SinOsc.ar(In.kr(~kbus3) + In.kr(~kbus4) + 440).scope("left"))}.play;
)

(
{Out.kr(~kbus3, SinOsc.kr(1).scope("out3") * 100)}.play;
{Out.kr(~kbus4, LFPulse.kr(1/3).scope("out4") * 200)}.play;
{Out.ar(1, SinOsc.ar(In.kr(~kbus3) + In.kr(~kbus4) + 840).scope("right"))}.play;
)





// When combined with a SynthDef, the routing can be swapped around in real time.

(
~kbus3 = Bus.control;
~kbus4 = Bus.control;
)
(
{Out.kr(~kbus3, SinOsc.kr(1).scope.range(340,540))}.play;
{Out.kr(~kbus4, LFPulse.kr(1/3).scope.range(240, 640))}.play;
)
(
SynthDef("Switch", {
	arg freq = 440;
	var out;
	out = Pan2.ar(SinOsc.ar(freq, 0, 0.3));
	Out.ar(0, out)
}).add
)
x = Synth("Switch"); //default
x.map(\freq, ~kbus3)
x.map(\freq, ~kbus4)










///////////////// composition

{SinOsc.ar([340,340])}.play
{SinOsc.ar([540,540])}.play
{Pan2.ar(SinOsc.ar(SinOsc.kr(1/3).range(340,540)))}.play;



(
SynthDef("lower", {
	arg freq, mul;
	var out;
	out = SinOsc.ar(freq, mul: mul);
	out = Pan2.ar(out);
	Out.ar(0, out);
}).play
)

(
SynthDef("upper", {
	arg freq, mul;
	var out;
	out = SinOsc.ar(freq, mul: mul);
	out = Pan2.ar(out);
	Out.ar(0, out);
}).play
)

(
SynthDef("shifter", {
	arg freq1, freq2, mul;
	var out;
	out = SinOsc.ar(SinOsc.kr(1/3).range(freq1,freq2), mul: mul);
	out = Pan2.ar(out);
	Out.ar(0, out);
}).play
)

~lower = Synth("lower",["freq", 64.midicps, "mul", 0.5])
~upper = Synth("upper",["freq", 72.midicps, "mul", 0.5])
~shifter = Synth("shifter", ["freq1", 64.midicps, "freq2", 72.midicps, "mul", 0.1])

~upper.set("freq", 71.midicps);
~upper.set("freq", 65.midicps);
~upper.set("freq", 76.midicps);

~lower.set("freq", 58.midicps);

~shifter.set("mul", 0.3);









//Tuning found in supercollider help file

Tuning.at(\werckmeister)

Scale.directory

t = Tuning.et12;
t.semitones;        // [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 ]
t.ratios;        // [ 1, 1.0594630943591, 1.1224620483089, 1.1892071150019, etc. ]

Pbind(\scale, Scale.major(t), \degree, Pseq((0..7) ++ (6..0) ++ [\rest], 1), \dur, 1).play;

// use non-standard tuning
t = Tuning.just;
t.semitones;        // [ 0, 1.1173128526978, 2.0391000173077, 3.1564128700055, etc. ]
t.ratios.collect(_.round(0.001));    // [ 1, 1.067, 1.125, 1.2, 1.25, 1.333, 1.406, 1.5, etc. ]

Pbind(\scale, Scale.major(t), \degree, Pseq((0..7) ++ (6..0) ++ [\rest], 1), \dur, 1).play;














//// How to make a click track metronome



(
~t = 0.9;
~sample1 = Buffer.readChannel(s,"/home/nikolas/.local/share/SuperCollider/downloaded-quarks/Dirt-Samples/808/RS.WAV");
~sample2 = Buffer.readChannel(s,"/home/nikolas/.local/share/SuperCollider/downloaded-quarks/Dirt-Samples/808/CH.WAV");
~lala = {Pan2.ar(PlayBuf.ar(1, ~sample1, rate: 1, loop:0))};
~lala2 = {Pan2.ar(PlayBuf.ar(1, ~sample2, rate: 1, loop:0))};
t = Task({ { ~lala.play; ~t.wait; ~lala2.play; ~t.wait; ~lala2.play; ~t.wait; ~lala2.play; ~t.wait;}.loop });
)

t.start;
t.stop;


//how to access information about the sample?
[~sample1.bufnum, ~sample1.numChannels, ~sample1.path, ~sample1.numFrames];
~sample1.numFrames/48000;
~sample2.numFrames/48000;
//numFrames gives the length of the sample(devide by sample rate (in my vase 48000) to get seconds


11026/48000




~kbus3 = Bus.control;
~kbus4 = Bus.control;
(
{Out.kr(~kbus3, SinOsc.kr(3).scope.range(340, 540))}.play;
{Out.kr(~kbus4, LFPulse.kr(6).scope.range(240, 640))}.play;
)
SynthDef("Switch", {arg freq = 440; Out.ar(0, [SinOsc.ar(freq, 0, 0.3),SinOsc.ar(freq, 0, 0.3)])}).add
x = Synth("Switch");
x.map(\freq, ~kbus3)
x.map(\freq, ~kbus4)
x.set(\freq, 140)






/// This new for of notation and composition inevitably led me to dive into tuning systems.
/// The computer can reproduce any frequency with ease, which makes microtonal composition more approachable then in
/// my daw or notation software

////build something to compare major third in just intonation vs equal temperament


(
SynthDef(\equalthird, {
	var sig, env;
	env = Line.kr(0.5,0.0,10.0);
	sig = [SinOsc.ar(69.midicps), SinOsc.ar(73.midicps)];
	sig = sig*env;
	Out.ar(0, sig);
}).add;
)

(
SynthDef(\justthird, {
	var sig, env;
	env = Line.kr(0.5,0.0,10.0);
	sig = [SinOsc.ar(69.midicps), SinOsc.ar(69.midicps*(5/4))];
	sig = sig*env;
	Out.ar(0, sig);
}).add;
)

t = Task({ { ~justthird = Synth(\justthird); "just third".postln; 10.wait;~equalthird = Synth(\equalthird); "equal third".postln; 10.wait; }.loop });

t.start;
t.stop







//Squences from "A Gentle Introduction to SuperCollider"

Pbind(\degree, Pseries(0, 1, 30), \dur, 0.5).play;
Pbind(\degree, -4).play;
Pbind(\degree, 0, \dur, 0.5).play;
Pbind(\degree, Pseq([0, 1, 2, 3, 4, 5, 6, 7], 2), \dur, 1, \legato, 1).play;
Pbind(\degree, Pseq([0, 1, 2, 3, 4, 5, 6, 7], 5), \dur, Pseq([0.2, 0.1, 0.1, 0.2, 0.2, 0.35], inf)).play;



/// Composition. Pseq for playing in sequence, Prand for random. Todo: implement randomness factor corresponding to
/// mouse position MouseX / MouseY

(¸
~duration = 1;
Pbind(
	\note, Prand([0, 2, 3, 5, 7, 8, 11, 12], inf),
	\dur, Prand([~duration, ~duration*2], inf),
	\legato, 1,
	\amp, Prand([1,0.5],inf)
).play;
Pbind(
	\note, Prand([3, 5, 7, 8, 11, 12, 14, 15], inf),
	\dur, Prand([~duration, ~duration*(1/3)], inf),
	\legato, 1,
	\amp, Prand([1,0.5],inf)
).play;
Pbind(
	\note, Prand([-12, -13, -17, -19, -21, -22, -24, -22, -21, -19, -17, -15, -13], inf),
	\dur, Prand([~duration, ~duration*(3)], inf),
	\legato, 1,
	\amp, Prand([1,0.5],inf)
).play;
Pbind(
	\note, Prand([-24, -22, -21, -25, -25, -24, -28, -29], inf),
	\dur, Prand([~duration*2, ~duration*4], inf),
	\legato, 1,
	\amp, Prand([1,0.5],inf)
).play;
)




//~prob = MouseX.kr(0, 10, 0)





(
Pdef(\fade).set(\fade, 0);
Pdef(\fade,
	Pbind(
		\scale, Scale.chromatic,
		\dur, 1/6,
		\legato, 2,
		\octave, 3,
		\degree, Pxfade([
			Pseq([0, 2, 7, 9, 4], inf), // non random...
			Pxrand([0, 2, 7, 9], inf), // random....
		], Pkey(\fade))
	)
).play;
)

Pdef(\fade).set(\fade, 0.5) // 50% from the non-random stream, 50% from the random stream
Pdef(\fade).set(\fade, 1) // 100% from the random stream



Pif(
   Pfunc({ |value| value > 0.5 }) <> Pwhite(),
   Pseq([0, 2, 7, 9, 4], inf),
   Pxrand([0, 2, 7, 9, 4], inf),
)




///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




(
Pbind(
	\freq, Pwhite(100,500),
	\dur, Prand([0.15, 0.25, 0.3], inf),
	\amp, 0.2,
	\legato, 0.3
).trace.play;
)

// Pseq
(
Pbind(
	\note, Pseq([0,2,3,5,7,8,11,12],4),
	\dur, Pwhite(0.15,0.5);
).trace.play;
)


(
Pbind(
\note, Pser([0, 2, 3, 5, 7, 8, 11, 12], 11),
\dur, 0.15;
).play;
)


(
p = Pbind(
	\note, Pxrand([0, 2, 3, 5, 7, 8, 11, 12], inf),
	\dur, 0.15;
).trace.play;
)


// Pshuf
(
p = Pbind(
	\note, Pshuf([0, 2, 3, 5, 7, 8, 11, 12], 6),
	\dur, 0.15;
).trace.play;
)


(
Pbind(
	\note, Pslide([0, 2, 3, 5, 7, 8, 11, 12], 7, 3, 1),
	\dur, 0.3;
).trace.play;
)


(
Pbind(
	\note, Pseries(0, 3, 15),
	\dur, 0.3;
).trace.play;
)


(
Pbind(
	\note, Pseq([0, 2, 3, 5, 7, 8, 11, 12], inf),
	\dur, Pgeom(0.1, 1.1, 25);
).trace.play;
)



(
Pbind(
	\note, Pseq([0, Pn(2, 3), 3, Pn(5, 3), 7, Pn(8, 3), 11, 12], 1),
	\dur, 0.15;
).trace.play;
)


//// chords

(
Pbind(
	\note, Pseq([[0, 3, 7], [-1, 2, 8], [0, 3, 7], [-4, 0, 5]], 3),
	\dur, 0.5
).play;
)


(
Pbind(
	\note, Pseq([[−7, 3, 7, 10], [0, 3, 5, 8]], 2),
	\dur, 1,
	\legato, 0.4,
	\strum, 0.2 // try 0, 0.1, 0.2, etc
).play;
)


(
Pbind(
	\note, Pser([0, 2, 3, 5, 7, 8, 11, 12], 11),
	\ctranspose, 12, // transpose an octave above (= 12 semitones)
	\dur, 0.15;
).play;
)



(
Pbind(\degree, Pseq([0, 0.1, 1, 2, 3, 4, 5, 6, 7]),
	\dur, 1;
).play(TempoClock(120/60)); // 120 beats over 60 seconds: 120 BPM
)

(
Pbind(
	\degree, Pwhite(0, 10),
	\dur, Pseq([0.5, 0.5, 0.5, 0.5, Rest(1), 0.5], inf);
).trace.play;
)


(
Pbind(
	\note, Pseq([0,2,3,5,7, Rest()], inf),
	\dur, Pseq([0.5, 0.5, 0.5, 0.5, 0.5, 2], inf);
).trace.play;
)






( // open big block
Pbind(
	\freq, Pn(Pseries(110, 111, 10)),
	\dur, 1/2,
	\legato, Pwhite(0.1, 1)
).trace.play;
Pbind(
	\freq, Pn(Pseries(220, 222, 10)),
	\dur, 1/4,
	\legato, Pwhite(0.1, 1)
).trace.play;
Pbind(
	\freq, Pn(Pseries(330, 333, 10)),
	\dur, 1/6,
	\legato, 0.1
).trace.play;
) // close big block





/////////////////////////From A gentle introduction to supercollider

// Basic fork example. Watch Post window:
(
{
	"one thing".postln;
	2.wait;
	"another thing".postln;
	1.5.wait;
	"one last thing".postln;
}.fork;
)
// A more interesting example:
(
t = TempoClock(76/60);
{
	Pbind(
		\note, Pseq([[4, 11], [6, 9]], 32),
		\dur, 1/6,
		\amp, Pseq([0.05, 0.03], inf)
	).play(t);
	2.wait;
	Pbind(
		\note, Pseq([[−25, −13, −1], [−20, −8, 4], \rest], 3),
		\dur, Pseq([1, 1, Rest(1)], inf),
		\amp, 0.1,
		\legato, Pseq([0.4, 0.7, \rest], inf)
	).play(t);
	2.75.wait;
	Pbind(
		\note, Pseq([23, 21, 25, 23, 21, 20, 18, 16, 20, 21, 23, 21], inf),
		\dur, Pseq([0.25, 0.75, 0.25, 1.75, 0.125, 0.125, 0.80, 0.20, 0.125,
			0.125, 1], 1),
		\amp, 0.1,
		\legato, 0.5
	).play(t);
}.fork(t);
)




c = [0, 2, 3, 5, 7, 8, 11, 12];
Pbind(\note, Pseq(c, 1), \dur, 0.15).play;
Pbind(\note, Prand(c, 6), \dur, 0.15).play;
Pbind(\note, Pslide(c, 5, 3, 1), \dur, 0.15).play;


~scale = [0, 1, 2, 3, 4, 5, 6, 7];
~durs = [0.4, 0.2, 0.2, 0.4, 0.8, 0.2, 0.2, 0.2];
(
Pbind(
	\degree, Pseq(~scale),
	\dur, Pseq(~durs)
).trace.play;
Pbind(
	\degree, Pseq(~scale.reverse + 7),
	\dur, Pseq(~durs)
).trace.play;
Pbind(
	\degree, Pseq(~scale + 2),
	\dur, Pseq(~durs)
).trace.play;
Pbind(
	\degree, Pseq(~scale.reverse + 9),
	\dur, Pseq(~durs)
).trace.play;
)




(
p = Pbind(
	\midinote, Pseq([57, 62, 64, 65, 67, 69], inf),
	\dur, 1/7
); // no .play here!
)
// Ask for the score to be played
p.play;



// my own example
(
~dur = 1/7;
{
	Pbind(
		\midinote, Pseq([57, 62, 64, 65, 67, 69], inf),
		\dur, ~dur,
		\amp, 0.1
	).trace.play;
	((~dur*6)*3).wait;
	Pbind(
		\midinote, Pseq([57, 69], inf),
		\ctranspose, -24,
		\dur, Pseq([(~dur*6)*2, (~dur*6)*3], inf),
		\amp, 0.4
	).trace.play;
}.fork
)



~myPlayer = p.play;
~myPlayer.stop;
~myPlayer.resume;
~myPlayer.stop.reset;
~myPlayer.start;
~myPlayer.stop;




/// Example of Tchaikovsky's Album for the Youth taken from A Gentle Introduction to Supercollider

// Define the score
(
var myDurs = Pseq([Pn(1, 5), 3, Pn(1, 5), 3, Pn(1, 6), 1/2, 1/2, 1, 1, 3, 1, 3], inf
) * 0.4;
~upperMelody = Pbind(
	\midinote, Pseq([69, 74, 76, 77, 79, 81, Pseq([81, 79, 81, 82, 79, 81], 2),
		82, 81, 79, 77, 76, 74, 74], inf),
	\dur, myDurs
);
~lowerMelody = Pbind(
	\midinote, Pseq([57, 62, 61, 60, 59, 58, 57, 55, 53, 52, 50, 49, 50, 52, 50,
		55, 53, 52, 53, 55, 57, 58, 61, 62, 62], inf),
	\dur, myDurs
);
)
// Play the two together:
(
~player1 = ~upperMelody.play;
~player2 = ~lowerMelody.play;
)
// Stop them separately:
~player1.stop;
~player2.stop;
// Other available messages
~player1.resume;
~player1.reset;
~player1.play;
~player1.start; // same as .play

//if
if(100 > 50, { "very true".postln }, { "very false".postln });

// case
(
~num = -2;
case
{~num == 0} {"WOW".postln}
{~num == 1} {"ONE!".postln}
{~num < 0} {"negative number!".postln}
{true} {"last case scenario".postln};
)

f = {2+2};
f.value;

f = {arg a, b; ["a plus b", a+b, "a times b", a*b].postln}; // define function
f.value(3, 7);

// Compare:
~sillyRand = rrand(0, 10); // not a function
~sillyRand.value; // evaluate several times
~sillyRand2 = {rrand(0, 10)}; // a function
~sillyRand2.value; // evaluate several times


(
~whatToDo = {
var today, dayName, actions;
today = Date.getDate.dayOfWeek;
dayName =
case
{today==0} {"Sunday"}
{today==1} {"Monday"}
{today==2} {"Tuesday"}
{today==3} {"Wednesday"}
{today==4} {"Thursday"}
{today==5} {"Friday"}
{today==6} {"Saturday"};
actions = ["boomerang throwing", "arm wrestling", "stair climbing", "playing
chess", "underwater hockey", "pea shooting", "a nap marathon"];
"Ah, " ++ dayName ++ "...! " ++ "What a good day for " ++ actions.choose;
};
)
// Run it in the morning
~whatToDo.value;

f = {|a, b| a + b}   // equivalent to f{arg a, b; a + b}
f.value(1, 2)

a = [10, 11, 12, 13, 14, 15, 16, 17];

a.reverse; // reverse
a.scramble; // scramble
a.choose; // picks one element at random
a.size;
// returns size of array
a.at(0);
// retrieves item at specified position
a[0]; // same as above
a.wrapAt(9); // retrieves item at specified position, wrapping around if > a.size
["wow", 99] ++ a; // concatenates the two arrays into a new one
a ++ \hi; // a Symbol is a single character
a ++ 'hi'; // same as above
a ++ "hi"; // a String is a collection of characters
a.add(44);// creates new array with new element at the end
a.insert(5, "wow"); // inserts "wow" at position 5, pushes other items forward (returns new array)
a; // evaluate this and see that none of the above operations actually changed theoriginal array
a.put(2, "oops"); // put "oops" at index 2 (destructive; evaluate line above again to check)
a.permute(3); // permute: item in position 3 goes to position 0, and vice−versa
a.mirror; // makes it a palindrome
a.powerset; // returns all possible combinations of the array's elements



~myFreqs = Array.fill(10, {rrand(440, 880)});
~myFreqs.do({arg item, count; ("Item: " ++ item ++ " Count: " ++ count).postln});
~myFreqs.do({arg item, count; ("Item " ++ count ++ " is " ++ item ++ " Hz. Closest midinote is " ++ item.cpsmidi.round).postln});
~myFreqs.do({arg item; {Pan2.ar(SinOsc.ar(item, 0, 0.1))}.play});
~myFreqs.do({arg item; item.squared.postln});



////////////////////// My Own Composition: Create random sound consisting of 10 Sine oscillators with hz between 440 and 880

(
~getsound = {Array.fill(10, {rrand(440, 880)})};

(
SynthDef(\playsound, {
	arg a0=440, a1=440, a2=440, a3=440, a4=440, a5=440, a6=440, a7=440, a8=440, a9=440;
	var sig, env, a;
	sig = SinOsc.ar(a0!2, 0, 0.1)+SinOsc.ar(a1!2, 0, 0.1)+SinOsc.ar(a2!2, 0, 0.1)+SinOsc.ar(a3!2, 0, 0.1)+SinOsc.ar(a4!2, 0, 0.1)+SinOsc.ar(a5!2, 0, 0.1)+SinOsc.ar(a6!2, 0, 0.1)+SinOsc.ar(a7!2, 0, 0.1)+SinOsc.ar(a8!2, 0, 0.1)+SinOsc.ar(a9!2, 0, 0.1);
	//env = Line.kr(0.1,0.0,1.0);
	Out.ar(0, sig);
}).add;
)
)

(
t = Task({ {~soundlist = ~getsound.value();

	~mysynth = Synth(\playsound, [\a0, ~soundlist[0], \a1, ~soundlist[1], \a2, ~soundlist[2], \a3, ~soundlist[3], \a4, ~soundlist[4], \a5, ~soundlist[5], \a6, ~soundlist[6], \a7, ~soundlist[7], \a8, ~soundlist[8], \a9, ~soundlist[9]]);

	3.wait; ~mysynth.free;}.loop});
)
t.start;
t.stop;













{Pulse.ar(freq: MouseX.kr(300, 2500), mul: MouseY.kr(0, 0.5))}.play;


// just watch the Post window (no sound)
{SinOsc.kr(1).poll}.play;
// hit ctrl+period, then evaluate the next line:
{LFPulse.kr(1).poll}.play;

{LFNoise0.ar(1).poll}.play;


{MouseX.kr(300, 2500).poll}.play;
{MouseX.kr(minval: 300, maxval: 2500, lag: 10).poll}.play;


{SinOsc.ar(freq: LFNoise0.kr(10).range(500, 1500).poll!2, mul: 0.1)}.play;

// Breaking it down:
{LFNoise0.kr(1).poll}.play; // watch a simple LFNoise0 in action
{LFNoise0.kr(1).range(500, 1500).poll}.play; // now with .range
{LFNoise0.kr(10).range(500, 1500).poll}.play; // now faster


{SinOsc.ar(freq: LFPulse.kr(1).range(500,1500).poll!2, mul: 0.5)}.play;


// This:
{SinOsc.kr(1).range(100, 200).poll}.play;
// ...is the same as this:
{SinOsc.kr(1, mul: 50, add: 150).poll}.play;
// This:
{LFPulse.kr(1).range(100, 200).poll}.play;
// ...is the same as this:
{LFPulse.kr(1, mul: 50, add: 100).poll}.play;




// A bunch of numbers
a = [1, 2, 3, 4, 5, 6, 7];
// Rescale to 0−127, linear to linear
a.linlin(1, 7, 0, 127).round(1);
// Rescale to 0−127, linear to exponential
a.linexp(1, 7, 0.01, 127).round(1); // don't use zero for an exponential range



{Out.ar([0,1], SinOsc.ar(440, 0, 0.1))}.play; // right channel

// start the effect
f = {Out.ar([0,1], BPF.ar(in: In.ar(55), freq: MouseY.kr(1000, 5000), rq: 0.1))}.play;
// start the source
n = {Out.ar(55, WhiteNoise.ar(0.5))}.play;


{Out.ar(0, Saw.ar(freq: [440, 570], mul: Line.kr(0, 1, 10)))}.play;

a = {Out.ar(0, SinOsc.ar(freq: [800, 880], mul: LFPulse.ar([2,3])))}.play;
a.free;


// Run this first ('turn reverb on' −− you won't hear anything at first)
r = {Out.ar(0, FreeVerb.ar(In.ar(55, 2), mix: 0.5, room: 0.9, mul: 0.4))}.play;
// Now run this second ('feed the busy tone into the reverb bus')
a = {Out.ar(55, SinOsc.ar([800, 880], mul: LFPulse.ar(2)))}.play;
a.free;



// Create the bus
~myBus = Bus.audio(s, 2);
// Turn on the reverb: read from myBus (source sound)
r = {Out.ar(0, FreeVerb.ar(In.ar(~myBus, 2), mix: 0.5, room: 0.9, mul: 0.4))}.play;
// Feed the busy tone into ~myBus
b = {Out.ar(~myBus, SinOsc.ar([800, 880], mul: LFPulse.ar(2)))}.play;
// Free both synths
r.free; b.free;



p = {Pan2.ar(in: PinkNoise.ar, pos: SinOsc.kr(2), level: 0.1)}.play;
p.free;





(
x = {
	var lfn = LFNoise2.kr(1);
	var saw = Saw.ar(
		freq: 30,
		mul: LFPulse.kr(
			freq: LFNoise1.kr(1).range(1, 10),
			width: 0.1));
	var bpf = BPF.ar(in: saw, freq: lfn.range(500, 2500), rq: 0.01, mul: 20);
	Pan2.ar(in: bpf, pos: lfn);
}.play;
)
x.free;


{SinOsc.ar(440!2)}.play;
{SinOsc.ar(freq: (SinOsc.kr(0.1, mul: 440))!2)}.play;

{Saw.ar(30!2)};
a = Saw.ar(30);
{Out.ar([0,1], BPF.ar(Saw.ar(30), freq: MouseY.kr(30, 4000), rq: 0.01, mul: 10))}.play;
{Out.ar(0, BPF.ar(in: a, freq: LFNoise2.kr(1).range(500, 2500), rq: 0.01, mul: 20))}.play;



// 5 channels output (watch Meter window)
a = { SinOsc.ar([100, 300, 500, 700, 900], mul: 0.1) }.play;
a.free;
// Mix it down to mono:
b = { Mix(SinOsc.ar([100, 300, 500, 700, 900], mul: 0.1)) }.play;
b.free;
// Mix it down to stereo (spread evenly from left to right)
c = { Splay.ar(SinOsc.ar([100, 300, 500, 700, 900], mul: 0.1)) }.play;
c.free
// Fun with Splay:
(
d = {arg fundamental = 110;
	var harmonics = [1, 2, 3, 4, 5, 6, 7, 8, 9];
	var snd = BPF.ar(
		in: Saw.ar(32, LFPulse.ar(harmonics, width: 0.1).poll),
		freq: harmonics * fundamental,
		rq: 0.01,
		mul: 20);
	Splay.ar(snd);
}.play;
)
d.set(\fundamental, 100); // change fundamental just for fun
d.free;



// Instant cluster generator
c = { Mix.fill(16, {SinOsc.ar(rrand(100, 3000).postln, mul: 0.01)}) }.play;
c.free;
// A note with 12 partials of decreasing amplitudes
(
n = { Mix.fill(12, {arg counter;
var partial = counter + 1; // we want it to start from 1, not 0
SinOsc.ar(partial * 440, mul: 1/partial.squared) * 0.1
})
}.play;
FreqScope.new;
)
n.free;



{Splay.ar(Array.fill(16, {SinOsc.ar(rrand(100, 3000).postln, mul: 0.05)}))}.play;




Array.fill(10, {arg counter; counter * 10});
// For example, generating a list of harmonic frequencies:
Array.fill(10, {arg wow; wow+2 * 440});




s.plotTree;



/// open the GUI
s.plotTree;
// run these one by one (don't stop the sound) and watch the Node Tree:
w = { SinOsc.ar(60.midicps, 0,0.1)}.play;
x = { SinOsc.ar(64.midicps, 0,0.1)}.play;
y = { SinOsc.ar(67.midicps, 0,0.1)}.play;
z = { SinOsc.ar(71.midicps, 0,0.1)}.play;
w.free;
x.free;
y.free;



// Evaluate and watch the Node Tree window for a few seconds
x = {WhiteNoise.ar(Line.kr(0.2, 0, 2, doneAction:2))}.play;
x.free;


//////////////////////////////////////////////////////////////////// ENVELOPES //////////////////////////////////////////

{WhiteNoise.ar(Line.kr(0.2, 0, 2, doneAction: 2))}.play

Env.perc.plot; // using all default args
Env.perc(0.5).plot; // attackTime: 0.5
Env.perc(attackTime: 0.3, releaseTime: 2, level: 0.4).plot;
Env.perc(0.3, 2, 0.4, 0).plot; // same as above, but curve:0 means straight lines

{PinkNoise.ar(Env.perc.kr(doneAction: 2))}.play; // default Env.perc args
{PinkNoise.ar(Env.perc(0.5).kr(doneAction: 2))}.play;
{PinkNoise.ar(Env.perc(0.3, 2, 0.4).kr(2))}.play;
{PinkNoise.ar(Env.perc(0.3, 2, 0.4, 0).kr(2))}.play;  // .kr defines the done action. 2: free synth when done


~bus1 = Bus.audio(s, 2);
{Out.ar([0,1], In.ar(~bus1, 2))}.play;
{Out.ar(~bus1, SinOsc.ar(440!2))}.play;


//How do the different curves look?
Env.perc(0.3, 2, 0.4, 0).plot; // 0 = straigt lines
Env.perc(0.3, 2, 0.4, 10).plot; // very quick rise and very quick fall



///////////////////////////////////////////////// Create a evolving sea sound!!!! /////////////////////////////////////



/*Idea: Create evolving seagull sounds, create something that plays a note and then waits for note input. Depending on the incoming note it should again respond with something, creating some sort of mode. If there is not mode for the input it should answer again with a randomly choosen mode etc */

s.plotTree; //to check how many synths are active at a given moment
(
~attack = Bus.control(s,1);
~release = Bus.control(s,1);
~level = Bus.control(s,1);
~curve = Bus.control(s,1);
~waveoverlap = Bus.control(s,1);
)
(
{Out.kr([~attack], SinOsc.kr(0.005).range(1,2))}.play;
{Out.kr([~release], SinOsc.kr(0.0052).range(2.5,4))}.play;
{Out.kr([~level], SinOsc.kr(0.0006).range(0.1,1))}.play;
{Out.kr([~curve], SinOsc.kr(0.0021).range(-4,4))}.play;
{Out.kr([~waveoverlap], SinOsc.kr(0.051).range(0.3,1.5))}.play;
)

~sea = {Out.ar([0,1], {PinkNoise.ar(Env.perc(In.kr(~attack, 1), In.kr(~release, 1), In.kr(~level, 1), In.kr(~curve, 1)).kr(2))})};


(
t = Task({ {
	~sea.play;
	(
		("Attack:      " + ~attack.getSynchronous).postln;
		("Release:     " + ~release.getSynchronous).postln;
		("Level:       " + ~level.getSynchronous).postln;
		("Curve:       " + ~curve.getSynchronous).postln;
		("Waveoverlap: " + ~waveoverlap.getSynchronous).postln;
		("Total time : " + (~attack.getSynchronous + ~release.getSynchronous - ~waveoverlap.getSynchronous)).postln;
		" ".postln;
	);
	(
		~attack.getSynchronous + ~release.getSynchronous - ~waveoverlap.getSynchronous)
	.wait;}.loop });
)
                                              /// If we dont let the SinOsc controllers run over
                                              /// seperate buses, the loop
                                              /// will start the whole structure at the same point, thus keeping the
                                              /// Parameters the same on every iteration.
t.start;
t.stop;
                                              /// How can I take ~bus3 and insert the current value into the loop?







///////////////////////////////////////////////////////////////// ENVELOPES CONTINUED ////////////////////////////////////

s.plotTree;
// See it:
Env.triangle.plot;
// Hear it:
{SinOsc.ar([440, 442], mul: Env.triangle(dur: 3).kr(2))}.play;
// By the way, an envelope can be a multiplier anywhere in your code
{SinOsc.ar([440, 442]) * Env.triangle(dur:3).kr(2)}.play;
// or like this
{(SinOsc.ar([440, 442]) + LFTri.ar([880,882])) * Env.triangle(dur:3).kr(2)}.play;

//See it:
Env.linen.plot;
// Hear it:
{SinOsc.ar([300, 350], mul: Env.linen(attackTime: 0.01, sustainTime: 2, releaseTime: 1, level: 0.2).kr(2))}.play;


// Env.pairs
/*Need more flexibility? With Env.pairs you can have envelopes of any shape and duration you
want. Env.pairs takes two arguments: an array of [time, level] pairs, and a type of curve (see
the Env Help file for all available curve types).*/

(
{
	var env = Env.pairs([[0, 0], [0.4, 1], [1, 0.2], [1.1, 0.5], [2, 0]], \lin);
	env.plot;
	SinOsc.ar([440, 442], mul: env.kr(2));
}.play;
)


/* 38.4.1
Envelopes—not just for amplitude
Nothing is stopping you from using these same shapes to control something other than amplitude.
You just need to scale them to the desired range of numbers. For example, you can create an
envelope to control change of frequencies over time: */

(
{
	var freqEnv = Env.pairs([[0, 100], [0.4, 1000], [0.9, 400], [1.1, 555], [2,
		440], [10,100]], \lin);
	SinOsc.ar(freqEnv.kr()!2, mul: 0.2);    //.kr() with no argument hold it open
}.play;
)


/* 38.5 ADSR Envelope
All envelopes seen up to now have one thing in common: they have a fixed, pre-defined duration.
There are situations, however, when this type of envelope is not adequate. For example, imagine
you are playing on a MIDI keyboard. The attack of the note is triggered when you press a key.
The release is when you take your finger off the key. But the amount of time that you keep the
finger down is not known in advance. What we need in this case is a so-called “sustained envelope.”
In other words, after the attack portion, the envelope must hold the note for an indefinite amount
of time, and only trigger the release portion after some kind of cue, or message—i.e., the moment
you ’release the key’.
An ASR (Attack, Sustain, Release) envelope fits the bill. A more popular variation of it is
the ADSR envelope (Attack, Decay, Sustain, Release). Let’s look at both. */

// ASR
// Play note ('press key')
// attackTime: 0.5 seconds, sustainLevel: 0.8, releaseTime: 3 seconds
x = {arg gate = 1, freq = 440; SinOsc.ar(freq: freq, mul: Env.asr(0.5, 0.8, 3).kr(doneAction: 2, gate: gate))}.play;
// Stop note ('finger off the key' − activate release stage)
x.set(\gate, 0); // alternatively, x.release

// ADSR (attack, decay, sustain, release)
// Play note:
(
d = {arg gate = 1;
	var snd, env;
	env = Env.adsr(0.01, 1, 0.4, 2, peakLevel: 1);
	snd = Splay.ar(BPF.ar(Saw.ar((32.1, 32.2..33)), LFNoise2.kr(12).range(100,
		1000), 0.05, 10));
	Out.ar(0, snd * env.kr(doneAction: 2, gate: gate));
}.play;
)
// Stop note:
d.set(\gate, 0); // this is equivalent to d.release;


y= {arg gate = 1; FreeVerb.ar(Splay.ar(Saw.ar((32.1, 32.2..33), mul: Env.asr(0.5, 0.3, 5).kr(doneAction: 2, gate: gate))), room: 1, mix: 0.4, mul: 1)}.play;
y.set(\gate, 0);


/* 38.6 EnvGen
For the record, you should know that the construction you learned in this section to generate
envelopes is a shortcut, as shown in the code below. */

// This:
x = { SinOsc.ar * Env.perc.kr(doneAction: 2) }.play;
// ... is a shortcut for this:
{ SinOsc.ar * EnvGen.kr(Env.perc, doneAction: 2) }.play;


////////EnvGen Env.new /////////////////////////////////Very good way of defining own envelope:////////////////////////////

Env.new(levels: [0, 1, 1, 0], times: [0.01, 5-0.01, 0.01], curve: [0]).plot;
Env.new(levels: [0, 1, 0.9, 0], times: [0.01, 0.5, 1], curve: [0]).plot;

(
SynthDef(\testo, {
	arg freq = 440, dur = 1;
	var signal, env;
	//takes 0.01 sec to go from 0 to 1, dur-0.01 sec to go from 1 to 1(i want it to stay open till very end) and 0.01s to go to 0
	env = EnvGen.ar(Env.new(levels: [0, 1, 1, 0], times: [0.01, dur-0.01, 0.01], curve: [0]));
	signal = SinOsc.ar([freq, freq-5], 0.0, env);
	Out.ar(0, signal);
}).add;
)

(
Pbind(
	\instrument, \testo,
	\freq, Pseq(([0,2,3,5,7]+69).midicps, inf),
	\dur, 5
).play;
)


///////////////////////////////////////// SYNTH DEFINITIONS ////////////////////////////////////////////////////////////
/*So far we have been seamlessly defining synths and playing them right away. In addition, the .set
message gave us some flexibility to alter synth controls in real time. However, there are situations
when you may want to just define your synths first (without playing them immediately), and
only play them later. In essence, this means we have to separate the moment of writing down
the recipe (the synth definition) from the moment of baking the cake (creating the sound).*/


// Synth definition with SynthDef object
SynthDef("mySine1", {Out.ar(0, SinOsc.ar(770, 0, 0.1))}).add;
// Play a note with Synth object
x = Synth("mySine1");
x.free;
// A slightly more flexible example using arguments
// and a self−terminating envelope (doneAction: 2)
(
SynthDef("mySine2", {arg freq = 440, amp = 0.1;
	var env = Env.perc(level: amp).kr(2);
	var snd = SinOsc.ar(freq, 0, env);
	Out.ar(0, snd);
}).add;
)
Synth("mySine2"); // using default values
Synth("mySine2", [\freq, 770, \amp, 0.2]);
Synth("mySine2", [\freq, 415, \amp, 0.1]);
Synth("mySine2", [\freq, 346, \amp, 0.3]);
Synth("mySine2", [\freq, rrand(440, 880)]);



/////////////////////////////////////////////////////////////Pitch following////////////////////////////////////////////////

c=Buffer.read(s,"/home/nikolas/.local/share/SuperCollider/Recordings/guitar.aiff"); //sitar test file, try anything you have on your disk

{PlayBuf.ar(2,c)}.play;

c.numFrames


(
        SynthDef("pitchFollow1", { |out|
            var in, amp, freq, hasFreq, sound;
            in = in = PlayBuf.ar(2,c.bufnum, loop:1);
            amp = Amplitude.kr(in, 0.05, 0.05);
            # freq, hasFreq = Pitch.kr(in, ampThreshold: 0.02, median: 7);
            //freq = Lag.kr(freq.cpsmidi.round(1).midicps, 0.05);
            sound = Mix.new(VarSaw.ar(freq * [0.5, 1, 2], 0, LFNoise1.kr(0.3, 0.1, 0.1), amp));
            6.do {
                sound = AllpassN.ar(sound, 0.040, [0.040.rand,0.040.rand], 2)
            };
            Out.ar(out, sound);
        }).play
    )




( //sample tracking
SynthDef("pitchFollow1",{
    var in, amp, freq, hasFreq, out;

    in = PlayBuf.ar(2,c.bufnum, loop:1);
    amp = Amplitude.kr(in, 0.05, 0.05);

    # freq, hasFreq = Tartini.kr(in);

    out = Mix.new(VarSaw.ar(freq * [0.5,1,2], 0, LFNoise1.kr(0.3,0.1,0.1), amp));

    Out.ar(0,[out,in])
}).play(s);
)


(
SynthDef(\RmOctaver, {
	arg out, shift = 2; // same as "arg out";
	var in, freq, hasFreq;
	in = SoundIn.ar(0);
	# freq, hasFreq = Pitch.kr(in);
	Out.ar(out, SinOsc.ar(freq: freq!2 * shift) * in);
}).add;
)

x = Synth.new(\RmOctaver);
// x.set(\shift, 10);

t = Task{({x.set(\shift, rrand(0.1,10)); 5.wait;}.loop)};
t.start;



# freq, hasFreq = Pitch.kr(SinOsc.ar(440!2 *1));




(
SynthDef("pitchFollow1",{
    var in, amp, freq, hasFreq, out;
    in = Mix.new(SoundIn.ar([0,1]));
    amp = Amplitude.kr(in, 0.05, 0.05);
    # freq, hasFreq = Tartini.kr(in, 0.93,1024,512,512);
    //freq = Lag.kr(freq.cpsmidi.round(1).midicps, 0.05);
    out = Mix.new(VarSaw.ar(freq * [0.5,1,2], 0, LFNoise1.kr(0.3,0.1,0.1), amp));
    6.do({
        out = AllpassN.ar(out, 0.040, [0.040.rand,0.040.rand], 2)
    });
    Out.ar(0,out)
}).play(s);
)


(
        SynthDef("pitchFollow2", { |out|
            var in, amp, freq, hasFreq, sound;
            in = Mix.new(SoundIn.ar([0, 1]));
            amp = Amplitude.kr(in, 0.05, 0.05);
            # freq, hasFreq = Pitch.kr(in, ampThreshold: 0.02, median: 7);
            sound = CombC.ar(LPF.ar(in, 1000), 0.1, (2 * freq + 10).reciprocal, -6).distort * 0.05;
            6.do({
                sound = AllpassN.ar(sound, 0.040, [0.040.rand, 0.040.rand], 2)
            });
            Out.ar(out, sound);
        }).play(s);
    )


/////////////////////////////////Synthdefs continued////////////////////////////////////////////////////////////////////

// Create SynthDef
(
SynthDef("wow", {arg freq = 60, amp = 0.1, gate = 1, wowrelease = 3;
	var chorus, source, filtermod, env, snd;
	chorus = freq.lag(2) * LFNoise2.kr([0.4, 0.5, 0.7, 1, 2, 5, 10]).range(1,
		1.02);
	source = LFSaw.ar(chorus) * 0.5;
	filtermod = SinOsc.kr(1/16).range(1, 10);
	env = Env.asr(1, amp, wowrelease).kr(2, gate);
	snd = LPF.ar(in: source, freq: freq * filtermod, mul: env);
	Out.ar(0, Splay.ar(snd))
}).add;
)


// Watch the Node Tree
s.plotTree;
// Create a 6−note chord
a = Array.fill(6, {Synth("wow", [\freq, rrand(40, 70).midicps, \amp, rrand(0.1, 0.5)])}); // all in a single line
// Release notes one by one
a[0].set(\gate, 0);
a[1].set(\gate, 0);
a[2].set(\gate, 0);
a[3].set(\gate, 0);
a[4].set(\gate, 0);
a[5].set(\gate, 0);
// ADVANCED: run 6−note chord again, then evaluate this line.
// Can you figure out what is happening?
SystemClock.sched(0, {a[5.rand].set(\midinote, rrand(40, 70)); rrand(3, 10)});


(
Pbind(
	\instrument, "wow",
	\degree, Pwhite(−7, 7),
	\dur, Prand([0.125, 0.25], inf),
	\amp, Pwhite(0.5, 1),
	\wowrelease, 1
).play;
)
(
Pbind(
	\instrument, "wow",
	\scale, Pstutter(8, Pseq([
		Scale.lydian,
		Scale.major,
		Scale.mixolydian,
		Scale.minor,
		Scale.phrygian], inf)),
	\degree, Pseq([0, 1, 2, 3, 4, 5, 6, 7], inf),
	\dur, 0.2,
	\amp, Pwhite(0.5, 1),
	\wowrelease, 4,
	\legato, 0.1
).play;
)

///////////////////////////////////////////////////////////NICE COMPOSITION/////////////////////////////////////////////


(
SynthDef("pluck", {arg amp = 0.1, freq = 440, decay = 5, mutedString = 0.1;
	var env, snd;
	env = Env.linen(0, decay, 0).kr(doneAction: 2);
	snd = Pluck.ar(
		in: WhiteNoise.ar(amp),
		trig: Impulse.kr(0),
		maxdelaytime: 0.1,
		delaytime: freq.reciprocal,
		decaytime: decay,
		coef: mutedString);
	Out.ar(0, [snd, snd]);
}).add;
)

(
Pbind(
	\instrument, "pluck",
	\note, Pseq([[0, 3, 7], [0, 5, 8], [0, 2, 7], [-1,2,7],[0, 3, 7]],inf),
	\dur, Pstutter(4, Pseq([0.4, 0.6, 0.8], inf)),
	\amp, Pseq([0.2], inf),
	\mutedString, 0.3,
	\strum, Pseq([0.6, 1], inf),
	\ctranspose, Pstutter(25, Pseq([0, 7],inf))
).play;
)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

(
Pbind(
	\instrument, "pluck",
	\note, Pseq([0,2,3,5,7],inf),
	\dur, Pseq([0.2], inf),
	\mutedString, Pstutter(8, Pseq([0.1, 0.5],inf)),
	\amp, Pseq([0.2,0.3],inf)
).play;
)


Quarks.gui;


////////////////////////////////////////////////////Control bus///////////////////////////////////////////////

// Create the control bus
~myControl = Bus.control(s, 1);
// Feed the control signal into the bus
c = {Out.kr(~myControl, Pulse.kr(freq: MouseX.kr(1, 10), mul: MouseY.kr(0, 1)))}.play;
// Play the sounds being controlled
// (move the mouse to hear changes)
(
{
	Blip.ar(
		freq: LFNoise0.kr([1/2, 1/3]).range(50, 60),
		numharm: In.kr(~myControl).range(1, 10),
		mul: LFTri.kr([1/4, 1/6]).range(0, 0.1))
}.play;
{
	Splay.ar(
		Pulse.ar(
			freq: LFNoise0.kr([1.4, 1, 1/2, 1/3]).range(100, 1000)
			* In.kr(~myControl).range(0.9, 1.1),
			mul: SinOsc.ar([1/3, 1/2, 1/4, 1/8]).range(0, 0.03))
	)
}.play;
)
// Turn off control signal to compare
c.free;


// Create a SynthDef
SynthDef("simple", {arg freq = 440; Out.ar(0, SinOsc.ar(freq, mul: 0.2))}).add;
// Creat control buses
~oneBus = Bus.control(s, 1);
~anotherBus = Bus.control(s, 1);
// Start controls
{Out.kr(~oneBus, LFSaw.kr(1).range(100, 1000))}.play;
{Out.kr(~anotherBus, LFSaw.kr(2, mul: −1).range(500, 2000))}.play;
// Start a note
x = Synth("simple", [\freq, 800]);
x.set(\freq, ~oneBus.asMap);
x.set(\freq, ~anotherBus.asMap);
x.free;



////order of execution useful positioning inside the node

n = Synth("noise", addAction: 'addToHead');
m = Synth("masterOut", addAction: 'addToTail');
f = Synth("filter", target: n, addAction: 'addAfter');
