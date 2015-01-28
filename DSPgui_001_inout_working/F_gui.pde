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

  source_dd.addItem("mic:1", 0);
  source_dd.addItem("mic:2", 1);
  source_dd.addItem("mic:3", 2);
  source_dd.addItem("mic:4", 3);
  
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

  out_dd.addItem("out:1", 0);
  out_dd.addItem("out:2", 1);
  out_dd.addItem("out:3", 2);
  out_dd.addItem("out:4", 3);

}

void mkflm(int ix, String lbl){
  switch(ix){
    case 0:
   // Source Level Meter
  flmset.mkinst(ix, 70, 70, 35, lbl);
  break;
    case 99:
   // Source Level Meter
  flmset.mkinst(ix, 70, height-60, 35, lbl);
  break;
  }
}

