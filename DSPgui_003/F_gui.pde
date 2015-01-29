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


