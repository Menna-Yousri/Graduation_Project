#include <DHT.h>

// --- Pin Definitions ---
const int ldrPin           = A0;
const int gasPin           = A1;
const int waterLevelPin    = A2;
const int phSensorPin      = A3;
const int dhtPin           = 2;
const int led1Pin          = 8;
const int led2Pin          = 9;
const int fanRelayPin      = 10;
const int coolingRelayPin  = 11;
const int refillRelayPin   = 12;
const int basePumpRelayPin = 6;
const int acidPumpRelayPin = 7;

// --- Thresholds ---
const int ldrThreshold       =500;
const int gasThreshold       = 200;
const float tempThreshold    = -10.0;
const int waterLevelThreshold = 500;
const float baseThreshold    = 2.5;

// --- DHT Setup ---
#define DHTTYPE DHT11
DHT dht(dhtPin, DHTTYPE);

void setup() {
  pinMode(led1Pin, OUTPUT);
  pinMode(led2Pin, OUTPUT);
  pinMode(fanRelayPin, OUTPUT);
  pinMode(coolingRelayPin, OUTPUT);
  pinMode(refillRelayPin, OUTPUT);
  pinMode(basePumpRelayPin, OUTPUT);
  pinMode(acidPumpRelayPin, OUTPUT);

  dht.begin();
  Serial.begin(9600);
}

void loop() {
  checkLightAndControlLEDs();
  checkGasAndControlFan();
  checkTempAndControlCoolingPump();
  checkWaterLevelAndControlRefillPump();
  checkPHAndControlChemicalPumps();
  delay(200);
}

// --- LDR ---
void checkLightAndControlLEDs() {
  int ldrValue = analogRead(ldrPin);
  Serial.print("LDR: ");
  Serial.println(ldrValue);

  bool isDark = ldrValue > ldrThreshold;
  digitalWrite(led1Pin, isDark ? HIGH : LOW);
  digitalWrite(led2Pin, isDark ? HIGH : LOW);
}

// --- MQ-137 ---
void checkGasAndControlFan() {
  int gasValue = analogRead(gasPin);
  Serial.print("Gas: ");
  Serial.println(gasValue);

  bool gasDetected = gasValue > gasThreshold;
  digitalWrite(fanRelayPin, gasDetected ? LOW : HIGH);  // Active LOW
}

// --- DHT11 Temperature ---
void checkTempAndControlCoolingPump() {
  float temp = dht.readTemperature();
  if (isnan(temp)) {
    Serial.println("Failed to read DHT");
    return;
  }

  Serial.print("Temp: ");
  Serial.println(temp);

  bool overTemp = temp > tempThreshold;
  digitalWrite(coolingRelayPin, overTemp ? LOW : HIGH); // Active LOW
}

// --- Water Level Sensor ---
void checkWaterLevelAndControlRefillPump() {
  int waterLevel = analogRead(waterLevelPin);
  Serial.print("Water Level: ");
  Serial.println(waterLevel);

  bool needsRefill = waterLevel < waterLevelThreshold;
  digitalWrite(refillRelayPin, needsRefill ? LOW : HIGH); // Active LOW
}

// --- pH Sensor ---
void checkPHAndControlChemicalPumps() {
  int rawValue = analogRead(phSensorPin);
  float voltage = rawValue * (5.0 / 1023.0);

  // Approximate linear conversion based on typical calibration
  // pH = 7 + ((2.5 - voltage) * 3.5)
  float pH = 5 + ((2.5 - voltage) * 3.5);

  Serial.print("pH Voltage: ");
  Serial.print(voltage);
  Serial.print(" | pH: ");
  Serial.println(pH);

  // Control pumps based on pH
  if (pH > baseThreshold) {
    // Alkaline → turn on base pump
    digitalWrite(basePumpRelayPin, LOW);
    digitalWrite(acidPumpRelayPin, HIGH);
  } else if (pH < baseThreshold) {
    // Acidic → turn on acid pump
    digitalWrite(acidPumpRelayPin, LOW);
    digitalWrite(basePumpRelayPin, HIGH);
  } else {
    // Neutral → turn off both
    digitalWrite(basePumpRelayPin, HIGH);
    digitalWrite(acidPumpRelayPin, HIGH);
  }
}
