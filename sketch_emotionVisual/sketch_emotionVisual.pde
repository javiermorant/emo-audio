import processing.sound.*;
import processing.serial.*;
import oscP5.*;
import netP5.*;
import controlP5.*;
import java.util.*;
import java.io.*;
//https://www.youtube.com/watch?v=nXUhWj52TCw
OscP5 oscp5;
ControlP5 cp5;
NetAddress myBroadcastLocation; 
int MAX_EVENT_GAP=200;
Queue mMax = new LinkedList();
PImage emojiCurrent;
PImage emojiMMax;
PImage emojiMax;
PImage [] emojis =new PImage[4];
boolean START=false;
int[] total=new int[]{0, 0, 0, 0};
int[] totalMMAX=new int[]{0, 0, 0, 0};

List allEvents=new LinkedList();
int getMax(int[] values){
   int currentIndex=1;
   int currentValue=values[0];
   for (int i=1;i<values.length;i++) {
     if(values[i]>currentValue){
         currentValue=values[i];
         currentIndex=i+1;
     }
   }
   return currentIndex;
} 

void setup() {
  size(475, 375);
  cp5 = new ControlP5(this);
  frameRate(16);
  emojis[1]=loadImage("SADNESS_ICO.png");
  emojis[0]=loadImage("FEAR_ICO.png");
  emojis[2]=loadImage("HAPPINESS_ICO.png");
  emojis[3]=loadImage("NEUTRAL_ICO.png");
  emojiCurrent=emojis[3];
  emojiMMax=emojis[3];
  emojiMax=emojis[3];
  oscp5 = new OscP5(this, 12000);
  myBroadcastLocation = new NetAddress("127.0.0.1",12000);
  
  
  cp5.addButton("Start")
     .setPosition(50,325)
     .updateSize();
    
      cp5.addButton("Stop")
     .setPosition(150,325)
     .updateSize();
    
      cp5.addButton("Export")
     .setPosition(250,325)
     .updateSize();
    
      cp5.addButton("Reset")
     .setPosition(350,325)
     .updateSize();

}


void processMessage(int code) {
  allEvents.add(code+";"+System.currentTimeMillis()+"\n");
  if(code<1||code>4) {
    return;
  }
  total[code-1]=total[code-1]+1;
  mMax.add(code);
  if(mMax.size()>MAX_EVENT_GAP) {
    Integer toRemove=(Integer)mMax.poll();
    totalMMAX[toRemove.intValue()-1]=totalMMAX[toRemove.intValue()-1]-1;
    totalMMAX[code-1]=totalMMAX[code-1]+1;
  }else {
    totalMMAX[code-1]=totalMMAX[code-1]+1;
  }
  
  emojiCurrent = emojis[code-1];
  emojiMMax = emojis[(getMax(totalMMAX))-1];
  emojiMax = emojis[getMax(total)-1];
}


void draw() {
  clear();
  background(255);
  
  image(emojiCurrent, 0, 0, 100, 100);
  image(emojiMMax, 0, 100, 100, 100);
  image(emojiMax, 0, 200,100, 100);

  printGraph(totalMMAX, 110, 150, 20, 250);
  printGraph(total, 210, 150, 20, 250);
 
}

void printGraph(int[] data, int startHeight, int startWidth, int barHeight, int max) {
  int maxGraph = data[getMax(data)-1];
  float conv=1.0f;
  if(maxGraph>=max){
    conv=((float)max/(float)maxGraph);
  }  
   for(int i=0; i<data.length;i++) { 
     if(i%2==0) {
      fill(200, 30+50*i, 200, 50);
     } else {
       fill(30+50*i, 200, 200, 50);
     }
     image(emojis[i], startWidth-barHeight, startHeight+barHeight*i,barHeight, barHeight);
     rect(startWidth, startHeight+barHeight*i,  floor(conv*data[i]), barHeight);
   }
}


public void controlEvent(ControlEvent theEvent) {
  String buttonName = theEvent.getController().getName();
 
  //load the file depends on button
  if(buttonName == "Start"){
     START = true;
  } else if(buttonName == "Stop"){
     START = false;
  } else if(buttonName == "Export"){
     //print(allEvents);
     export();
  } else if(buttonName == "Reset"){
     allEvents=new LinkedList();
     total=new int[]{0, 0, 0, 0};
     totalMMAX=new int[]{0, 0, 0, 0};
     mMax = new LinkedList();
     emojiCurrent=emojis[3];
     emojiMMax=emojis[3];
     emojiMax=emojis[3];
  }
  
    
}

void export() {
  try{
  File file=new File("export_"+System.currentTimeMillis()+".csv");
  FileWriter writer=null;
  try{
    writer=new FileWriter(file);
    for(Object current: allEvents){
    writer.write(current.toString());
    }
    writer.flush();
  }finally {
    if(writer!=null){
      writer.close();
    }
  }
  }catch(Exception e){
    e.printStackTrace();
  }
}
/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  
  if(START&&theOscMessage.checkAddrPattern("/wek/outputs")){ 
      processMessage ((int)theOscMessage.get(0).floatValue());
  }
 
}
