void getdspnames(String names){
  dspnames = split(names, "#");
 dsp1_dd.clear();
  dsp1_dd.addItem("DSP1", 0);
 for (int i=0; i<dspnames.length; i++) {
    dsp1_dd.addItem(dspnames[i], i+1);
 }
}
