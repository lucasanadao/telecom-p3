import GetPut::*;
import Connectable::*;
import ManchesterDecoder::*;
import SFDLocator::*;
import CommonIfc::*;
import FIFOF::*;

interface FrameDelimiter;
    interface Put#(Bit#(1)) in;
    interface Get#(Maybe#(Bit#(1))) out;
endinterface

module mkFrameDelimiter(FrameDelimiter);
    Reg#(Bool) inside_frame <- mkReg(False);
    Reg#(Bit#(1)) prev <- mkReg(0);
    Reg#(Bit#(16)) how_long <- mkReg(0);
    Reg#(Bit#(6)) strikes <- mkReg(0);

    let manchesterDecoder <- mkManchesterDecoder;
    FIFOF#(Maybe#(Bit#(1))) frameFifo <- mkFIFOF;
    mkConnection(toGet(frameFifo), manchesterDecoder.in);

    let sfdLocator <- mkSFDLocator;
    mkConnection(manchesterDecoder.out, sfdLocator.in);

    interface Put in;
        method Action put(Bit#(1) in);
            prev <= in;
            if (inside_frame) begin
                // detect End of Frame (a long sequence of zeros)
                if (how_long == 40) begin  // minimum IPG is 47 bit times ~ 47*7 (329) worst case, but noise can occur
                    inside_frame <= False;
                    strikes <= 0;
                    how_long <= 0;
                    frameFifo.enq(Invalid);  // we send Invalid to notify End of Frame
                end else begin
                    if (in == 1) begin
                        how_long <= 0;
                    end else begin
                        how_long <= how_long + 1;
                    end
                    frameFifo.enq(Valid(in));
                end
            end else begin
                if (in == prev) begin
                    // detect Start of Frame (preamble) after a sequence of long pulses ("strikes")
                    if (strikes == 5 && how_long == 2) begin  // adjust phase to start of bit
                        inside_frame <= True;
                        strikes <= 0;
                        how_long <= 0;
                    end else if (how_long != 10) begin
                        how_long <= how_long + 1;
                    end
                end else begin
                    how_long <= 0;
                    if (how_long == 7 || how_long == 8 || how_long == 9) begin
                        strikes <= strikes + 1;
                    end else begin
                        strikes <= 0;
                    end
                end
            end
        endmethod
    endinterface
    interface out = sfdLocator.out;
endmodule
