// Set delay unit to 1 ns and simulation precision to 0.1 ns (100 ps)
`timescale 1ns / 100ps

module isSame_tb();
  logic clk;
  logic a,b,c;
  logic y, yExpected;
  logic [31:0] vectornum, errors;
  logic [3:0] testvectors[1000:0];

  // instantiate device under test
  isSame dut(.a, .b, .c, .y);

  // generate clock
  always
    begin
      clk=1; #5; clk=0; #5;
    end

  // at start of test, load test vectors
  // and pulse reset
  initial
    begin
      $readmemb("isSame.tv", testvectors);
      vectornum=0; errors=0;
    end

  // apply test vectors on rising edge of clk
  always @(posedge clk)
    begin
      #1; {a, b, c, yExpected} = testvectors[vectornum];
    end

  // check results on falling edge of clk
  always @(negedge clk) begin
    if (y !== yExpected) begin // check result
      $display("Error: inputs=%b", {a, b, c});
      $display("outputs=%b (%b expected)", y, yExpected);
      errors = errors + 1; 
    end
    vectornum = vectornum + 1;
    if(testvectors[vectornum] === 4'bx) begin
      $display("%d tests completed with %d errors", vectornum, errors);
      //$dumpflush;
      $finish;
    end
  end
endmodule