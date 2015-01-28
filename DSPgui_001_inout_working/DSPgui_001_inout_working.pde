import oscP5.*;
import netP5.*;
import controlP5.*;

ControlP5 cp5;
DropdownList source_dd, out_dd;

OscP5 meosc;
NetAddress sc;
int myport = 12321;
PFont liGothicMed20, liGothicMesource_dd4;
FunkyLMSet flmset; 

int numbanks = 7;
String[] dspbank = new String[numbanks];


void setup() {
  size(500, 500, P3D);
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

  cp5gui();
}

void draw() {
  background(50, 58, 72);
  //lights();
  ortho();
  flmset.drw();
}




void controlEvent(ControlEvent e) {
  if (e.isGroup()) {
    //  //INS DropDown
    if (e.getGroup() == source_dd) {
      //  int idx = int(e.getGroup().getValue()); //to get the index number of the pulldown item
      String name = e.getGroup().getCaptionLabel().getText();
      String[] splitname = split(name, ":");
      if (splitname[0].equals("mic")) {
        int micnum = int(splitname[1]);
        String label = splitname[0]+splitname[1];
        switch(micnum) {
        case 1:
          meosc.send("/mkaudioin", new Object[] {
            label, micnum-1
          }
          , sc);
          mkflm(0, label);
          dspbank[0] = label;
          println(dspbank);
          break;
        case 2:
          meosc.send("/mkaudioin", new Object[] {
            label, micnum-1
          }
          , sc);
          dspbank[0] = label;
          break;
        }
      }
    }

    //  OUTS DropDown
    if (e.getGroup() == out_dd) {
      //  int idx = int(e.getGroup().getValue()); //to get the index number of the pulldown item
      String name = e.getGroup().getCaptionLabel().getText();
      String[] splitname = split(name, ":");
      if (splitname[0].equals("out")) {
        int num = int(splitname[1]);
        String label = splitname[0]+splitname[1];
        switch(num) {
        case 1:
          meosc.send("/mkaudioOut_m", new Object[] {
            label, num-1
          }
          , sc);
          mkflm(99, label);
          dspbank[numbanks-1] = label;
          for (int i=dspbank.length-2; i>=0; i--) {
            println(dspbank);
            if (dspbank[i]!=null) {
              println(dspbank[i]);
              meosc.send("/route", new Object[] {
                dspbank[i], label
              }
              , sc);
              break;
            }
          }
          break;
        case 2:
          meosc.send("/mkaudioOut_m", new Object[] {
            label, num-1
          }
          , sc);
          break;
        }
      }
    }
  }
  //
  else if (e.isController()) {
    println("event from controller : "+e.getController().getValue()+" from "+e.getController());
  }
}
/*
MAKE A LEVEL METER AND POLL SC
 MAKE AN OUT AND AUTO CONNECT IN AND OUT
 WHEN YOU CHANGE AN ITEM, GET RID OF ALL OTHERS IN SC
 */
