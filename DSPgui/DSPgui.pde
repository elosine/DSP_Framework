import oscP5.*;
import netP5.*;
import controlP5.*;

ControlP5 cp5;
DropdownList source_dd, d2;

OscP5 meosc;
NetAddress sc;
PFont liGothicMed20, liGothicMesource_dd4;
FunkyLMSet flmset; 


void setup() {
  size(500, 500, P3D);
  liGothicMed20 = loadFont("LiGothicMed-20.vlw");
  liGothicMesource_dd4 = loadFont("LiGothicMed-14.vlw");

  cp5 = new ControlP5(this);
  ControlFont font = new ControlFont(liGothicMesource_dd4);
  cp5.setControlFont(font);

  meosc = new OscP5(this, 12321);
  sc = new NetAddress("127.0.0.1", 57120);
  meosc.plug(this, "rms", "/rms/mic1");

  // FUNKY LEVEL METER /////////////////////////////////////////////
  flmset = new FunkyLMSet();
  meosc.plug(flmset, "aniSprite", "/rms");
  
  cp5gui();
}

void draw() {
  background(50, 58, 72);
  //lights();
  ortho();
  flmset.drw();
}


void rms(float val) {
  println(val);
}


void controlEvent(ControlEvent e) {
  if (e.isGroup()) {
    //  //INS DropDown
    if (e.getGroup() == source_dd) {
      //  int idx = int(e.getGroup().getValue()); //to get the index number of the pulldown item
      String label = e.getGroup().getCaptionLabel().getText();
      String[] splitlabel = split(label, ":");
      if (splitlabel[0].equals("mic")) {
        int micnum = int(splitlabel[1]);
        switch(micnum) {
        case 1:
          meosc.send("/mkaudioin", new Object[] {label, micnum}, sc);
          mkflm(0, label);
          break;
        case 2:
          meosc.send("/mkaudioin", new Object[] {label, micnum}, sc);
          break;
        }
      }
    }
  }//
  else if (e.isController()) {
    println("event from controller : "+e.getController().getValue()+" from "+e.getController());
  }
}
/*
MAKE A LEVEL METER AND POLL SC
MAKE AN OUT AND AUTO CONNECT IN AND OUT
WHEN YOU CHANGE AN ITEM, GET RID OF ALL OTHERS IN SC
 */
