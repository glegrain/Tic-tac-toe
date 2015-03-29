// Set delay unit to 1 ns and simulation precision to 0.1 ns (100 ps)
`timescale 1ns / 100ps

module winLogic_tb();
  logic clk, reset;
  logic [17:0]gBoard;
  logic gameIsDone, gameIsDoneExp;
  logic [1:0] winner, winnerExp;
  logic [31:0] vectornum, errors;
  logic [20:0] testvectors[1000:0];

  // instantiate device under test
  winLogic dut(.gBoard, .gameIsDone, .winner);

  // generate clock
  always
    begin
      clk=1; #5; clk=0; #5;
    end

  // at start of test, load test vectors
  // and pulse reset
  initial
    begin
      //$dumpfile("winLogic_tb.vcd"); // where to dump the results
      //$dumpvars(1, clk, reset, gBoard, gameIsDone, winner);
      $readmemb("winLogic.tv", testvectors);
      vectornum=0; errors=0;
      reset=1; #27; reset=0;
    end

  // apply test vectors on rising edge of clk
  always @(posedge clk)
    begin
      #1; {gBoard, gameIsDoneExp, winnerExp} = testvectors[vectornum];
    end

  // check results on falling edge of clk
  always @(negedge clk)
    if(~reset) begin // skip during reset
      //$display("Testing: gameIsDoneExp=%b , winnerExp=%b...", gameIsDoneExp, winnerExp);
      if ((gameIsDone !== gameIsDoneExp)|(winner !== winnerExp)) begin // check result
        $display("Error: on testvector number:%d, input=%b", vectornum, gBoard);
        $display("output done: %b, (%b expected)", gameIsDone, gameIsDoneExp);
        $display("output winner: %b, (%b expected)", winner, winnerExp);
        errors = errors + 1;
     
    end
    vectornum = vectornum + 1;
    //$display("testing we want %b, we see %b..", 21'bx, testvectors[vectornum]);
    if(testvectors[vectornum] === 21'bx) begin
      $display("%d tests completed with %d errors", vectornum, errors);
      //$dumpflush;
      $finish;
    end
  end
endmodule
