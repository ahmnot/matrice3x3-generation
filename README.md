This is a p5.js program that generates blocks.

Definition: a “block” is a 3x3 matrix made up of 0 or 1.

To visualize these blocks, we say 0=small black square, and 1=small white square.

The objective of this code is to generate the completeness of these blocks and classify them.

We have some filters on blocks. A "continuous" or "connected" block is a block in which all "1" are connected, but not in diagonal.
A "broken" block is a block which is not continuous.
Then there is the pattern filters.
Then you can export all the blocks you see in a zip file, or click on a block to export it.

[![Demo matrice3x3-generation-p5](https://github.com/ahmnot/matrice3x3-generation/blob/main/example%20video.gif)
](https://www.youtube.com/watch?v=Y9bNTE-mXM0)


There is also the Processing version, in BlocGenerator.pde.
