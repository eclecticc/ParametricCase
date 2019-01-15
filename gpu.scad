// Parametric Mini-ITX Case
// https://github.com/eclecticc/ParametricCase
//
// BSD 2-Clause License
// Copyright (c) 2018, Nirav Patel, http://eclecti.cc
//
// PCI-e GPU modules

include <defaults.scad>;
include <fan.scad>;
include <pci_bracket.scad>;

pci_e_front_edge = -57.15;
pci_e_cutout_height = 8.25+(111.15-106.65);
pci_e_spacing = 47.29-26.97;
// Transform from pci e card datum to bracket datum
pci_e_to_bracket = [-64.13, 2.84-pcb_thickness, 100.36];

module dual_gpu( length, height) {
    // Using the bottom center of the notch as the datum
    color("Green", 1.0) {
        difference() {
            translate([pci_e_front_edge, -pcb_thickness/2, 0]) cube([length, pcb_thickness, height]);
            translate([pci_e_front_edge-extra, -pcb_thickness/2-extra/2, 0-extra]) cube([-pci_e_front_edge+extra-12.15, pcb_thickness+extra, pci_e_cutout_height]);
            translate([72.15, -pcb_thickness/2-extra/2, 0-extra]) cube([length-72.15+extra, pcb_thickness+extra, pci_e_cutout_height]);
        }
    }

    translate(pci_e_to_bracket) {
        pci_bracket();
        translate([0, -pci_e_spacing, 0]) pci_bracket();
    }
}

module single_bracket_gpu( length, height) {
    // Using the bottom center of the notch as the datum
    color("Green", 1.0) {
        difference() {
            translate([pci_e_front_edge, -pcb_thickness/2, 0]) cube([length, pcb_thickness, height]);
            translate([pci_e_front_edge-extra, -pcb_thickness/2-extra/2, 0-extra]) cube([-pci_e_front_edge+extra-12.15, pcb_thickness+extra, pci_e_cutout_height]);
            translate([72.15, -pcb_thickness/2-extra/2, 0-extra]) cube([length-72.15+extra, pcb_thickness+extra, pci_e_cutout_height]);
        }
    }

    translate(pci_e_to_bracket) {
        pci_bracket();
    }
}

module dual_gpu_cutout() {
    slot_extra = 0.1;

    translate(pci_e_to_bracket) {
        pci_bracket_cutout();
        translate([0, -pci_e_spacing, 0]) pci_bracket_cutout();
        // Handle the gap between the two brackets, typically one piece on dual slot GPUs
        translate([-(11.43-5.08), -pci_e_spacing, 0]) cube([11.43, pci_e_spacing, 50]);
    }
}

module single_bracket_gpu_cutout() {
    slot_extra = 0.1;

    translate(pci_e_to_bracket) {
        pci_bracket_cutout();
    }
}


zotac_1080_mini_pcb = [172.48, 110];
zotac_1080_thickness = 41.9;
zotac_1080_mini_length = 36+zotac_1080_mini_pcb[0]; // TODO: Needs measurement
zotac_1080_front_fan = 100;
zotac_1080_back_fan = 90;
zotac_1080_fan_thickness = 15;

zotac_1080_mini_size = [zotac_1080_mini_length, zotac_1080_mini_pcb[1], zotac_1080_thickness];

module zotac_1080_mini() {
    // Brackets and PCB
    dual_gpu(zotac_1080_mini_pcb[0], 111.15);



    // Body
    color("DimGray", 1.0) {
        translate([pci_e_front_edge, -(zotac_1080_thickness-3)+zotac_1080_fan_thickness, pci_e_cutout_height]) {
            cube([zotac_1080_mini_length, zotac_1080_thickness-zotac_1080_fan_thickness, zotac_1080_mini_pcb[1]]);
        }
    }

    // Add the fans
    translate([pci_e_front_edge, -(zotac_1080_thickness-3), pci_e_cutout_height+zotac_1080_mini_pcb[1]/2]) {

        translate([zotac_1080_back_fan/2, 0, 0]) rotate([-90, 0, 0]) fan(zotac_1080_back_fan, zotac_1080_fan_thickness, 9);
        translate([zotac_1080_back_fan+zotac_1080_front_fan/2, 0, 0]) rotate([-90, 0, 0]) fan(zotac_1080_front_fan, zotac_1080_fan_thickness, 8);
    }
}

module zotac_1080_mini_cutout() {
    dual_gpu_cutout();

    // Side panel fan cutouts
    translate([pci_e_front_edge+(zotac_1080_back_fan+zotac_1080_front_fan)/2, -(zotac_1080_thickness-3), pci_e_cutout_height+zotac_1080_mini_pcb[1]/2]) {
        rotate([90, 0, 0]) {
            vent_rectangular([zotac_1080_back_fan+zotac_1080_front_fan, zotac_1080_front_fan], 10, 2.0);
        }
    }

    // Front panel cutout
    translate([pci_e_front_edge+zotac_1080_mini_length, -(zotac_1080_thickness-3)/2+wall, pci_e_cutout_height+zotac_1080_mini_pcb[1]/2]) {
        rotate([0, 90, 0]) {
            vent_rectangular([zotac_1080_front_fan, zotac_1080_thickness], 10, 2.0);
        }
    }
}

//
accelero_970_pcb = [172.48, 110];
accelero_970_thickness = 40;
accelero_970_main_fan = 120;
accelero_fan_thickness = 20;

accelero_970_length = 36+accelero_970_pcb[0]; // TODO: Needs measurement
accelero_970_height = accelero_970_pcb[1] + 50;
accelero_970_depth = accelero_970_thickness + accelero_fan_thickness + 5;

accelero_970_size = [accelero_970_length, accelero_970_height, accelero_970_depth];

module accelero_970() {
    // Brackets and PCB
    dual_gpu(accelero_970_pcb[0], 111.15);



    // Body
    color("DimGray", 1.0) {
        translate([pci_e_front_edge, -(accelero_970_thickness/2), pci_e_cutout_height]) {
            union(){
                translate([accelero_970_length-160, -accelero_970_thickness/2, 10]){
                    cube([138, accelero_970_thickness, 136]);
                }
            }
        }
    }

    // Add the fan
    translate([pci_e_front_edge, -(accelero_970_thickness/2), pci_e_cutout_height+accelero_970_pcb[1]/2]) {
        translate([accelero_970_length-90, -accelero_970_thickness, 20]) rotate([-90, 0, 0]) fan(accelero_970_main_fan, accelero_fan_thickness, 9);
    }
}

module accelero_970_cutout() {
    dual_gpu_cutout();

    // Side panel fan cutouts
    translate([pci_e_front_edge+(accelero_970_main_fan), -(accelero_970_thickness)-40, pci_e_cutout_height+accelero_970_pcb[1]/2 + 20]) {
        rotate([90, 0, 0]) {
            vent_rectangular([accelero_970_main_fan, accelero_970_main_fan], 10, 2.0);
        }
    }
}

// sizes for GT730
gt730_1G_pcb = [114, 69];
gt730_1G_thickness = 33;
//gt730_1G_length = gt730_1G_pcb[0]; // TODO: Needs measurement
//gt730_1G_height = gt730_1G_pcb[1];
gt730_1G_depth = gt730_1G_thickness + 5;

gt730_1G_size = [gt730_1G_pcb[0], gt730_1G_pcb[1], gt730_1G_depth];

module gt730_1G() {
    // Brackets and PCB
    single_bracket_gpu(gt730_1G_pcb[0], gt730_1G_pcb[1]);

    // Body
    color("DimGray", 1.0) {
        translate([pci_e_front_edge, -(gt730_1G_thickness/2), -gt730_1G_pcb[1]/2 ]) {
            union(){
                translate([73, gt730_1G_thickness/2, gt730_1G_pcb[1]+7]) {
                    rotate([90, 0, 0]) { heatsink([76, 55, gt730_1G_thickness], 3, 11); }
                }
            }
        }
    }
}

module gt730_1G_cutout() {
    // @todo: clean this up
    dual_gpu_cutout();
    //single_bracket_gpu_cutout();
}



_gpus=[
    ["zotac_1080_mini", zotac_1080_mini_size],
    ["accelero_970", accelero_970_size],
    //["gt730_1g", [gt730_1G_pcb[0], gt730_1G_pcb[1], gt730_1G_thickness+5]],
    ["gt730_1g", gt730_1G_size],
    ];

// Return the height of the GPU by name
function gpu_size(gpu) = _gpus[search([gpu], _gpus, 1, 0)[0]][1];

/************ place for testing the elements above ****************/

// zotac_1080_mini();
// %zotac_1080_mini_cutout();

// translate ([300, 0, 0]){
//     accelero_970();
//     %accelero_970_cutout();
// }

//gt730_1G();
