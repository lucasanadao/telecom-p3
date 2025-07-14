import GetPut::*;
import FIFOF::*;
import CommonIfc::*;

module mkManchesterDecoder(FrameBitProcessor);
    Reg#(Maybe#(Bit#(1))) prev <- mkReg(Invalid);
    Reg#(Bit#(3)) i <- mkReg(0);
    FIFOF#(Maybe#(Bit#(1))) outFifo <- mkFIFOF;

    interface Put in;
        method Action put(Maybe#(Bit#(1)) in);
            if (in matches tagged Valid .bit) begin
                if (prev matches tagged Valid .prevBit) begin
                    // Verifica se houve transição
                    if (prevBit != bit) begin
                        // Houve transição! Realinha a fase
                        if (i == 4) begin
                            // Transição no meio do símbolo (fase correta)
                            // Produz saída baseada na direção da transição
                            if (prevBit == 0 && bit == 1) begin
                                outFifo.enq(Valid(1)); // 0->1 = bit 1
                            end else begin
                                outFifo.enq(Valid(0)); // 1->0 = bit 0
                            end
                        end
                        // Realinha a fase para o próximo símbolo
                        i <= 0;
                    end
                end
                
                // Atualiza o bit anterior e incrementa contador de fase
                prev <= Valid(bit);
                i <= i + 1;
                
                // Reseta contador se chegou ao fim do ciclo (8 amostras)
                if (i == 7) begin
                    i <= 0;
                end
            end else begin
                // Recebeu Invalid - fim do quadro
                // Reinicia estado e repassa Invalid
                prev <= Invalid;
                i <= 0;
                outFifo.enq(Invalid);
            end
        endmethod
    endinterface
    interface out = toGet(outFifo);
endmodule
