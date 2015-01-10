// ::: General utility modules and functions :::
// CC BY 3.0 Tom Øyvind Hogstad <tom.oyvind.hogstad@gmail.com> unless othervise stated by referenced authors

_pi = 3.14159265;
F  = 0.001;

// Convenience / Easy read rotate
module rotateX(a) {for(i=[0:$children-1]) {rotate([a,0,0]) children(i);}}
module rotateY(a) {for(i=[0:$children-1]) {rotate([0,a,0]) children(i);}}
module rotateZ(a) {for(i=[0:$children-1]) {rotate([0,0,a]) children(i);}}

// Convenience / Easy read translate
module translateX(a) {for(i=[0:$children-1]) {translate([a,0,0]) children(i);}}
module translateY(a) {for(i=[0:$children-1]) {translate([0,a,0]) children(i);}}
module translateZ(a) {for(i=[0:$children-1]) {translate([0,0,a]) children(i);}}

function pi() = _pi;

// Floatingpoint correction for translates
function xF(v) = v - [F,0,0];
function yF(v) = v - [0,F,0];
function zF(v) = v - [0,0,F];


// Vector Readability
function vX(v) = v[0];
function vY(v) = v[1];
function vZ(v) = v[2];

// Product of each element against each element, good for center cube translate(v=prod(cube_s, [0.5,0.5,1]))
function prod(v1,v2) = [v1[0]*v2[0], v1[1]*v2[1], v1[2]*v2[2]];

function sqr(a) = pow(a,2);


// Pythagoras
function hypotenuse(a,b) = sqrt(a*a+b*b);

// Sagitta
function sagitta(r,l) = r - sqrt(r*r-l*l);

// poly: calculates new radius (r) to get distance between facets to be radius (r)
function poly(r, fn=$fn) = r/cos(180/fn);

// Cylinder with $fn=8
module cylinder_screw(r,h,z=0,center=false,align=true) {
	translateZ(z) rotate(align ? 180/8 : 0) cylinder(r=r,h=h,center=center, $fn=8);
}

// Cylinder with $fn=6
module cylinder_nut(r,h,z=0,center=false,align=false) {
	translateZ(z) rotate(align ? 180/6 : 0) cylinder(r=r,h=h,center=center, $fn=6);
}

module cylinder_poly(r, h, z=0, center=false, fn=$fn) {
    translateZ(z) cylinder(r=poly(r, fn=$fn),h=h,center=center,$fn=fn);
}


module cube_centered(v,z=0,fillet_r=0) {
	translateZ(v[2]/2+z) 
		difference() {
		cube(v, center=true);
		if (fillet_r > 0) {
			translate([-v[0]/2, -v[1]/2, -(v[2]+2)/2]) 	rotateZ(0) 		fillet(r=fillet_r, h=v[2]+2);
			translate([v[0]/2, -v[1]/2, -(v[2]+2)/2]) 	rotateZ(90) 	fillet(r=fillet_r, h=v[2]+2);
			translate([v[0]/2, v[1]/2, -(v[2]+2)/2]) 	rotateZ(180) 	fillet(r=fillet_r, h=v[2]+2);
			translate([-v[0]/2, v[1]/2, -(v[2]+2)/2]) 	rotateZ(270) 	fillet(r=fillet_r, h=v[2]+2);
		}
		}
}



module teardrop(h, r, center=true, cut=true, $fn=20)
{
	z  = center ? -h/2 : 0;
	
	translate([0, 0, z])
	difference() {
		union() {
			cylinder(h=h, r=r, $fn=$fn);
			translate([0, r/2*sqrt(2), 0])
			cylinder(h=h, r=r*cos(45), $fn=4);
		}
		if(cut)
		translate([0,r+r*1.6,-z]) cube([r*3, r*3, h+.2], center=center);
	}
}







/* 
Bezier Curve with 3 control points 
Based on bezierconic.scad By Don B, 2011, released into the Public Domain
*/
// Helper function returns single point in sequence
function b3p(p0,p1,p2,steps=5, step=1, i=0) =
	(i==step-1) 
	? (p0+((p1-p0)/steps)*i)+(((p1+((p2-p1)/steps)*i)-(p0+((p1-p0)/steps)*i))*(i/steps)) 
	:b3p(p0=p0,p1=p1, p2=p2, steps=steps, step=step, i= i+1)
;

module bezier3(p0,p1,p2,steps=5, above=false) {
	y_min = p0[1] < p1[1]
		? (p0[1] < p2[1] ? p0[1] : p2[1])
		: (p1[1] < p2[1] ? p1[1] : p2[1]);
	y_max = p0[1] > p1[1]
		? (p0[1] > p2[1] ? p0[1] : p2[1])
		: (p1[1] > p2[1] ? p1[1] : p2[1]);
	echo(y_min, ":", y_max);
	y = (above) ? y_max : y_min;

	for (i=[0:steps-1]) {
		assign(pt1 = b3p(p0=p0,p1=p1,p2=p2,steps=steps, step=i+1) )
		assign(pt2 = b3p(p0=p0,p1=p1,p2=p2,steps=steps, step=i+2) ) {
					
			polygon(points=[pt1,pt2,[pt2[0], y], [pt1[0], y]]);
		}
	}
}

// Lag Bezier med startpunkt, sluttpunkt, start_tangent, end_tangent

// Punkt på tangent for sirkel hvor grader er
// circle_tan(r,a) = [tan(), tan()]


module bezier3_3d(xy0,xy1,xy2, xz0,xz1,xz2, steps=5,above=false) {
// For hvert step kalkuler Bezier xz i tillegg, beskriver høyde
//A Primer on Bézier Curves
//http://pomax.github.io/bezierinfo/



}

	
// Angle between 2 points
function a2p(p1,p2) = atan2(p2[1]-p1[1],p2[0]-p1[0]);

// Hypotenuse between 2 points
function h2p(p1,p2) = hypotenuse(p2[1]-p1[1],p2[0]-p1[0]);

module bezier3_line(p0,p1,p2,weight=2,steps=5) {
	for (i=[0:steps-1]) {
		assign(pt1 = b3p(p0=p0,p1=p1,p2=p2,steps=steps, step=i+1))
		assign(pt2 = b3p(p0=p0,p1=p1,p2=p2,steps=steps, step=i+2)) 
		assign(pt3 = b3p(p0=p0,p1=p1,p2=p2,steps=steps, step=i+3)) {
			assign(a1 = a2p(pt1, pt2)) 
			assign(a2 = a2p(pt2, pt3))   { 	
				assign(d1 = [weight*sin(a1)*-1, weight*cos(a1)]) 
				assign(d2 = [weight*sin(a2)*-1, weight*cos(a2)]) {
					polygon(points=[pt2, pt2+d1, pt1+d1, pt1]);
					polygon(points=[pt2, pt2+d1, pt3+d2]);

				}
			}
		}
	}
}




p = [[0,18], [12,6], [20,8]];
for(i=p) 
	%translate([i[0], i[1],0]) cylinder(r=1, h=3, $fn=10);
linear_extrude(height=2)
bezier3(p0=p[0], p1=p[1], p2=p[2], weight=2, steps=20, above=false);



module cylinder_pie(h, r, angle, center=false, $fn=0) {
	dz = center ? -h/2-.1 : -.1;
	difference() {
		cylinder(r=r, h=h, center=center, $fn=$fn);
		rotate(angle/2) translate([0,-r-.1,dz]) cube([r+.1,r*2+.2, h+.2]);
		rotate(-angle/2) translate([-r-.1,-r-.1,dz]) cube([r+.1,r*2+.2, h+.2]);
	}
}

//cylinder_pie(h=20, r=5, angle=10);

module cylinder_tilted(h, r, a, $fn=0) {

	difference() {
		rotateY(a) translate([r, 0,0]) cylinder(r=r, h=h/cos(a)+tan(a)*2*r, $fn=$fn);
		translate([h,0,-h]) cylinder(r=h*2, h=h);
		translate([h,0,h]) cylinder(r=h*2, h=h);

	}
}

//rotate(45) cylinder_tilted(r=5, h=20, a=30);


module tube(h=24, od=15, id=8, split=0, poly=false, center=true, $fn=0) {
	or 	= 	od/2;
	ir	=	id/2;
	z 	= 	center ? 0 : -.01;
	y 	=	center ? -or+(or-ir)/2-.1 :-or-.01 ;
	x 	=	-split/2;
	difference() {
		if (poly) {
			cylinder_poly(h=h, r=or, center=center);
		}
		else {
			cylinder(h=h, r=or, center=center, $fn=$fn);
		}

		if (poly) {
			translate([0,0,z]) cylinder_poly(h=h+.02, r=ir, center=center);
		}
		else {
			translate([0,0,z]) cylinder(h=h+.02, r=ir, center=center, $fn=$fn);
		}
    echo(2*atan((split/2)/(od/2)));
		if (split > 0) {
			translate([0,0,z]) cylinder_pie(h=h+.02, r=od+.01, angle=split, center=center, $fn=$fn);
		}
	}
}

//tube(split=2);

/* Creates a fillet to a cylinder
 r = fillet radius
 h = z height
 dy = fillet y edge above baseline
 rc = cylinder radius
 F  = correction for floatingpoint error
*/
module filletForCylinder(r,h,dy,rc,F=0.02, center=true, $fn=$fn) {
translate([0,0,center ? -h/2 : 0])
difference() {
  translate([(cos(asin((dy+r) / (r+rc)))*rc)-F,dy-F,0]) 
cube([sqrt(pow(r + rc,2) - pow(dy+r,2))-(cos(asin((dy+r) / (r+rc)))*rc)+F,sqrt(pow(rc,2)-pow((cos(asin((dy+r) / (r+rc)))*rc),2))-dy+F,h]);
  translate([sqrt(pow(r + rc,2) - pow(dy+r,2)), r+dy, -F]) cylinder(r=r, h=h+2*F);
}

}



module fillet(r,h,z=0,fn=$fn, F=0.01) {
	difference() {
		translate([-F,-F,z]) cube([r+F,r+F,h]);
		translate([r,r,-1+z]) cylinder(r=r, h=h+2, $fn=fn);
	}
}



// Tripod hole 1/4-20
//thread_inner(r1=(25.4/4)/2-.5, r2=20, h=20, 	pitch=25.4/20, 		steps=12	);



module thread_inner(r1, r2, h, pitch=1, steps=50) {
	difference() {
	for(n=[0:h/pitch+1]) {
		translate([0,0,pitch*n]) thread_turn_inner(r1=r1, r2=r2, pitch=pitch, steps=steps);
	}
	translate([0,0,-pitch-1]) rotate(180/steps) cylinder(r=r2+1, h=pitch+1, $fn=steps);
	translate([0,0,h]) rotate(180/steps) cylinder(r=r2+1, h=pitch+1, $fn=steps);
	}

}


module thread_turn_inner(r1, r2, pitch=1, steps=50) {
	render()
		for(d=[0:steps-1])
			rotate(360/steps*d)
				translate([0,0,pitch/steps*d-pitch]) thread_step_inner(r1=r1, r2=r2, pitch=pitch, steps=steps);
}


module thread_step_inner(r1,r2,pitch, steps) {
	y1=((2*r1*_pi/steps)/cos(180/steps)+0.01)/2;
	y2=((2*r2*_pi/steps)/cos(180/steps)+0.01)/2;
	rp= r1+sqrt(pitch*pitch+pitch*pitch);
	yp=((2*rp*_pi/steps)/cos(180/steps)+0.01)/2;

	polyhedron(
		points=[
			[r1+pitch,-yp,0], [r1+pitch,yp,0], [r2,y2,0], [r2,-y2,0], // Bottom
			[r1,-y1,pitch], [r1,y1,pitch], [r2,y2,pitch], [r2,-y2,pitch]  // Top
		],
		faces=[
			[0,1,5], [5,4,0],
			[1,2,6], [6,5,1],
			[2,3,7], [7,6,2],
			[3,0,4], [4,7,3],
			[0,3,2], [2,1,0],
			[4,5,6], [6,7,4]
		]
	);

}



