import GetPut::*;
import CommonIfc::*;

module mkCommonTest#(module#(FrameBitProcessor) mkDut)(Empty);
    function ord(s) = fromInteger(charToInteger(stringHead(s)));
    let dut <- mkDut;

    rule produce_input;
        let c <- $fgetc(stdin);
        case (c)
            -1: $finish(0);
            ord("\n"): noAction;
            ord("-"): dut.in.put(Invalid);
            ord("0"): dut.in.put(Valid(0));
            ord("1"): dut.in.put(Valid(1));
            default: begin
                $display("Syntax error: unexpected char ", c);
                $finish(1);
            end
        endcase
    endrule

    rule consume_output;
        let item <- dut.out.get;
        case (item) matches
            tagged Invalid: $display("-");
            tagged Valid .x: $display(x);
        endcase
    endrule
endmodule
