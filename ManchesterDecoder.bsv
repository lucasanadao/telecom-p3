import GetPut::*;
import FIFOF::*;
import CommonIfc::*;

module mkManchesterDecoder(FrameBitProcessor);
    Reg#(Maybe#(Bit#(1))) prev <- mkReg(Invalid);
    Reg#(Bit#(3)) i <- mkReg(0);
    FIFOF#(Maybe#(Bit#(1))) outFifo <- mkFIFOF;

    interface Put in;
        method Action put(Maybe#(Bit#(1)) in);
            Bit#(3) new_i = i;
            Bit#(1) output_val = ?;
            
            if (!isValid(in)) begin
                // Reset no final do quadro
                prev <= Invalid;
                new_i = 0;
                outFifo.enq(Invalid);
            end
            else begin
                let current = validValue(in);
                
                if (isValid(prev)) begin
                    let prev_val = validValue(prev);
                    
                    // Verifica se houve transição
                    if (current != prev_val) begin
                        // Ajusta a fase baseado na posição atual
                        if (i % 4 == 3) begin
                            // Se estamos em posição 3 ou 7, avança para 4 ou 0
                            new_i = i + 1;
                        end 
                        if (i % 4 == 1) begin
                            // Se estamos em posição 1 ou 5, volta para 0 ou 4
                            new_i = i - 1;
                        end 
                        
                        // Se após ajuste estamos no meio do símbolo (posição 4)
                        if (new_i == 4) begin
                            if (prev_val == 0 && current == 1) begin
                                // Transição 0->1 = bit 1
                                output_val = 1;
                                outFifo.enq(Valid(output_val));
                            end else if (prev_val == 1 && current == 0) begin
                                // Transição 1->0 = bit 0
                                output_val = 0;
                                outFifo.enq(Valid(output_val));
                            end
                        end
                    end
                end
                
                // Atualiza o bit anterior
                prev <= Valid(current);
                // Incrementa contador (será limitado pelo módulo 8 implícito do Bit#(3))
                new_i = new_i + 1;
            end
            
            // Atualiza o contador de fase
            i <= new_i;
        endmethod
    endinterface

interface out = toGet(outFifo);
endmodule
