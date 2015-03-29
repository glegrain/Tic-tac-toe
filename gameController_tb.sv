// Cell states constants
//typedef enum logic [1:0] {EMPTY = 2'b00, O = 2'b11, X = 2'b10} cellStateType;

// states
//typedef enum logic [2:0] {START, PLAYER1, PLAYER2, END} statetype;

module gameController_tb();
  logic         ph1, ph2;
  logic         reset;
  logic         isPlayer1Start;
  logic         playerWrite;
  logic  [3:0]  playerInput;  // cell address to play. the cell state is based on the FSM state
  logic         gameIsDone;
  ///outputs
  logic  [3:0]  addr, addrExp;
  logic  [1:0]  cellState, cellStateExp;
  logic  [2:0]  outputState, outputStateExp;
  //logic [17:0]  gBoardExpected;
  logic [31:0] vectornum, errors;
  logic [16:0] testvectors[10000:0];  



  // instantiate device under test
  gameController dut(.ph1, .ph2, .reset,
                     .isPlayer1Start,
                     .playerWrite,
                     .playerInput,
                     .gameIsDone,
                     .addr,
                     .cellState,
                     .outputState);

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
      $readmemb("gameController.tv", testvectors);
      vectornum=0; errors=0;
      reset=1; #17; reset=0;
    end

  // apply test vectors on rising edge of clk
  always @(posedge ph2)
    begin
      #1; {reset, isPlayer1Start, playerWrite, playerInput, gameIsDone, addrExp, cellStateExp, outputStateExp} = testvectors[vectornum];
    end

  // Custom input signals
  initial
    begin
      isPlayer1Start = 0;
    end

  // check results on falling edge of clk
  always @(negedge ph2)
    if(~reset) begin // skip during reset
      if ((addr !== addrExp) | (cellState !== cellStateExp) | (outputState !== outputStateExp)) begin // check result
        $display("Error: vectornum=%d", vectornum);
        $display("inputs: reset=%d isPlayer1Start=%b, gameIsDone=%b", reset, isPlayer1Start, gameIsDone);
        $display("player inputs: playerInput=%b, playerWrite=%b", playerInput, playerWrite );
        $display("outputs: addr=%b (%b expected)， outputState=%b (%b expected)， cellState=%b (%b expected)", addr, addrExp, outputState, outputStateExp, cellState, cellStateExp);
        errors = errors + 1;
      end
      vectornum = vectornum + 1;
      if(testvectors[vectornum] === 17'bx) begin
        $display("%d tests completed with %d errors", vectornum, errors);
        $finish;
      end
    end
    

endmodule
