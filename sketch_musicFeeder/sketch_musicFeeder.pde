import processing.sound.*;
import processing.serial.*;
import oscP5.*;
import netP5.*;
import controlP5.*;
SoundFile file;
OscP5 oscp5;
ControlP5 cp5;
Textlabel myTextlabelA;
Textlabel myTextlabelB;
String path1="/Users/user/Downloads/Paquette_Peretz_Belin(2013)/Clarinet-MEB/";
String path2="/Users/user/Downloads/Paquette_Peretz_Belin(2013)/Violin-MEB/";
boolean rendered=false;
NetAddress myRemoteLocation;
void setup() {
  size(640, 360);
  noStroke();
  background(255);
  oscp5 = new OscP5(this, 10000);
  myRemoteLocation = new NetAddress("127.0.0.1",6448);
  // Load a soundfile from the /data folder of the sketch and play it back
  //processFiles(path1);
  //processFiles(path2);
   PFont font = createFont("arial",14);
  
  cp5 = new ControlP5(this);
  
  cp5.addTextfield("Directory")
     .setPosition(20,100)
     .setSize(500,40)
     .setFont(font)
     .setFocus(true)
     .setColor(color(255,255,255))
     .setText("/Users/user/Downloads/Paquette_Peretz_Belin(2013)/Clarinet-MEB/")
     ;
     cp5.addButton("Process")
     .setValue(0)
     .setFont(font)
     .setPosition(100,200)
     .setSize(200,19)
     ;
    
 textFont(font);
}

void processEventsFor() {
  processFiles(cp5.get(Textfield.class,"Directory").getText());
}

void processFiles(String path) {
  File[] files = listFiles(path);
  for (int i = 0; i < files.length; i++) {
      String name = files[i].getName();
      float[] value= valueFromNameClassifier(name);
      processSoundFile(path, name, value);
  }

}

float[] valueFromName( String fileName) {
  if(fileName.contains("FEAR")) {
    return new float[]{0};
  }
  if(fileName.contains("SADNESS")) {
    return new float[]{0.15};
  }
  if(fileName.contains("HAPPINESS")) {
    return new float[]{0.5};
  }
  
  return new float[]{0.3};
}

float[] valueFromNameClassifier( String fileName) {
  if(fileName.contains("FEAR")) {
    return new float[]{1};
  }
  if(fileName.contains("SADNESS")) {
    return new float[]{2};
  }
  if(fileName.contains("HAPPINESS")) {
    return new float[]{3};
  }
  
  return new float[]{4};
}

void processSoundFile(String path,String fileName, float[] values) {
  sendLabels(values);
  startRecording();
  playSound(path+fileName);
  stopRecording();
}

void playSound(String fileName) {
  file = new SoundFile(this, fileName);
  int duration=ceil(file.duration()*1000);
  file.play();
  delay(duration);
}

void startRecording() {
  sendWekinatorMessage("/wekinator/control/startRecording");
}
void stopRecording() {
  sendWekinatorMessage("/wekinator/control/stopRecording");
}
void sendLabels(float[] labels) {
  OscMessage message = new OscMessage("/wekinator/control/outputs");
  message.add(labels);
  oscp5.send(message, myRemoteLocation);
}
void sendEnable(int[] labels) {
  OscMessage message = new OscMessage("/wekinator/control/enableModelRecording");
  message.add(labels);
  oscp5.send(message, myRemoteLocation);
}

void sendWekinatorMessage(String message) {
  OscMessage myMessage = new OscMessage(message);
  oscp5.send(myMessage, myRemoteLocation); 
}
public void controlEvent(ControlEvent theEvent) {
  if(rendered&&theEvent.getController().getName().equals("Process")){
     processEventsFor();
  }
 
}

void draw() {
  background(0);
  fill(255);
  rendered=true;
  
 
}
