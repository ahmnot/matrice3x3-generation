This is a p5.js program that generates blocks, with a UI.

Definition: a “block” is a 3x3 matrix made up of 0 or 1.

To visualize these squares, we say 0=small black square, and 1=small white square.

The objective of this code is to generate the completeness of these blocks and classify them.

Block format (example): [[1,1,1],[1,1,0],[0,0,0]].

We have some filters on blocks. A "continuous" or "connected" block is a block in which all "1" are connected, but not in diagonal.
A "broken" block is a block which is not continuous.
Then there is the pattern filters. You can try to check the pattern filters and guess for yourself what the patterns are.