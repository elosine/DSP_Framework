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
  float mainSpriteAmpMin = -55.0;
  float mainSpriteAmpMax = -4.0;
  float azi= -HALF_PI;
  int rx = 0;
  int ry = 0;
  int rz = 0;
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
    //write channel number
    textFont(liGothicMed20); 
    fill(255);
    text(label, (cos(-HALF_PI) * (r)), (sin(-HALF_PI) * (r)));
    text(label, (cos(0) * (r)), (sin(0) * (r))); 
    text(label, (cos(HALF_PI) * (r+14)), (sin(HALF_PI) * (r+14)));
    text(label, (cos(PI) * (r+14)), (sin(PI) * (r+14)));
   text(label, 0, 0, r+5);
    text(label, 0, 0, -r-5); 
    popMatrix();

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
