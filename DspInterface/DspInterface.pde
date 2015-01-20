import oscP5.*;
import netP5.*;

OscP5 meosc;
NetAddress sclang;

void setup(){
  size(500, 500);
  
  meosc = new OscP5(this, 12321);
  sclang = new NetAddress("127.0.0.1", 57120);
  meosc.plug(this, "rms", "/rms/mic1");
}

void draw(){
  background(0);
  
}

void keyPressed(){
  if(key=='a'){
    OscMessage msg = new OscMessage("/mkaudioin");
    msg.add("mic1");
    msg.add(0);
    meosc.send(msg, sclang);
  }
  if(key=='f'){
    OscMessage msg = new OscMessage("/getrms");
    msg.add("mic1");
    msg.add("127.0.0.1");
    msg.add(12321);
    meosc.send(msg, sclang);
  }
}

void rms(float val){
  println(val);
}

/*
Hook Up to DANI Graphic
USE SC to Poll soundcard and find ins and outs and make
corresponding graphics here, give names
*/
