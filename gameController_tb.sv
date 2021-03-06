// Cell states constants
//typedef enum logic [1:0] {EMPTY = 2'b00, O = 2'b11, X = 2'b10} cellStateType;

// states
//typedef enum logic [2:0] {START, PLAYER1, PLAYER2, END} statetype;

// Set delay unit to 1 ns and simulation precision to 0.1 ns (100 ps)
`timescale 1ns / 100ps

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
  logic  [1:0]  gameState, gameStateExp;
  logic [31:0] vectornum, errors;
  logic [16:0] testvectors[1000:0];
  logic startTest;



  // instantiate device under test
  gameController dut(.ph1, .ph2, .reset,
                     .isPlayer1Start,
                     .playerWrite,
                     .playerInput,
                     .gameIsDone,
                     .addr,
                     .cellState,
                     .gameState);

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
      startTest=0; 
    end

  // apply test vectors on rising edge of clk
  always @(posedge ph2)
    begin
      #1; {reset, isPlayer1Start, playerWrite, playerInput, gameIsDone, addrExp, cellStateExp, gameStateExp} = testvectors[vectornum];
    end
  // check results on falling edge of clk
  always @(negedge ph2) begin
    startTest = ((testvectors[vectornum] === 17'bx)) ? 0 : 1;
    //$display("what's the input? %b, %b", testvectors[vectornum], startTest);
    if((~reset)|(startTest)) begin // skip during reset
      if ((addr !== addrExp) | (cellState !== cellStateExp) | (gameState !== gameStateExp)) begin // check result
        $display("Error: vectornum=%d", vectornum);
        $display("inputs: reset=%d isPlayer1Start=%b, gameIsDone=%b", reset, isPlayer1Start, gameIsDone);
        $display("player inputs: playerInput=%b, playerWrite=%b", playerInput, playerWrite );
        $display("outputs: addr=%b (%b expected), gameState=%b (%b expected), cellState=%b (%b expected)", addr, addrExp, gameState, gameStateExp, cellState, cellStateExp);
        
        errors = errors + 1;
      end
      vectornum = vectornum + 1;
      if(testvectors[vectornum][0] === 1'bx) begin
        $display("%d tests completed with %d errors", vectornum, errors);
        $finish;
      end
    end
  end
endmodule
