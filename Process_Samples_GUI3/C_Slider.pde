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
    h2=h-40;

    sm=b2-8;
    st1=sm-8;
    sb1=sm+8;
    st2=sm-1;
    sb2=sm+1;
  } //end constructor 1

  //  DRAW METHOD //
  void drw() {
    //Change value
    
    if (mousePressed) {
      if (mouseX>=l1&&mouseX<=r1&&mouseY>=st1&&mouseY<=sb1) {
        sm = constrain( sm-pmouseY+mouseY, t2+8, b2-8 );
        st1=sm-8;
        sb1=sm+8;
        st2=sm-1;
        sb2=sm+1;
        sv = map(sm, b2-8, t2+8, lo, hi);
        osc.send("/slider", new Object[]{ix, sv}, sc);
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
    fill(0, 130);
    rect(l2, st1, w2, 16);
    //slider
    fill(0);
    rect(l1, st2, w, 2, 3);
    //value back
    fill(0);
    noStroke();
    rect(l2, t1+10, w2, 20, 4);
    fill(153, 255, 0);
    textAlign(LEFT, CENTER);
    text(sv, l2, t2-10);
    
  } //End drw
  //
  //
}  //End class