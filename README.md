# Tic-tac-toe

## Introduction
This project is a 3x3 game of Tic-tac-toe built on a 0.6 µm process on a 1.5 × 1.5 mm 40-pin MOSIS
“TinyChip”. The goal of this project was to create a Tic-Tac-Toe board which is able to monitor the state
of a game and return the win/loose/draw state of the game after each player’s move. Specifically, for each
player’s turn, the game records the player’s inputs and at the end of the game determines if the game is done
and who the winner is. The game allows two players to play against each other. Each of the nine spaces can
be “X”, “O” or blank.

![Chip layout](https://raw.githubusercontent.com/glegrain/Tic-tac-toe/master/report/chip-layout.png)

## Architecture
The architecture consists of 3 main modules, one of which was synthesized, and two other were hand laid.

### Memory Array
The memory array remembers the status of the tic-tac-toe game board through sequential logic. It consists
of enable reset flip-flops and a 4 to 8 bit decoder.

## Check Win Status
The win status module is a combinational logic block that checks the win state of the tic-tac-toe board.
There are two custom made leaf cells in this module. This cell is very repetitive and can be organised as a
datapath.

## Game Controller
The game controller module is a finite state machine which switches between players, player input and game
board. This module will be synthesized as the structure is more irregular and harder to be hand laid.


Check the project's final report [report/main.pdf](https://github.com/glegrain/Tic-tac-toe/raw/master/report/main.pdf) for more information.
