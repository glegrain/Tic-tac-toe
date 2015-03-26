module top_tb();
  logic        ph1, ph2, reset;
  logic        isPlayer1Start;
  logic        playerWrite;
  logic  [3:0] playerInput;
  logic [17:0] gBoard;
  logic  [2:0] outputState;
  logic        gameIsDone;
  logic  [1:0] winner;

  logic [17:0] gBoardExpected;
  logic [31:0] vectornum, errors;
  logic [22:0] testvectors[10000:0]; 

  
  // instantiate device under test
  top dut(.ph1, .ph2, .reset,
          .isPlayer1Start,
          .playerWrite,
          .playerInput,
          .gBoard,
          .outputState,
          .gameIsDone,
          .winner);

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
      $dumpfile("top.vcd");
      $dumpvars;
    end

  // at start of test, load test vectors
  initial
    begin
      $readmemb("top.tv", testvectors);
      vectornum=0; errors=0;
      reset=1; #17; reset=0;
    end

  // apply test vectors on rising edge of clk
  always @(posedge ph2)
    begin
      #1; {playerInput, playerWrite, gBoardExpected} = testvectors[vectornum];
    end

  // Custom input signals
  initial
    begin
    	isPlayer1Start = 0;
    end

  // check results on falling edge of clk
  always @(negedge ph2)
    if(~reset) begin // skip during reset
      if (gBoard !== gBoardExpected) begin // check result
        $display("Error: vectornum=%d", vectornum);
        $display("inputs: playerInput=%d playerWrite=%b", playerInput, playerWrite);
        $display("outputs: gameBoard=%b (%b expected)", gBoard, gBoardExpected);
        errors = errors + 1;
      end
      if (gameIsDone) begin
      	$display("Game is done: player 2'b%b wins",winner);
      	$finish;
      end
      vectornum = vectornum + 1;
      if(testvectors[vectornum] === 23'bx) begin
        $display("%d tests completed with %d errors", vectornum, errors);
        $finish;
      end
    end
    
    

endmodule