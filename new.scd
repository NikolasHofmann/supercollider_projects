(
Pbind(
    \degree, Pseries(0, 1, 8),
    \dur, 0.25
).play;
)

(
var number;
number = 3.cubed;
)

//global variables a-z reserved or use "~" for example ~number

~number = 3.cubed;

~number;

(
var foo;
foo = 3;
foo = foo.cubed;
foo = foo + 100;
foo = foo / 2;
foo;
)


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

x = {SoundIn.ar([0,0])}.play;

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

//How to record sound?


//How to play a sample:

~sample = Buffer.readChannel(s,"
