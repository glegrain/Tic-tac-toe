// Cell states constants
// CAUSES ModelSim simulation error ??
//typedef enum logic [1:0] {EMPTY = 2'b00, O = 2'b11, X = 2'b10} cellStateType;

// states
//typedef enum logic [2:0] {START, PLAYER1, PLAYER2, END} statetype;

module gameController_tb();
  logic         ph1, ph2;
  logic         reset;
  logic         isPlayer1Start;
  logic         playerWrite;
  logic  [3:0]  playerInput;  // cell address to play. the cell state is based on the FSM state
  logic [17:0]  gBoard;
  logic         gameIsDone;
  logic  [1:0]  winner;
  logic  [3:0]  addr;
  logic  [1:0]  cellState;  



  // instantiate device under test
  gameController dut(.ph1, .ph2, .reset,
                     .isPlayer1Start,
                     .playerWrite,
                     .playerInput,
                     .gBoard,
                     .gameIsDone,
                     .winner,
                     .addr,
                     .cellState);

  memArray dut2(ph1, ph2, reset, addr, cellState, gBoard);
  //winLogic winLogic1(.gBoard, .gameIsDone, .winner);

  // generate clock to sequence tests
  always
    begin
     ph1 = 0; ph2 = 0; #1; 
     ph1 = 1; # 4; 
     ph1 = 0; # 1; 
     ph2 = 1; # 4;
    end

  // tell the simulator to store the waveform into a file for inspection
  // and start dumping all signal to the .vcd file
  initial
    begin
      $dumpfile("gameController.vcd");
      $dumpvars;
    end

  initial
    begin
      isPlayer1Start = 1;
      gameIsDone = 0;
      playerWrite = 0;
      gBoard = {18{1'b0}}; // FIXME: hack until reset on memArray is working
      reset=1; #7; reset=0;
      // SHOULD change state to PLAYER1
      if (addr !== 4'b1111) begin
        $display("Error: addr should be 4'b1111 instead of %b",addr);
      end
      # 50
      playerInput = 4'b0000;  // upperleft cell (cell 0)
      # 40
      playerWrite = 1;
      # 10
      // SHOULD change state to PLAYER2
      playerWrite = 0;
      playerInput = 4'b0100;    // Testbench AI chooses center cell
      # 40
      playerWrite = 1;
      # 10
      // SHOULD change back to PLAYER1
      playerWrite = 0;
    end

  initial
    begin
      # 500
      $display("Test completed");
      //$finish;
    end

endmodule
