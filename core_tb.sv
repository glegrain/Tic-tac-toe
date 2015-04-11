// Set delay unit to 1 ns and simulation precision to 0.1 ns (100 ps)
`timescale 1ns / 100ps

module core_tb();
  logic        ph1_core, ph2_core, reset_core;
  logic        isPlayer1Start_core;
  logic        playerWrite_core;
  logic  [3:0] playerInput_core;
  logic [17:0] gBoard_core;
  logic  [1:0] gameState_core;
  logic  [1:0] winner_core;

  logic [17:0] gBoardExpected;
  logic [31:0] vectornum, errors;
  logic [23:0] testvectors[10000:0]; 

  
  // instantiate device under test
  core dut(.ph1_core, .ph2_core, .reset_core,
          .isPlayer1Start_core,
          .playerWrite_core,
          .playerInput_core,
          .gBoard_core,
          .gameState_core,
          .winner_core);

  // generate clock to sequence tests
  always
    begin
     ph1_core = 0; ph2_core = 0; #1; 
     ph1_core = 1; # 4; 
     ph1_core = 0; # 1; 
     ph2_core = 1; # 4;
    end

   // tell the simulator to store the waveform into a file for inspection
  // and start dumping all signal to the .vcd file
  initial
    begin
      $dumpfile("core.vcd");
      $dumpvars;
    end

  // at start of test, load test vectors
  initial
    begin
      $readmemb("core.tv", testvectors);
      vectornum=0; errors=0;
      reset_core=1; #17; reset_core=0;
    end

  // apply test vectors on rising edge of clk
  always @(posedge ph2_core)
    begin
      #1; {playerInput_core, playerWrite_core, isPlayer1Start_core, gBoardExpected} = testvectors[vectornum];
    end

  // Custom input signals
  initial
    begin
    	isPlayer1Start_core = 0;
    end

  // check results on falling edge of clk
  always @(negedge ph2_core)
    if(~reset_core) begin // skip during reset_core
      if ((winner_core == 2'b01) | (winner_core == 2'b11)| (winner_core == 2'b10)) begin
      	$display("Game is done: player 2'b%b wins",winner_core);
      	$finish;
      end
      vectornum = vectornum + 1;
      if(testvectors[vectornum] === 24'bx) begin
        $display("%d tests completed with %d errors", vectornum, errors);
        $finish;
      end
      if (gBoard_core !== gBoardExpected) begin // check result
        $display("Error: vectornum=%d", vectornum);
        $display("inputs: playerInput_core=%b playerWrite_core=%b", playerInput_core, playerWrite_core);
        $display("outputs: gameBoard=%b (%b expected)", gBoard_core, gBoardExpected);
        errors = errors + 1;
      end
    end
    
    

endmodule