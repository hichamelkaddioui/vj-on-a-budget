# VJ on a budget

## Setup

### Requirements

- Some LED stripes
- As many NPN transistors as there are stripes
- Some electrical cable
- 1 x 12V DC alimentation
- 1 x Arduino board
- 1 x Computer connected to said Arduino with Arduino (and drivers) and Processing installed

### Processing

Install the `ControlP5` library

### Arduino IDE

1. Install the `Chrono` library
2. Edit the LED pins in `arduino/arduino.ino`
3. (Optional) Set the `NUMBER_OF_LINES` and `NUMBER_OF_COLUMNS` in `arduino/arduino.ino` for optimal results
4. Compile & upload `arduino/arduino.ino` to the board

### Physical setup

1. Put the LED stripes where you would like them to be
2. Connect the negative pole of the alimentation to the Arduino's `GND` pin
3. Connect all the stripes `+12V` lines to the positive pole of the alimentation
4. Connect all the stripes `GND` lines to the collector (C) pin of a NPN transistor
5. Connect all the base (B) pins of the NPN transistors to the digital pins you want to use on the Arduino
6. Connect all the emitter (E) pins of the NPN transistors to the Arduino's `GND` pin
7. Add some resistors here and there

This schema illustrates, roughly speaking, how LED stripes should be connected to the Arduino and power supply.

![Schematics](./docs/schematics.svg)

## Usage

1. Connect the Arduino board to your computer
2. Open and run `processing/processing.pde`

## In depth

### Context

Recently my roommate gave me a 5-meter, generic, white LED stripe that he never used and no longer needed. Convinced that it's possible to make fancier stuff than just some decoration, I used it as a pretext to dedust my Arduino and tried build something more playful.

Since we were having a party a few days later, so the idea was to make a club-like lighting system that would be kind of reactive with the music. While there are nice DIY projects on the web when you google "led stripe music Arduino", most of them require either a microphone chip or a fancy addressable LED stripe, or both...and I had none of these.

### Cheap solution

Instead of powering a single long stripe, the idea is to control multiple smaller stripes arranged on a grid. The user sets a rhythm (aka beats per minute aka _BPM_), some other duration settings (see below for further explanation) and an looping animation through a Processing interface, and Arduino takes care of turning LEDs on and off.

![Overview schema](./docs/overview.svg)

Compared to buying a smart LED stripe, this only requires few NPN transistors (cheap), some cable (very cheap) and a spoonful of Processing code (even cheaper).

### Concepts

Animations are set to be run, then wait, then loop over.

Animations loop on fractions or multiples of a beat duration, from 1/16 of a beat to 8 beats: it's the _loop length_.

The time during which the animation actually runs is a fraction, between 1/16 of the loop length and the total length: it's the _animation length_.

A _program_ is the implementation of an animation, in Arduino. It consists of:

- a number of distinct steps
- a handler function

Arduino evenly divides the animation length by the number of steps, and repeatedly calls the handler with the current step number. Then handler is in charge of turning LEDs on and off given this number.

For instance, for a BPM of `100`, a loop length of `4` beats, an animation length of `1/2` and a program that consists of `4` steps:

- the loop length will be `(60 / 100) * 4 = 2.4 s = 2400 ms`
- the animation length will be `2.4 * 0.5 = 1.2 s = 1200 ms`
- each step will last `1.2 / 4 = 0.3 s = 300 ms`

![Timing illustration](./docs/timing.svg)

## Debug

Processing and Arduino use the Serial port to communicate between each other: Processing gives orders and Arduino returns its state.

Messages are prefixed by an uppercase letter and a colon, and the messages consist of key/value couples like so: `PREFIX:key1=value1&key2=value2`.

You can debug these messages and send commands through the Arduino IDE's serial monitor.

### Serial messages from Processing to Arduino

| Prefix | Description                  | Example   | Response    | Default | Range                                       |
| :----: | :--------------------------- | --------- | ----------- | ------- | ------------------------------------------- |
|  `P`   | Set the program              | `P:3`     | `U:P=3&S=8` | `0`     | `0` - `{number of programs}`                |
|  `B`   | Set the BPM                  | `B:128`   | `U:B=128`   | `120`   | `50` - `200`                                |
|  `M`   | Set the beat multiplier      | `M:0.125` | `U:M=0.12`  | `1.0`   | `1/16th` of a beat - `8` beats              |
|  `A`   | Set the animation multiplier | `A:0.75`  | `U:A=0.75`  | `0.5`   | `1/16th` of the loop length - `full` length |
|  `S`   | Sync the animation start     | `S:`      | N/A         | N/A     | N/A                                         |

### Serial messages from Arduino to Processing

All messages from Arduino are prefixed with `U:`. At the beginning of each animation loop, the Arduino board send data to Processing so that it can update its GUI. Typically, theses messages look like `U:P=3&S=8&B=128&M=0.12&A=0.75`.
