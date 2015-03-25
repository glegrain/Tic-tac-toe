// Game Controller FSM block for tic-tac-toe project
// Written by Katherine Yang and Guillaume Legrain
// Written in: March 23, 2015
// Last edited: March 24, 2015
// player1:11, player2:10, tie:01, noWin:00
// cellState: empty:00, player1:11, player2:10
/////////////////////////////////////////////////////

// states
typedef enum logic [2:0] {WAIT, CHECKROW0, CHECKROW1, CHECKROW2, END} statetype;

// This module checks if the row is full
module isRowFull(input logic [5:0] gBoardRow,
                  output logic isFull);
  assign isFull = gBoardRow[0] & gBoardRow[2] & gBoardRow[4];
endmodule



// This module finds the row given the state
module extractRow(input logic [17:0] gBoard,
                  input logic [2:0] state,
                  output logic [5:0] gBoardRow);
  always_comb begin
    case(state)
      3'b001: gBoardRow<=gBoard[5:0];
      3'b010: gBoardRow<=gBoard[11:6];
      3'b011: gBoardRow<=gBoard[17:12];

      default: gBoardRow<=6'b111111;
    endcase
  end   
endmodule



// This module finds the closest position at which there is a empty space and returns the address
module closestEmptyPos(input logic [5:0] gBoardRow,
                       input logic [2:0] state,
                        output logic [3:0] addr);
  logic [8:0] combState = {state, gBoardRow};
  
  always_comb begin
    casez(combState)
      9'b001?????0: addr<=4'b0000;
      9'b001???0?1: addr<=4'b0001;
      9'b001?0?1?1: addr<=4'b0010;

      9'b010?????0: addr<=4'b0011;
      9'b010???0?1: addr<=4'b0100;
      9'b010?0?1?1: addr<=4'b0101;

      9'b011?????0: addr<=4'b0110;
      9'b011???0?1: addr<=4'b0111;
      9'b011?0?1?1: addr<=4'b1000;
      
      default: addr<=4'b1111; //bad address
    endcase 
  end 
endmodule

module closestPosAI(input  logic          ph1, ph2, reset,
                      input  logic  [1:0] cellState, //our AI is when the cellState is 2'b10
                      input  logic [17:0] gBoard,
                      output logic  [3:0] addr,
                      output logic        writeToBoard);
  statetype [2:0] state;
  logic [5:0] gBoardRow;
  logic rowIsFull, isTurn;
  // assign the gBoard row according to states
  extractRow findRow(gBoard, state, gBoardRow);
  // find if current row is full
  isRowFull rowFull(gBoardRow, rowIsFull);
  // find the address of the top leftmost empty square
  closestEmptyPos assignAddr(gBoardRow, state, addr);

  assign isTurn = cellState[1] & (~cellState[0]);

  outputlogic outputlog(state, isFull, writeToBoard); 
  // control FSM
  statelogic  statelog(.ph1, .ph2, .reset,
                       .isTurn, .rowIsFull, .state);
  //outputlogic outputlog(.state, .playerWrite, .playerInput, .addr, .cellState);

endmodule


module statelogic(input  logic     ph1, ph2, reset,
                  input  logic     isTurn, rowIsFull
                  output statetype[2:0] state);

  statetype [2:0]nextstate;
  logic [2:0] ns, state_logic;

  // resetable state register with initial value of START
  mux2 #(3) resetmux(nextstate, WAIT, reset, ns);
  flop #(3) stateregister(ph1, ph2, ns, state_logic);
  assign state = statetype'(state_logic);

  // next state logic
  always_comb
    begin
      case (state)
        WAIT:      nextstate = (isTurn) ? CHECKROW0 : WAIT;
        CHECKROW0: nextstate = (isFull) ? CHECKROW1 : WAIT;
        CHECKROW1: nextstate = (isFull) ? CHECKROW2 : WAIT;
        CHECKROW2: nextstate = (isFull) ? END : WAIT;
        END:       nextstate = END;
        default: nextstate = WAIT;
      endcase
    end
endmodule

module outputlogic(input  statetype [2:0] state,
                   input logic  isFull,
                   output logic writeToBoard);

  logic [3:0]combState = {isFull, state};
  always_comb
    begin
      case (state)
        4'b0001: writeToBoard <= 1'b1;
        4'b0010: writeToBoard <= 1'b1;
        4'b0011: writeToBoard <= 1'b1;
        default: writeToBoard <= 1'b0;
      endcase
endmodule