

void controlEvent(ControlEvent e) {
  if (e.isGroup()) {
    //  INS DropDown
    if (e.getGroup() == source_dd) {
      String name = e.getGroup().getCaptionLabel().getText();
      String[] splitname = split(name, ":");
      //Get rid of exsisting synth etc. in sc
      meosc.send("/freesynth", new Object[] {dspbank[0]}, sc);
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

    //  DSP1 DropDown
    if (e.getGroup() == dsp1_dd) {
      //Refresh List of SynthDefs from SC
      meosc.send( "/getdspnames", new Object[] {meosc.ip(), myport}, sc);
      String name = e.getGroup().getCaptionLabel().getText();
      //Get rid of exsisting synth etc. in sc
      meosc.send("/freesynth", new Object[] {dspbank[1]}, sc);
      //Petals of Resonance
      if (name.equals("petalsOfResonance")) {
        meosc.send("/mkdsp_m", new Object[] {
          "dsp1", //dictionary name
          1, //group number
          "petalsOfResonance", //synthdef name
          dspbank[0] //dictionary name of source - in dspbank[0]
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

    //  OUTS DropDown
    if (e.getGroup() == out_dd) {
      String name = e.getGroup().getCaptionLabel().getText();
      String[] splitname = split(name, ":");
      //Get rid of exsisting synth etc. in sc
      meosc.send("/freesynth", new Object[] {dspbank[numbanks-1]}, sc);
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
          }
        }
      }
    }
  }
  //
  else if (e.isController()) {
    // println("event from controller : "+e.getController().getValue()+" from "+e.getController());
  }
}

