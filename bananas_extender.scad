include <NopSCADlib/utils/core/core.scad>
include <NopSCADlib/vitamins/screws.scad>
include <NopSCADlib/vitamins/led_meters.scad>
include <NopSCADlib/vitamins/potentiometers.scad>
include <NopSCADlib/vitamins/rockers.scad>
include <NopSCADlib/vitamins/pcbs.scad>
include <NopSCADlib/vitamins/radials.scad>
include <NopSCADlib/vitamins/inserts.scad>
include <NopSCADlib/vitamins/radial.scad>
include <NopSCADlib/vitamins/component.scad>
include <NopSCADlib/vitamins/components.scad>
use <NopSCADlib/vitamins/jack.scad>
use <NopSCADlib/printed/printed_box.scad>
use <NopSCADlib/printed/foot.scad>
use <NopSCADlib/printed/knob.scad>


buck = ["buck", "4A buck converter",
    43, 21, 1.25, // size
    0, // corner radius
    3, // mounting hole diameter
    5, // pad around mounting hole
    "blue", // color
    false, // // true if parts should be separate BOM items
    [[6.5, -2.25], [-6.25, 2.25]], // hole positions
    [ // components
        [5, 10.5, 0, "rd_electrolytic", ECAP8x11, "xd"],
        [-5, 10.5, 0, "rd_electrolytic", ECAP8x11, "xd"],
        [31, -2, 0, "smd_diode", DO214AC, "SS34"],
        [15, -2.5, 0, "trimpot10", true],
        [15, 8, 0, "smd_inductor", CDRH104],
        [27.5, 7,  0, "chip", 10, 10, 4.5],
   ],
];

insert_m2 = [
    "M2",
    2.55, // length
    3.18, // outer d
    2.1, // hole d
    2, // screw d
    2.0, // barrel d,
    1.0, 3.4, 3.1];


part = "box"; // ["box", "base"]

// Panel with switch and voltmeter
panel = false;

// Number of output connectors on the top
outputs = 6;

// Box width including wall
w = 36;
// Box height including wall
h = 34;
// Wall thickness
wall = 2;

// Offset between black and red banana plug on the top
output_banana_offset = 7;
// banana output hole diameter
output_banana_d = 9;

// diameter of input banana plug on the side
input_banana_d = 4;
// offset from the input side to first connector on the top
side_offset_input = 14;
// offset from the output side to last connector on the top
side_offset_output = 14;

buck_offset_z = 13.5+wall;

total_side_offset_input = panel ? (side_offset_input + 43) : side_offset_input;

// measured distance from the bottom to the top edge of the inner screw
input_banana_h = 27 - input_banana_d/2;
// measured distance between outer edges of the first and second screws
input_banana_spacing = 22.5 - input_banana_d;
l = total_side_offset_input + side_offset_output + output_banana_offset * 2 * outputs;

box1 = pbox(name = "box1", wall = wall, top_t = wall, base_t = 1, radius = 0, size = [l-2*wall, w-2*wall, h-4*wall], screw = M3_cap_screw);
voltmeter = ["led_meter",  [22.72, 14.05, 7.7], 0, [22.72, 11.04, 0.96], [30, 4.2],  0,  27, 2.2 / 2, false];

module output_positions() {
    translate([-l/2+output_banana_offset+side_offset_input, 0, 0]) {
        for(i = [0:outputs-1]) {
            translate([i * output_banana_offset*2, 0, 0]) {
                children();
            }
        }
    }
}

module panel_position() {
    if(panel) {
        translate([l/2-side_offset_input-meter_size(voltmeter).y/2, 0, h/2])
        children();
    }
}

module voltmeter_position() {
    translate([0, 7, 0])
    rotate([180, 0, 90])
    children();
}

module switch_position() {
    translate([0, -16, 0])
    rotate([0, 0, -90])
    children();
}

module buck_position() {
    translate([-25, 0, -buck_offset_z])
    rotate([0, 0, -90])
    children();
}

module box() {
    difference() {
        union() {
            rotate([180, 0, 0]) translate([0, 0, -h/2]) pbox(box1) {}
            panel_position() {
                voltmeter_position() {               
                    meter_hole_positions(voltmeter) {
                        difference() {
                            size = meter_size(voltmeter);
                            translate_z(size.z/2)
                            cube([meter_lug_size(voltmeter)[1], size[1], size.z], center=true);
                            
                            translate_z(size.z)
                                insert_hole(insert_m2);
                        }
                    }
                }
                
                buck_position() {
                    pcb_screw_positions(buck) {
                        translate_z(1.25) {
                            difference() {
                                cylinder(d=6, h=buck_offset_z-wall);
                                insert_hole(F1BM3);
                            }
                        }
                    }
                }
            }
        }
        
        panel_position()
        buck_position()
        pcb_cutouts(buck);
            
        // hole for input banana
        for(i = [-1, 1]) {
            translate([l/2-wall, i*input_banana_spacing/2, -h/2 + input_banana_h])
            rotate([0, 90, 0])
            cylinder(d=input_banana_d, h=wall);
        }
        
        // side output
        for(i = [-1, 1]) {
            translate([-l/2, i*input_banana_spacing/2, -h/2 + input_banana_h])
            rotate([0, 90, 0])
            cylinder(d=output_banana_d, h=wall);
        }
        
        
        // top outputs
        output_positions() {
            for(i = [-1, 1]) {
                translate([0, i*output_banana_offset, h/2-wall])
                    cylinder(d=output_banana_d, h=wall);
            }
        }
        
        panel_position() {
            voltmeter_position() {
                size = meter_size(voltmeter) + [0.03, 0.12, 0];
                translate_z(size.z/2)
                    cube(size, center=true);
            }
                
            switch_position()
            translate_z(-wall/2)
                rocker_hole(micro_rocker, h=wall);
        }
    }

    if($preview) {
        panel_position() {
            voltmeter_position() {
                meter(voltmeter, value="12.3");
            }
            
            switch_position()
                rocker(micro_rocker);
            
            buck_position()
                pcb(buck);
        }
    
        translate([0, 0, h/2])
        output_positions() {
            translate([0, output_banana_offset, 0])
                jack_4mm("red", 3, "red");
            translate([0, -output_banana_offset, 0])
                jack_4mm("black", 3, "black");
        }
        
        translate([-l/2, 0, -h/2 + input_banana_h])
        rotate([0, -90, 0]) {
            for(item = [[1, "red"], [-1, "black"]]) {
                translate([0, item[0] * input_banana_spacing/2, 0]) {
                    jack_4mm(item[1], 3, item[1]);
                    
                    color([1, 0, 0])
                    translate([0, 0, -wall-1.5])
                        nut(M6_half_nut);
                }
            }
        }
    }
}
    
if(part == "box") {
    box();
} else if(part == "base") {
 pbox_base(box1);
}
