package karl2d

import "core:math/linalg"
import "core:math"

//Feature toggle to switch between new and old logic
USE_NEW_DRAW_RECT_OUTLINE :: true

// Draw the outline of a rectangle with a specific thickness and color.
draw_rect_outline :: proc(rect: Rect, thickness: f32, color: Color) {
	r := rect

	if USE_NEW_DRAW_RECT_OUTLINE == false {
		draw_rect_outline_old(r, thickness, color)
		return;
	}

	if s.vertex_buffer_cpu_used + s.batch_shader.vertex_size * 24 > len(s.vertex_buffer_cpu) {
		draw_current_batch()
	}

	if s.batch_texture != s.shape_drawing_texture {
		draw_current_batch()
	}

	s.batch_texture = s.shape_drawing_texture

	thickness_x := thickness
	thickness_y := thickness

	if thickness < 0 {
		t := -thickness
		thickness_x = t
		thickness_y = t

		r.x -= t
		r.y -= t
		r.w += t*2
		r.h += t*2
	} else {
		if thickness_x > r.w / 2 {
			thickness_x = r.w / 2
		}
	
		if thickness_y > r.h / 2 {
			thickness_y = r.h / 2
		}
	}
	
	tl := Vec2{r.x, r.y}
	tr := Vec2{r.x + r.w, r.y}
	br := Vec2{r.x + r.w, r.y + r.h}
	bl := Vec2{r.x, r.y + r.h}

	tlt := Vec2{r.x + thickness_x, r.y + thickness_y}
	trt := Vec2{r.x + r.w - thickness_x, r.y + thickness_y}
	brt := Vec2{r.x + r.w - thickness_x, r.y + r.h - thickness_y}
	blt := Vec2{r.x + thickness_x, r.y + r.h - thickness_y}
	
	tluv := Vec2{0, 0}
	truv := Vec2{1, 0}
	bluv := Vec2{0, 1}
	bruv := Vec2{1, 1}

	centeruv := Vec2{0.5, 0.5}

	//Top
	batch_vertex(tlt, centeruv, color)
	batch_vertex(tl, tluv, color)
	batch_vertex(tr, tluv, color)
	
	batch_vertex(tlt, centeruv, color)
	batch_vertex(tr, tluv, color)
	batch_vertex(trt, centeruv, color)

	//Right
	batch_vertex(trt, centeruv, color)
	batch_vertex(tr, tluv, color)
	batch_vertex(br, bruv, color)

	batch_vertex(trt, centeruv, color)
	batch_vertex(br, bruv, color)
	batch_vertex(brt, centeruv, color)

	//Bottom
	batch_vertex(brt, centeruv, color)
	batch_vertex(br, bruv, color)
	batch_vertex(bl, bluv, color)

	batch_vertex(brt, centeruv, color)
	batch_vertex(bl, bluv, color)
	batch_vertex(blt, centeruv, color)

	//Left
	batch_vertex(blt, centeruv, color)
	batch_vertex(bl, bluv, color)
	batch_vertex(tl, tluv, color)

	batch_vertex(blt, centeruv, color)
	batch_vertex(tl, tluv, color)
	batch_vertex(tlt, centeruv, color)
	
}

// Draw the outline of a rectangle from its top-left corner with the given size, line thickness, and color.
draw_rect_outline_vec :: proc(position: Vec2, size: Vec2, thickness: f32, color: Color) {
	if USE_NEW_DRAW_RECT_OUTLINE == false {
		return
	}

	draw_rect_outline({position.x, position.y, size.x, size.y}, thickness, color)
}

// Draw the outline of a rectangle with a specified line thickness and color.
// Rotation is given in radians. The origin is at the top-left corner {0, 0}. 
// To rotate around the rectangle’s center, use {width / 2, height / 2}.
draw_rect_outline_ex :: proc(rect: Rect, origin: Vec2, rotation: f32, thickness: f32, color: Color) {
	
	if USE_NEW_DRAW_RECT_OUTLINE == false {
		return
	}
	
	if s.vertex_buffer_cpu_used + s.batch_shader.vertex_size * 24 > len(s.vertex_buffer_cpu) {
		draw_current_batch()
	}
	
	if s.batch_texture != s.shape_drawing_texture {
		draw_current_batch()
	}
	
	s.batch_texture = s.shape_drawing_texture
	
	r := rect
	ori := origin
	thickness_x := thickness
	thickness_y := thickness

	if thickness < 0 {
		t := -thickness
		thickness_x = t
		thickness_y = t

		r.w += t*2
		r.h += t*2

		ori.x += t
		ori.y += t
	} else {
		if thickness_x > r.w / 2 {
			thickness_x = r.w / 2
		}
	
		if thickness_y > r.h / 2 {
			thickness_y = r.h / 2
		}
	}

	tl, tr, bl, br: Vec2
	tlt, trt, brt, blt: Vec2
	
	if rotation == 0 {
		x := r.x - ori.x
		y := r.y - ori.y

		tl = {x, y}
		tr = {x + r.w, y}
		br = {x + r.w, y + r.h}
		bl = {x, y + r.h}

		tlt = {x + thickness_x, y + thickness_y}
		trt = {x + r.w - thickness_x, y + thickness_y}
		brt = {x + r.w - thickness_x, y + r.h - thickness_y}
		blt = {x + thickness_x, y + r.h - thickness_y}
	} else {
		sin_rot := math.sin(rotation)
		cos_rot := math.cos(rotation)
		x := r.x
		y := r.y
		dx := -ori.x
		dy := -ori.y
		
		tl = {
			x + dx * cos_rot - dy * sin_rot,
			y + dx * sin_rot + dy * cos_rot,
		}
		
		tr = {
			x + (dx + r.w) * cos_rot - dy * sin_rot,
			y + (dx + r.w) * sin_rot + dy * cos_rot,
		}
		
		bl = {
			x + dx * cos_rot - (dy + r.h) * sin_rot,
			y + dx * sin_rot + (dy + r.h) * cos_rot,
		}
		
		br = {
			x + (dx + r.w) * cos_rot - (dy + r.h) * sin_rot,
			y + (dx + r.w) * sin_rot + (dy + r.h) * cos_rot,
		}
		
		tlt = {
			x + (dx + thickness_x) * cos_rot - (dy + thickness_y) * sin_rot,
			y + (dx + thickness_x) * sin_rot + (dy + thickness_y) * cos_rot,
		}
		
		trt = {
			x + (dx + r.w - thickness_x) * cos_rot - (dy + thickness_y) * sin_rot,
			y + (dx + r.w - thickness_x) * sin_rot + (dy + thickness_y) * cos_rot,
		}
		
		blt = {
			x + (dx + thickness_x) * cos_rot - (dy + r.h - thickness_y) * sin_rot,
			y + (dx + thickness_x) * sin_rot + (dy + r.h - thickness_y) * cos_rot,
		}
		
		brt = {
			x + (dx + r.w - thickness_x) * cos_rot - (dy + r.h - thickness_y) * sin_rot,
			y + (dx + r.w - thickness_x) * sin_rot + (dy + r.h - thickness_y) * cos_rot,
		}
	}

	tluv := Vec2{0, 0}
	truv := Vec2{1, 0}
	bluv := Vec2{0, 1}
	bruv := Vec2{1, 1}

	centeruv := Vec2{0.5, 0.5}

	//Top
	batch_vertex(tlt, centeruv, color)
	batch_vertex(tl, tluv, color)
	batch_vertex(tr, tluv, color)
	
	batch_vertex(tlt, centeruv, color)
	batch_vertex(tr, tluv, color)
	batch_vertex(trt, centeruv, color)

	//Right
	batch_vertex(trt, centeruv, color)
	batch_vertex(tr, tluv, color)
	batch_vertex(br, bruv, color)

	batch_vertex(trt, centeruv, color)
	batch_vertex(br, bruv, color)
	batch_vertex(brt, centeruv, color)

	//Bottom
	batch_vertex(brt, centeruv, color)
	batch_vertex(br, bruv, color)
	batch_vertex(bl, bluv, color)

	batch_vertex(brt, centeruv, color)
	batch_vertex(bl, bluv, color)
	batch_vertex(blt, centeruv, color)

	//Left
	batch_vertex(blt, centeruv, color)
	batch_vertex(bl, bluv, color)
	batch_vertex(tl, tluv, color)

	batch_vertex(blt, centeruv, color)
	batch_vertex(tl, tluv, color)
	batch_vertex(tlt, centeruv, color)
}

//Feature toggle to switch between new and old logic
USE_NEW_DRAW_CIRCLE_OUTLINE :: true

//Draw the outline of a circle with a specific radius, thickness and color.
//Optionally specify the number of `segments` to control the smoothness.
draw_circle_outline :: proc(center: Vec2, radius: f32, thickness: f32, color: Color, segments := 16) {
	if USE_NEW_DRAW_CIRCLE_OUTLINE == false {
		draw_circle_outline_old(center, radius, thickness, color, segments)
		return
	}

	if s.vertex_buffer_cpu_used + s.batch_shader.vertex_size * 6 * segments > len(s.vertex_buffer_cpu) {
		draw_current_batch()
	}

	if s.batch_texture != s.shape_drawing_texture {
		draw_current_batch()
	}

	s.batch_texture = s.shape_drawing_texture

	t := thickness
	r := radius

	if t > radius {
		t = radius
	} else if t < 0 {
		t = -t
		r += t
	}

	radians_per_segment := f32(math.TAU / f32(segments))
	rot := linalg.matrix2_rotate(radians_per_segment)
	prev_p := center + rot * Vec2{r, 0}
	prev_pt := center + rot * Vec2{r - t, 0}
	
	for s in 0..=segments {
		radians_per_segment := (f32(s)/f32(segments)) * math.TAU
		rot := linalg.matrix2_rotate(radians_per_segment)
		
		p := center + rot * Vec2{r, 0}
		pt := center + rot * Vec2{r - t, 0}
		
		batch_vertex(prev_pt, {0, 0}, color)
		batch_vertex(prev_p, {0, 0}, color)
		batch_vertex(p, {0, 0}, color)

		batch_vertex(prev_pt, {0, 0}, color)
		batch_vertex(p, {0, 0}, color)
		batch_vertex(pt, {0, 0}, color)

		prev_p = p
		prev_pt = pt
	}
}

//Draw the outline of a circle with a specific radius, thickness and color.
//Rotation is in radians and the origin {0, 0} is at the center of the circle.
//Optionally specify the number of `segments` to control the smoothness.
draw_circle_outline_ex :: proc(position: Vec2, radius: f32, origin: Vec2, rotation: f32, thickness: f32, color: Color, segments := 16) {
	if USE_NEW_DRAW_CIRCLE_OUTLINE == false {
		return
	}

	if s.vertex_buffer_cpu_used + s.batch_shader.vertex_size * 6 * segments > len(s.vertex_buffer_cpu) {
		draw_current_batch()
	}

	if s.batch_texture != s.shape_drawing_texture {
		draw_current_batch()
	}

	s.batch_texture = s.shape_drawing_texture

	thickness := thickness
	radius := radius
	
	if thickness > radius {
		thickness = radius
	} else if thickness < 0 {
		thickness = -thickness
		radius += thickness
	}

	sin_rot := math.sin(rotation)
	cos_rot := math.cos(rotation)

	radians_per_segment := math.TAU / f32(segments)
	segment_rotation := linalg.matrix2_rotate(radians_per_segment)

	current_p0 := Vec2{radius - thickness, 0}
	current_p1 := Vec2{radius, 0}

	p0 := origin + current_p0
	prev_p0 := Vec2{
		position.x + p0.x * cos_rot - p0.y * sin_rot,
		position.y + p0.x * sin_rot + p0.y * cos_rot,
	}
	
	p1 := origin + current_p1
	prev_p1 := Vec2{
		position.x + p1.x * cos_rot - p1.y * sin_rot,
		position.y + p1.x * sin_rot + p1.y * cos_rot,
	}

	for s in 0..=segments {
		current_p0 = segment_rotation * current_p0
		current_p1 = segment_rotation * current_p1

		p0 := origin + current_p0
		p0 = {
			position.x + p0.x * cos_rot - p0.y * sin_rot,
			position.y + p0.x * sin_rot + p0.y * cos_rot,
		}

		p1 := origin + current_p1
		p1 = {
			position.x + p1.x * cos_rot - p1.y * sin_rot,
			position.y + p1.x * sin_rot + p1.y * cos_rot,
		}

		batch_vertex(prev_p0, {0, 0}, color)
		batch_vertex(prev_p1, {0, 0}, color)
		batch_vertex(p1, {0, 0}, color)

		batch_vertex(prev_p0, {0, 0}, color)
		batch_vertex(p1, {0, 0}, color)
		batch_vertex(p0, {0, 0}, color)

		prev_p1 = p1
		prev_p0 = p0
	}
}


// Draws a circular arc.
//
// This procedure draws a circular arc centered at the specified `position` with a given `radius` and `color`.
// The portion of the circle to be drawn is defined by `start_angle` and `end_angle` in radians.
//
// You can optionally specify the number of `segments` to control the smoothness of the curve.
// Higher values result in a smoother arc. The `segments` value defaults to 16 and is clamped to the range [3, 128].
draw_arc :: proc(position: Vec2, radius: f32, start_angle: f32, end_angle: f32, color: Color, segments: int = 16){
	
	if s.vertex_buffer_cpu_used + s.batch_shader.vertex_size * 3 * segments > len(s.vertex_buffer_cpu) {
		draw_current_batch()
	}

	if s.batch_texture != s.shape_drawing_texture {
		draw_current_batch()
	}

	s.batch_texture = s.shape_drawing_texture

	start_angle := start_angle
	end_angle := end_angle
	if end_angle < start_angle {
		tmp := start_angle
		start_angle = end_angle
		end_angle = tmp
	}

	radians_per_segment := (end_angle - start_angle) / f32(segments)
	segment_rotation := linalg.matrix2_rotate(radians_per_segment)
	
	center := position + Vec2{0, 0}

	prev_p := linalg.matrix2_rotate(start_angle) * Vec2{radius, 0}
	prev_segment := position + prev_p
	for s in 0..<segments {		
		p := segment_rotation * prev_p
		prev_p = p
		
		segment := position + p
		batch_vertex(center, {0, 0}, color)
		batch_vertex(prev_segment, {0, 0}, color)
		batch_vertex(segment, {0, 0}, color)
		prev_segment = segment
	}
}

// Draws a circular arc.
//
// This procedure draws a circular arc centered at the specified `position` with a given `radius` and `color`.
// The portion of the circle to be drawn is defined by `start_angle` and `end_angle` in radians.
//
// You can optionally specify the number of `segments` to control the smoothness of the curve.
// Higher values result in a smoother arc. The `segments` value defaults to 16 and is clamped to the range [3, 128].
draw_arc_ex :: proc(position: Vec2, radius: f32, start_angle: f32, end_angle: f32, rotation: f32, origin: Vec2, color: Color, segments: int = 16){
	
	if s.vertex_buffer_cpu_used + s.batch_shader.vertex_size * 3 * segments > len(s.vertex_buffer_cpu) {
		draw_current_batch()
	}

	if s.batch_texture != s.shape_drawing_texture {
		draw_current_batch()
	}

	s.batch_texture = s.shape_drawing_texture

	start_angle := start_angle
	end_angle := end_angle
	if end_angle < start_angle {
		tmp := start_angle
		start_angle = end_angle
		end_angle = tmp
	}

	object_rotation := linalg.matrix2_rotate(rotation)

	radians_per_segment := (end_angle - start_angle) / f32(segments)
	segment_rotation := linalg.matrix2_rotate(radians_per_segment)
	
	center := position + object_rotation * -origin

	prev_p := linalg.matrix2_rotate(start_angle) * Vec2{radius, 0}
	prev_segment := position + object_rotation * (prev_p - origin)
	for s in 0..<segments {		
		p := segment_rotation * prev_p
		prev_p = p
		
		segment := position + object_rotation * (p - origin)
		batch_vertex(center, {0, 0}, color)
		batch_vertex(prev_segment, {0, 0}, color)
		batch_vertex(segment, {0, 0}, color)
		prev_segment = segment
	}
}

// Draws a circular arc.
//
// This procedure draws a circular arc centered at the specified `position` with a given `radius` and `color`.
// The portion of the circle to be drawn is defined by `start_angle` and `end_angle` in radians.
//
// You can optionally specify the number of `segments` to control the smoothness of the curve.
// Higher values result in a smoother arc. The `segments` value defaults to 16 and is clamped to the range [3, 128].
draw_arc_open :: proc(position: Vec2, radius: f32, start_angle: f32, end_angle: f32, color: Color, segments: int = 16){
		if s.vertex_buffer_cpu_used + s.batch_shader.vertex_size * 3 * (segments - 1) > len(s.vertex_buffer_cpu) {
		draw_current_batch()
	}

	if s.batch_texture != s.shape_drawing_texture {
		draw_current_batch()
	}

	s.batch_texture = s.shape_drawing_texture

	start_angle := start_angle
	end_angle := end_angle
	if end_angle < start_angle {
		tmp := start_angle
		start_angle = end_angle
		end_angle = tmp
	}

	radians_per_segment := (end_angle - start_angle) / f32(segments)
	segment_rotation := linalg.matrix2_rotate(radians_per_segment)
	
	prev_p := linalg.matrix2_rotate(start_angle) * Vec2{radius, 0}
	start := position + prev_p

	prev_p = segment_rotation * prev_p
	prev_segment := position + prev_p

	for s in 1..<segments {		
		p := segment_rotation * prev_p
		prev_p = p
		
		segment := position + p
		batch_vertex(start, {0, 0}, color)
		batch_vertex(prev_segment, {0, 0}, color)
		batch_vertex(segment, {0, 0}, color)

		prev_segment = segment
	}
}

// Draws a circular arc.
//
// This procedure draws a circular arc centered at the specified `position` with a given `radius` and `color`.
// The portion of the circle to be drawn is defined by `start_angle` and `end_angle` in radians.
//
// You can optionally specify the number of `segments` to control the smoothness of the curve.
// Higher values result in a smoother arc. The `segments` value defaults to 16 and is clamped to the range [3, 128].
draw_arc_open_ex :: proc(position: Vec2, radius: f32, start_angle: f32, end_angle: f32, rotation: f32, origin: Vec2, color: Color, segments: int = 16){
	if s.vertex_buffer_cpu_used + s.batch_shader.vertex_size * 3 * (segments - 1) > len(s.vertex_buffer_cpu) {
		draw_current_batch()
	}

	if s.batch_texture != s.shape_drawing_texture {
		draw_current_batch()
	}

	s.batch_texture = s.shape_drawing_texture

	start_angle := start_angle
	end_angle := end_angle
	if end_angle < start_angle {
		tmp := start_angle
		start_angle = end_angle
		end_angle = tmp
	}

	object_rotation := linalg.matrix2_rotate(rotation)

	radians_per_segment := (end_angle - start_angle) / f32(segments)
	segment_rotation := linalg.matrix2_rotate(radians_per_segment)
	
	prev_p := linalg.matrix2_rotate(start_angle) * Vec2{radius, 0}
	start := position + object_rotation * (prev_p - origin)

	prev_p = segment_rotation * prev_p
	prev_segment := position + object_rotation * (prev_p - origin)
	for s in 1..<segments {		
		p := segment_rotation * prev_p
		prev_p = p
		
		segment := position + object_rotation * (p - origin)
		batch_vertex(start, {0, 0}, color)
		batch_vertex(prev_segment, {0, 0}, color)
		batch_vertex(segment, {0, 0}, color)

		prev_segment = segment
	}
}

draw_poly_line :: proc(position: Vec2, points: []Vec2, thickness: f32, color: Color){ 
	if len(points) < 2 {
		return
	}

	//This is not correct redo it when procedure is finished
	if s.vertex_buffer_cpu_used + s.batch_shader.vertex_size * 3 * 2 * len(points) > len(s.vertex_buffer_cpu) {
		draw_current_batch()
	}

	if s.batch_texture != s.shape_drawing_texture {
		draw_current_batch()
	}

	s.batch_texture = s.shape_drawing_texture


	half_tickness := thickness / 2.0

	start_point := position + points[0]

	prev_epr := Vec2{0, 0}
	use_prev_epr := false

	prev_epl := Vec2{0, 0}
	use_prev_epl := false

	for i in 1..<len(points) {
		end_point := position + points[i]

		direction := end_point - start_point
		perpendicular_direction := linalg.normalize(Vec2{-direction.y, direction.x})

		spr := start_point + perpendicular_direction * half_tickness
		if use_prev_epr {
			spr = prev_epr
			use_prev_epr = false
		}
		
		spl := start_point - perpendicular_direction * half_tickness
		if use_prev_epl {
			spl = prev_epl
			use_prev_epl = false
		}
		
		epr := end_point + perpendicular_direction * half_tickness
		epl := end_point - perpendicular_direction * half_tickness

		if i + 1 < len(points){

			from_direction := linalg.normalize(-direction)
			next_point := position + points[i+1]
			next_direction := linalg.normalize(next_point - end_point)
			next_perpendicular_direction := linalg.normalize(Vec2{-next_direction.y, next_direction.x})
			
			half_direction := linalg.lerp(from_direction, next_direction, 0.5)
			if half_direction.x != 0 || half_direction.y != 0 {
				
				if linalg.cross(from_direction, half_direction) < 0{
					intersect_point, ok := line_intersect(spr, epr, end_point, end_point + half_direction * thickness * 100)
					if ok {
						epr = intersect_point 
						use_prev_epr = true
						prev_epr = epr
					}

					//bevel logic
					npl := end_point - next_perpendicular_direction * half_tickness
					batch_vertex(epl, {0, 0}, color)
					batch_vertex(npl, {0, 0}, color)
					batch_vertex(end_point, {0, 0}, color)
				} else {
					intersect_point, ok := line_intersect(spl, epl, end_point, end_point + half_direction * thickness * 100)
					if ok {
						epl = intersect_point 
						use_prev_epl = true
						prev_epl = epl
					}

					//bevel logic
					npr := end_point + next_perpendicular_direction * half_tickness
					batch_vertex(npr, {0, 0}, color)
					batch_vertex(epr, {0, 0}, color)
					batch_vertex(end_point, {0, 0}, color)
				}
			}
		}

		batch_vertex(start_point, {0, 0}, color)
		batch_vertex(end_point, {0, 0}, color)
		batch_vertex(spr, {0, 0}, color)

		batch_vertex(spr, {0, 0}, color)
		batch_vertex(end_point, {0, 0}, color)
		batch_vertex(epr, {0, 0}, color)

		batch_vertex(start_point, {0, 0}, color)
		batch_vertex(spl, {0, 0}, color)
		batch_vertex(end_point, {0, 0}, color)

		batch_vertex(spl, {0, 0}, color)
		batch_vertex(epl, {0, 0}, color)
		batch_vertex(end_point, {0, 0}, color)

		start_point = end_point
	}
}

line_intersect :: proc(p1, p2, p3, p4: Vec2) -> (intr: Vec2, ok: bool = false) {
    x1, y1 := p1.x, p1.y
    x2, y2 := p2.x, p2.y
    x3, y3 := p3.x, p3.y
    x4, y4 := p4.x, p4.y

    den := (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
    if den == 0 {
        return
    }

    t := ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / den
    u := -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / den

    if t > 0 && t < 1 && u > 0 {
        intr.x = x1 + t * (x2 - x1)
        intr.y = y1 + t * (y2 - y1)
        ok = true
        return
    }

    return
}

draw_quad :: proc(p1: Vec2, p2: Vec2, p3: Vec2, p4: Vec2, color: Color) {
	if s.vertex_buffer_cpu_used + s.batch_shader.vertex_size * 4 > len(s.vertex_buffer_cpu) {
		draw_current_batch()
	}

	if s.batch_texture != s.shape_drawing_texture {
		draw_current_batch()
	}

	s.batch_texture = s.shape_drawing_texture

	batch_vertex(p1, {0, 0}, color)
	batch_vertex(p2, {0, 0}, color)
	batch_vertex(p3, {0, 0}, color)

	batch_vertex(p1, {0, 0}, color)
	batch_vertex(p3, {0, 0}, color)
	batch_vertex(p4, {0, 0}, color)
}

draw_tris :: proc(p1: Vec2, p2: Vec2, p3: Vec2, color: Color) {
	if s.vertex_buffer_cpu_used + s.batch_shader.vertex_size * 3 > len(s.vertex_buffer_cpu) {
		draw_current_batch()
	}

	if s.batch_texture != s.shape_drawing_texture {
		draw_current_batch()
	}

	s.batch_texture = s.shape_drawing_texture

	batch_vertex(p1, {0, 0}, color)
	batch_vertex(p2, {0, 0}, color)
	batch_vertex(p3, {0, 0}, color)
}