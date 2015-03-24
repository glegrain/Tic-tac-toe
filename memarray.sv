// Memory array block for tic-tac-toe project
// Written by Katherine Yang and Guillaume Legrain
// March 23, 2015 
// player1:11, player2:10, tie:01, noWin:00
// cellState: empty:00, player1:11, player2:10
/////////////////////////////////////////////////////
module memArray(input logic ph1, ph2, reset,
                input logic [3:0]addr,
                input logic [1:0]cellState,
                output logic [17:0]gameBoard);
   
    logic [8:0]writePos, clkEn;
    logic [17:0] prevGB;
    
    // Write decoder
    add2mem  decoder(addr[3:0], writePos[8:0]);
    
    assign clkEn = ph2 & writePos & reset;

    // array of Flip-flops
    flopenr #(2) cell0(ph1, ph2, reset, writePos[0], cellState[1:0],
                       prevGB[1:0]);
    flopenr #(2) cell1(ph1, ph2, reset, writePos[1], cellState[1:0],
                       prevGB[3:2]);
    flopenr #(2) cell2(ph1, ph2, reset, writePos[2], cellState[1:0],
                       prevGB[5:4]);
    flopenr #(2) cell3(ph1, ph2, reset, writePos[3], cellState[1:0],
                       prevGB[7:6]);
    flopenr #(2) cell4(ph1, ph2, reset, writePos[4], cellState[1:0],
                       prevGB[9:8]);
    flopenr #(2) cell5(ph1, ph2, reset, writePos[5], cellState[1:0],
                       prevGB[11:10]);
    flopenr #(2) cell6(ph1, ph2, reset, writePos[6], cellState[1:0],
                       prevGB[13:12]);
    flopenr #(2) cell7(ph1, ph2, reset, writePos[7], cellState[1:0],
                       prevGB[15:14]);
    flopenr #(2) cell8(ph1, ph2, reset, writePos[8], cellState[1:0],
                       prevGB[17:16]);

    assign gameBoard = prevGB;
    
endmodule

// Write decoder logic
module add2mem(input logic [3:0]addr,
               output logic[8:0]writePos);
   always_comb
        begin
            writePos[0] = ~addr[2] & ~addr[1] & ~addr[0]; // addr = 4'b0000 //upperleft
            writePos[1] = ~addr[2] & ~addr[1] &  addr[0]; // addr = 4'b0001
            writePos[2] = ~addr[2] &  addr[1] & ~addr[0]; // addr = 4'b0010
            writePos[3] = ~addr[2] &  addr[1] &  addr[0]; // addr = 4'b0011
            writePos[4] =  addr[2] & ~addr[1] & ~addr[0]; // addr = 4'b0100
            writePos[5] =  addr[2] & ~addr[1] &  addr[0]; // addr = 4'b0101
            writePos[6] =  addr[2] &  addr[1] & ~addr[0]; // addr = 4'b0110
            writePos[7] =  addr[2] &  addr[1] &  addr[0]; // addr = 4'b0111
            writePos[8] =  addr[3];                       // addr = 4'b1000 //lower right
        end
endmodule

/**
 * Safe Flip-Flop code from lab 3
 */

module flop #(parameter WIDTH = 8)
             (input  logic             ph1, ph2, 
              input  logic [WIDTH-1:0] d, 
              output logic [WIDTH-1:0] q);

  logic [WIDTH-1:0] mid;

  latch #(WIDTH) master(ph2, d, mid);
  latch #(WIDTH) slave(ph1, mid, q);
endmodule

module flopenr #(parameter WIDTH = 8)
                (input  logic             ph1, ph2, reset, en,
                 input  logic [WIDTH-1:0] d, 
                 output logic [WIDTH-1:0] q);
 
  logic [WIDTH-1:0] d2, resetval;

  assign resetval = 0;

  mux3 #(WIDTH) enrmux(q, d, resetval, {reset, en}, d2);
  flop #(WIDTH) f(ph1, ph2, d2, q);
endmodule

module latch #(parameter WIDTH = 8)
              (input  logic             ph, 
               input  logic [WIDTH-1:0] d, 
               output logic [WIDTH-1:0] q);

  always_latch
    if (ph) q <= d;
endmodule

module mux3 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1, d2,
              input  logic [1:0]       s, 
              output logic [WIDTH-1:0] y);

  always_comb 
    casez (s)
      2'b00: y = d0;
      2'b01: y = d1;
      2'b1?: y = d2;
    endcase
endmodule


