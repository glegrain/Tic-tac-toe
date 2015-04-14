// Set delay unit to 1 ns and simulation precision to 0.1 ns (100 ps)
`timescale 1ns / 100ps

module chip_tb();
  logic        ph1, ph2, reset;
  logic        isPlayer1Start;
  logic        playerWrite;
  logic  [3:0] playerInput;
  logic [17:0] gBoard;
  logic  [1:0] gameState;
  logic  [1:0] winner;

  logic [17:0] gBoardExpected;
  logic [31:0] vectornum, errors;
  logic [23:0] testvectors[10000:0]; 

  
  // instantiate device under test
  chip dut(.ph1, .ph2, .reset,
          .isPlayer1Start,
          .playerWrite,
          .playerInput,
          .gBoard,
          .gameState,
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
      $dumpfile("chip.vcd");
      $dumpvars;
    end

  // at start of test, load test vectors
  initial
    begin
      $readmemb("chip.tv", testvectors);
      vectornum=0; errors=0;
      reset=1; #18; reset=0;
    end

  // apply test vectors on rising edge of clk
  always @(posedge ph2)
    begin
      #1; {playerInput, playerWrite, isPlayer1Start, gBoardExpected} = testvectors[vectornum];
    end

  // Custom input signals
  initial
    begin
    	isPlayer1Start = 0;
    end

  // check results on falling edge of clk
  always @(negedge ph2)
    if(~reset) begin // skip during reset
      if ((winner == 2'b01) | (winner == 2'b11)| (winner == 2'b10)) begin
      	$display("Game is done: player 2'b%b wins",winner);
      	$finish;
      end
      vectornum = vectornum + 1;
      if(testvectors[vectornum] === 24'bx) begin
        $display("%d tests completed with %d errors", vectornum, errors);
        $finish;
      end
      if (gBoard !== gBoardExpected) begin // check result
        $display("Error: vectornum=%d", vectornum);
        $display("inputs: playerInput=%d playerWrite=%b", playerInput, playerWrite);
        $display("outputs: gameBoard=%b (%b expected)", gBoard, gBoardExpected);
        errors = errors + 1;
      end
    end
    
    

endmodule
