#include <LightChrono.h>
#include <EasyButton.h>

#define ARRAY_SIZE(arr) sizeof(arr) / sizeof(arr[0])

#define COMMAND_PROGRAM               "P"
#define COMMAND_BPM                   "B"
#define COMMAND_BEAT_MULTIPLIER       "M"
#define COMMAND_ANIMATION_MULTIPLIER  "A"
#define COMMAND_SYNC                  "S"
#define COMMAND_UPDATE_TO_SERIAL      "U:"

#define BPM_MIN                   50
#define BPM_MAX                   200
#define BEAT_MULTIPLIER_MIN       1.0 / 16.0
#define BEAT_MULTIPLIER_MAX       16
#define ANIMATION_MULTIPLIER_MIN  1.0 / 16.0
#define ANIMATION_MULTIPLIER_MAX  1.0

#define FULL_ON_BUTTON_PIN        22

/*
 * LEDS
 */
int leds[] = { 2, 3, 4, 5 };
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
	stepNumber = 1;
	selectedProgram = 2;
}

void black(int stepNumber) {
	turnOffAllLeds();
}

void blink(int stepNumber) {
	turnOnAllLeds();
}

void sweep(int stepNumber) {
	for (int i = 0; i < numberOfLeds; i++) {
		if (i == stepNumber)
			digitalWrite(leds[i], HIGH);
		else
			digitalWrite(leds[i], LOW);
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

void alternate(int stepNumber) {
	byte ledState = 0 == stepNumber ? HIGH : LOW;

	for (int i = 0; i < numberOfLeds / 2; i++) {
		digitalWrite(leds[i], ledState);
	}

	for (int i = numberOfLeds / 2; i < numberOfLeds; i++) {
		digitalWrite(leds[i], !ledState);
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
	{ 2 * numberOfLeds, fill },
	{ 2, alternate }
};

void runProgram(int elapsed, int animationLength) {
	int numberOfSteps = programs[selectedProgram].numberOfSteps;
	int currentStep = ceil(elapsed * numberOfSteps / animationLength);

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
double beatMultiplier;
double animationMultiplier;
bool shouldSync;
String command;
String value;

void initAnimation() {
	bpm = 120;
	beatMultiplier = 1.0;
	animationMultiplier = 0.5;
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

void setBeatMultiplierFromSerial(double newBeatMultiplier) {
	beatMultiplier = constrain(newBeatMultiplier, BEAT_MULTIPLIER_MIN, BEAT_MULTIPLIER_MAX);

	Serial.print(COMMAND_UPDATE_TO_SERIAL);
	Serial.print("M=");
	Serial.print(beatMultiplier);
	Serial.println();
}

void setAnimationMultiplierFromSerial(double newAnimationMultiplier) {
	animationMultiplier = constrain(newAnimationMultiplier, ANIMATION_MULTIPLIER_MIN, ANIMATION_MULTIPLIER_MAX);

	Serial.print(COMMAND_UPDATE_TO_SERIAL);
	Serial.print("A=");
	Serial.print(animationMultiplier);
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
	Serial.print(beatMultiplier);
	Serial.print("&A=");
	Serial.print(animationMultiplier);
	Serial.println();
}

void readFromSerial() {
	if (Serial.available() <= 0) {
		return;
	}

	command = Serial.readStringUntil(':');
	value = Serial.readStringUntil('\n');

	if (command == COMMAND_PROGRAM) {
		setProgramFromSerial(value.toInt());
	} else if (command == COMMAND_BPM) {
		setBpmFromSerial(value.toDouble());
	} else if (command == COMMAND_BEAT_MULTIPLIER) {
		setBeatMultiplierFromSerial(value.toDouble());
	} else if (command == COMMAND_ANIMATION_MULTIPLIER) {
		setAnimationMultiplierFromSerial(value.toDouble());
	} else if (command == COMMAND_SYNC) {
		setShouldSync();
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
	return (long int) (beatMultiplier * 1000 * 60 / bpm);
}

int getAnimationLength() {
	return (long int) (animationMultiplier * beatMultiplier * 1000 * 60 / bpm);
}

void resetLoop() {
	stepNumber = 1;

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
