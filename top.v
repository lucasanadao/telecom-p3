module top(CLK,
          RST_N,
          rs232_SIN,
          rs232_SOUT,
          LED,
          ETH_RX_P,
          ETH_RX_N);

    input  CLK;
    input  RST_N;
    input  rs232_SIN;
    output rs232_SOUT;
    output [5 : 0] LED;
    input  ETH_RX_P;
    input  ETH_RX_N;

    wire   ETH_RX;
    wire   CLK_MAIN;
    wire   CLK_UART;

    wire RDY_eth_rx_put;

    pll_main pll0(
        .clock_in(CLK),
        .clock_out(CLK_MAIN)
    );

    pll_uart pll1(
        .clock_in(CLK),
        .clock_out(CLK_UART)
    );

    TLVDS_IBUF uut(
        .O(ETH_RX),
        .I(ETH_RX_P),
        .IB(ETH_RX_N)
    );

    mkTop real_top(
        .CLK_clk_uart(CLK_UART),
        .CLK(CLK_MAIN),
        .RST_N(RST_N),
        .rs232_SIN(rs232_SIN),
        .rs232_SOUT(rs232_SOUT),
        .LED(LED),
        .eth_rx_put(ETH_RX),
        .EN_eth_rx_put(RDY_eth_rx_put),
        .RDY_eth_rx_put(RDY_eth_rx_put)
    );

endmodule
