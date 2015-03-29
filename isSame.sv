// Custom logic used by the winLogic for tic-tac-toe project
// Written by Katherine Yang and Guillaume Legrain
// Written in: March 28, 2015
/////////////////////////////////////////////////////
module isSame(input  logic a,b,c,
              output logic y);

always_comb
  y = ~((a ^ b) | (c ^ b));

endmodule