include <defaults.scad>;
include <fan.scad>;

// Generic rectangular heatsink with fins
module heatsink(size, base, fins) {
    translate([-size[0]/2, -size[1]/2, 0]) {
        color("Gainsboro") {
            difference() {
                cube(size);
                for (i = [0:fins-1]) {
                    translate([-extra/2, i*(size[1]-size[1]/fins/3)/fins + size[1]/fins/3, base]) cube([size[0]+extra, 2*size[1]/fins/3, size[2]-base+extra]);
                }
            }
        }
    }
}

cryorig_c7_size = [97, 97, 47+15];

module cryorig_c7() {
    heatsink([cryorig_c7_size[0], cryorig_c7_size[1], cryorig_c7_size[2]-15], 5, 57);
    translate([0, 0, 47]) fan(92, 15, 11);
}

noctua_nh_l12s_size = [146, 128, 70];

module noctua_nh_l12s() {
    translate([noctua_nh_l12s_size[0]/2-66, 0, noctua_nh_l12s_size[2]-20]) heatsink([noctua_nh_l12s_size[0], noctua_nh_l12s_size[1], 20], 0, 80);
    translate([noctua_nh_l12s_size[0]/2-66, 0, noctua_nh_l12s_size[2]-15-20]) fan(120, 15, 9);
    color("Gainsboro") {
        translate([-20, -20, 0]) cube([40, 40, 15]);
    }
}

module noctua_nh_u9s() {
    color("Gainsboro") {
        translate([-47.5, -47.5, 0]) cube([95, 95, 125]);
    }
}


// Dimensions including stock fan
corsair_h60_size = [27+25, 152, 120];
corsair_h60_fan = [120, 25];
corsair_h60_fan_offset = 4; // TODO: Need to measure actual offset

// Corsair Hydro H60 all in one CPU cooler
module corsair_h60() {
    fan_thickness = 25;
    color("DarkSlateGray", 1.0) {
        translate([fan_thickness, 0, 0]) {
            cube([corsair_h60_size[0]-fan_thickness, corsair_h60_size[1], corsair_h60_size[2]]);
            
            // Add placeholders for the tubes
            tube_r = 6; // TODO: measure this
            translate([0, corsair_h60_size[1]-tube_r, corsair_h60_size[2]/4]) {
                rotate([0, -90, 0]) cylinder(r = tube_r, h = 50);
                translate([0, 0, corsair_h60_size[2]/2]) rotate([0, -90, 0]) cylinder(r = tube_r, h = 50);
            }
        }
    }
    
    translate([0, corsair_h60_size[1]/2-corsair_h60_fan_offset, corsair_h60_fan[0]/2]) rotate([0, 90, 0]) fan(corsair_h60_fan[0], fan_thickness, 7);
}

//cryorig_c7();
//noctua_nh_l12s();
//corsair_h60();
