// Memory array block for tic-tac-toe project
// Written by Katherine Yang and Guillaume Legrain
// Written in: March 23, 2015
// Last edited: March 27, 2015
// player1:11, player2:10, tie:01, noWin:00
// cellState: empty:00, player1:11, player2:10
/////////////////////////////////////////////////////
module memArray(input  logic        ph1, ph2, reset,
                input  logic  [3:0] addr,
                input  logic  [1:0] cellState,
                output logic [17:0] gBoard);
   
    logic [8:0]  writePos;
    logic [17:0] prevGB;
    
    // Write decoder
    addr2writePos  decoder(addr[3:0], writePos[8:0]);

    // array of Flip-flops
    // NOTE: cellState bit order is flip to have the LSB of the gBoard be the MSB
    // of the cellState
    flopenr #(2) cell0(ph1, ph2, reset, writePos[0], {cellState[0],cellState[1]},
                       prevGB[1:0]);
    flopenr #(2) cell1(ph1, ph2, reset, writePos[1], {cellState[0],cellState[1]},
                       prevGB[3:2]);
    flopenr #(2) cell2(ph1, ph2, reset, writePos[2], {cellState[0],cellState[1]},
                       prevGB[5:4]);
    flopenr #(2) cell3(ph1, ph2, reset, writePos[3], {cellState[0],cellState[1]},
                       prevGB[7:6]);
    flopenr #(2) cell4(ph1, ph2, reset, writePos[4], {cellState[0],cellState[1]},
                       prevGB[9:8]);
    flopenr #(2) cell5(ph1, ph2, reset, writePos[5], {cellState[0],cellState[1]},
                       prevGB[11:10]);
    flopenr #(2) cell6(ph1, ph2, reset, writePos[6], {cellState[0],cellState[1]},
                       prevGB[13:12]);
    flopenr #(2) cell7(ph1, ph2, reset, writePos[7], {cellState[0],cellState[1]},
                       prevGB[15:14]);
    flopenr #(2) cell8(ph1, ph2, reset, writePos[8], {cellState[0],cellState[1]},
                       prevGB[17:16]);

    assign gBoard = prevGB;
    
endmodule

// Write decoder logic
module addr2writePos(input  logic [3:0] addr,
                     output logic [8:0] writePos);
   always_comb
        begin
          case (addr)
            4'b0000: writePos = 9'b000000001; // upperleft cell is writePos[0]
            4'b0001: writePos = 9'b000000010;
            4'b0010: writePos = 9'b000000100;
            4'b0011: writePos = 9'b000001000;
            4'b0100: writePos = 9'b000010000;
            4'b0101: writePos = 9'b000100000;
            4'b0110: writePos = 9'b001000000;
            4'b0111: writePos = 9'b010000000;
            4'b1000: writePos = 9'b100000000;  // lowerleft cell
            4'b1111: writePos = 9'b000000000; //bad case
            default: writePos = 9'b000000000;  // else, don't write
          endcase
        end
endmodule

