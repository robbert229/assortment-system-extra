// All the units are in mm.

// cellSize is the width of a single organizer 1x1 container.
cellSize = 55;

// cylinderFn is the number of faces that a cylinder will have. Its mainly 
// a "quality" parameter.
cylinderFn = 32;

// betweenWidth is the distance between two of the bits
betweenWidth = 7;

// bitLengthMargin is a tolerance margin that is added to the length of a bit. This 
// is used to ensure that the slots for a bit are not two short.
bitLengthMargin = 0.2;

// bitDiameterMargin is a tolerance margin that is added to the diameter of a bit. This 
// is used to ensure that the slots for a bit are not two narrow.
bitDiameterMargin = 0.2;

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
    ["8", 3/4, 5/16, 5/16, 3 + 1/2],
    ["7", 5/8, 1/4, 1/3, 3 + 1/4],
    ["6", 1/2, 7/32, 7/32, 3],
    ["5", 7/16, 3/16, 3/16, 2+3/4],
    ["4", 5/16, 1/8, 1/8, 2+1/8],
    ["3", 1/4, 7/64, 7/64, 2],
    ["2", 3/16, 5/64, 5/64, 1 + 7/8],
    ["1", 1/8, 3/64, 3/64, 1 + 1/4],
    ["0", 1/8, 1/32, 0.038, 1 + 1/8],
    ["00", 1/8, 0.025, 0.030, 1 + 1/8]
];

module bitsTop(bits) {
    // inchToMMMultiplier
    inchToMMMultiplier = 25.4;

    function getBitLabel(idx) = str("#", bits[idx][0]);

    function getBitDiameter(idx) = (bits[idx][1] * inchToMMMultiplier) + bitDiameterMargin;

    function getBitDrillDiameter(idx) = (bits[idx][2] * inchToMMMultiplier) + bitDiameterMargin;

    function getBitLength(idx) = (bits[idx][3] * inchToMMMultiplier) + bitLengthMargin;

    function getBitOverallLength(idx) = (bits[idx][4] * inchToMMMultiplier) + (bitLengthMargin*2);
    
    // truncMultiple is a constant that is multiplied againt cellSize to ensure that can use
    // ceil to get the number of times that cellSize that the prism needs to be.
    truncMultiple = 100000;

    internalWidth = xOffset(len(bits)-1) + getBitDiameter(len(bits)-1)/2;
    minimumWidthCells = ceil((internalWidth*truncMultiple) / (cellSize*truncMultiple));

    internalDepth = getBitOverallLength(0);
    minimumDepthCells = ceil((internalDepth*truncMultiple) / (cellSize * truncMultiple));

    internalHeight = getBitDiameter(0) / 2;

    prismHeight = internalHeight;
    prismWidth = minimumWidthCells * cellSize;
    prismDepth = minimumDepthCells * cellSize;

    bitsXOffset = (prismWidth - internalWidth) / 2;
    bitsYOffset = (prismDepth - internalDepth) / 2;
    
    // insetHeight is the height of the internal inset lip.
    insetHeight = 0.55 * inchToMMMultiplier;


    
        translate([0,0,insetHeight])
        difference(){
            cube([
                prismWidth,
                prismDepth,
                prismHeight,
            ]);
            translate([bitsXOffset, bitsYOffset, 1 * prismHeight])
            allBits();
        };     
        insetV2();
        //insetV1();  
    
    
    bowlBottomFilePath = str(
        "assortment+box+master+set/02 assortment box master set/organizers/bowl ", 
        minimumDepthCells, 
        "x", 
        minimumWidthCells,
        "/organizer bowl single square ", 
        minimumDepthCells, 
        "x", 
        minimumWidthCells, 
        ".STL"
    );
    
    module insetV1(){
        difference(){
            import(bowlBottomFilePath);
            translate([0, 0, insetHeight])
            cube([
                prismWidth + 1,
                prismDepth + 1,
                internalHeight + 100,
            ]);
        }
    }
    
    module insetV2(){
        insetSize = 3.3;
        insetRampHeight = 4;

        points = [
            [insetSize, insetSize, insetHeight - insetRampHeight],
            [prismWidth - insetSize, insetSize, insetHeight - insetRampHeight],
            [prismWidth - insetSize, prismDepth - insetSize, insetHeight -insetRampHeight],
            [insetSize, prismDepth - insetSize, insetHeight - insetRampHeight],
            
            [0, 0, insetHeight],
            [prismWidth, 0, insetHeight],
            [prismWidth, prismDepth, insetHeight],
            [0, prismDepth, insetHeight],
        ];
        
        faces = [[0,1,2,3],  // bottom
            [4,5,1,0],  // front
            [7,6,5,4],  // top
            [5,6,2,1],  // right
            [6,7,3,2],  // back
            [7,4,0,3]]; // left
    
        polyhedron(
            points,
            faces
        );
        
        translate([insetSize, insetSize, 0])
        cube([prismWidth - insetSize*2, prismDepth - insetSize*2, insetHeight]);
    }
    


    // xOffset calculates the offset to add to the x axis of each of the bit. This is used
    // to ensure that each bit is equidistant to both the previous and next bit.
    function xOffset(idx) = idx > 0 ?
        getBitDiameter(idx)/2 + getBitDiameter(idx - 1)/2 + betweenWidth + xOffset(idx - 1) :
        getBitDiameter(idx)/2;

    baseYOffset = getBitOverallLength(0)/2;

    // yOffset calculates the offset to add to the y axis of each of the bits.
    // This function ensures that the bottom of each bit lines up to the previous pin.
    function yOffset(idx) = idx > 0 ?
        -1 * (getBitOverallLength(0) - getBitOverallLength(idx)) / 2 + baseYOffset:
        baseYOffset;

    // allBits is a module that contains all of the bits spaced 'betweenWidth' apart.
    module allBits(){
        for (idx = [ 0 : len(bits) - 1 ] ) {        
            translate([xOffset(idx), yOffset(idx), 0])
            rotate([90,0,0])
            bitProfile(
                getBitLabel(idx), 
                getBitDiameter(idx), 
                getBitDrillDiameter(idx), 
                getBitLength(idx), 
                getBitOverallLength(idx)
            );
        }
    };

    // bitProfile returns the geometry for a bit.
    module bitProfile(
        label,
        bodyDiameter,
        drillDiameter,
        drillLength,
        overallLength
    ) {
        fontDepth = 1;
        fontSize = 5.5;
        distanceBetweenTextAndBottomOfBit = 2;
        
        rotate([-90,0,0])
        translate([0,- (overallLength/2 + fontSize + distanceBetweenTextAndBottomOfBit),- fontDepth])
        linear_extrude(fontDepth*2)
        text(label, font = "Liberation Sans", size = fontSize, halign="center", valign="bottom");
        
        cylinder(
            h = overallLength - (2 * drillLength),
            d = bodyDiameter,
            center = true,
            $fn = cylinderFn 
        );
        
        bitZOffset = (overallLength / 2) - drillLength;
        
        translate([0,0, bitZOffset])
        cylinder(
            h = drillLength,
            r1 = bodyDiameter/2,
            r2 = drillDiameter/2,
            $fn = cylinderFn 
        );
        
        translate([0,0, -1 * bitZOffset - drillLength])
        cylinder(
            h = drillLength,
            r1 = drillDiameter/2,
            r2 = bodyDiameter/2,
            $fn = cylinderFn 
        );
    };
}

// Example of Usage
//
// bitsTop(bits);