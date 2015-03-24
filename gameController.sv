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
                      input  logic [17:0] gBoard,
                      input  logic        gameIsDone,
                      input  logic  [1:0] winner);
  statetype state;

  // control FSM
  statelogic  statelog(ph1, ph2, reset, state);
  outputlogic outputlog(state);

endmodule


module statelogic(input logic ph1, ph2, reset,
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
        START:   nextstate = PLAYER1;
        PLAYER1: nextstate = PLAYER2;
        END:     nextstate = END;
        default: nextstate = START;
      endcase
    end
endmodule

module outputlogic(input statetype state);

  always_comb
    begin
      /* TODO */
    end
endmodule
