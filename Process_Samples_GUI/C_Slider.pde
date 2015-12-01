// DECLARE/INITIALIZE CLASS SET
SliderSet sliderz = new SliderSet();
/**********
 /// PUT IN SETUP ///
 meosc.plug(sliderz, "mk", "/mkslider");
 meosc.plug(sliderz, "rmv", "/rmvslider");
 meosc.plug(sliderz, "rmvall", "/rmvallslider");
 /// PUT IN DRAW ///
 sliderz.drw();
 *******/
class Slider {
  // CONSTRUCTOR VARIALBES //
  int ix, x, y, w, h;
  float lo, hi;
  // CLASS VARIABLES //
  float l1, t1, b1, r1;
  float l2, t2, b2, r2;
  float w2, h2;
  float st1, sm, sb1, st2, sb2;
  float sv=0.0;
  // CONSTRUCTORS //

  /// Constructor 1 ///
  Slider(int aix, int ax, int ay, int aw, int ah, float alo, float ahi) {
    ix = aix;
    x = ax;
    y = ay;
    lo = alo;
    hi = ahi;
    w = aw;
    h = ah;

    l1=x;
    t1=y;
    r1=x+w;
    b1=y+h;
    l2=l1+10;
    t2=t1+30;
    r2=r1-10;
    b2=b1-10;
    w2=w-20;
    h2 = h-20;

    sm = b2-6;
    st1 = sm-6;
    sb1=sm+6;
    st2=sm-1;
    sb2=sm+1;
  } //end constructor 1

  //  DRAW METHOD //
  void drw() {
    //Change value
    if (mousePressed) {
      if (mouseX>=l1&&mouseX<=r1&&mouseY>=st1&&mouseY<=sb1) {
        sm = constrain( sm-pmouseY+mouseY, t2+6, b2-6 );
        st1=sm-6;
        sb1=sm+6;
        st2=sm-1;
        sb2=sm+1;
        sv = norm(sm, b2-6, t2+6);
      }
    }
    //background
    noStroke();
    fill(0, 150);
    rect(l1, t1, w, h, 3);
    //slider area
    fill(153, 255, 0);
    rect(l2, t2, w2, h2, 3);
    //slider backing
    noStroke();
    fill(100, 200);
    rect(st1, sb1, w2, h2, 3);
    //slider
    fill(0);
    rect(st2, sb2, w, h, 3);
    //value back
    fill(0);
    noStroke();
    rect(l1, t1+10, w2, 20, 4);
    fill(153, 255, 0);
    textAlign(LEFT, CENTER);
    text(sv, l2, sm);
  } //End drw
  //
  //
}  //End class

////////////////////////////////////////////////////////////
/////////////   CLASS SET     //////////////////////////////
////////////////////////////////////////////////////////////

class SliderSet {
  ArrayList<Slider> cset = new ArrayList<Slider>();

  // Make Instance Method //
  void mk(int ix) {
    cset.add( new Slider(ix) );
  } //end mk method

  // Remove Instance Method //
  void rmv(int ix) {
    for (int i=cset.size ()-1; i>=0; i--) {
      Slider inst = cset.get(i);
      if (inst.ix == ix) {
        cset.remove(i);
        break;
      }
    }
  } //End rmv method

  // Draw Set Method //
  void drw() {
    for (Slider inst : cset) {
      inst.drw();
    }
  }//end drw method
  //
  //
} // END CLASS SET CLASS