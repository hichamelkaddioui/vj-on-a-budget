# VJ on a budget

## Installation

### Arduino

1. Install the following libraries:

   - Chrono
   - EasyButton

2. Edit LED pins in `arduino/arduino.ino`

3. Upload `arduino/arduino.ino` to the board using Arduino IDE

### Processing

> TODO

## Usage

```
Processing <-> Arduino
          Serial
```

### From Processing to Arduino

| Command | Description                  | Example   | Response    | Default | Range                                    |
| :------ | :--------------------------- | --------- | ----------- | ------- | ---------------------------------------- |
| `P`     | Set the program              | `P:3`     | `U:P=3&S=8` | `0`     | 0 - number of programs                   |
| `B`     | Set the BPM                  | `B:128`   | `U:B=128`   | `120`   | 50 - 200                                 |
| `M`     | Set the beat multiplier      | `M:0.125` | `U:M=0.12`  | `1.0`   | 1/16th of a beat - 16 beats              |
| `A`     | Set the animation multiplier | `A:0.75`  | `U:A=0.75`  | `0.5`   | 1/16th of the total length - full length |
| `S`     | Sync the first beat          | `S:`      | N/A         | N/A     | N/A                                      |

### From Arduino to Processing

Every loop iteration, all relavant variables are sent to Processing.

E.g.

```
U:P=3&S=8&B=128&M=0.12&A=0.75
```
