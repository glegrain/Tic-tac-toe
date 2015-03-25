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
  logic [17:0]  gBoardExpected;
  logic [31:0] vectornum, errors;
  logic [17:0] testvectors[10000:0];  



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

  // at start of test, load test vectors
  initial
    begin
      $readmemb("gameBoard.tv", testvectors);
      vectornum=0; errors=0;
      reset=1; #7; reset=0;
    end

  // apply test vectors on rising edge of clk
  always @(posedge ph2)
    begin
      {gBoardExpected} = testvectors[vectornum];
    end

  initial
    begin
      isPlayer1Start = 0;
      gameIsDone = 0;
      playerWrite = 0;

      // FIXME: hack until reset on memArray is working
      cellState = 2'b00;
      addr = 4'b0000; #10
      addr = 4'b0001; #10
      addr = 4'b0010; #10
      addr = 4'b0011; #10
      addr = 4'b0100; #10
      addr = 4'b0101; #10
      addr = 4'b0110; #10
      addr = 4'b0111; #10
      addr = 4'b1000; #10
      addr = 4'b1111; #20

      if (gBoard !== gBoardExpected) begin
        $display("Error: gBoard=%b (%b expected)", gBoard, gBoardExpected);
      end
      vectornum = vectornum + 1;

      // isPlayer1Start is moved 
      // to after initialization to prevent unwanted state change
      isPlayer1Start = 1; 

      // SHOULD change state to PLAYER1
      if (addr !== 4'b1111) begin
        $display("Error: addr should be 4'b1111 instead of %b",addr);
      end
      # 50
      playerInput = 4'b0000;  // upperleft cell (cell 0)
      # 40
      playerWrite = 1;
      # 10
      playerWrite = 0;
      // SHOULD change state to PLAYER2
      if (gBoard !== gBoardExpected) begin
        $display("1");
        $display("Error: gBoard=%b (%b expected)", gBoard, gBoardExpected);
      end
      vectornum = vectornum + 1;

      playerInput = 4'b0001;
      # 40
      playerWrite = 1;
      # 10
      playerWrite = 0;
      // SHOULD change back to PLAYER1
      if (gBoard !== gBoardExpected) begin
        $display("2");
        $display("Error: gBoard=%b (%b expected)", gBoard, gBoardExpected);
      end
      vectornum = vectornum + 1;

      playerInput = 4'b0010;
      # 40
      playerWrite = 1;
      # 10
      playerWrite = 0;
      // SHOULD change back to PLAYER2
      if (gBoard !== gBoardExpected) begin
        $display("3");
        $display("Error: gBoard=%b (%b expected)", gBoard, gBoardExpected);
      end
      vectornum = vectornum + 1;

      playerInput = 4'b0011;
      # 40
      playerWrite = 1;
      # 10
      playerWrite = 0;
      // SHOULD change back to PLAYER1
      if (gBoard !== gBoardExpected) begin
        $display("4");
        $display("Error: gBoard=%b (%b expected)", gBoard, gBoardExpected);
      end
      playerInput = 4'b0100;
      # 40
      playerWrite = 1;
      # 10
      playerWrite = 0;
      // SHOULD change back to PLAYER2
      if (gBoard !== gBoardExpected) begin
        $display("5");
        $display("Error: gBoard=%b (%b expected)", gBoard, gBoardExpected);
      end
      vectornum = vectornum + 1;

      playerInput = 4'b0101;
      # 40
      playerWrite = 1;
      # 10
      playerWrite = 0;
       // SHOULD change back to PLAYER1
      if (gBoard !== gBoardExpected) begin
        $display("6");
        $display("Error: gBoard=%b (%b expected)", gBoard, gBoardExpected);
      end
      vectornum = vectornum + 1;

      playerInput = 4'b0110;
      # 40
      playerWrite = 1;
      # 10
      playerWrite = 0;
       // SHOULD change back to PLAYER1
      if (gBoard !== gBoardExpected) begin
        $display("7");
        $display("Error: gBoard=%b (%b expected)", gBoard, gBoardExpected);
      end
      vectornum = vectornum + 1;

      playerInput = 4'b0111;
      # 40
      playerWrite = 1;
      # 10
      playerWrite = 0;
       // SHOULD change back to PLAYER1
      if (gBoard !== gBoardExpected) begin
        $display("8");
        $display("Error: gBoard=%b (%b expected)", gBoard, gBoardExpected);
      end
      vectornum = vectornum + 1;

      playerInput = 4'b1000;
      # 40
      playerWrite = 1;
      # 10
      playerWrite = 0;
       // SHOULD change back to PLAYER1
      if (gBoard !== gBoardExpected) begin
        $display("9");
        $display("Error: gBoard=%b (%b expected)", gBoard, gBoardExpected);
      end
      vectornum = vectornum + 1;
    end



  initial
    begin
      # 500
      $display("Test completed");
      //$finish;
    end

endmodule
