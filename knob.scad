model = "knob"; // [knob, shaft]

tol = 0.015;
d = 2.19+0.15;
wall = 0.5;
h_top = 10;
h_bot = 2;
h = h_bot+h_top+wall;
hs = 1.52;
sh = 0.76;
$fn = 120;
shaft_diameter = d + 2*wall;

knob_diameter = 14; // outer diameter of knob
knob_top_wall = 3;
knob_height = h_top+knob_top_wall;
notch_depth = 1.5; // depth of side grip notches
notch_count = 8; // number of notches around knob

module shaft() {
    difference() {
        union() {
            cylinder(d=shaft_diameter, h=h, $fn=180, center=true);
            translate([0, 0, h/2-h_bot/2])
                cylinder(d=d + 2 * 2 * wall, h=h_bot, center=true);
        }
        translate([0, 0, (h - hs)/2])
        cylinder(d=d, h=hs, $fn=180, center=true);
    }


    translate([0, 0, (h - hs - sh)/2])
    cube([d, 0.56-tol, sh], center=true);
}

module knob() {    
    difference() {
        // main body
        cylinder(d = knob_diameter, h = knob_height, center=true);

        // shaft hole
        translate([0, 0, knob_top_wall/2])
            #cylinder(d = shaft_diameter + 0.06, h = h_top, center=true);

        // notches
        for (i = [0 : 360/notch_count : 360-360/notch_count]) {
            rotate([0,0,i])
                translate([knob_diameter/2 - notch_depth/2, 0, -knob_height/3])
                    cube([notch_depth, 2, knob_height/3*2], center=true);
        }
    }
}

if (model == "shaft") {
    shaft();
} else if(model == "knob") {
    knob();
}
