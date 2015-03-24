module gameController_tb();
  logic ph1, ph2;
  logic reset;
  logic a, b, y, yExpected;
  logic [17:0] gBoard;
  logic        gameIsDone;
  logic  [1:0] winner;
  logic [31:0] vectornum, errors;
  logic [20:0] testvectors[10000:0];

  // instantiate device under test
  gameController dut(ph1, ph2, reset);

  // generate clock to sequence tests
  always
    begin
     ph1 = 0; ph2 = 0; #1; 
     ph1 = 1; # 4; 
     ph1 = 0; # 1; 
     ph2 = 1; # 4;
    end

  // at start of test, load test vectors
  initial
    begin
      $readmemb("gameController.tv", testvectors);
      vectornum=0; errors=0;
      reset=1; #7; reset=0;
    end

  // apply test vectors on rising edge of clk
  always @(posedge ph2)
    begin
      #1; {gBoard, gameIsDone, yExpected} = testvectors[vectornum];
    end

  // check results on falling edge of clk
  always @(negedge ph2)
    if(~reset) begin // skip during reset
      if (y !== yExpected) begin // check result
        $display("Error: inputs=%b", {a, b});
        $display("outputs=%b (%b expected)", y, yExpected);
        errors = errors + 1;
    end
    vectornum = vectornum + 1;
    if(testvectors[vectornum] === 21'bx) begin
      $display("%d tests completed with %d errors", vectornum, errors);
      $finish;
    end
  end
endmodule
