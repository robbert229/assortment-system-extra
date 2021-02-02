use<center-drill-bits-lib.scad>;

// bits contains the actual dimensions of the bits. The largest bit should be the first
// bit in the array. These dimensions are in inches which is in contrast to every other 
// measurement contained in this file.
//
// bits[x][0] is the name of the bit.
// bits[x][1] is the body diameter of the bit.
// bits[x][2] is the drill diameter of the bit.
// bits[x][3] is the length of cutting part of the drill bit.
// bits[x][4] is the overall length of the drill bit.
bits = [
    ["5", 7/16, 3/16, 3/16, 2+3/4],
    ["4", 5/16, 1/8, 1/8, 2+1/8],
    ["3", 1/4, 7/64, 7/64, 2],
    ["2", 3/16, 5/64, 5/64, 1 + 7/8],
    ["1", 1/8, 3/64, 3/64, 1 + 1/4]
];

bitsTop(bits);

