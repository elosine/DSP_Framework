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

  cp5gui();
  
  meosc.send( "/getdspnames", new Object[] {meosc.ip(), myport}, sc);
}

void draw() {
  background(50, 58, 72);
  //lights();
  ortho();
  flmset.drw();
}


//TO RUN CODE ON EXIT
void exit() {
  meosc.send( "/freeall", new Object[] {}, sc);
  super.exit();
}


void mousePressed() {
  // println(dspbank);
}


/*
MAKE A LEVEL METER AND POLL SC
 MAKE AN OUT AND AUTO CONNECT IN AND OUT
 WHEN YOU CHANGE AN ITEM, GET RID OF ALL OTHERS IN SC
 */
Colors clr = new Colors();

class Colors {
  StringDict clrs = new StringDict(); 

  Colors() {
    ////add colors
    clrs.set("Tranquil Blue", "25 33 47");
    clrs.set("orange", "255 128 0");
    clrs.set("red", "255 0 0");
    clrs.set("green", "0 255 0");
    clrs.set("blue", "0 0 255");
    clrs.set("black", "0 0 0");
    clrs.set("white", "255 255 255");
    clrs.set("violetred", "208 32 144");
    clrs.set("springgreen", "0 255 127");
    clrs.set("turquoiseblue", "0 199 140");
    clrs.set("seagreen", "67 205 128");
    clrs.set("mint", "189 252 201");
    clrs.set("yellow", "255 255 0");
    clrs.set("goldenrod", "218 165 32");
    clrs.set("darkorange", "238 118 0");
    clrs.set("chocolate", "139 69 19");
    clrs.set("slateblue", "113 113 198");
    clrs.set("indigo", "75 0 130");
    clrs.set("purple", "128 0 128");
    clrs.set("magenta", "255 0 255");
    clrs.set("plum", "221 160 221");
    clrs.set("maroon", "139 10 80");
    clrs.set("pink", "255 105 180");
    clrs.set("royalblue", "72 118 255");
    clrs.set("dodgerblue", "30 144 255");
    clrs.set("grey", "119 136 153");
    clrs.set("nicegreen", "138 216 20");
    clrs.set("pine", "64 129 64");
    clrs.set("papaya", "255 164 142");
    clrs.set("beet", "157 84 156");
    clrs.set("slate", "117 119 123");
    clrs.set("peacock", "0 130 137");
    clrs.set("fig", "128 84 98");
    clrs.set("sunshine", "255 234 100");
  } //End Constructor

  color get(String clrname) {
    color cl; 
    String[] rgb = split(clrs.get(clrname), ' ');
    cl = color(int(rgb[0]), int(rgb[1]), int(rgb[2]));
    return cl;
  } //End get method

  color getByIx(int ix) {
    color cl; 
    String[] rgb = clrs.valueArray();
    String[] rgbsplit = split(rgb[ix], ' ');
    cl = color(int(rgbsplit[0]), int(rgbsplit[1]), int(rgbsplit[2]));
    return cl;
  } //End get method

  color getAlpha(String clrname, int alpha ) {
    color cl; 
    String[] rgb = split(clrs.get(clrname), ' ');
    cl = color(int(rgb[0]), int(rgb[1]), int(rgb[2]), alpha);
    return cl;
  } //End getAlpha method

 
  
  
} //End Class

class FunkyLM {
  //CONSTRTUCTOR VARIABLES (CS) /////////////////////
  int ix = 0;
  int x = width/2;
  int y = height/2;
  float r = 50.0;
  String label = "";
  //CLASS VARIABLES /////////////////////////////
  int rotateSpdX = 2;
  int rotateSpdY = 3;
  int rotateSpdZ = 2;
  color mainShellClr = color(100, 100, 100, 70);
  color mainSpriteClr = color(0, 255, 0);
  color mainSpriteStrokeWt = 1;
  int vtxsMainSize = 333;
  Float [] vtxsMain;
  float mainSpriteAmpMin = 0.0;
  float mainSpriteAmpMax = 1.0;
  float azi= -HALF_PI;
  int rx = 0;
  int ry = 0;
  int rz = 0;
  boolean drawlabel = false;
  boolean getamp = true;
  //CONSTRTUCTOR(s) ////////////////////////////////////
  FunkyLM(int argix, int argx, int argy, float argr, String arglabel) {
    ix = argix;
    x = argx;
    y = argy;
    r = argr;
    label = arglabel;
    //POST-CONSTRUCTOR CLASS VARIABLES (C) ///////////
    vtxsMain = new Float [vtxsMainSize];
  }
  //CLASS METHOD (): drawFunkyLM /////////////////////////
  void drw() {
    //draw shell
    pushMatrix();
    //scale(1, 1, 0.1);
    translate(x, y);
    noFill();    
    stroke(mainShellClr);
    strokeWeight(1);
    if ( (frameCount%rotateSpdX)==0 ) rx=(rx+1)%360;
    rotateX(radians(rx));
    if ( (frameCount%rotateSpdY)==0 ) ry=(ry+1)%360;
    rotateY(radians(ry));
    if ( (frameCount%rotateSpdZ)==0 ) rz=(rz+1)%360;
    rotateY(radians(rz));

    sphere(r);

    //write label
    if (drawlabel) {
      textFont(liGothicMed20); 
      fill(255);
      text(label, (cos(-HALF_PI) * (r)), (sin(-HALF_PI) * (r)));
      text(label, (cos(0) * (r)), (sin(0) * (r))); 
      text(label, (cos(HALF_PI) * (r+14)), (sin(HALF_PI) * (r+14)));
      text(label, (cos(PI) * (r+14)), (sin(PI) * (r+14)));
      text(label, 0, 0, r+5);
      text(label, 0, 0, -r-5);
    }

    popMatrix();
    
    //Get Amplitude
    if(getamp) meosc.send("/getrms", new Object[] {label, meosc.ip(), myport}, sc);
    //draw sound sprite
    pushMatrix();
    // scale(1, 1, 0.1);
    translate(x, y, -r/2);
    rotateY(PI*0.3);
    rotateZ(PI*0.72);
    stroke(mainSpriteClr);
    strokeWeight(mainSpriteStrokeWt);
    noFill();
    beginShape();
    for (int i=0; i<vtxsMain.length/3; i=i+3) {
      if (vtxsMain[i] !=null && vtxsMain[i+1] !=null && vtxsMain[i+2] !=null) {
        vertex(vtxsMain[i], vtxsMain[i+1], vtxsMain[i+2]);
      }
    }
    endShape(CLOSE);
    popMatrix();
    
    
  }  // end method

  //CLASS METHOD (): aniSpriteMain /////////////////////////
  void aniSpriteMain(float ampRaw) {
    float ampMapped = map(ampRaw, mainSpriteAmpMin, mainSpriteAmpMax, 0.0, r);
    for (int i=0; i<vtxsMain.length; i++) {
      vtxsMain[i] = constrain(ampMapped, 0.0, r) * random(0.1, 1.4);
    }
  }  // end method
} //end class 

// CLASS SET CLASS ////////////////////////////////
class FunkyLMSet {
  ArrayList<FunkyLM> clset = new ArrayList<FunkyLM>();

  //ADD INSTANCE OF MAIN INS TO ARRAY LIST
  void mkinst(int ix, int x, int y, float r, String label) {
    clset.add(new FunkyLM(ix, x, y, r, label));
  }

  //REMOVE CLASS INSTANCE FROM ARRAY LIST
  void rmv(int ix) {
    for (int i = clset.size ()-1; i >= 0; i--) { 
      FunkyLM inst = clset.get(i);
      if (inst.ix == ix) {
        clset.remove(i);
      }
    }
  }

  //CHANGE LABEL
  void chglabel(int ix, String label) {
    for (int i = clset.size ()-1; i >= 0; i--) { 
      FunkyLM inst = clset.get(i);
      if (inst.ix == ix) {
        inst.label = label;
      }
    }
  }

  //VERIFY IF EXISTS
  boolean verify(int ix) {
    boolean exsists = false;
    for (int i = clset.size ()-1; i >= 0; i--) { 
      FunkyLM inst = clset.get(i);
      if (inst.ix == ix) {
        exsists = true;
      }
    }
    return exsists;
  }

  //CLASS SET METHOD (CStM): aniSpriteMainCStM /////////////////////////
  void aniSprite(String label, float ampRaw) {
    for (int i = clset.size ()-1; i >= 0; i--) { 
      FunkyLM inst = clset.get(i);
      if (inst.label.equals(label)) {
        inst.aniSpriteMain(ampRaw);
      }
    }
  }  // end method

  //DRAW METHOD
  void drw() {
    for (int i=clset.size ()-1; i >= 0; i--) {
      // for(int i=0; i<clset.size(); i++){
      FunkyLM inst = clset.get(i);
      inst.drw();
    }
  } //End Method
} //end of class set class

void getdspnames(String names){
  dspnames = split(names, "#");
 dsp1_dd.clear();
  dsp1_dd.addItem("DSP1", 0);
 for (int i=0; i<dspnames.length; i++) {
    dsp1_dd.addItem(dspnames[i], i+1);
 }
}


void controlEvent(ControlEvent e) {
  
  if (e.isGroup()) {
    
    //  INS DropDown
    if (e.getGroup() == source_dd) {
      if(int(e.getGroup().getValue())!=0){
        String name = e.getGroup().getCaptionLabel().getText();
        String[] splitname = split(name, ":");
        //Get rid of exsisting synth etc. in sc
        if(dspbank[0]!=null) meosc.send("/freesynth", new Object[] {dspbank[0]}, sc);
        //All MICS
        if (splitname[0].equals("mic")) {
          int micnum = int(splitname[1]);
          String label = splitname[0]+splitname[1];
          //Make new synth
          meosc.send("/mkaudioin", new Object[] {label, micnum-1}, sc);
          //make funky level meter
          if(!flmset.verify(0)) mkflm(0, label); 
          else flmset.chglabel(0, label);
          dspbank[0] = label;  //add label to dspbank
        }
      }
      //
      else{
        println("fds");
        meosc.send("/freesynth", new Object[] {dspbank[0]}, sc);
        flmset.rmv(0);
        dspbank[0] = null;
      }
    }

    //  DSP1 DropDown
    if (e.getGroup() == dsp1_dd) {
      if(int(e.getGroup().getValue())!=0){
        //Refresh List of SynthDefs from SC
      //  meosc.send( "/getdspnames", new Object[] {meosc.ip(), myport}, sc);
        String sourceloc = dspbank[0];
        String name = e.getGroup().getCaptionLabel().getText();
        //Get rid of exsisting synth etc. in sc
        if(dspbank[1]!=null) meosc.send("/freesynth", new Object[]{"dsp1"}, sc);
        //Petals of Resonance
        if (name.equals("petalsOfResonance")) {
          meosc.send("/mkdsp_m", new Object[] {
          "dsp1", //dictionary name
          1, //group number
          "petalsOfResonance", //synthdef name
          sourceloc //dictionary name of source - in dspbank[0]
          }
          , sc);
        }
        //RingMod
        if (name.equals("ringmod")) {
          meosc.send("/mkdsp_m", new Object[] {"dsp1", 1, "ringmod", dspbank[0]}, sc);
        }
        dspbank[1] = "dsp1";
        //make funky level meter
       if(!flmset.verify(1)) mkflm(1, "dsp1"); 
      }
      //
      else{
        meosc.send("/freesynth", new Object[] {"dsp1"}, sc);
        flmset.rmv(1);
        dspbank[1] = null; 
      }
    }

    //  OUTS DropDown
    if (e.getGroup() == out_dd) {
      if(int(e.getGroup().getValue())!=0){
        String name = e.getGroup().getCaptionLabel().getText();
        String[] splitname = split(name, ":");
        //Get rid of exsisting synth etc. in sc
        if(dspbank[numbanks-1]!=null) meosc.send("/freesynth", new Object[] {dspbank[numbanks-1]}, sc);
        if (splitname[0].equals("out")) {
          int num = int(splitname[1]);
          String label = splitname[0]+splitname[1];
          //Make Audio Out
          meosc.send("/mkaudioOut_m", new Object[] {label, num-1}, sc);
          //make funky level meter
          if(!flmset.verify(99)) mkflm(99, label); 
          else flmset.chglabel(99, label);
          dspbank[numbanks-1] = label;
          //Route Sound from latest in DSP Chain
          for (int i=dspbank.length-2; i>=0; i--) {
            if (dspbank[i]!=null) {
            meosc.send("/route", new Object[] {dspbank[i], label}, sc);
            break;
            }
          }
        }
      }
      //
      else{
        meosc.send("/freesynth", new Object[] {dspbank[numbanks-1]}, sc);
        flmset.rmv(99);
        dspbank[numbanks-1] = null; 
      }
    }
  }
  //
  else if (e.isController()) {
    // println("event from controller : "+e.getController().getValue()+" from "+e.getController());
  }
}

void cp5gui() {
  // Source DropdownList
  source_dd = cp5.addDropdownList("ins")
    .setPosition(20, 30)
      .setSize(100, 200)
        .setItemHeight(17)
          .setBarHeight(17)
            .toUpperCase(false)
              .setColorBackground(clr.get("plum"));
  source_dd.captionLabel()
    .set("SOURCE")
      .toUpperCase(false);
  source_dd.captionLabel().style().marginTop = 0;
  source_dd.captionLabel().style().marginLeft = 3;

  source_dd.addItem("SOURCE", 0);
  source_dd.addItem("mic:1", 1);
  source_dd.addItem("mic:2", 2);
  source_dd.addItem("mic:3", 3);
  source_dd.addItem("mic:4", 4);

  //Source GUI Button
  cp5.addButton("sourcegui")
      .setSize(27, 17)
        .setPosition(123, 12)
        .setCaptionLabel("GUI")
        .setColorBackground(clr.get("sunshine"))
        .setColorCaptionLabel(clr.get("black"))
          .updateSize()
            ;

  // DSP 1
  dsp1_dd = cp5.addDropdownList("dsp1")
    .setPosition(20, 150)
      .setSize(100, 200)
        .setItemHeight(17)
          .setBarHeight(17)
            .toUpperCase(false)
              .setColorBackground(clr.get("dodgerblue"));
  dsp1_dd.captionLabel()
    .set("DSP1")
      .toUpperCase(false);
  dsp1_dd.captionLabel().style().marginTop = 0;
  dsp1_dd.captionLabel().style().marginLeft = 3;

  dsp1_dd.addItem("DSP1", 0);
  for (int i=0; i<dspnames.length; i++) {
    dsp1_dd.addItem(dspnames[i], i+1);
  }

  //DSP1 GUI Button
  cp5.addButton("dsp1gui")
      .setSize(27, 17)
        .setPosition(123, 132)
        .setCaptionLabel("GUI")
        .setColorBackground(clr.get("sunshine"))
        .setColorCaptionLabel(clr.get("black"))
          .updateSize()
            ;

  // Out DropdownList
  out_dd = cp5.addDropdownList("outs")
    .setPosition(20, height-100)
      .setSize(100, 200)
        .setItemHeight(17)
          .setBarHeight(17)
            .toUpperCase(false)
              .setColorBackground(clr.get("pine"));
  out_dd.captionLabel()
    .set("OUT")
      .toUpperCase(false);
  out_dd.captionLabel().style().marginTop = 0;
  out_dd.captionLabel().style().marginLeft = 3;

  out_dd.addItem("OUT", 0);
  out_dd.addItem("out:1", 1);
  out_dd.addItem("out:2", 2);
  out_dd.addItem("out:3", 3);
  out_dd.addItem("out:4", 4);
}

void mkflm(int ix, String lbl) {
  switch(ix) {
  case 0:
    // Source Level Meter
    flmset.mkinst(ix, 70, 70, 35, lbl);
    break;
  case 1:
    // DSP1 Level Meter
    flmset.mkinst(ix, 70, 190, 35, lbl);
    break;
  case 99:
    // Out Level Meter
    flmset.mkinst(ix, 70, height-60, 35, lbl);
    break;
  }
}

//GUI Functions
//BUTTONS
public void sourcegui(int val) {
  if(dspbank[0]!=null) meosc.send("/mkautogui", new Object[]{dspbank[0]}, sc);
}
public void dsp1gui() {
  if(dspbank[1]!=null) meosc.send("/mkautogui", new Object[]{"dsp1"}, sc);
}



