module vent_rectangular(size, pitch, wall) {
    // Adjust the pitch to fit the total size
    fixed_pitch = size[0]/floor(size[0]/pitch);
    
    // Holes for ventilation
    // TODO: Taper the holes to reduce turbulance
    for (x = [-size[0]/2:fixed_pitch:size[0]/2-fixed_pitch]) {
        for (y = [-size[1]/2:fixed_pitch:size[1]/2-fixed_pitch]) {
            translate([x+wall/2, y+wall/2, -15]) cube([fixed_pitch-wall, fixed_pitch-wall, 30]);
        }
    }
}

module vent_circular(r, pitch, wall) {
    $fn = 100;
    
    intersection() {
        vent_rectangular([r*2, r*2], pitch, wall);
        cylinder(r = r, h = 30, center = true);
    }
}

module vent_rounded_rect(r, size, pitch, wall) {
    $fn = 100;
    
    intersection() {
        vent_rectangular(size, pitch, wall);
        cylinder(r = r, h = 30, center = true);
    }
}

//vent_rounded_rect(60, [100, 100], 10, 2);
