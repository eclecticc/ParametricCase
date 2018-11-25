// Parametric Micro-ATX Case
// https://github.com/eclecticc/ParametricCase
//
// BSD 2-Clause License
// Copyright (c) 2018, Nirav Patel, http://eclecti.cc
//
// The main file with the case itself

include <defaults.scad>;
include <pci_bracket.scad>;
include <fan.scad>;
include <vent.scad>;
include <psu.scad>;
include <heatsink.scad>;
include <gpu.scad>;
include <motherboard.scad>;
include <power_switch.scad>;
include <front_panel.scad>;

// Uxcell M3 threaded inserts from Amazon
insert_r = 5.3/2+0.1;
insert_h = 5.0;

module motherboard_standoff() {
    difference() {
        cylinder(r = (0.4*25.4)/2, h = microatx_bottom_keepout);
        translate([0, 0, microatx_bottom_keepout-insert_h]) cylinder(r = insert_r - 0.1, h = insert_h+extra);
    }
}

module motherboard_standoffs_microatx() {
    $fn = 50;

    // Mounting holes for the motherboard
    translate([microatx_hole_b[0], microatx_hole_b[1], 0]) {
        motherboard_standoff();
        for (hole = [microatx_hole_c, microatx_hole_d, microatx_hole_e, microatx_hole_f, microatx_hole_g, microatx_hole_h, microatx_hole_i, microatx_hole_j]) {
            translate([hole[0], hole[1], 0]) motherboard_standoff();
        }
    }
}

// Just a little wedge to provide support for the PSU
module psu_ledge() {
    cube_size = 15;
    translate([0, extra, 0]) difference() {
        translate([-cube_size/2, 0, 0]) rotate([-45, 0, 0]) cube([cube_size, cube_size, cube_size], true);
        translate([-cube_size*1.5, -cube_size*1.5, 0]) cube([cube_size*2, cube_size*2, cube_size*2]);
        translate([-cube_size*1.5, 0, -cube_size*1.5]) cube([cube_size*2, cube_size*2, cube_size*2]);
    }
}

module psu_corner_ledge() {
    cube_size = 25;
    translate([-extra, -extra, 0]) difference() {
        translate([-cube_size/5, -cube_size/5, 0]) rotate([0, 0, -45]) rotate([45, 0, 0]) cube([cube_size, cube_size, cube_size], true);
        translate([-cube_size*1.1, -cube_size*1.1, 0]) cube([cube_size*2, cube_size*2, cube_size*2]);
        translate([-cube_size*2, -cube_size*1.1, -cube_size]) cube([cube_size*2, cube_size*2, cube_size*2]);
        translate([-cube_size*1.1, -cube_size*2, -cube_size]) cube([cube_size*2, cube_size*2, cube_size*2]);
    }
}

module cable_wrap_holder() {
    wrap_width = 15;

    difference () {
        translate([wall, -wall-wrap_width/2, 0]) {
            cube([wall, wall*2+wrap_width, wall*2]);
            translate([-wall*1.5, 0, 0]) cube([wall*2, wall, wall*2]);
            translate([-wall*1.5, wall+wrap_width, 0]) cube([wall*2, wall, wall*2]);
            translate([wall, 0, 0]) rotate([0, -45-90, 0]) cube([wall*2, wall, wall*4]);
            translate([wall, wall+wrap_width, 0]) rotate([0, -45-90, 0]) cube([wall*2, wall, wall*4]);
        }
        translate([-wall/2-10, -wall-wrap_width, -10]) cube([10, wrap_width*2+wall*2, 20]);
    }
}

// The tab that the pci bracket screws into
module pci_bracket_holder() {
    tab_depth = 11.43;

    bottom_wall = 1.0;

    translate(pci_e_to_bracket) {
        difference() {
            // The body of the tab
            translate([pci_bracket_back_edge, -pci_e_spacing+pci_bracket_right_edge-pci_bracket_slot_extra, -tab_depth]) cube([tab_depth, pci_e_spacing+pci_bracket_total_width+pci_bracket_slot_extra*2-2.54, tab_depth]);
            // Chop it at 45 degrees to make it printable
            translate([pci_bracket_back_edge+tab_depth, -pci_e_spacing+pci_bracket_right_edge-pci_bracket_slot_extra-extra/2, -tab_depth]) rotate([0, -45-90, 0]) cube([tab_depth*2, pci_e_spacing+pci_bracket_total_width+pci_bracket_slot_extra*2-2.54+extra, tab_depth]);
        }
    }
}

module pci_bracket_holder_cutout() {
    $fn = 20;

    bottom_wall = 1.0;

    translate(pci_e_to_bracket) {
        // Cut out the holes for the threaded insert and the bolt
        translate([0, 0, -insert_h]) {
            cylinder(r = insert_r - 0.1, h = insert_h+extra);
            translate([0, 0, -bottom_wall-extra/2]) cylinder(r = 1.5, h = bottom_wall+extra);
        }
        translate([0, -pci_e_spacing, -insert_h]) {
            cylinder(r = insert_r - 0.1, h = insert_h+extra);
            translate([0, 0, -bottom_wall-extra/2]) cylinder(r = 1.5, h = bottom_wall+extra);
        }
    }
}

module top_lid(size) {
    cube([size[0], size[1], wall]);
    translate([0, 0, wall/2]) rotate([45, 0, 0]) translate([0, -wall/4, -wall/4]) cube([size[0], wall/2, wall/2]);
    translate([0, size[1], wall/2]) rotate([45, 0, 0]) translate([0, -wall/4, -wall/4]) cube([size[0], wall/2, wall/2]);
    translate([size[0], 0, wall/2]) rotate([45, 0, 90]) translate([0, -wall/4, -wall/4]) cube([size[1], wall/2, wall/2]);
}

module back_to_back() {
    motherboard_microatx(false, am4_holes, am4_socket);

    translate([am4_holes[0], am4_holes[1], am4_socket[2]+microatx[2]]) cryorig_c7();

    translate([0, microatx[1]-flexatx_size[2], -microatx_bottom_keepout-wall]) {
        rotate([-90, 0, 0]) flexatx();
    }

    translate([microatx_pci_e_baseoffset[0], microatx_pci_e_baseoffset[1]+100, -40]) {
        rotate([90, 0, 0]) zotac_1080_mini();
    }
}

module traditional(show_body, show_lid, show_internals, heatsink_type, psu_type) {
    // Airflow clearance for CPU fan
    cpu_fan_clearance = 5;
    heatsink_height = heatsink_height(heatsink_type);
    psu_size = psu_size(psu_type);
    // Extra height for cable clearance for 8-pin connectors on the top of the card
    gpu_power_height = 5;
    // FIXME: gpu thickness doesn't account for bracket width
    // @todo: use variable to position the cpu
    gpu_location = microatx_pci_e_position_0;
    case_origin = [microatx_motherboard_back_edge-wall, -zotac_1080_thickness-wall+microatx_pci_e_offset_3[1]+3, -microatx_bottom_keepout-wall]; // TODO: Clean up the Y calculation

    m2_size = [110, 22+10];
    m2_location = [microatx[0]/2, 30];  // Note that this should be adjusted to match the mobo used

    case_fan_size = 140;
    case_fan_thickness = 25;
    case_exhaust_fan_size = 80;
    case_exhaust_fan_thickness = 15;

    // Figure out the stacked heights of the tallest components to use for case height
    psu_heatsink_stack = -case_origin[2]+microatx[2]+am4_socket[2]+heatsink_height+cpu_fan_clearance+psu_size[2]+wall;
    gpu_stack = -case_origin[2]+wall+microatx_pci_e_offset_0[2]+microatx[2]+pci_e_cutout_height+zotac_1080_mini_pcb[1]+gpu_power_height;

    // Figure out the stacked lengths of the longest components to use for case length
    microatx_cooling_length = -microatx_motherboard_back_edge+wall*3+microatx[0]+(heatsink_type == "aio" ? corsair_h60_size[0] : case_fan_thickness);
    gpu_length = zotac_1080_mini_length+wall*3; // Note the extra wall length for assembly margin

    case_size = [max(microatx_cooling_length, gpu_length), microatx[1]-case_origin[1]+microatx_motherboard_back_panel_overhang+motherboard_back_panel_lip, max(psu_heatsink_stack, gpu_stack)];

    psu_location = [microatx_motherboard_back_edge, case_origin[1]+case_size[1]-psu_size[1]-wall-wall/4, case_origin[2]+case_size[2]-psu_size[2]-wall];

    cable_wrap_location = [psu_location[0] + psu_size[0] + (case_size[0] - psu_size[0])/3, case_origin[1]+case_size[1]-wall, case_origin[2]+case_size[2]-psu_size[2]-wall];

    case_fan_location = [case_size[0]-wall-case_fan_thickness, (case_fan_size >= 120) ? case_size[1]/2-case_origin[1]/2 : case_size[1]/2, case_fan_size/2+wall*2];
    case_exhaust_fan_location = [wall, case_size[1]-psu_size[1]-case_exhaust_fan_size/2-wall, case_size[2]-case_exhaust_fan_size/2-wall];

    power_switch_location = [case_origin[0]+case_size[0], case_origin[1]+power_switch_r+wall*2.5, case_origin[2]+power_switch_r+wall*2.5];
    dual_usb_location = [case_origin[0]+case_size[0]-wall, case_origin[1]+case_size[1]-wall-dual_usb_size[2]-0.5, case_origin[2]+case_size[2]/2];

    // Calculate the case size in liters
    case_volume = case_size[0]*case_size[1]*case_size[2]/1000000.0;
    echo("Case dimensions X:", case_size[0], " Y:", case_size[1], " Z:", case_size[2], " L:", case_volume);

    corsair_h60_location = [case_size[0]-wall-corsair_h60_size[0], case_size[1]-wall*2-corsair_h60_size[1], case_size[2]-wall*2-corsair_h60_size[2]];

    // Using the bottom corner of the motherboard near the GPU as the origin
    if (show_internals == true) {
        motherboard_microatx(true, microatx_am4_holes, am4_socket);

        translate([microatx_am4_holes[0], microatx_am4_holes[1], am4_socket[2]+microatx[2]]) {
            heatsink_type(heatsink_type);
        }

        translate(psu_location) psu_type(psu_type);
        if (psu_type == "flexatx") {
            // The exhaust fan only fits (sort of) with flexatx
            translate(case_origin)  {
                translate(case_exhaust_fan_location) {
                    rotate([0, 90, 0]) fan(case_exhaust_fan_size, case_exhaust_fan_thickness, 10);
                }
            }
        }

        translate(gpu_location) {
            zotac_1080_mini();
        }

        translate(case_origin)  {
            // Put into place a radiator for AIO cooling
            if (heatsink_type == "aio") {
                translate(corsair_h60_location) {
                    corsair_h60();
                }
            } else {
                // Otherwise put a standard case fan in the front
                translate(case_fan_location) {
                    rotate([0, 90, 0]) fan(case_fan_size, case_fan_thickness, 10);
                }
            }
        }

        translate(power_switch_location) {
            rotate([0, 90, 0]) power_switch();
        }

        translate(dual_usb_location) {
               rotate([-90, 0, 0]) rotate([0, 0, 90]) dual_usb();
        }
    }

    // Make the lid separately so it can be printed on its own
    if (show_lid == true) color("WhiteSmoke", 0.5) {
        translate(case_origin) {
            translate([0, wall, case_size[2]-wall]) top_lid([case_size[0]-wall, case_size[1]-wall*2]);
        }
    }

    // The actual case
    if (show_body == true) color("WhiteSmoke", 0.5) {
        // Motherboard standoffs taking threaded inserts
        translate([0, 0, -microatx_bottom_keepout]) {
            motherboard_standoffs_microatx();
        }

        // Part that the GPU screws into
        translate(gpu_location) {
            difference() {
                pci_bracket_holder();
                pci_bracket_holder_cutout();
            }
        }

        // Attach ledges to the walls to help hold up the PSU
        translate(psu_location) {
            translate([psu_size[0], psu_size[1], 0]) psu_ledge();
            translate([0, psu_size[1], 0]) rotate([0, 0, -90]) psu_corner_ledge();
        }

        // Put some cable wrap holders on the wall near the PSU
        translate(cable_wrap_location) {
            rotate([0, 0, -90]) {
                cable_wrap_holder();
                translate([0, 0, psu_size[2]-wall*4]) cable_wrap_holder();
            }
        }

        difference() {
            // Body of the case
            translate(case_origin) {
                difference() {
                    cube(case_size);
                    translate([wall, wall, wall]) cube([case_size[0]-wall*2, case_size[1]-wall*2, case_size[2]]);
                    minkowski() {
                        translate([0-extra, wall, case_size[2]-wall]) top_lid([case_size[0]-wall+extra, case_size[1]-wall*2]);
                        cube([0.2, 0.2, 0.2], center = true);
                    }
                }
            }

            translate(case_origin) {
                translate([8, 0.2, 8]) {
                    rotate([90, 0, 0]) linear_extrude(wall) {
                        text(str(case_volume), font = "Helvetica:style=Normal", size = 20);
                    }
                }
            }

            motherboard_microatx_back_panel_cutout();

            // Put a vent in the bottom for a typical M.2 SSD location.
            translate([m2_location[0], m2_location[1], case_origin[2]]) vent_rectangular(m2_size, 10, 2.0);

            // Put in a vent for the radiator for AIO cooling
            if (heatsink_type == "aio") {
                translate(case_origin) translate(corsair_h60_location) translate([corsair_h60_size[0]+wall, corsair_h60_size[1]/2-corsair_h60_fan_offset, corsair_h60_fan[0]/2]) {
                    rotate([0, 90, 0]) {
                        fan_cutout(corsair_h60_fan[0]);
                    }
                }
            } else {
                // Otherwise put in a regular case fan vent
                translate(case_origin) translate([case_fan_location[0]+case_fan_thickness+wall, case_fan_location[1], case_fan_location[2]]) {
                    rotate([0, 90, 0]) {
                        fan_cutout(case_fan_size);
                    }
                }
            }

            if (psu_type == "sfx" || psu_type == "sfx_l") {
                translate(psu_location) {
                    sfx_cutout();
                }

                // Put in vents on the back wall to improve airflow
                back_panel_vent_v = [sfx_size[2], case_size[1]-zotac_1080_thickness-sfx_size[1]-wall*3];
                translate(psu_location) translate([0, -back_panel_vent_v[1]/2+wall, back_panel_vent_v[0]/2-wall]) {
                    rotate([0, 90, 0]) vent_rectangular(back_panel_vent_v, 10, 2.0);
                }

                back_panel_vent_h = [case_size[2]-sfx_size[2]-wall*3-motherboard_back_panel_size[1]-microatx_bottom_keepout, case_size[1]-zotac_1080_thickness-wall*2];
                translate(psu_location) translate([0, sfx_size[1]-back_panel_vent_h[1]/2+wall, -back_panel_vent_h[0]/2]) {
                    rotate([0, 90, 0]) vent_rectangular(back_panel_vent_h, 10, 2.0);
                }

            } else {
                translate(psu_location) {
                    flexatx_cutout(true);
                }

                translate(case_origin) translate([case_exhaust_fan_location[0]-wall, case_exhaust_fan_location[1], case_exhaust_fan_location[2]]) {
                    rotate([0, -90, 0]) {
                        fan_cutout(case_exhaust_fan_size);
                    }
                }
            }

            translate(gpu_location) {
                zotac_1080_mini_cutout();
                pci_bracket_holder_cutout();
            }

            translate(power_switch_location) {
                rotate([0, 90, 0]) power_switch_cutout();
            }

            translate(dual_usb_location) {
               rotate([-90, 0, 0]) rotate([0, 0, 90]) dual_usb_cutout();
            }

            // Prevent corner lift by angling the bottom corners
            translate(case_origin) {
                rotate([0, 0, -45]) rotate([45, 0, 0]) cube([wall*3, wall*2, wall*2], center = true);
                translate([case_size[0], 0, 0]) rotate([0, 0, 45]) rotate([45, 0, 0]) cube([wall*3, wall*2, wall*2], center = true);
                translate([case_size[0], case_size[1], 0]) rotate([0, 0, 135]) rotate([45, 0, 0]) cube([wall*3, wall*2, wall*2], center = true);
                translate([0, case_size[1], 0]) rotate([0, 0, -135]) rotate([45, 0, 0]) cube([wall*3, wall*2, wall*2], center = true);
            }
        }
    }
}

module traditional_tower_cooler() {
    motherboard_microatx(false, microatx_am4_holes, am4_socket);

    translate([microatx_am4_holes[0], microatx_am4_holes[1], am4_socket[2]+microatx[2]]) noctua_nh_u9s();

    translate([0, microatx[1]-flexatx_size[2], flexatx_size[1]+microatx[2]+45]) rotate([-90, 0, 0]) {
        flexatx();
    }

    translate([microatx_pci_e_offset_0[0], microatx_pci_e_offset_0[1], microatx_pci_e_offset_0[2]+microatx[2]]) {
        zotac_1080_mini();
    }
}

traditional(show_body = true, show_lid = false, show_internals = true, heatsink_type = "noctua_nh_l12s", psu_type = "sfx");
//traditional(show_body = true, show_lid = false, show_internals = true, heatsink_type = "aio", psu_type = "sfx");

translate ([400, 0, 0]){
    traditional_tower_cooler();
}
