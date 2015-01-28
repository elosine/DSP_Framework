import oscP5.*;
import netP5.*;
import controlP5.*;

ControlP5 cp5;
DropdownList d1, d2;

OscP5 meosc;
NetAddress sclang;
PFont liGothicMed20, liGothicMed14;
FunkyLMSet flmset; 

void setup() {
  size(500, 500, P3D);
  liGothicMed20 = loadFont("LiGothicMed-20.vlw");
  liGothicMed14 = loadFont("LiGothicMed-14.vlw");

  cp5 = new ControlP5(this);
  ControlFont font = new ControlFont(liGothicMed14);
  cp5.setControlFont(font);
  // create a DropdownList
  d1 = cp5.addDropdownList("ins")
    .setPosition(100, 100)
      .setSize(200, 200)
        .setBackgroundColor(color(190))
          .setItemHeight(20)
            .setBarHeight(15)
              .setColorBackground(color(60))
                .setColorActive(color(255, 128));
  d1.captionLabel()
    .set("Inputs")
      .setFont(font)
        .toUpperCase(false);
  d1.captionLabel().style().marginTop = 0;
  d1.captionLabel().style().marginLeft = 3;

  d1.addItem("item ", 0);
  d1.toUpperCase(false);
 // d1.item(0).setFont(font);
  
 // d1.valueLabel().style().setFont(font);
//  d1.captionLabel().style().marginTop = 0;
 // d1.captionLabel().style().marginLeft = 3;
  



  meosc = new OscP5(this, 12321);
  sclang = new NetAddress("127.0.0.1", 57120);
  meosc.plug(this, "rms", "/rms/mic1");

  // FUNKY LEVEL METER /////////////////////////////////////////////
  flmset = new FunkyLMSet();
  meosc.plug(flmset, "aniSprite", "/rms");
}

void draw() {
  background(50, 58, 72);
  lights();
  // ortho(-width/2, width/2, -height/2, height/2, -100, 100); 
  // theta = (frameCount/200.0)*TWO_PI;
  flmset.drw();
}

void keyPressed() {
  if (key=='a') {
    OscMessage msg = new OscMessage("/mkaudioin");
    msg.add("mic1");
    msg.add(0);
    meosc.send(msg, sclang);
  }
  if (key=='f') {
    OscMessage msg = new OscMessage("/getrms");
    msg.add("mic1");
    msg.add("127.0.0.1");
    msg.add(12321);
    meosc.send(msg, sclang);
  }
}

void rms(float val) {
  println(val);
}

/*
Hook Up to DANI Graphic
 USE SC to Poll soundcard and find ins and outs and make
 corresponding graphics here, give names
 */
