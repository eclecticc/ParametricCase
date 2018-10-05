include <defaults.scad>;
include <vent.scad>;

_hole_spacings=[
        [220, 170],
        [200, 154],
        [140, 124.5],
        [120, 105],
        [92, 83],
        [80, 72],
        [70, 60],
        [60, 50],
        [50, 40],
        [40, 32]
        ];

function hole_spacing(size) = _hole_spacings[search([size], _hole_spacings, 1, 0)[0]][1];

module fan(size, thickness, blades) {
    // Center at base of exhaust side is datum
    $fn = 50;
    fan_wall = 1;
    hole_spacing = hole_spacing(size);
    
    color("DarkSlateGray", 1.0) {
        difference() {
            translate([-size/2, -size/2, 0]) {
                cube([size, size, thickness]);
            }
            translate([0, 0, -extra/2]) cylinder(r = size/2-fan_wall, h = thickness + extra);
            
            // Holes for the fan screws
            for (x = [-hole_spacing/2, hole_spacing/2]) {
                for (y = [-hole_spacing/2, hole_spacing/2]) {
                    translate([x, y, -extra/2]) cylinder(r = 4.0/2, h = thickness+extra);
                }
            }
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
    hole_spacing = hole_spacing(size);
    
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
