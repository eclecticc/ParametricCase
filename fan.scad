include <defaults.scad>;
include <vent.scad>;

module fan(size, thickness, blades) {
    // Center at base of exhaust side is datum
    $fn = 50;
    fan_wall = 1;
    
    color("DarkSlateGray", 1.0) {
        difference() {
            translate([-size/2, -size/2, 0]) {
                    cube([size, size, thickness]);
                }
            translate([0, 0, -extra/2]) cylinder(r = size/2-fan_wall, h = thickness + extra);
        }
    }
    
    color("Snow", 1.0) {
        cylinder(r = size/5, h = thickness);
        intersection() {
            for (i = [0:blades]) {
                rotate([0, 0, i*360/blades]) translate([0, -thickness/2, thickness/4]) rotate([-60, 0, 0]) cube([size/2, 1, thickness]);
            }
            cylinder(r = size/2-fan_wall*2, h = thickness);
        }
    }
}

module fan_cutout(size) {
    $fn = 20;
    hole_spacing = size*0.9;
    
    // Hole spacing for standard PC fan sizes
    if (size == 220) {hole_spacing = 170;}
    else if (size == 200) {hole_spacing = 154;}
    else if (size == 140) {hole_spacing = 124.5;}
    else if (size == 120) {hole_spacing = 105;}
    else if (size == 92) {hole_spacing = 83;}
    else if (size == 80) {hole_spacing = 72;}
    else if (size == 70) {hole_spacing = 60;}
    else if (size == 60) {hole_spacing = 50;}
    else if (size == 50) {hole_spacing = 40;}
    else if (size == 40) {hole_spacing = 32;}
    
    vent_rounded_rect(size/2*1.1, [size, size], 10, 2.0);
    
    // Countersunk holes for the fan screws
    for (x = [-hole_spacing/2, hole_spacing/2]) {
        for (y = [-hole_spacing/2, hole_spacing/2]) {
            translate([x, y, 0]) {
                // TODO: verify this dimensions
                cylinder(r = 6.2/2, h = 15);
                translate([0, 0, -1]) cylinder(r1 = 4.0/2, r2 = 6.2/2, h = 1);
                translate([0, 0, -15]) cylinder(r = 4.0/2, h = 15);
            }
        }
    }
}

//fan(120, 25, 9);
//% fan_cutout(120);
