import oscP5.*;
import netP5.*;

OscP5 osc;
NetAddress sc;
int h = 500;
int w = 540;
int bufsize;
float[] samparrays;
float x0=20;
float y0=20;
float bh = 100;
float bw = 500;
float bmid;
float csrx = 0.0;
int bufnum=0;
PFont font1;

void setup() {
  size(1000, 640);
  surface.setResizable(true); // Allow the canvas to be resizeable
  surface.setSize(w, h); // Resize the canvas to the calculated width and height

  OscProperties properties= new OscProperties();
  properties.setListeningPort(12321);              
  properties.setDatagramSize(5136);   
  osc= new OscP5(this, properties);
  sc = new NetAddress("127.0.0.1", 57120);
  osc.plug(this, "ix", "/ix");

  font1 = loadFont("Monaco-12.vlw");
  textFont(font1);

  bmid = bh/2.0;
  bufsize = int(bw);


  samparrays = new float[bufsize];
  for (int i=0; i<samparrays.length; i++) samparrays[i]=0.0;
}//end setup

void draw() {
  background(255);
  background(255, 234, 100);
  //Draw Buffer Background
  noStroke();
  fill(0);
  rect(x0, y0, bw, bh);
  //waveform display
  stroke(153, 255, 0);
  strokeWeight(1);
  for (int i=1; i<bufsize; i++) {
    line( x0+i-1, y0+bmid-(samparrays[i-1]*bh), x0+i, y0+bmid-(samparrays[i]*bh) );
  }

  //Cursor
  osc.send("/getix", new Object[]{bufnum}, sc); //get current cursor location from sc
  strokeWeight(3);
  stroke(153, 255, 0);
  line(csrx, y0, csrx, y0+bh);

  //slider
  noStroke();
  fill(0, 150);
  rect(50, 140, 50, 200, 3);
  fill(153, 255, 0);
  rect(60, 170, 30, 160, 3);
  noStroke();
  fill(100, 200);
  rect(60, st-7, 30, sb-st+14);
  fill(0);
  rect(sl, st, sr-sl, sb-st, 3); //slider
  fill(0);
  noStroke();
  rect(60, 150, 30, 20, 4);
  fill(153, 255, 0);
  textAlign(LEFT, TOP);
  text(sv, 60, 154);
  if (mousePressed) {
    if (mouseX>=50&&mouseX<=100&&mouseY>=(st-7)&&mouseY<=(sb+7)) {
      st = constrain(st-pmouseY+mouseY, 177, 320);
      sb = constrain(sb-pmouseY+mouseY, 180, 323);
      sv = norm(st, 320, 177.9); 
    }
  }
}
int sl=50;
int st = 230;
int sr = 100;
int sb = 233;
float sv=0.0;




void oscEvent(OscMessage msg) {
  //get waveform data and store in samparrays
  if ( msg.checkAddrPattern("/sbuf") ) {
    for (int i=0; i<bufsize; i++) {
      samparrays[i] = msg.get(i).floatValue();
    }
  }
}

void mousePressed() {
  osc.send("/loadsamp", new Object[]{0}, sc);
  osc.send("/getwf", new Object[]{"127.0.0.1", 12321, 500, 0}, sc);
}

void keyPressed() {
  if (key=='s') osc.send("/stopsamp", new Object[]{}, sc);
}


//Receives track index location
public void ix(float idx) {
  csrx = (idx*bw) + x0;
}