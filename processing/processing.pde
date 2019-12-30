import processing.serial.*;
import controlP5.*;

Serial arduino;
String message;

ControlP5 cp5;
public float numberboxValue = 100;

int selectedProgram;
int numberOfSteps;
double bpm;
double beatMultiplier;
double animationMultiplier;

void setupArduino() {
	String portName = Serial.list()[2];
	arduino = new Serial(this, portName, 9600);
}

void updateParameter(String newParameterValue) {
	String[] splitParameterValue = split(newParameterValue, '=');

	if (splitParameterValue.length < 2) {
		return;
	}

	String parameter = splitParameterValue[0];
	String value = splitParameterValue[1];

	if ("P".equals(parameter)) {
		selectedProgram = parseInt(value);
	} else if ("B".equals(parameter)) {
		numberOfSteps = parseInt(value);
	} else if ("B".equals(parameter)) {
		bpm = Double.parseDouble(value);
	} else if ("M".equals(parameter)) {
		beatMultiplier = Double.parseDouble(value);
	} else if ("A".equals(parameter)) {
		animationMultiplier = Double.parseDouble(value);
	}
}

void updateModelFromMessage(String message) {
	String[] splitMessage = split(message, ':');

	if (!"U".equals(splitMessage[0])) {
		return;
	}

	String[] values = split(splitMessage[1], '&');

	println(values);

	for (int i = 0; i < values.length; i++) {
		updateParameter(values[i]);
	}
}

void readFromSerial() {
	if (arduino.available() == 0) {
		return;
	}

	message = arduino.readStringUntil('\n');

	if (null == message) return;

	updateModelFromMessage(message);
}

void setupCp5() {
	cp5 = new ControlP5(this);

	cp5.addNumberbox("program")
	.setPosition(100, 160)
	.setMin(0)
	.setMax(4)
	.setSize(100, 20)
	.setScrollSensitivity(1.1)
	.setValue(1)
	;
}

void setup() {
	size(700, 400);
	noStroke();
	background(0, 0, 0);

	setupArduino();

	setupCp5();
}

void draw() {
	readFromSerial();

	cp5.getController("program").setValue(selectedProgram);
}

void controlEvent(ControlEvent controlEvent) {
	if (controlEvent.isController()) {
		String controllerName = controlEvent.getController().getName();
		float value = controlEvent.getController().getValue();

		if ("program".equals(controllerName) && value != selectedProgram) {
			arduino.write("P:" + (int) value);
		}
	}
}
