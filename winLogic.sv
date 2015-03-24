// Memory array block for tic-tac-toe project
// Written by Katherine Yang and Guillaume Legrain
// Written in: March 21, 2015
// Last edited: March 22, 2015
// player1:11, player2:10, tie:01, noWin:00
// cellState: empty:00, player1:11, player2:10
/////////////////////////////////////////////////////
module winLogic(input  logic[17:0] gBoard,
                output logic gameIsDone,
                output logic[1:0] winner); // player1: 11, player2: 10, tie: 01, noWin: 00
logic col0IsFull, col1IsFull, col2IsFull;
logic col0IsSame, col1IsSame, col2IsSame;
logic row0IsFull, row1IsFull, row2IsFull;
logic row0IsSame, row1IsSame, row2IsSame;
logic diag0IsFull, diag1IsFull;
logic diag0IsSame, diag1IsSame;
logic gameIsTie, thereIsAWin;

// each cell is represented by two bits in gBoard
// empty:   00
// player1: 11
// player2: 10
  always_comb begin
    // First check that the column is filled 
    // and then check that they are all the same
    col0IsFull = (gBoard[0] & gBoard[6] & gBoard[12]);
    col0IsSame = ~((gBoard[1] ^ gBoard[7]) | (gBoard[13] ^ gBoard[7]));
    col1IsFull = gBoard[2] & gBoard[8] & gBoard[14];
    col1IsSame = ~((gBoard[3] ^ gBoard[9]) | (gBoard[15] ^ gBoard[9]));
    col2IsFull = gBoard[4] & gBoard[10] & gBoard[16];
    col2IsSame = ~((gBoard[5] ^ gBoard[11]) | (gBoard[17] ^ gBoard[11]));

    row0IsFull = gBoard[0] & gBoard[2] & gBoard[4];
    row0IsSame = ~((gBoard[1] ^ gBoard[3]) | (gBoard[5] ^ gBoard[3]));
    row1IsFull = gBoard[6] & gBoard[8] & gBoard[10];
    row1IsSame =  ~((gBoard[7] ^ gBoard[9]) | (gBoard[11] ^ gBoard[9]));
    row2IsFull = gBoard[12] & gBoard[14] & gBoard[16];
    row2IsSame =  ~((gBoard[13] ^ gBoard[15]) | (gBoard[17] ^ gBoard[15]));

    diag0IsFull = gBoard[0] & gBoard[8] & gBoard[16];
    diag0IsSame = ~((gBoard[1] ^ gBoard[9]) | (gBoard[17] ^ gBoard[9]));
    diag1IsFull = gBoard[4] & gBoard[8] & gBoard[12];
    diag1IsSame = ~((gBoard[5] ^ gBoard[9]) | (gBoard[13] ^ gBoard[9]));

    // If all columns are filled, there is no more free space.
    gameIsTie = col0IsFull & col1IsFull & col2IsFull;
    
    // Check to see if somebody made a line
    thereIsAWin = (col0IsFull & col0IsSame)| (col1IsFull & col1IsSame) | (col2IsFull & col2IsSame) |
                  (row0IsFull & row0IsSame)| (row1IsFull & row1IsSame) | (row2IsFull & row2IsSame) |
                  (diag0IsFull & diag0IsSame) | (diag1IsFull & diag1IsSame);

    // Game is done if a player wins or the board is full.
    gameIsDone = thereIsAWin | gameIsTie;

    // winner logic
    if      (col0IsFull & col0IsSame) winner <= {gBoard[0], gBoard[1]};
    else if (col1IsFull & col1IsSame) winner <= {gBoard[2], gBoard[3]};
    else if (col2IsFull & col2IsSame) winner <= {gBoard[4], gBoard[5]};
    else if (col0IsFull & col0IsSame) winner <= {gBoard[0], gBoard[1]};
    else if (row0IsFull & row0IsSame) winner <= {gBoard[0], gBoard[1]};
    else if (row1IsFull & row1IsSame) winner <= {gBoard[6], gBoard[7]};
    else if (row2IsFull & row2IsSame) winner <= {gBoard[12], gBoard[13]};
    else if (diag0IsFull & diag0IsSame) winner <= {gBoard[0], gBoard[1]};
    else if (diag1IsFull & diag1IsSame) winner <= {gBoard[4], gBoard[5]};
    else if (gameIsTie) winner <= 2'b01;
    else winner <= 2'b00;

  end
endmodule
