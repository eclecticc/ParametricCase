// Parametric Mini-ITX Case
// https://github.com/eclecticc/ParametricCase
//
// BSD 2-Clause License
// Copyright (c) 2018, Nirav Patel, http://eclecti.cc
//
// Parametric CPU heatsink modules

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

aio_pump_size = [66, 66, 30];

// A generic placeholder for an AIO cooling system pump
module aio_pump() {
    color("DarkSlateGray", 1.0) {
        translate([-aio_pump_size[0]/2, -aio_pump_size[1]/2, 0]) cube(aio_pump_size);
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

noctua_nh_u9s_size = [95, 95, 125];
module noctua_nh_u9s() {
    color("Gainsboro") {
        translate([-noctua_nh_u9s_size[0]/2, -noctua_nh_u9s_size[1]/2, 0]) cube(noctua_nh_u9s_size);
    }
}


bequiet_shadowrock_lp_size = [122, 134.21, 75.4];
module bequiet_shadowrock_lp() {
    rotate([0,0,-90]){
        // cpu-block
        color("Gainsboro") {
            translate([-20, -20, 0]) { cube([40, 40, 15]); }
        }
        // middle heatsink
        translate([0, -10, 19.9]) {
            heatsink([76, 76, 31.7-19.9], 0, 80);
        }
        //upper heatsink
        translate([bequiet_shadowrock_lp_size[0]/2-66, 20, 31.7]) {
            //rotate([0,0, 90])
            heatsink([bequiet_shadowrock_lp_size[0], bequiet_shadowrock_lp_size[1], 50-31.7], 0, 80);
        }

        // fan
        translate([bequiet_shadowrock_lp_size[0]/2-66, 20, 50]){
            fan(120, 25, 9);
        }
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

// Build the heatsink from the name of it
module heatsink_type(type) {
    if (type == "cryorig_c7") {
        cryorig_c7();
    } else if (type == "noctua_nh_l12s") {
        noctua_nh_l12s();
    } else if (type == "noctua_nh_u9s") {
        noctua_nh_u9s();
    } else if (type == "bequiet_shadowrock_lp") {
        bequiet_shadowrock_lp();
    } else if (type == "aio") {
        aio_pump();
    } else {
        echo("Unknown heatsink ", type);
    }
}

_heatsinks=[
        ["cryorig_c7", cryorig_c7_size[2]],
        ["noctua_nh_l12s", noctua_nh_l12s_size[2]],
        ["noctua_nh_u9s", noctua_nh_u9s_size[2]],
        ["bequiet_shadowrock_lp", bequiet_shadowrock_lp_size[2]],
        ["aio", aio_pump_size[2]]
        ];

// Return the height of the heatsink from the name of it
function heatsink_height(heatsink) = _heatsinks[search([heatsink], _heatsinks, 1, 0)[0]][1];

//heatsink_type("noctua_nh_l12s");

//cryorig_c7();
//noctua_nh_l12s();
//bequiet_shadowrock_lp();
//corsair_h60();
