// Game Controller top module for tic-tac-toe project
// Written by Katherine Yang and Guillaume Legrain
// Written in: March 25, 2015
// player1:11, player2:10, tie:01, noWin:00
// cellState: empty:00, player1:11, player2:10
/////////////////////////////////////////////////////
module top(input  logic        ph1, ph2, reset,
           input  logic        isPlayer1Start,
           input  logic        playerWrite,
           input  logic  [3:0] playerInput,
           output logic [17:0] gBoard,
           output logic  [2:0] gameState,
           output logic        gameIsDone,
           output logic  [1:0] winner);
  
  logic  [3:0] addr;
  logic  [1:0] cellState;
  
  gameController gameControllerFSM(.ph1, .ph2, .reset,
                                   .isPlayer1Start,
                                   .playerWrite,
                                   .playerInput,
                                   .gameIsDone,
                                   .addr,
                                   .cellState,
                                   .gameState);

  memArray gameBoard(.ph1, .ph2, .reset, .addr, .cellState, .gBoard);

  winLogic winLogic1(.gBoard, .gameIsDone, .winner);

 endmodule