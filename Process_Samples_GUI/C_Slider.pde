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