import GetPut::*;

interface FrameBitProcessor;
    interface Put#(Maybe#(Bit#(1))) in;
    interface Get#(Maybe#(Bit#(1))) out;
endinterface
