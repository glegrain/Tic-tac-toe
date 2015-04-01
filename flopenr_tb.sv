// Set delay unit to 1 ns and simulation precision to 0.1 ns (100 ps)
`timescale 1ns / 100ps

module flopenr_tb();
  logic ph1, ph2;
  logic reset;
  logic d, q, en, qExpected;
  logic [31:0] vectornum, errors;
  logic [23:0] testvectors[10000:0];

  // instantiate device under test
  memArray dut(.ph1, .ph2, .reset, .addr, .cellState, .gBoard);

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
      $readmemb("flopenr.tv", testvectors);
      vectornum=0; errors=0;
      reset=1; #17; reset=0;
    end

  // apply test vectors on rising edge of clk
  always @(posedge ph2)
    begin
      #1; {d, en, qExpected} = testvectors[vectornum];
    end

  // check results on falling edge of clk
  always @(negedge ph2)
    if(~reset) begin // skip during reset
      if (gBoard !== gBoardExpected) begin // check result
        $display("Error: inputs=%b", {d, en});
        $display("outputs=%b (%b expected)", q, qExpected);
        errors = errors + 1;
      end
      vectornum = vectornum + 1;
      if(testvectors[vectornum] === 24'bx) begin
        $display("%d tests completed with %d errors", vectornum, errors);
        $finish;
      end
    end
endmodule
