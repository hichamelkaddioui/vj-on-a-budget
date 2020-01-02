import processing.serial.*;
import controlP5.*;

ControlP5 cp5;

/*
 * GUI
 */

final float MIN_BPM = 50f;
final float MAX_BPM = 200f;

int selectedProgram;
int numberOfSteps;
float bpm;
int beatMultiplier;
int animationMultiplier;
boolean isWaitingForArduinoValues = true;

final int margin = 20;
final int colorBlack = color(17, 17, 20);
final int colorDark = color(20, 33, 61);
final int colorBlue = color(86, 201, 193);
final int colorLight = color(249, 221, 214);

final String[] programLabels = { "Black", "Blink", "Sweep", "Column sweep", "Fill", "Alternate", "Random", "Breathe" };
final String[] multiplierLabels = { "1/16", "1/8", "1/4", "1/2", "1", "2", "4", "8" };

PFont bigFont;
PFont font;

boolean isEditingBpm;
CallbackListener bpmKnobCallbackListener;
Knob bpmKnob;
Textfield bpmTextField;

Textlabel bpmTextLabel;
Textlabel selectedProgramLabel;

RadioButton pRadioButton;
RadioButton mRadioButton;
RadioButton aRadioButton;

// BPM Control

public void applyBpmTextField() {
	float inField = Float.parseFloat(bpmTextField.getText());
	arduino.write("B:" + inField);
	bpmTextField.clear();
}

void setupBpmControl() {
	bpmTextField = cp5.addTextfield("bpmTextField")
	               .setPosition(margin, 70)
	               .setSize(200, 40)
	               .setFocus(true)
	               .setInputFilter(2)
	               .setDefaultValue(0.00)
	               .setValue(0.00)
	               .setLabel("BPM")
	               .setColor(colorLight)
	               .setDecimalPrecision(1)
	               .setColorLabel(colorLight)
	               .setColorActive(colorBlue)
	;

	bpmTextField.getCaptionLabel().align(ControlP5.RIGHT, ControlP5.CENTER);

	cp5.addBang("applyBpmTextField")
	.setPosition(240, 70)
	.setSize(120, 40)
	.setColorLabel(colorBlack)
	.setColorActive(colorBlue)
	.setLabel("Set BPM")
	.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
	;

	bpmKnobCallbackListener = new CallbackListener() {
		public void controlEvent(CallbackEvent event) {
			if (event.getAction() == ControlP5.ACTION_PRESS) {
				isEditingBpm = true;

				return;
			}

			if (event.getAction() == ControlP5.ACTION_RELEASED) {
				isEditingBpm = false;

				float newBpm = event.getController().getValue();

				arduino.write("B:" + newBpm);

				event.getController().setValue(newBpm);
			}
		}
	};

	bpmKnob = cp5.addKnob("bpmKnob")
	          .setRange(MIN_BPM, MAX_BPM)
	          .setPosition(80, 130)
	          .setRadius(50)
	          .setSize(150, 150)
	          .setDragDirection(Knob.VERTICAL)
	          .setLabel("BPM")
	          .setColorActive(colorBlue)
	          .setColorValue(colorLight)
	          .setDecimalPrecision(1)
	          .setColorLabel(colorLight)
	          .addCallback(bpmKnobCallbackListener)
	;

	bpmTextLabel = cp5.addTextlabel("bpmTextLabel")
	               .setPosition(width / 2 + margin, 160)
	               .setSize(100, 40)
	               .setFont(bigFont)
	               .setColor(colorLight);
}

// Program Control

void setupProgramControl() {
	int groupX = width / 2 + margin;
	int groupY = height / 2;

	cp5.addTextlabel("TitleProgram")
	.setText("Program")
	.setPosition(groupX, groupY)
	.setSize(80, 40)
	.setColor(colorLight)
	;

	pRadioButton = cp5.addRadioButton("pRadioButton")
	               .setPosition(groupX, groupY + 60)
	               .setBackgroundHeight(40)
	               .setItemsPerRow(4)
	               .setSpacingColumn(20)
	               .setSpacingRow(20)
	               .setColorActive(colorBlue)
	               .setColorLabel(colorBlack)
	               .setColorBackground(colorLight)
	               .setNoneSelectedAllowed(false)
	;

	for (int i = 0; i < programLabels.length; i++) {
		String label = programLabels[i];
		Toggle toggleProgram = cp5.addToggle("P" + i).setLabel(label).setSize(label.length() * 20 + 20, 50);

		toggleProgram.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

		pRadioButton.addItem(toggleProgram, i);
	}

	selectedProgramLabel = cp5.addTextlabel("selectedProgramLabel")
	                       .setPosition(groupX, 250)
	                       .setSize(100, 40)
	                       .setFont(bigFont)
	                       .setColor(colorLight);
}

// Beat Multiplier Control

void setupBeatMultiplierControl() {
	int groupY = height / 2;

	cp5.addTextlabel("TitleBeatMultiplier")
	.setText("Loop length in beats")
	.setPosition(margin, groupY)
	.setSize(80, 40)
	.setColor(colorLight)
	;

	mRadioButton = cp5.addRadioButton("mRadioButton")
	               .setPosition(margin, groupY + 60)
	               .setBackgroundHeight(40)
	               .setItemsPerRow(4)
	               .setSpacingColumn(20)
	               .setSpacingRow(20)
	               .setColorActive(colorBlue)
	               .setColorLabel(colorBlack)
	               .setColorBackground(colorLight)
	               .setNoneSelectedAllowed(false)
	;

	for (int i = 0; i < multiplierLabels.length; i++) {
		String label = multiplierLabels[i];
		Toggle toggleBeatMultiplier = cp5.addToggle("M" + label).setLabel(label).setSize(100, 50);

		toggleBeatMultiplier.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

		mRadioButton.addItem(toggleBeatMultiplier, i);
	}
}

// Animation Multiplier Control

void setupAnimationMultiplierControl() {
	int groupY = 2 * height / 3 + 50;

	cp5.addTextlabel("TitleAnimationMultiplier")
	.setText("Animation length")
	.setPosition(margin, groupY)
	.setSize(80, 40)
	.setColor(colorLight);

	aRadioButton = cp5.addRadioButton("aRadioButton")
	               .setPosition(margin, groupY + 60)
	               .setSize(70, 40)
	               .setBackgroundHeight(40)
	               .setItemsPerRow(5)
	               .setSpacingColumn(20)
	               .setSpacingRow(20)
	               .setColorActive(colorBlue)
	               .setColorLabel(colorBlack)
	               .setNoneSelectedAllowed(false)
	               .setColorBackground(colorLight);
	for (int i = 0; i < multiplierLabels.length / 2 + 1; i++) {
		String label = multiplierLabels[i];
		Toggle toggleAnimationMultiplier = cp5.addToggle("A" + label).setLabel(label).setSize(100, 50);

		toggleAnimationMultiplier.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

		aRadioButton.addItem(toggleAnimationMultiplier, i);
	}
}

// Sync Control

public void syncButton() {
	arduino.write("S:");
}

void setupSyncButton() {
	cp5.addBang("syncButton")
	.setPosition(margin, height / 3)
	.setSize(width / 4, 100)
	.setColorLabel(colorBlack)
	.setColorActive(colorBlue)
	.setLabel("SYNC")
	.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
	;
}

void setGuiFromModel() {
	if (!isEditingBpm) {
		bpmTextLabel.setStringValue(bpm + " BPM");
		bpmKnob.setValue(bpm);
	};

	selectedProgramLabel.setStringValue(programLabels[selectedProgram]);

	pRadioButton.activate(selectedProgram);
	mRadioButton.activate(beatMultiplier);
	aRadioButton.activate(animationMultiplier);
}

void setupCp5() {
	cp5 = new ControlP5(this);

	font = createFont("DejaVu Sans Mono", 20);
	bigFont = createFont("DejaVu Sans Mono", 50);

	cp5.setFont(font);
	cp5.setColorBackground(colorBlack);
	cp5.setColorForeground(colorLight);

	setupProgramControl();
	setupBpmControl();
	setupBeatMultiplierControl();
	setupAnimationMultiplierControl();
	setupSyncButton();

	textFont(font);
}

/*
 * Arduino communication
 */

Serial arduino;
String message;

void updateParameterFromArduino(String newParameterValue) {
	String[] splitParameterValue = split(trim(newParameterValue), '=');

	if (splitParameterValue.length < 2) {
		return;
	}

	String parameter = splitParameterValue[0];
	String value = splitParameterValue[1];

	if ("P".equals(parameter)) {
		selectedProgram = parseInt(value);
	} else if ("S".equals(parameter)) {
		numberOfSteps = parseInt(value);
	} else if ("B".equals(parameter) && !isEditingBpm) {
		bpm = float(value);
	} else if ("M".equals(parameter)) {
		beatMultiplier = parseInt(value);
	} else if ("A".equals(parameter)) {
		animationMultiplier = parseInt(value);
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
		updateParameterFromArduino(values[i]);
	}

	isWaitingForArduinoValues = false;
}

void setupArduino() {
	String portName = Serial.list()[2];

	arduino = new Serial(this, portName, 9600);
}

/*
 * Global Handlers
 */

void serialEvent(Serial arduino) {
	message = arduino.readStringUntil('\n');

	if (null == message) return;

	updateModelFromMessage(message);
}

void controlEvent(ControlEvent controlEvent) {
	if (controlEvent.isFrom(bpmKnob)) {
		float newBpm = controlEvent.getController().getValue();

		if (bpm == newBpm || !isEditingBpm) {
			return;
		}

		bpm = newBpm;
	}

	if (controlEvent.isFrom(bpmTextField)) {
		applyBpmTextField();
	}

	if (controlEvent.isFrom(pRadioButton)) {
		int newSelectedProgram = int(controlEvent.getValue());

		if (selectedProgram != newSelectedProgram) {
			selectedProgram = newSelectedProgram;

			arduino.write("P:" + selectedProgram);
		}
	}

	if (controlEvent.isFrom(mRadioButton)) {
		int newBeatMultiplier = int(controlEvent.getValue());

		if (beatMultiplier != newBeatMultiplier) {
			beatMultiplier = newBeatMultiplier;

			arduino.write("M:" + beatMultiplier);
		}
	}

	if (controlEvent.isFrom(aRadioButton)) {
		int newAnimationMultiplier = int(controlEvent.getValue());

		if (animationMultiplier != newAnimationMultiplier) {
			animationMultiplier = newAnimationMultiplier;

			arduino.write("A:" + animationMultiplier);
		}
	}

	isWaitingForArduinoValues = true;
}

final String programLetters = "azertyui";

void keyPressed() {
	char lowercaseKey = Character.toLowerCase(key);

	if (0 <= programLetters.indexOf(lowercaseKey)) {
		int programIndex = programLetters.indexOf(lowercaseKey);

		arduino.write("P:" + programIndex);
	} else if (lowercaseKey == 'b') {
		arduino.write("P:0");
	} else if (key == ENTER) {
		arduino.write("S:");
	} else if (keyCode == UP) {
		arduino.write("B:" + (bpm + 1));
	} else if (keyCode == DOWN) {
		arduino.write("B:" + (bpm - 1));
	} else if (keyCode == RIGHT) {
		if (animationMultiplier == (multiplierLabels.length / 2)) return;

		arduino.write("A:" + (animationMultiplier + 1));
	} else if (keyCode == LEFT) {
		if (animationMultiplier == 0) return;

		arduino.write("A:" + (animationMultiplier - 1));
	} else if (keyCode == 33) {
		// Page up
		if (beatMultiplier == 0) return;

		arduino.write("M:" + (beatMultiplier - 1));
	} else if (keyCode == 34) {
		// Page down
		if (beatMultiplier == multiplierLabels.length - 1) return;

		arduino.write("M:" + (beatMultiplier + 1));
	}
}

void setup() {
	fullScreen();
	smooth();
	noStroke();
	background(0);

	setupArduino();

	setupCp5();
}

void draw() {
	background(0);

	if (!isWaitingForArduinoValues) {
		setGuiFromModel();
	}
}
