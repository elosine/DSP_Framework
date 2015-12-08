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
Slider sl1, sl2, sl3;

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
  
  sl1 = new Slider(0, 200, 140, 70, 280, 0.0, 1.0);
  sl2 = new Slider(1, 280, 140, 70, 280, 48.0, 72.0);
  sl3 = new Slider(2, 360, 140, 70, 280, 0.0, 20.0);

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
  
  //Sliders
  sl1.drw();
  sl2.drw();
  sl3.drw();
}

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