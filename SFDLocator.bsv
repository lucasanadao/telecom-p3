import GetPut::*;
import FIFOF::*;
import CommonIfc::*;

module mkSFDLocator(FrameBitProcessor);
    Reg#(Bit#(1)) prev <- mkReg(0);
    Reg#(Bool) afterSfd <- mkReg(False);
    FIFOF#(Maybe#(Bit#(1))) outFifo <- mkFIFOF;

    interface Put in;
        method Action put(Maybe#(Bit#(1)) in);
            if (in matches tagged Valid .b) begin
                if (afterSfd) begin
                    // Já encontrou o SFD - repassa todos os bits
                    outFifo.enq(Valid(b));
                end else begin
                    // Ainda procurando SFD
                    // Verifica se prev=1 e bit atual=1 (sequência "11")
                    if (prev == 1 && b == 1) begin
                        // Encontrou o fim do SFD! Próximos bits serão dados úteis
                        afterSfd <= True;
                    end
                    // Atualiza o bit anterior apenas quando ainda procurando SFD
                    prev <= b;
                end
            end else begin
                // Fim do quadro - reinicia estado e repassa Invalid
                afterSfd <= False;
                prev <= 0;
                outFifo.enq(Invalid);
            end
        endmethod
    endinterface
    
    interface out = toGet(outFifo);
endmodule
