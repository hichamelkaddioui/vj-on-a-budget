# VJ on a budget

## Overview

<details>

<summary>Context</summary>

Recently my roommate gave me a 5-meter, generic, white LED stripe that he never used and no longer needed. Convinced that it's possible to make fancier stuff than just some decoration, I used it as a pretext to dedust my Arduino and tried build something more playful.

We were having a party a few days later, so the idea was to make a club-like lightning system that would be kind of reactive with the music. There are nice DIY projects on the web when you google "led stripe music Arduino", but most of them require either a microphone chip or a fancy addressable LED stripe, or both...but I had none of these - hence "on a budget".

</details>

### Cheap solution

Instead of a single long stripe the idea is to control multiple smaller stripes disposed on a grid. The user sets a rhythm (aka beats per minute aka _BPM_), some other duration settings (see below for further explanation) and an looping animation (see below for the list of animations) through a processing interface, and Arduino takes care of turning LEDs on and off.

```
┌────────────┐              ┌─────────┐            ┌─────────────┐
│ Processing │ <--Serial--> │ Arduino │ Digital--> │ LED stripes │
└────────────┘              └─────────┘            └─────────────┘
```

Compared to buying a smart LED stripe, this only requires few NPN transistors (cheap), some cable (very cheap) and a spoonful of processing code.

#### LED grid

This piece of software is made to work with a 3x3 grid of LEDs due to the architecture of our living room.

This is how Arduino thinks that the LED are disposed, with their corresponding pins:

```
┌──────┬──────┬──────┐
│   2  │   5  │   8  │
├──────┼──────┼──────┤
│   3  │   6  │   9  │
├──────┼──────┼──────┤
│   4  │   7  │  10  │
└──────┴──────┴──────┘
```

#### Programs

An program basically consist of

- a number of distinct steps
- a handler function that turn LEDs on and off given the current step

#### Timing

Animations are set to be run, then wait, then loop over.

Animations loop on fractions or multiples of a beat duration, from 1/16 of a beat to 8 beats. This defines the _loop length_.

The time during which the animation actually runs is a fraction of the total loop length, internally called _animation duration_.

For instance, for a BPM of `100`, a loop length of `4 beats` and an animation duration of `1/2`:

- the loop length will be `(60 / 100) * 4 = 2.4 s = 2400 ms`
- the animation length will be `2.4 * 0.5 = 1.2 s = 1200 ms`

```
Beat #1           Beat #2           Beat #3           Beat #4
───────────────── ───────────────── ───────────────── ─────────────────
0                               1200ms                           2400ms
┌─────────────────────────────────────────────────────────────────────┐
│                             Loop length                             │
└─────────────────────────────────────────────────────────────────────┘
┌──────────────────────────────────┐┌─────────────────────────────────┐
│         Animation length         ││           All LEDs off          │
└──────────────────────────────────┘└─────────────────────────────────┘
```

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
3. Compile & upload `arduino/arduino.ino` to the board

### Physical setup

1. Put the LED stripes where you would like them to be
2. Connect the negative pole of the alimentation to the Arduino's `GND` pin
3. Connect all the stripes `+12V` lines to the positive pole of the alimentation
4. Connect all the stripes `GND` lines to the collector (C) pin of a NPN transistor
5. Connect all the bases (B) pins of the NPN transistors to the digital pins you want to use on the Arduino
6. Connect all the emitter (E) pins of the NPN transistors to the Arduino's `GND` pin

## Usage

Once setup, connect the Arduino board to your computer and run the processing file eloquently called `processing/processing.pde`.

## Debug

Processing and Arduino use the Serial port to communicate between each other. Most of the time though, Processing gives orders and Arduino just acknowledges. Messages are prefixed by an uppercase letter and a colon, and the messages consist of key/value couples like so: `PREFIX:key1=value1&key2=value2`.

If the Processing GUI were to fail, you can debug these messages and send commands through the Arduino IDE's serial monitor.

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
