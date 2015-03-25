// Game Controller FSM block for tic-tac-toe project
// Written by Katherine Yang and Guillaume Legrain
// Written in: March 23, 2015
// Last edited: March 25, 2015
// player1:11, player2:10, tie:01, noWin:00
// cellState: empty:00, player1:11, player2:10
/////////////////////////////////////////////////////

// Cell states constants
// 0 is the human player, X is the AI
typedef enum logic [1:0] {EMPTY = 2'b00, O = 2'b11, X = 2'b10} cellStateType;

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
                      output cellStateType cellState);
  statetype state;

  // control FSM
  statelogic  statelog(.ph1, .ph2, .reset,
                       .isPlayer1Start, .gameIsDone, .playerWrite, .gBoard, .state);
  outputlogic outputlog(.state, .playerWrite, .playerInput, .addr, .cellState);

endmodule


module statelogic(input  logic     ph1, ph2, reset,
                  input  logic     isPlayer1Start,
                  input  logic     gameIsDone,
                  input  logic     playerWrite,
                  input  logic [17:0] gBoard,    
                  output statetype state);

  statetype nextstate;
  logic [2:0] ns, state_logic;

  // resetable state register with initial value of START
  mux2 #(3) resetmux(nextstate, START, reset, ns);
  flop #(3) stateregister(ph1, ph2, ns, state_logic);
  assign state = statetype'(state_logic);

  // next state logic
  always_comb
    begin
      case (state)
        START:   if (gBoard == 18'b0) // Wait for gBoard to be initialized
                  nextstate = (isPlayer1Start) ? PLAYER1 : PLAYER2;
                 else
                  nextstate = START;
        PLAYER1: if (gameIsDone) nextstate = END;
                 else if (playerWrite) nextstate = PLAYER2;
                 else nextstate = PLAYER1;
        PLAYER2: if (gameIsDone) nextstate = END;
                 else if (~playerWrite) nextstate = PLAYER1;
                 else nextstate = PLAYER2;
        END:     nextstate = END;
        default: nextstate = START;
      endcase
    end
endmodule

module outputlogic(input  statetype   state,
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
      addr = (playerWrite) ? playerInput : 4'b1111;
      if (state == PLAYER1)
        cellState = O;
      else if (state == PLAYER2)
        cellState = X;
      else
        cellState = EMPTY;
    end
endmodule
