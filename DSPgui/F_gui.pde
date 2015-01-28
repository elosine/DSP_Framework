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

}

void mkflm(int ix, String lbl){
  println(ix + "   " + lbl);
  switch(ix){
    case 0:
   // Source Level Meter
   println("hello");
  flmset.mkinst(ix, 70, 70, 35, lbl);
  break;
  }
}

