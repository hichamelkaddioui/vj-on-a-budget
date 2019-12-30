import processing.serial.*;
import controlP5.*;

Serial arduino;
String message;

ControlP5 cp5;

final float MIN_BPM = 50f;
final float MAX_BPM = 200f;

int selectedProgram;
int numberOfSteps;
float bpm;
float beatMultiplier;
float animationMultiplier;
boolean isWaitingForArduinoValues = true;

void setupArduino() {
	String portName = Serial.list()[2];
	arduino = new Serial(this, portName, 9600);
}

final int colorBlack = color(17, 17, 20);
final int colorDark = color(20, 33, 61);
final int colorBlue = color(86, 201, 193);
final int colorLight = color(249, 221, 214);

final float[] beatMultiplierValues = { 1f / 8f, 1f / 4f, 1f / 3f, 1f / 2f, 1f, 2f, 3f, 4f, 8f };
final float[] animationMultiplierValues = { 1f / 8f, 1f / 4f, 1f / 3f, 1f / 2f, 1f };
final String[] multiplierLabels = { "1/8", "1/4", "1/3", "1/2", "1", "2", "3", "4", "8" };

Textfield bpmTextField;
Knob bpmKnob;
Textlabel bpmTextLabel;

RadioButton mRadioButton;
RadioButton aRadioButton;

boolean isEditingBpm;
CallbackListener bpmKnobCallbackListener;


public void applybpmTextField() {
	float inField = Float.parseFloat(bpmTextField.getText());
	arduino.write("B:" + inField);
	bpmTextField.clear();
}

void setupBpmControl() {
	PFont bigFont = createFont("DejaVu Sans Mono", 35);

	bpmKnobCallbackListener = new CallbackListener() {
		public void controlEvent(CallbackEvent event) {
			if (event.getAction() == ControlP5.ACTION_RELEASED) {
				isEditingBpm = false;

				arduino.write("B:" + event.getController().getValue());

				event.getController().setValue(bpm);
			} else if (event.getAction() == ControlP5.ACTION_PRESS) {
				isEditingBpm = true;

				println("enter");
			}
		}
	};

	bpmTextField = cp5.addTextfield("bpmTextField")
									   .setPosition(20, 70)
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

	cp5.addBang("applybpmTextField")
	 	 .setPosition(240, 70)
		 .setSize(80, 40)
		 .setColorLabel(colorBlack)
		 .setColorActive(colorBlue)
		 .setLabel("APPLY")
		 .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
		 ;

	bpmKnob = cp5.addKnob("applybpmknob")
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
	               .setPosition(450, 160)
	               .setSize(100, 40)
	               .setFont(bigFont)
	               .setColor(colorLight);
}

void setupBeatMultiplierControl() {
	mRadioButton = cp5.addRadioButton("mRadioButton")
	               .setPosition(21, 420)
	               .setSize(70, 40)
	               .setBackgroundHeight(40)
	               .setItemsPerRow(5)
	               .setSpacingColumn(20)
	               .setSpacingRow(20)
	               .setColorActive(colorBlue)
	               .setColorLabel(colorBlack)
	               .setColorBackground(colorLight)
	               .setNoneSelectedAllowed(false)
	               .setValue(1f)
	;

	cp5.addTextlabel("TitleBeatMultiplier")
	.setText("Beat Multiplier")
	.setPosition(18, 380)
	.setSize(80, 40)
	.setColor(colorLight);

	String label;
	float value;

	for (int i = 0; i < beatMultiplierValues.length; i++) {
		label = multiplierLabels[i];
		value = beatMultiplierValues[i];

		Toggle toggleBeatMultiplier = cp5.addToggle("M " + label).setLabel(label).setSize(100, 50);
		toggleBeatMultiplier.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

		mRadioButton.addItem(toggleBeatMultiplier, value).setLabel(label);
	}
}

void setupAnimationMultiplierControl() {
	aRadioButton = cp5.addRadioButton("aRadioButton")
	               .setPosition(21, 620)
	               .setSize(70, 40)
	               .setBackgroundHeight(40)
	               .setItemsPerRow(5)
	               .setSpacingColumn(20)
	               .setSpacingRow(20)
	               .setColorActive(colorBlue)
	               .setColorLabel(colorBlack)
	               .setNoneSelectedAllowed(false)
	               .setColorBackground(colorLight);

	cp5.addTextlabel("TitleAnimationMultiplier")
	.setText("Animation Multiplier")
	.setPosition(18, 580)
	.setSize(80, 40)
	.setColor(colorLight);

	String label;
	float value;

	for (int i = 0; i < animationMultiplierValues.length; i++) {
		label = multiplierLabels[i];
		value = animationMultiplierValues[i];

		Toggle toggleAnimationMultiplier = cp5.addToggle("A " + label).setLabel(label).setSize(100, 50);
		toggleAnimationMultiplier.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

		aRadioButton.addItem(toggleAnimationMultiplier, value).setLabel(label);
	}
}

void setupCp5() {
	cp5 = new ControlP5(this);

	PFont font = createFont("DejaVu Sans Mono", 20);

	cp5.setFont(font);
	cp5.setColorBackground(colorBlack);
	cp5.setColorForeground(colorLight);

	setupBpmControl();
	setupBeatMultiplierControl();
	setupAnimationMultiplierControl();

	textFont(font);
}

void setup() {
	size(700, 800);
	smooth();
	noStroke();
	background(0);

	setupArduino();

	setupCp5();
}

void draw() {
	background(0);

	if (isWaitingForArduinoValues) {
		return;
	}

	setGuiFromModel();
}

void serialEvent(Serial arduino) {
	message = arduino.readStringUntil('\n');

	if (null == message) return;

	updateModelFromMessage(message);
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
	} else if ("S".equals(parameter)) {
		numberOfSteps = parseInt(value);
	} else if ("B".equals(parameter)) {
		if (isEditingBpm) return;

		bpm = float(value);
	} else if ("M".equals(parameter)) {
		beatMultiplier = float(value);
	} else if ("A".equals(parameter)) {
		animationMultiplier = float(value);
	}
}

void updateModelFromMessage(String message) {
	String[] splitMessage = split(message, ':');

	if (!"U".equals(splitMessage[0])) {
		return;
	}

	String[] values = split(splitMessage[1], '&');

	for (int i = 0; i < values.length; i++) {
		updateParameter(values[i]);
	}

	isWaitingForArduinoValues = false;
}

void controlEvent(ControlEvent controlEvent) {
	if (!controlEvent.isController()) {
		return;
	}

	if (controlEvent.isFrom(bpmKnob)) {
		float newBpm = controlEvent.getController().getValue();

		if (bpm == newBpm || !isEditingBpm) {
			return;
		}

		bpm = newBpm;
	}

	if (controlEvent.isFrom(bpmTextField)) {
		applybpmTextField();
	}

	isWaitingForArduinoValues = true;
}

void setGuiFromModel() {
	if (isEditingBpm) return;

	bpmTextLabel.setStringValue(bpm + " BPM");
	bpmKnob.setValue(bpm);
}
