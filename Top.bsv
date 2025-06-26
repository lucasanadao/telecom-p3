import RS232::*;
import GetPut::*;
import FIFOF::*;
import Connectable::*;
import Clocks::*;
import Vector::*;
import FrameDelimiter::*;

interface Top;
    interface RS232 rs232;
    interface Reset rs232_rst;
    (* always_ready, prefix="", result="LED" *)
    method Bit#(6) led;
    interface Put#(Bit#(1)) eth_rx;
endinterface

(* synthesize *)
module mkTop#(Clock clk_uart)(Top);
    FrameDelimiter frameDelimiter <- mkFrameDelimiter;

    Reset rst_uart <- mkAsyncResetFromCR(2, clk_uart);
    UART#(16) uart <- mkUART(8, NONE, STOP_1, 1, clocked_by clk_uart, reset_by rst_uart);
    SyncFIFOIfc#(Bit#(8)) uartSync <- mkSyncFIFOFromCC(2, clk_uart);
    mkConnection(toGet(uartSync), uart.rx);

    // UART is slower than Ethernet 10baseT (2.4M vs 10M),
    // but this FIFO is enough to buffer an entire frame
    FIFOF#(Bit#(8)) uartBuffer <- mkSizedFIFOF(1522);
    mkConnection(toGet(uartBuffer), toPut(uartSync));

    Reg#(Bit#(6)) ledCounter <- mkReg(0);

    Reg#(Bit#(8)) deserByte <- mkRegU;
    Reg#(Bit#(3)) deserCounter <- mkReg(0);

    rule discard;
        let b <- uart.tx.get;
    endrule

    rule process_frame_bit;
        let frame_bit <- frameDelimiter.out.get;
        case (frame_bit) matches
            tagged Invalid:
                begin
                    // count a new frame at each End of Frame marker
                    ledCounter <= ledCounter + 1;
                    deserCounter <= 0;
                end
            tagged Valid .b:
                begin
                    // deserialize content bits and send bytes to UART
                    let deserByte_ = {b, deserByte[7:1]};
                    if (deserCounter == 7) begin
                        uartBuffer.enq(deserByte_);
                    end
                    deserByte <= deserByte_;
                    deserCounter <= deserCounter + 1;
                end
        endcase
    endrule

    interface eth_rx = frameDelimiter.in;
    interface rs232 = uart.rs232;
    interface rs232_rst = rst_uart;
    method led = ~ledCounter;
endmodule
