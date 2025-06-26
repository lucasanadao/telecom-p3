import GetPut::*;
import ManchesterDecoder::*;
import CommonTest::*;

(* synthesize *)
module mkTestManchesterDecoder(Empty);
    (* hide *)
    let _m <- mkCommonTest(mkManchesterDecoder);
    return _m;
endmodule
