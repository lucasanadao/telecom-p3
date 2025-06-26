import GetPut::*;
import SFDLocator::*;
import CommonTest::*;

(* synthesize *)
module mkTestSFDLocator(Empty);
    (* hide *)
    let _m <- mkCommonTest(mkSFDLocator);
    return _m;
endmodule
