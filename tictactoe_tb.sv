// Cell states constants
// CAUSES ModelSim simulation error ??
//typedef enum logic [1:0] {EMPTY = 2'b00, O = 2'b11, X = 2'b10} cellStateType;

// states
//typedef enum logic [2:0] {START, PLAYER1, PLAYER2, END} statetype;

module gameController_tb();
  logic         ph1, ph2;
  logic         reset;
  logic         clk; // for the testvectors
  logic         isPlayer1Start;
  logic         playerWrite;
  logic  [3:0]  playerInput;  // cell address to play. the cell state is based on the FSM state
  logic [17:0]  gBoard;
  logic  [3:0]  addr;
  logic  [1:0]  cellState; 
  // Outputs and expected values
  logic         gameIsDone, gameIsDoneExp;
  logic  [1:0]  winner, winnerExp;
  logic  [2:0]  gameState, gameStateExp;
  // add testvector stuff
  logic [31:0] vectornum, errors; 
  logic [12:0] testvectors[1000:0];




  // instantiate device under test
  gameController dut(.ph1, .ph2, .reset,
                     .isPlayer1Start,
                     .playerWrite,
                     .playerInput,
                     .gBoard,
                     .gameIsDone,
                     .winner,
                     .addr,
                     .gameState,
                     .cellState);
  // updates to memory
  memArray dut2(ph1, ph2, reset, addr, cellState, gBoard);
  // checks for win logic
  winLogic dut3(gBoard, gameIsDone, winner); //ADDED HERE

  // generate clock to sequence tests
  always
    begin
     ph1 = 0; ph2 = 0; #1; 
     ph1 = 1; # 4; 
     ph1 = 0; # 1; 
     ph2 = 1; # 4;
    end
  // initialize clk for testvector checks
  always
    begin
     clk = 1; #5; 
     clk = 0; #5;
    end
  // tell the simulator to store the waveform into a file for inspection
  // and start dumping all signal to the .vcd file
  initial
    begin
      $dumpfile("tictactoe.vcd");
      $dumpvars;
    end

  initial
    begin
      isPlayer1Start = 0;
      gameIsDone = 0;
      playerWrite = 0;

      reset=1; #7; reset=0;

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
      addr = 4'b1111; #10

      // isPlayer1Start is moved 
      // to after initialization to prevent unwanted state change
      isPlayer1Start = 0; 

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
      $display("Hand test completed");
      //$finish;
    end
    // at start of test, load test vectors
  // and pulse reset
  initial
    begin
      //$dumpfile("winLogic_tb.vcd"); // where to dump the results
      //$dumpvars(1, clk, reset, gBoard, gameIsDone, winner);
      $readmemb("tictactoe.tv", testvectors);
      vectornum=0; errors=0;
      reset=1; #27; reset=0;
    end

  // apply test vectors on rising edge of clk
  always @(posedge clk)
    begin
      #1; {isPlayer1Start, playerWrite, playerInput, gameIsDoneExp, winnerExp, gameStateExp} = testvectors[vectornum];
    end

  // check results on falling edge of clk
  always @(negedge clk)
    if(~reset) begin // skip during reset
      //$display("Testing: gameIsDoneExp=%b , winnerExp=%b...", gameIsDoneExp, winnerExp);
      if ((gameIsDone !== gameIsDoneExp)|(winner !== winnerExp)|(gameState !== gameStateExp)) begin // check result
        $display("Error: on testvector number:%d, input=%b", vectornum, gBoard);
        $display("output done: %b, (%b expected)", gameIsDone, gameIsDoneExp);
        $display("output winner: %b, (%b expected)", winner, winnerExp);
        $display("output gameState: %b, (%b expected)", gameState, gameStateExp);
        errors = errors + 1;
     
    end
    vectornum = vectornum + 1;
    //$display("testing we want %b, we see %b..", 21'bx, testvectors[vectornum]);
    if(testvectors[vectornum] === 12'bx) begin
      $display("%d tests completed with %d errors", vectornum, errors);
      //$dumpflush;
      $finish;
    end
  end
endmodule
