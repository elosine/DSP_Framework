

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

    //  DSP1 DropDown
    if (e.getGroup() == dsp1_dd) {
      //  int idx = int(e.getGroup().getValue()); //to get the index number of the pulldown item
      String name = e.getGroup().getCaptionLabel().getText();
      if (name.equals("petalsOfResonance")) {
        meosc.send("/mkdsp_m", new Object[] {
          "dsp1", //dictionary name
          1, //group number
          "petalsOfResonance", //synthdef name
          dspbank[0], //dictionary name of source - in dspbank[0]
        }
        , sc);
        dspbank[1] = "dsp1";
        mkflm(1, "dsp1");
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
            if (dspbank[i]!=null) {
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

