import oscP5.*;
import netP5.*;
import controlP5.*;

ControlP5 cp5;
DropdownList source_dd, dsp1_dd, out_dd;

OscP5 meosc;
NetAddress sc;
int myport = 12321;
PFont liGothicMed20, liGothicMesource_dd4;
FunkyLMSet flmset; 

int numbanks = 7;
String[] dspbank = new String[numbanks];

String[] dspnames = new String[0];


void setup() {
  size(500, 700, P3D);
  liGothicMed20 = loadFont("LiGothicMed-20.vlw");
  liGothicMesource_dd4 = loadFont("LiGothicMed-14.vlw");

  cp5 = new ControlP5(this);
  ControlFont font = new ControlFont(liGothicMesource_dd4);
  cp5.setControlFont(font);



  meosc = new OscP5(this, myport);
  sc = new NetAddress("127.0.0.1", 57120);

  // FUNKY LEVEL METER /////////////////////////////////////////////
  flmset = new FunkyLMSet();
  meosc.plug(flmset, "aniSprite", "/rms");

  meosc.plug(this, "getdspnames", "/dspnames");
  meosc.send( "/getdspnames", new Object[] {
    meosc.ip(), myport
  }
  , sc);

  cp5gui();
}

void draw() {
  background(50, 58, 72);
  //lights();
  ortho();
  flmset.drw();
}





void mousePressed() {
  // println(dspbank);
}


/*
MAKE A LEVEL METER AND POLL SC
 MAKE AN OUT AND AUTO CONNECT IN AND OUT
 WHEN YOU CHANGE AN ITEM, GET RID OF ALL OTHERS IN SC
 */
