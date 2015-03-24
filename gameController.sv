// Game Controller FSM block for tic-tac-toe project
// Written by Katherine Yang and Guillaume Legrain
// Written in: March 23, 2015
// Last edited: March 23, 2015
// player1:11, player2:10, tie:01, noWin:00
// cellState: empty:00, player1:11, player2:10
/////////////////////////////////////////////////////

// states
typedef enum logic [2:0] {START, PLAYER1, PLAYER2, END} statetype;


module gameController(input  logic        ph1, ph2, reset,
                      input  logic        isPlayer1Start,
                      input  logic        playerWrite,
                      input  logic  [3:0] playerInput,  // cell address to play. the cell state is based on the FSM state
                      input  logic [17:0] gBoard,
                      input  logic        gameIsDone,
                      input  logic  [1:0] winner,
                      output logic  [3:0] addr,
                      output logic  [1:0] cellState);
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
      addr = (playerWrite) playerInput : prevAddr;
      if (state == PLAYER1)
        cellState = 2'b11;
      else if (state == PLAYER2)
        cellState = 2'b10;
      else
        cellState = 2'b00;
    end
endmodule
