import GetPut::*;
import FIFOF::*;
import CommonIfc::*;

module mkSFDLocator(FrameBitProcessor);
    Reg#(Bit#(1)) prev <- mkReg(0);
    Reg#(Bool) afterSfd <- mkReg(False);
    FIFOF#(Maybe#(Bit#(1))) outFifo <- mkFIFOF;

    interface Put in;
        method Action put(Maybe#(Bit#(1)) in);
            case (in) matches
                tagged Invalid: begin
                    // Fim do quadro - reinicia estado e repassa Invalid
                    afterSfd <= False;
                    prev <= 0;
                    outFifo.enq(Invalid);
                end
                
                tagged Valid .bit: begin
                    if (afterSfd) begin
                        // Já encontramos o SFD - repassa todos os bits
                        outFifo.enq(Valid(bit));
                    end
                    else begin
                        // Ainda procurando pelo SFD
                        // Verifica se prev=1 e bit atual=1 (sequência "11")
                        if (prev == 1 && bit == 1) begin
                            // Encontrou o fim do SFD! Próximos bits serão dados úteis
                            afterSfd <= True;
                        end
                    end
                    
                    // Sempre atualiza o bit anterior para a próxima iteração
                    prev <= bit;
                end
            endcase
        endmethod
    endinterface
    
    interface out = toGet(outFifo);
endmodule
