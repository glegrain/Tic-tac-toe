// Set delay unit to 1 ns and simulation precision to 0.1 ns (100 ps)
`timescale 1ns / 100ps

module addr2writePos_tb();
  logic [8:0] writePos, writePosExpected;
  logic [3:0] addr;
  logic ph1, ph2, reset;
  logic [31:0] vectornum, errors;
  logic [12:0] testvectors[10:0];

  // instantiate device under test
  addr2writePos dut(.writePos, .addr);

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
      $readmemb("addr2writePos.tv", testvectors);
      vectornum=0; errors=0;
      reset=1; #17; reset=0;
    end

  // apply test vectors on rising edge of clk
  always @(posedge ph2)
    begin
      #1; {addr, writePosExpected} = testvectors[vectornum];
    end

  // check results on falling edge of clk
  always @(negedge ph2)
    if(~reset) begin // skip during reset
      vectornum = vectornum + 1;
      if (writePos !== writePosExpected) begin // check result
        $display("Error: inputs=%b", addr);
        $display("outputs=%b (%b expected)", writePos, writePosExpected);
        errors = errors + 1;
      end
      if(testvectors[vectornum] === 13'bx) begin
        $display("%d tests completed with %d errors", vectornum, errors);
        $finish;
      end
    end
endmodule
