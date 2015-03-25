// Game Controller FSM block for tic-tac-toe project
// Written by Katherine Yang and Guillaume Legrain
// Written in: March 23, 2015
// Last edited: March 24, 2015
// player1:11, player2:10, tie:01, noWin:00
// cellState: empty:00, player1:11, player2:10
/////////////////////////////////////////////////////

// states
typedef enum logic [3:0] {WAIT, CHECKROW0, CHECKROW1, CHECKROW2, WRITE, END} statetype;

// This module checks if the row is full
module isRowFull(input logic [5:0] gBoardRow,
                  output logic isFull,
                  output logic );
  
endmodule

module closestPosAI(input  logic          ph1, ph2, reset,
                      input  logic [2:0]  cellState,
                      input  logic        playerWrite,
                      input  logic  [3:0] playerInput,  // cell address to play. the cell state is based on the FSM state
                      input  logic [17:0] gBoard,
                      input  logic        gameIsDone,
                      input  logic  [1:0] winner,
                      output logic  [3:0] addr);
  statetype state;

  // control FSM
  statelogic  statelog(.ph1, .ph2, .reset,
                       .isPlayer1Start, .gameIsDone, .playerWrite, .state);
  outputlogic outputlog(.state, .playerWrite, .playerInput, .addr, .cellState);

endmodule


module statelogic(input  logic     ph1, ph2, reset,
                  input  logic     isPlayer1Start,
                  input  logic     gameIsDone,
                  input  logic     playerWrite,
                  output statetype state);

  statetype nextstate;
  logic [1:0] ns, state_logic;

  // resetable state register with initial value of START
  mux2 #(2) resetmux(nextstate, START, reset, ns);
  flop #(2) stateregister(ph1, ph2, ns, state_logic);
  assign state = statetype'(state_logic);

  // next state logic
  always_comb
    begin
      case (state)
        START:   nextstate = (isPlayer1Start) ? PLAYER1 : PLAYER2;
        PLAYER1: if (gameIsDone) nextstate = END;
                 else if (playerWrite) nextstate = PLAYER2;
                 else nextstate = PLAYER1;
        PLAYER2: if (gameIsDone) nextstate = END;
                 else if (playerWrite) nextstate = PLAYER1;
                 else nextstate = PLAYER1;
        END:     nextstate = END;
        default: nextstate = START;
      endcase
    end
endmodule

module outputlogic(input  statetype   state,
                   input  logic       playerWrite,
                   input  logic [3:0] playerInput,
                   output logic [3:0] addr,
                   output logic [1:0] cellState);

  always_comb
    begin
      // NOTE: Assuming playerWrite is enable bit active on one clock cycle.
      //       A sperate module can be used to detect the playerWrite rising edge.

      // always send cellState to memory but will write only
      // on valid addr (addr of 9'b0 won't write anything)
      addr = (playerWrite) playerInput : 9'b000000000;
      if (state == PLAYER1)
        cellState = 2'b11;
      else if (state == PLAYER2)
        cellState = 2'b10;
      else
        cellState = 2'b00;
    end
endmodule
