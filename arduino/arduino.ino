#include <LightChrono.h>
#include <EasyButton.h>

const char DEBUG[100];

#define ARRAY_SIZE(arr) sizeof(arr) / sizeof(arr[0])

#define NUMBER_OF_LINES								3
#define NUMBER_OF_COLUMNS							3

#define COMMAND_PROGRAM               "P"
#define COMMAND_BPM                   "B"
#define COMMAND_BEAT_MULTIPLIER       "M"
#define COMMAND_ANIMATION_MULTIPLIER  "A"
#define COMMAND_SYNC                  "S"
#define COMMAND_TURN_ON_LED           "L"
#define COMMAND_UPDATE_TO_SERIAL      "U:"

#define BPM_MIN                   50
#define BPM_MAX                   200

#define FULL_ON_BUTTON_PIN        22

const double BEAT_MULTIPLIERS[] = { 1.0 / 16, 1.0 / 8, 1.0 / 4, 1.0 / 2, 1.0, 2.0, 4.0, 8.0 };
const double ANIMATION_MULTIPLIERS[] = { 1.0 / 16, 1.0 / 8, 1.0 / 4, 1.0 / 2, 1.0 };

/*
 * LEDS
 */
int leds[] = { 2, 3, 4, 5, 6, 7, 8, 9, 10 };
int numberOfLeds = ARRAY_SIZE(leds);
bool shouldBeFullOn;
bool shouldBeFullOff;

void initLeds() {
	shouldBeFullOn = false;
	shouldBeFullOff = false;

	for (int i = 0; i < numberOfLeds; i++) {
		pinMode(leds[i], OUTPUT);
	}
}

void turnOnLed(int value) {
	int ledIndex = constrain(value, 0, numberOfLeds - 1);

	digitalWrite(leds[ledIndex], HIGH);
}

void turnOffLed(int value) {
	int ledIndex = constrain(value, 0, numberOfLeds - 1);

	digitalWrite(leds[ledIndex], LOW);
}

void turnOnAllLeds() {
	for (int i = 0; i < numberOfLeds; i++) {
		digitalWrite(leds[i], HIGH);
	}
}

void turnOffAllLeds() {
	for (int i = 0; i < numberOfLeds; i++) {
		digitalWrite(leds[i], LOW);
	}
}

/*
 * Buttons
 */
EasyButton buttonShouldBeFullOn(FULL_ON_BUTTON_PIN);

void initButtons() {
	buttonShouldBeFullOn.begin();
}

void readFullOnButton() {
	buttonShouldBeFullOn.read();

	shouldBeFullOn = buttonShouldBeFullOn.isPressed();
}

void readFromButtons() {
	readFullOnButton();
}

/*
 * PROGRAMS
 */
int stepNumber;
int selectedProgram;

void initPrograms() {
	stepNumber = -1;
	selectedProgram = 0;
}

void black(int stepNumber) {
	turnOffAllLeds();
}

void blink(int stepNumber) {
	turnOnAllLeds();
}

void sweep(int stepNumber) {
	turnOffAllLeds();

	turnOnLed(stepNumber);
}

void columnSweep(int stepNumber) {
	byte ledState;

	for (int i = 0; i < numberOfLeds; i++) {
		ledState = stepNumber * NUMBER_OF_COLUMNS <= i && i < (stepNumber + 1) * NUMBER_OF_COLUMNS ? HIGH : LOW;

		digitalWrite(leds[i], ledState);
	}
}

void lineSweep(int stepNumber) {
	int lineNumber;

	for (int i = 0; i < numberOfLeds; i++) {
		lineNumber = map(i % NUMBER_OF_LINES, 0, NUMBER_OF_LINES - 1, NUMBER_OF_LINES - 1, 0);

		digitalWrite(leds[i], stepNumber == lineNumber);
	}
}

void fill(int stepNumber) {
	int ledIndex;
	byte state;

	if (stepNumber < numberOfLeds) {
		ledIndex = stepNumber;
		state = HIGH;
	} else {
		ledIndex = stepNumber - numberOfLeds;
		state = LOW;
	}

	digitalWrite(leds[ledIndex], state);
}

void clockwise(int stepNumber) {
	int ledIndex;

	switch (stepNumber) {
		case 0: ledIndex = 0; break;
		case 1: ledIndex = 1; break;
		case 2: ledIndex = 2; break;
		case 3: ledIndex = 5; break;
		case 4: ledIndex = 8; break;
		case 5: ledIndex = 7; break;
		case 6: ledIndex = 6; break;
		case 7: ledIndex = 3; break;
	}

	turnOffAllLeds();

	turnOnLed(ledIndex);
}

void counterClockwise(int stepNumber) {
	int ledIndex;

	switch (stepNumber) {
		case 0: ledIndex = 0; break;
		case 1: ledIndex = 3; break;
		case 2: ledIndex = 6; break;
		case 3: ledIndex = 7; break;
		case 4: ledIndex = 8; break;
		case 5: ledIndex = 5; break;
		case 6: ledIndex = 2; break;
		case 7: ledIndex = 1; break;
	}

	turnOffAllLeds();

	turnOnLed(ledIndex);
}

void zigzag(int stepNumber) {
	int ledIndex;

	switch (stepNumber) {
		case 0: ledIndex = 2; break;
		case 1: ledIndex = 5; break;
		case 2: ledIndex = 8; break;
		case 3: ledIndex = 7; break;
		case 4: ledIndex = 4; break;
		case 5: ledIndex = 1; break;
		case 6: ledIndex = 0; break;
		case 7: ledIndex = 3; break;
		case 8: ledIndex = 6; break;
	}

	turnOffAllLeds();

	turnOnLed(ledIndex);
}

void snake(int stepNumber) {
	boolean isPhaseOne = stepNumber < numberOfLeds;

	int step = isPhaseOne ? stepNumber : stepNumber - numberOfLeds;
	byte state = isPhaseOne ? HIGH : LOW;

	int ledIndex;

	switch (step) {
		case 0: ledIndex = 2; break;
		case 1: ledIndex = 5; break;
		case 2: ledIndex = 8; break;
		case 3: ledIndex = 7; break;
		case 4: ledIndex = 4; break;
		case 5: ledIndex = 1; break;
		case 6: ledIndex = 0; break;
		case 7: ledIndex = 3; break;
		case 8: ledIndex = 6; break;
	}

	digitalWrite(leds[ledIndex], state);
}

void alternate(int stepNumber) {
	byte ledState = 0 == stepNumber ? HIGH : LOW;

	for (int i = 0; i < numberOfLeds / 2; i++) {
		digitalWrite(leds[i], ledState);
	}

	for (int i = numberOfLeds / 2; i < numberOfLeds; i++) {
		digitalWrite(leds[i], !ledState);
	}
}

void random(int stepNumber) {
	for (int i = 0; i < numberOfLeds; i++) {
		byte ledState = 0 == random(0, 2) ? HIGH : LOW;

		digitalWrite(leds[i], ledState);
	}
}

void breathe(int stepNumber) {
	int middleLed = numberOfLeds / 2;

	if (0 == stepNumber) {
		turnOffAllLeds();

		turnOnLed(4);
	} else {
		turnOnAllLeds();

		turnOffLed(4);
	}
}

typedef struct {
	int numberOfSteps;
	void (* handler)(int stepNumber);
} program;

program programs[] = {
	{ 1, black },
	{ 1, blink },
	{ numberOfLeds, sweep },
	{ NUMBER_OF_COLUMNS, columnSweep },
	{ NUMBER_OF_LINES, lineSweep },
	{ 2 * numberOfLeds, fill },
	{ numberOfLeds - 1, clockwise },
	{ numberOfLeds - 1, counterClockwise },
	{ numberOfLeds, zigzag },
	{ 2 * numberOfLeds, snake },
	{ 2, alternate },
	{ numberOfLeds, random },
	{ 2, breathe }
};

void runProgram(int elapsed, int animationLength) {
	double numberOfSteps = (double) programs[selectedProgram].numberOfSteps;
	int currentStep = (long int) (elapsed * numberOfSteps / animationLength);

	if (currentStep == numberOfSteps) {
		return;
	}

	if (currentStep != stepNumber) {
		stepNumber = currentStep;

		programs[selectedProgram].handler(stepNumber);
	}
}

/*
 * TIMING
 */
double bpm;
int beatMultiplierIndex;
double animationMultiplier;
int animationMultiplierIndex;
bool shouldSync;

void initAnimation() {
	bpm = 120;
	beatMultiplierIndex = 4;
	animationMultiplierIndex = 3;
	shouldSync = false;
}

void setProgramFromSerial(int newSelectedProgram) {
	selectedProgram = constrain(newSelectedProgram, 0, ARRAY_SIZE(programs) - 1);

	Serial.print(COMMAND_UPDATE_TO_SERIAL);
	Serial.print("P=");
	Serial.print(selectedProgram);
	Serial.print("&S=");
	Serial.print(programs[selectedProgram].numberOfSteps);
	Serial.println();
}

void setBpmFromSerial(double newBpm) {
	bpm = constrain(newBpm, BPM_MIN, BPM_MAX);

	Serial.print(COMMAND_UPDATE_TO_SERIAL);
	Serial.print("B=");
	Serial.print(bpm);
	Serial.println();
}

void setBeatMultiplierFromSerial(int value) {
	int newBeatMultiplierIndex = constrain(value, 0, ARRAY_SIZE(BEAT_MULTIPLIERS) - 1);

	beatMultiplierIndex = newBeatMultiplierIndex;

	Serial.print(COMMAND_UPDATE_TO_SERIAL);
	Serial.print("M=");
	Serial.print(newBeatMultiplierIndex);
	Serial.println();
}

void setAnimationMultiplierFromSerial(int value) {
	int newAnimationMultiplierIndex = constrain(value, 0, ARRAY_SIZE(ANIMATION_MULTIPLIERS) - 1);

	animationMultiplierIndex = newAnimationMultiplierIndex;

	Serial.print(COMMAND_UPDATE_TO_SERIAL);
	Serial.print("A=");
	Serial.print(animationMultiplierIndex);
	Serial.println();
}

void setShouldSync() {
	shouldSync = true;
}

void sendAllToSerial() {
	Serial.print(COMMAND_UPDATE_TO_SERIAL);
	Serial.print("P=");
	Serial.print(selectedProgram);
	Serial.print("&S=");
	Serial.print(programs[selectedProgram].numberOfSteps);
	Serial.print("&B=");
	Serial.print(bpm);
	Serial.print("&M=");
	Serial.print(beatMultiplierIndex);
	Serial.print("&A=");
	Serial.print(animationMultiplierIndex);
	Serial.println();
}

void readFromSerial() {
	if (Serial.available() <= 0) {
		return;
	}

	String command = Serial.readStringUntil(':');
	String value = Serial.readStringUntil('\n');

	if (command == COMMAND_PROGRAM) {
		setProgramFromSerial(value.toInt());
	} else if (command == COMMAND_BPM) {
		setBpmFromSerial(value.toDouble());
	} else if (command == COMMAND_BEAT_MULTIPLIER) {
		setBeatMultiplierFromSerial(value.toInt());
	} else if (command == COMMAND_ANIMATION_MULTIPLIER) {
		setAnimationMultiplierFromSerial(value.toInt());
	} else if (command == COMMAND_SYNC) {
		setShouldSync();
	} else if (command == COMMAND_TURN_ON_LED) {
		turnOnLed(value.toInt());
	}
}

/*
 * ANIMATION
 */
int elapsed = 0;
bool isTimeOn;
bool isTimeOff;
LightChrono chrono;

int getTotalLength() {
	double beatMultiplier = BEAT_MULTIPLIERS[beatMultiplierIndex];

	return (long int) (beatMultiplier * 1000 * 60 / bpm);
}

int getAnimationLength() {
	double beatMultiplier = BEAT_MULTIPLIERS[beatMultiplierIndex];
	double animationMultiplier = ANIMATION_MULTIPLIERS[animationMultiplierIndex];

	return (long int) (animationMultiplier * beatMultiplier * 1000 * 60 / bpm);
}

void resetLoop() {
	stepNumber = -1;

	chrono.restart();

	sendAllToSerial();
}

/*
 * MAIN
 */
void setup() {
	Serial.begin(9600);
	Serial.setTimeout(100);

	initLeds();

	initButtons();

	initPrograms();

	initAnimation();
}

void loop() {
	readFromButtons();

	readFromSerial();

	if (shouldBeFullOn) {
		turnOnAllLeds();

		return;
	}

	if (shouldBeFullOff) {
		turnOffAllLeds();

		return;
	}

	if (shouldSync) {
		resetLoop();

		shouldSync = false;

		return;
	}

	elapsed = chrono.elapsed();
	int total = getTotalLength();
	int animationLength = getAnimationLength();

	isTimeOn = elapsed <= animationLength;
	isTimeOff = animationLength < elapsed && elapsed <= total;

	if (isTimeOn)
		runProgram(elapsed, animationLength);

	else if (isTimeOff)
		turnOffAllLeds();

	else
		resetLoop();
}
