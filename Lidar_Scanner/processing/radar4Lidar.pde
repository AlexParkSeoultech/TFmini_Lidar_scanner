import processing.serial.*; // imports library for serial communication
import java.awt.event.KeyEvent; // imports library for reading the data from the serial port
import java.io.IOException;

Serial myPort; // defines Object Serial
// defubes variables
String angle="";
String distance="";
String data="";
String noObject;
float pixsDistance;
int iAngle, iDistance;
int index1=0;
int index2=0;
PFont orcFont, conFont;
int RANGE_MAX=950;
int AXIS_MAX=960;

void setup() { 
 size (1920, 1080);
 smooth();
 myPort = new Serial(this,"COM3", 230400); // starts the serial communication
 myPort.bufferUntil('\n'); // reads the data from the serial port up to the character '.'. So actually it reads this: angle,distance.
 orcFont = loadFont("OCRAExtended-30.vlw"); 
 conFont = loadFont("Consolas-30.vlw");
 frameRate(100);
}

void draw() {
  
  fill(98,245,31);
  textFont(conFont);
  // simulating motion blur and slow fade of the moving line
  noStroke();
  fill(0,5); 
  rect(0, 0, width, 1010); 
  
  fill(98,245,31); // green color
  // calls the functions for drawing the radar
  drawRadar(); 
  drawLine();
  drawObject();
  drawText();
  serialEvent();
}

void serialEvent () { // starts reading data from the Serial Port
  // reads the data from the Serial Port up to the character '.' and puts it into the String variable "data".
  data = myPort.readStringUntil('.');
  //  println(data);
    if (data!=null){
    data = data.substring(0,data.length()-1);
    
    index1 = data.indexOf(","); // find the character ',' and puts it into the variable "index1"
    angle= data.substring(0, index1); // read the data from position "0" to position of the variable index1 or thats the value of the angle the Arduino Board sent into the Serial Port
    distance= data.substring(index1+1, data.length()); // read the data from position "index1" to the end of the data pr thats the value of the distance
    
    // converts the String variables into Integer
    iAngle = int(angle)*180/400;
    iDistance = int(distance);
  }
}

void drawRadar() {
  pushMatrix();
  translate(AXIS_MAX,1000); // moves the starting coordinats to new location
  noFill();
  strokeWeight(1);
  //stroke(98,245,31);
  stroke(94,155,255);
  // draws the arc lines
  for (int r=600;r<=1800; r+=400){ arc(0,0,r,r,PI,TWO_PI);}
  //arc(0,0,1800,1800,PI,TWO_PI);
  //arc(0,0,1400,1400,PI,TWO_PI);
  //arc(0,0,1000,1000,PI,TWO_PI);
  //arc(0,0,600,600,PI,TWO_PI);
  // draws the angle lines
  line(-AXIS_MAX,0,AXIS_MAX,0);
  //line(0,0,-960*cos(radians(30)),-960*sin(radians(30)));
  //line(0,0,-960*cos(radians(60)),-960*sin(radians(60)));
  //line(0,0,-960*cos(radians(90)),-960*sin(radians(90)));
  //line(0,0,-960*cos(radians(120)),-960*sin(radians(120)));
  //line(0,0,-960*cos(radians(150)),-960*sin(radians(150)));
  line(-AXIS_MAX*cos(radians(30)),0,AXIS_MAX,0);
  for (int angle=30;angle<180; angle+=30){
    float angle_rad=radians(angle);
    line(0,0,-AXIS_MAX*cos(angle_rad),-AXIS_MAX*sin( angle_rad));    
  }
  popMatrix();
}
void polarLine(float angle,float from_r, float to_r){
   float angle_rad=radians(angle);
   line(from_r*cos(angle_rad),-from_r*sin(angle_rad),to_r*cos(angle_rad),-to_r*sin(angle_rad));
}
void drawObject() {
  pushMatrix();
  translate(AXIS_MAX,1000); // moves the starting coordinats to new location
  strokeWeight(19); strokeCap(SQUARE);
  stroke(255,150,10); // orange color
  pixsDistance = iDistance*2.25; // covers the distance from the sensor from cm to pixels
  // limiting the range to 40 cms
   if(iDistance<400){
    // draws the object according to the angle and the distance
  //line(pixsDistance*cos(radians(iAngle)),-pixsDistance*sin(radians(iAngle)),RANGE_MAX*cos(radians(iAngle)),-RANGE_MAX*sin(radians(iAngle)));
  polarLine(iAngle,pixsDistance,RANGE_MAX);
  }
  popMatrix();
}

void drawLine() {
  pushMatrix();
  strokeWeight(19); strokeCap(SQUARE);
  stroke(30,250,60); //30,250,60
  translate(AXIS_MAX,1000); // moves the starting coordinats to new location
 // line(0,0,RANGE_MAX*cos(radians(iAngle)),-RANGE_MAX*sin(radians(iAngle))); // draws the line according to the angle
  polarLine(iAngle,0,RANGE_MAX);
  popMatrix();
}

void drawText() { // draws the texts on the screen
  
  pushMatrix();
  if(iDistance>400) {
    
    noObject = "Out of Range";
  }
  else {
    noObject = "In Range";
  }
  fill(0,0,0);
  noStroke();
  rect(0, 1010, width, 1080);
  fill(98,245,31);
  textSize(25);
  text("100cm",1180,990);
  text("200cm",1380,990);
  text("300cm",1580,990);
  text("400cm",1780,990);
  textSize(40);
  text("Object: " + noObject, 240, 1050);
  text("Angle: " + iAngle +" °", 1050, 1050);
  text("Distance: ", 1380, 1050);
  if(iDistance<400) {
    text("         " + iDistance +" cm", 1400, 1050);
  } else  text("         " + "---", 1400, 1050);
  textSize(25);
  fill(98,245,60);
  translate(961+AXIS_MAX*cos(radians(30)),982-AXIS_MAX*sin(radians(30)));
  rotate(-radians(-60));
  text("30°",0,0);
  resetMatrix();
  translate(954+AXIS_MAX*cos(radians(60)),984-AXIS_MAX*sin(radians(60)));
  rotate(-radians(-30));
  text("60°",0,0);
  resetMatrix();
  translate(945+AXIS_MAX*cos(radians(90)),990-AXIS_MAX*sin(radians(90)));
  rotate(radians(0));
  text("90°",0,0);
  resetMatrix();
  translate(935+AXIS_MAX*cos(radians(120)),1003-AXIS_MAX*sin(radians(120)));
  rotate(radians(-30));
  text("120°",0,0);
  resetMatrix();
  translate(940+AXIS_MAX*cos(radians(150)),1018-AXIS_MAX*sin(radians(150)));
  rotate(radians(-60));
  text("150°",0,0);
  popMatrix(); 
}
