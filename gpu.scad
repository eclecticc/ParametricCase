include <defaults.scad>;
include <fan.scad>;
include <pci_bracket.scad>;

pci_e_front_edge = -57.15;
pci_e_cutout_height = 8.25+(111.15-106.65);
pci_e_spacing = 47.29-26.97;
// Transform from pci e card datum to bracket datum
pci_e_to_bracket = [-64.13, 2.84-pcb_thickness, 100.36];

module dual_gpu(length) {
    // Using the bottom center of the notch as the datum
    color("Green", 1.0) {
        difference() {
            translate([pci_e_front_edge, -pcb_thickness/2, 0]) cube([length, pcb_thickness, 111.15]);
            translate([pci_e_front_edge-extra, -pcb_thickness/2-extra/2, 0-extra]) cube([-pci_e_front_edge+extra-12.15, pcb_thickness+extra, pci_e_cutout_height]);
            translate([72.15, -pcb_thickness/2-extra/2, 0-extra]) cube([length-72.15+extra, pcb_thickness+extra, pci_e_cutout_height]);
        }
    }
    
    translate(pci_e_to_bracket) {
        pci_bracket();
        translate([0, -pci_e_spacing, 0]) pci_bracket();
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

zotac_1080_mini_pcb = [172.48, 110];
zotac_1080_thickness = 41.9;
zotac_1080_mini_length = 36+zotac_1080_mini_pcb[0]; // TODO: Needs measurement
zotac_1080_front_fan = 100;
zotac_1080_back_fan = 90;

module zotac_1080_mini() {
    // Brackets and PCB
    dual_gpu(zotac_1080_mini_pcb[0]);
    
    fan_thickness = 15;
    
    // Body
    color("DimGray", 1.0) {
        translate([pci_e_front_edge, -(zotac_1080_thickness-3)+fan_thickness, pci_e_cutout_height]) {
            cube([zotac_1080_mini_length, zotac_1080_thickness-fan_thickness, zotac_1080_mini_pcb[1]]);
        }
    }
    
    // Add the fans
    translate([pci_e_front_edge, -(zotac_1080_thickness-3), pci_e_cutout_height+zotac_1080_mini_pcb[1]/2]) {
        
        translate([zotac_1080_back_fan/2, 0, 0]) rotate([-90, 0, 0]) fan(zotac_1080_back_fan, fan_thickness, 9);
        translate([zotac_1080_back_fan+zotac_1080_front_fan/2, 0, 0]) rotate([-90, 0, 0]) fan(zotac_1080_front_fan, fan_thickness, 8);
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

//zotac_1080_mini();
//% zotac_1080_mini_cutout();
