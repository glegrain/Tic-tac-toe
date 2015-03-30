// Game Controller FSM block for tic-tac-toe project
// Written by Katherine Yang and Guillaume Legrain
// Written in: March 23, 2015
// Last edited: March 25, 2015
// player1:11, player2:10, tie:01, noWin:00
// cellState: empty:00, player1:11, player2:10
/////////////////////////////////////////////////////

// Cell states constants
// 0 is the human player, X is the AI
typedef enum logic [1:0] {EMPTY = 2'b00, WRITE_O = 2'b11, WRITE_X = 2'b10} cellStateType;

// states
typedef enum logic [1:0] {START, PLAYER1, PLAYER2, END} statetype;


module gameController(input  logic        ph1, ph2, reset, 
                      input  logic        isPlayer1Start,
                      input  logic        playerWrite,
                      input  logic  [3:0] playerInput,  // cell address to play. the cell state is based on the FSM state
                      input  logic        gameIsDone,
                      output logic  [3:0] addr, // outputs the user input, otherwise output 4'b1111
                      output cellStateType cellState, // outputs the user number 
                      output statetype gameState); //outputs state type
  statetype state;
  assign gameState = state;
  // control FSM
  statelogic  statelog(.ph1, .ph2, .reset,
                       .isPlayer1Start, .gameIsDone, .playerWrite, .state);
  outputlogic outputlog(.state, .reset, .playerWrite, .playerInput, .addr, .cellState);

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
      case (state) // Note: The game controller stays at the same state for one cycle after reset is released?
        START:   nextstate = (isPlayer1Start) ? PLAYER1 : PLAYER2;
        PLAYER1: if (gameIsDone & (~reset)) nextstate = END;
                 else if (~reset) nextstate = (playerWrite) ? PLAYER2 : PLAYER1;
                 else nextstate = START;
        PLAYER2: if (gameIsDone & (~reset)) nextstate = END;
                 else if (~reset) nextstate = (playerWrite) ? PLAYER1 : PLAYER2;
                 else nextstate = START;
        END:     nextstate = (reset) ? START : END;
        default: nextstate = START;
      endcase
    end
endmodule

///////////////////////////////////////////////////////////////////////
module outputlogic(input  statetype   state,
		   input logic        reset,
                   input  logic       playerWrite,
                   input  logic [3:0] playerInput,
                   output logic [3:0] addr,
                   output cellStateType cellState);

  always_comb
    begin
      // NOTE: Assuming playerWrite is enable bit active on one clock cycle.
      //       A sperate module can be used to detect the playerWrite rising edge.

      // always send cellState to memory but will write only
      // on valid addr (addr of 4'b1111 won't write anything)
      addr = (playerWrite & (~reset)) ? playerInput : 4'b1111;
      if (state == PLAYER1)
        cellState = WRITE_O;
      else if (state == PLAYER2)
        cellState = WRITE_X;
      else
        cellState = EMPTY;
    end
endmodule
