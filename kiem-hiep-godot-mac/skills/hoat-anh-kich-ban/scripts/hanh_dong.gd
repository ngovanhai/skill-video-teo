extends RefCounted
# hanh_dong.gd — HỆ THỐNG VŨ ĐẠO HÀNH ĐỘNG CHIBI 2D (CHIBI COMBAT & ACTION CHOREOGRAPHY)
# Tích hợp cho skill hoat-anh-kich-ban — Hoạt cảnh Kiếm Hiệp & Lịch Sử Tèo Tửu Lâu.
# Cung cấp 12 tuyệt kỹ vũ đạo: chém kiếm có vệt sáng, đối đầu đao kiếm tóe lửa, bắn cung đạn đạo,
# cưỡi ngựa phi nước đại, đập bàn đứng dậy chém góc bàn, thổ huyết gục ngã, quỳ dâng chiếu thư,
# nhấp rượu cạn ly, quạt lông tạo gió lốc, phất cờ lệnh, gảy đàn sóng âm, tụ khí phóng chưởng.

const Ng := preload("res://nguoi.gd")
const B := preload("res://but.gd")

# ==============================================================================
# HÀM BĂM & TIỆN ÍCH HÌNH HỌC DÙNG CHUNG
# ==============================================================================

static func _h(x: float) -> float:
	var s := sin(x * 127.1 + 311.7) * 43758.5453
	return s - floor(s)

static func _smooth(a: float, b: float, x: float) -> float:
	var t := clampf((x - a) / maxf(0.0001, b - a), 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)

static func _ease_out(x: float) -> float:
	var t := clampf(x, 0.0, 1.0)
	return 1.0 - (1.0 - t) * (1.0 - t)

# Vẽ vệt trăng lưỡi liềm (kiếm khí / đao quang)
static func crescent(ci: CanvasItem, p: Vector2, r: float, a0: float, a1: float, rot: float, col: Color, hot: Color, alpha: float = 1.0) -> void:
	if alpha <= 0.001: return
	var outer := PackedVector2Array()
	var inner := PackedVector2Array()
	var n := 16
	for i in n + 1:
		var a := lerpf(a0, a1, float(i) / n)
		var th := sin(clampf((a + 1.2) / 2.4, 0.0, 1.0) * PI)
		outer.append(p + Vector2(cos(a), sin(a)).rotated(rot) * r)
		inner.append(p + Vector2(cos(a), sin(a)).rotated(rot) * (r * (1.0 - 0.35 * th)) + Vector2(-r * 0.12 * th, 0).rotated(rot))
	var poly := outer.duplicate()
	inner.reverse()
	poly.append_array(inner)
	if Geometry2D.triangulate_polygon(poly).size() > 0:
		ci.draw_colored_polygon(poly, Color(col, col.a * alpha))
	ci.draw_polyline(outer, Color(hot, hot.a * alpha), 3.5)

# Vòng sóng xung kích mở rộng
static func shockwave(ci: CanvasItem, p: Vector2, r: float, col: Color, w: float = 3.0, alpha: float = 1.0) -> void:
	if alpha <= 0.001 or r <= 0.5: return
	ci.draw_arc(p, r, 0, TAU, 36, Color(col, col.a * alpha), w)
	ci.draw_arc(p, maxf(1.0, r * 0.82), 0, TAU, 28, Color(col.lightened(0.2), col.a * alpha * 0.4), w * 1.6)

# Tia lửa tóe ra theo chùm
static func sparks(ci: CanvasItem, p: Vector2, count: int, base_dir: Vector2, spread: float, speed_max: float, t_age: float, col: Color, seed: float = 0.0) -> void:
	var fade := clampf(1.0 - t_age / 0.55, 0.0, 1.0)
	if fade <= 0.01: return
	for i in count:
		var s := seed + float(i) * 3.17
		var ang := base_dir.angle() + (_h(s) - 0.5) * spread
		var sp := lerpf(120.0, speed_max, _h(s + 1.1))
		var len := lerpf(14.0, 32.0, _h(s + 2.3)) * fade
		var v := Vector2(cos(ang), sin(ang))
		var pt := p + v * sp * t_age
		ci.draw_line(pt, pt - v * len, Color(col, fade), 2.2)

# Cụm khói bụi đất
static func dust_puff(ci: CanvasItem, p: Vector2, r: float, col: Color, alpha: float = 1.0) -> void:
	if alpha <= 0.001 or r <= 0.5: return
	for i in 4:
		var off := Vector2((_h(float(i) * 1.7) - 0.5) * r * 0.8, -_h(float(i) * 2.3) * r * 0.4)
		var cr := r * (0.6 + 0.4 * _h(float(i) * 3.1))
		ci.draw_circle(p + off, cr, Color(col, alpha * 0.25))

# ==============================================================================
# 1. TUỐT KIẾM CHÉM RA VỆT SÁNG HÌNH CUNG (SWORD ARC SLASH)
# ==============================================================================
static func chem_kiem(ci: CanvasItem, pos: Vector2, dir: float, t: float, opt: Dictionary = {}) -> void:
	var vai: String = opt.get("vai", "chudu")
	var F: float = opt.get("F", 125.0)
	var col: Color = opt.get("col", Color("ff8f00"))
	var hot: Color = opt.get("hot", Color("fff9c4"))
	var radius: float = opt.get("radius", 185.0)
	var dur: float = opt.get("dur", 1.8)
	var cyc := fmod(t, dur)
	
	var char_pos := pos
	var pose := "dung"
	var expr := "quyet-tam"
	var lunge := 0.0
	
	if cyc < 0.5:
		# Giai đoạn 1: Lấy đà, rút gươm hông ra sau
		pose = "dangdao"
		expr = "quyet-tam"
	elif cyc < 1.0:
		# Giai đoạn 2: Bổ nhát kiếm chém chéo tới trước
		pose = "chem"
		expr = "gian"
		var k := (cyc - 0.5) / 0.5
		lunge = sin(k * PI) * 50.0 * dir
		char_pos.x += lunge
	else:
		# Giai đoạn 3: Thu thế, kiếm chỉ xuống đất
		pose = "dung"
		expr = "tu-tin"
		
	var hR := Ng.ve(ci, vai, char_pos, F, pose, expr, t, dir)
	
	# Vẽ thanh kiếm thép
	var sword_dir := Vector2(dir, 0.3).normalized()
	if pose == "dangdao":
		sword_dir = Vector2(-dir * 0.7, -0.7).normalized()
	elif pose == "chem":
		sword_dir = Vector2(dir * 0.9, 0.4).normalized()
	elif pose == "dung":
		sword_dir = Vector2(dir * 0.4, 0.9).normalized()
		
	var blade_len := F * 1.15
	var tip := hR + sword_dir * blade_len
	var sword_col := Color("d7d9db")
	ci.draw_line(hR - sword_dir * 15.0, hR + sword_dir * 8.0, Color("4a2810"), 6.0) # Chuôi kiếm
	ci.draw_line(hR + sword_dir * 8.0 + sword_dir.orthogonal() * 10.0, hR + sword_dir * 8.0 - sword_dir.orthogonal() * 10.0, Color("c9a24a"), 5.0) # Đốc kiếm
	ci.draw_line(hR + sword_dir * 8.0, tip, sword_col, 3.5) # Lưỡi kiếm
	ci.draw_line(hR + sword_dir * 8.0, tip, Color(1, 1, 1, 0.8), 1.5) # Sống kiếm sáng
	
	# Tua kiếm đỏ đung đưa
	var tassel := hR - sword_dir * 15.0
	ci.draw_line(tassel, tassel + Vector2(-dir * 8.0 + sin(t * 12.0) * 4.0, 16.0), Color("b8352a"), 3.0)
	
	# Vệt chém hình cung (Slash Arc)
	if cyc >= 0.5 and cyc < 1.0:
		var k := (cyc - 0.5) / 0.5
		var arc_alpha := 1.0 - k * 0.8
		var slash_center := hR + Vector2(dir * 25.0, -15.0)
		var rot_base := 0.25 if dir > 0 else PI - 0.25
		crescent(ci, slash_center, radius, -1.3, 1.3, rot_base, col, hot, arc_alpha)
		
		# Vệt sáng phụ bên trong
		crescent(ci, slash_center, radius * 0.82, -1.1, 1.1, rot_base, col.lightened(0.2), Color(1, 1, 1), arc_alpha * 0.7)
		
		# Bắn tia lửa tóe ra
		sparks(ci, slash_center + Vector2(dir * radius * 0.7, 0), 16, Vector2(dir, 0.2), 1.1, 450.0, k * 0.5, hot, cyc)
		
		# Sóng xung kích nhỏ
		shockwave(ci, slash_center, k * 140.0, col, 2.5, 1.0 - k)
		
		# Bụi chân khi xông lên
		dust_puff(ci, char_pos, 28.0, Color("8d6e63"), 1.0 - k)

# ==============================================================================
# 2. ĐỐI ĐẦU ĐAO KIẾM CHẠM NHAU TÓE LỬA (CLASH SPARKS & RECOIL)
# ==============================================================================
static func doi_dau_kiem_dao(ci: CanvasItem, pos1: Vector2, pos2: Vector2, t: float, opt: Dictionary = {}) -> void:
	var vai1: String = opt.get("vai1", "chudu")
	var vai2: String = opt.get("vai2", "taothao")
	var F1: float = opt.get("F1", 120.0)
	var F2: float = opt.get("F2", 120.0)
	var dur: float = opt.get("dur", 2.2)
	var cyc := fmod(t, dur)
	
	var mid := (pos1 + pos2) * 0.5
	var half_gap := absf(pos2.x - pos1.x) * 0.5
	var p1 := pos1
	var p2 := pos2
	var pose1 := "dung"
	var pose2 := "dung"
	var expr1 := "gian"
	var expr2 := "gian"
	var clash_now := false
	
	if cyc < 0.65:
		# Giai đoạn 1: Lao nhanh vào nhau
		var k := _ease_out(cyc / 0.65)
		p1.x = lerpf(pos1.x, mid.x - 65.0, k)
		p2.x = lerpf(pos2.x, mid.x + 65.0, k)
		pose1 = "chay"
		pose2 = "chay"
		expr1 = "quyet-tam"
		expr2 = "quyet-tam"
		dust_puff(ci, p1, 20.0, Color("8d6e63"), 0.5)
		dust_puff(ci, p2, 20.0, Color("8d6e63"), 0.5)
	elif cyc < 1.15:
		# Giai đoạn 2: Chạm đao kiếm cực mạnh (CLASH!)
		clash_now = true
		var sh := sin(cyc * 65.0) * 3.5
		p1.x = mid.x - 65.0 + sh
		p2.x = mid.x + 65.0 - sh
		pose1 = "chem"
		pose2 = "dangdao"
		expr1 = "gian"
		expr2 = "gian"
	else:
		# Giai đoạn 3: Bị lực chấn giật lùi về sau
		var k_back := _ease_out((cyc - 1.15) / 1.05)
		p1.x = lerpf(mid.x - 65.0, pos1.x, k_back)
		p2.x = lerpf(mid.x + 65.0, pos2.x, k_back)
		pose1 = "dangdao"
		pose2 = "dung"
		expr1 = "quyet-tam"
		expr2 = "soc"
		
	var h1 := Ng.ve(ci, vai1, p1, F1, pose1, expr1, t, 1.0)
	var h2 := Ng.ve(ci, vai2, p2, F2, pose2, expr2, t, -1.0)
	
	var clash_pt := mid + Vector2(0, -95.0)
	
	# Vẽ kiếm người 1 chém chéo xuống
	ci.draw_line(h1, clash_pt + Vector2(25, 20), Color("cfd8dc"), 3.8)
	ci.draw_line(h1, clash_pt + Vector2(25, 20), Color(1, 1, 1), 1.6)
	
	# Vẽ đao người 2 đỡ chéo lên
	ci.draw_line(h2, clash_pt - Vector2(25, 20), Color("b0bec5"), 4.8)
	ci.draw_line(h2, clash_pt - Vector2(25, 20), Color(1, 1, 1), 2.0)
	
	# Hiệu ứng tóe lửa chớp nháy tại điểm va chạm
	if clash_now:
		var dt_clash := cyc - 0.65
		# Lõi chớp trắng rực
		ci.draw_circle(clash_pt, 16.0, Color("ffffff"))
		ci.draw_circle(clash_pt, 28.0, Color("ffe082", 0.7))
		
		# Ngôi sao 8 cánh tóe sáng
		for s in 4:
			var ang := s * (PI * 0.25) + sin(t * 18.0) * 0.1
			var v := Vector2(cos(ang), sin(ang))
			var ray_len := 42.0 + sin(t * 30.0 + s) * 12.0
			ci.draw_line(clash_pt - v * ray_len, clash_pt + v * ray_len, Color("fff8e1"), 2.5)
			
		# Chùm tia lửa văng đa hướng
		sparks(ci, clash_pt, 24, Vector2(0, -1), PI * 1.5, 520.0, dt_clash, Color("ffd54f"), cyc)
		sparks(ci, clash_pt, 16, Vector2(0, 1), PI * 1.2, 400.0, dt_clash, Color("ff6f00"), cyc + 1.0)
		
		# Vòng sóng xung kích kép
		shockwave(ci, clash_pt, dt_clash * 280.0, Color("ffe082"), 3.5, 1.0 - dt_clash / 0.5)
		shockwave(ci, clash_pt, dt_clash * 170.0, Color("ff6f00"), 2.0, 1.0 - dt_clash / 0.5)

# ==============================================================================
# 3. GIƯƠNG CUNG BẮN TÊN VỚI VỆT KHÓI ĐẠN ĐẠO (DRAW & RELEASE BOW)
# ==============================================================================
static func ban_cung(ci: CanvasItem, pos: Vector2, dir: float, t: float, opt: Dictionary = {}) -> void:
	var vai: String = opt.get("vai", "hoangcai")
	var F: float = opt.get("F", 115.0)
	var dur: float = opt.get("dur", 2.4)
	var cyc := fmod(t, dur)
	
	var pose := "giotay"
	var expr := "quyet-tam"
	var bow_pull := 0.0
	
	if cyc < 0.9:
		# Giai đoạn 1: Giương cung kéo căng dây
		pose = "cam"
		expr = "quyet-tam"
		bow_pull = (cyc / 0.9) * 38.0
	elif cyc < 1.0:
		# Giai đoạn 2: Buông dây tên bật đi
		pose = "chi"
		expr = "quyet-tam"
		bow_pull = 0.0
	else:
		# Giai đoạn 3: Giữ thế ngắm nhìn mục tiêu
		pose = "chi"
		expr = "tu-tin"
		bow_pull = 0.0
		
	var hR := Ng.ve(ci, vai, pos, F, pose, expr, t, dir)
	
	# Cánh cung uốn cong
	var bow_center := hR + Vector2(dir * 18.0, -15.0)
	var bow_top := bow_center + Vector2(dir * 12.0, -68.0)
	var bow_bot := bow_center + Vector2(dir * 12.0, 68.0)
	
	# Thân cung gỗ dâu tằm + sừng
	var bow_pts := PackedVector2Array([
		bow_top,
		bow_center + Vector2(dir * 28.0, 0),
		bow_bot
	])
	B.net(ci, bow_pts, 5.5, Color("3e2723"), 0.0)
	B.net(ci, bow_pts, 3.0, Color("8d6e63"), 1.0)
	
	# Dây cung
	var string_notch := bow_center - Vector2(dir * bow_pull, 0)
	ci.draw_line(bow_top, string_notch, Color("f5f5f5"), 1.8)
	ci.draw_line(bow_bot, string_notch, Color("f5f5f5"), 1.8)
	
	# Mũi tên nạp trên dây hoặc đang bay
	if cyc < 0.9:
		# Tên nằm trên cánh cung
		var arrow_tip := string_notch + Vector2(dir * 72.0, 0)
		ci.draw_line(string_notch, arrow_tip, Color("4e342e"), 3.2)
		ci.draw_colored_polygon(PackedVector2Array([arrow_tip, arrow_tip + Vector2(-dir * 12, -5), arrow_tip + Vector2(-dir * 12, 5)]), Color("cfd8dc"))
		# Đốm sáng tụ lực đầu mũi tên
		var glint := sin(t * 15.0) * 4.0
		ci.draw_circle(arrow_tip, 6.0 + glint, Color("ffe082", 0.6))
	else:
		# Tên đã rời cung, lao vút đi với vận tốc cao
		var dt_fly := cyc - 0.9
		var arr_x := pos.x + dir * (65.0 + dt_fly * 1250.0)
		var arr_y := bow_center.y - sin(dt_fly * 1.4) * 30.0
		var arr_tip := Vector2(arr_x, arr_y)
		var arr_tail := arr_tip - Vector2(dir * 65.0, 0)
		
		# Thân tên thép + lông chim đỏ
		ci.draw_line(arr_tail, arr_tip, Color("4e342e"), 3.5)
		ci.draw_colored_polygon(PackedVector2Array([arr_tip, arr_tip + Vector2(-dir * 14, -6), arr_tip + Vector2(-dir * 14, 6)]), Color("cfd8dc"))
		ci.draw_line(arr_tail, arr_tail + Vector2(-dir * 10, -6), Color("b71c1c"), 3.0) # Lông đuôi đỏ
		ci.draw_line(arr_tail, arr_tail + Vector2(-dir * 10, 6), Color("b71c1c"), 3.0)
		
		# Vệt khói đạn đạo (Ballistic Smoke Trail)
		for s in 12:
			var lag := float(s) * 0.02
			var past_x := pos.x + dir * (65.0 + maxf(0.0, dt_fly - lag) * 1250.0)
			var past_y := bow_center.y - sin(maxf(0.0, dt_fly - lag) * 1.4) * 30.0
			var past_alpha := clampf(1.0 - float(s) / 12.0, 0.0, 1.0) * 0.6
			var past_r := 3.0 + float(s) * 1.5
			ci.draw_circle(Vector2(past_x, past_y), past_r, Color("ffe082", past_alpha))
			
		# Sóng phát tên ở cánh cung
		if dt_fly < 0.25:
			shockwave(ci, bow_center, dt_fly * 120.0, Color("fff8e1"), 2.0, 1.0 - dt_fly / 0.25)

# ==============================================================================
# 4. CƯỠI TUẤN MÃ PHI NƯỚC ĐẠI (GALLOPING HORSE & DUST)
# ==============================================================================
static func cuoi_ngua_phi(ci: CanvasItem, pos: Vector2, dir: float, t: float, opt: Dictionary = {}) -> void:
	var vai: String = opt.get("vai", "chudu")
	var horse_col: Color = opt.get("horse_col", Color("422718")) # Xích thố / Hắc mã
	var F: float = opt.get("F", 110.0)
	var speed: float = opt.get("speed", 10.0)
	var g_phase := t * speed
	
	var h_bob := sin(g_phase) * 12.0
	var h_pitch := cos(g_phase) * 0.12 * dir
	var h_pos := pos + Vector2(0, h_bob)
	
	# Bóng mờ trên mặt đất
	ci.draw_colored_polygon(B.elip(pos + Vector2(0, 10), 120.0, 22.0, 18), Color(B.MUC, 0.2))
	
	# Bụi mù bốc lên dưới móng ngựa
	for d in 5:
		var d_t := fmod(t * 3.0 + d * 0.4, 1.5)
		var d_alpha := clampf(1.0 - d_t / 1.5, 0.0, 1.0) * 0.35
		var d_x := pos.x - dir * (60.0 + d_t * 90.0) + (d % 3) * 15.0
		var d_y := pos.y + 8.0 - d_t * 25.0
		ci.draw_circle(Vector2(d_x, d_y), 12.0 + d_t * 18.0, Color("8d6e63", d_alpha))
		
	# BỐN CHÂN NGỰA CO DUỖI THEO CHU KỲ PHI
	var ph1 := sin(g_phase)
	var ph2 := cos(g_phase)
	
	# Chân sau
	var hip_pos := h_pos + Vector2(-dir * 65.0, -45.0)
	var h_foot1 := hip_pos + Vector2(-dir * 30.0 + ph1 * 35.0, 55.0 - maxf(0.0, -ph1) * 30.0)
	var h_foot2 := hip_pos + Vector2(-dir * 15.0 - ph1 * 35.0, 55.0 - maxf(0.0, ph1) * 30.0)
	ci.draw_line(hip_pos, h_foot1, horse_col.darkened(0.15), 9.0)
	ci.draw_line(hip_pos, h_foot2, horse_col, 10.0)
	ci.draw_circle(h_foot1, 5.0, Color("1a120c")) # Móng sắt
	ci.draw_circle(h_foot2, 5.0, Color("1a120c"))
	
	# Thân mình ngựa (Lưng & Bụng)
	var horse_body := PackedVector2Array([
		h_pos + Vector2(-dir * 75.0, -60.0),
		h_pos + Vector2(dir * 55.0, -75.0),
		h_pos + Vector2(dir * 75.0, -45.0),
		h_pos + Vector2(dir * 35.0, -15.0),
		h_pos + Vector2(-dir * 55.0, -15.0)
	])
	B.vat(ci, horse_body, horse_col, 5.0, 0.0)
	
	# Cổ và đầu ngựa vươn cao
	var neck_top := h_pos + Vector2(dir * 85.0, -115.0)
	var head_snout := neck_top + Vector2(dir * 35.0, 10.0)
	var head_pts := PackedVector2Array([
		h_pos + Vector2(dir * 45.0, -70.0),
		neck_top,
		head_snout,
		neck_top + Vector2(dir * 15.0, 30.0),
		h_pos + Vector2(dir * 70.0, -40.0)
	])
	B.vat(ci, head_pts, horse_col, 4.0, 1.0)
	# Tai ngựa dựng đứng
	ci.draw_colored_polygon(PackedVector2Array([neck_top, neck_top + Vector2(-dir * 6, -18), neck_top + Vector2(dir * 6, -10)]), horse_col)
	
	# Bờm ngựa tung bay theo gió
	for m in 6:
		var m_root := neck_top.lerp(h_pos + Vector2(dir * 45.0, -70.0), float(m) / 6.0)
		var m_tip := m_root + Vector2(-dir * (22.0 + sin(g_phase * 1.5 + m) * 10.0), -12.0)
		ci.draw_line(m_root, m_tip, Color("1a120c"), 4.0)
		
	# Đuôi ngựa cuộn sóng tung bay
	var tail_root := h_pos + Vector2(-dir * 75.0, -55.0)
	var tail_mid := tail_root + Vector2(-dir * 45.0, -25.0 + sin(g_phase * 1.3) * 14.0)
	var tail_tip := tail_mid + Vector2(-dir * 35.0, 20.0 + cos(g_phase * 1.3) * 16.0)
	B.cong(ci, tail_root, tail_mid, tail_tip, 8.0, Color("1a120c"), 2.0)
	
	# Chân trước
	var sh_pos := h_pos + Vector2(dir * 55.0, -45.0)
	var f_foot1 := sh_pos + Vector2(dir * 25.0 + ph2 * 40.0, 55.0 - maxf(0.0, ph2) * 35.0)
	var f_foot2 := sh_pos + Vector2(dir * 10.0 - ph2 * 40.0, 55.0 - maxf(0.0, -ph2) * 35.0)
	ci.draw_line(sh_pos, f_foot1, horse_col.darkened(0.15), 9.0)
	ci.draw_line(sh_pos, f_foot2, horse_col, 10.0)
	ci.draw_circle(f_foot1, 5.0, Color("1a120c"))
	ci.draw_circle(f_foot2, 5.0, Color("1a120c"))
	
	# Yên ngựa đỏ thêu kim tuyến
	var saddle_rect := Rect2(h_pos.x - 22.0, h_pos.y - 75.0, 44.0, 16.0)
	ci.draw_rect(saddle_rect, Color("b8352a"))
	ci.draw_rect(saddle_rect, Color("c9a24a"), false, 2.0)
	
	# Dây cương da vàng nối đầu ngựa
	ci.draw_line(head_snout, h_pos + Vector2(0, -90.0), Color("c9a24a"), 2.0)
	
	# Kỵ sĩ cưỡi trên lưng ngựa
	var rider_pos := h_pos + Vector2(dir * 5.0, -75.0)
	Ng.ve(ci, vai, rider_pos, F, "ngoi", "tu-tin", t, dir, false, h_pitch)

# ==============================================================================
# 5. TỨC GIẬN ĐẬP BÀN ĐỨNG PHẮT DẬY CHÉM GÓC BÀN (SLAM DESK & STAND)
# ==============================================================================
static func dap_ban_dung_day(ci: CanvasItem, pos: Vector2, t: float, opt: Dictionary = {}) -> void:
	var vai: String = opt.get("vai", "tonquyen")
	var F: float = opt.get("F", 125.0)
	var dur: float = opt.get("dur", 3.8)
	var cyc := fmod(t, dur)
	
	var char_pos := pos
	var desk_bob := 0.0
	var pose := "cam"
	var expr := "gian"
	var cut_corner := false
	
	# Bàn gỗ mun nghị sự
	var table_top := pos + Vector2(0, -75.0)
	
	if cyc < 1.1:
		# Hồi 1: Ngồi tức giận, đập mạnh tay xuống bàn
		pose = "cam"
		expr = "gian"
		if cyc >= 0.38 and cyc < 0.9:
			var dt_slam := cyc - 0.38
			desk_bob = sin(dt_slam * 45.0) * exp(-dt_slam * 8.0) * 12.0
			shockwave(ci, table_top + Vector2(30.0, 0), dt_slam * 160.0, Color("ffb300"), 3.5, 1.0 - dt_slam / 0.5)
	elif cyc < 2.0:
		# Hồi 2: Đứng phắt dậy, tuốt gươm lóe sáng
		pose = "dangdao"
		expr = "gian"
		char_pos.y -= 25.0
	else:
		# Hồi 3: Chém đứt văng một góc bàn!
		pose = "chem"
		expr = "quyet-tam"
		char_pos.y -= 25.0
		cut_corner = true
		
	var hR := Ng.ve(ci, vai, char_pos, F, pose, expr, t, 1.0)
	
	# Vẽ bàn gỗ
	var desk_y := table_top.y + desk_bob
	var desk_w := 280.0
	var desk_rect := Rect2(pos.x - 140.0, desk_y, desk_w, 24.0)
	
	if not cut_corner:
		ci.draw_rect(desk_rect, Color("3e2723"))
		ci.draw_rect(desk_rect, Color("1a100a"), false, 2.5)
		# Chân bàn
		ci.draw_line(Vector2(pos.x - 120, desk_y + 24), Vector2(pos.x - 120, pos.y), Color("2b1810"), 12.0)
		ci.draw_line(Vector2(pos.x + 120, desk_y + 24), Vector2(pos.x + 120, pos.y), Color("2b1810"), 12.0)
	else:
		# Bàn đã bị chém vát góc bên phải!
		var desk_cut_poly := PackedVector2Array([
			Vector2(pos.x - 140.0, desk_y),
			Vector2(pos.x + 95.0, desk_y),
			Vector2(pos.x + 140.0, desk_y + 20.0),
			Vector2(pos.x + 140.0, desk_y + 24.0),
			Vector2(pos.x - 140.0, desk_y + 24.0)
		])
		ci.draw_colored_polygon(desk_cut_poly, Color("3e2723"))
		ci.draw_polyline(desk_cut_poly, Color("1a100a"), 2.5)
		ci.draw_line(Vector2(pos.x - 120, desk_y + 24), Vector2(pos.x - 120, pos.y), Color("2b1810"), 12.0)
		ci.draw_line(Vector2(pos.x + 120, desk_y + 24), Vector2(pos.x + 120, pos.y), Color("2b1810"), 12.0)
		
		# Góc bàn gỗ văng bay trong không khí
		var dt_cut := cyc - 2.0
		var chunk_pos := Vector2(pos.x + 125.0 + dt_cut * 140.0, desk_y - 20.0 + dt_cut * dt_cut * 220.0 - dt_cut * 80.0)
		var chunk_poly := PackedVector2Array([
			chunk_pos,
			chunk_pos + Vector2(25, 0).rotated(dt_cut * 8.0),
			chunk_pos + Vector2(0, 20).rotated(dt_cut * 8.0)
		])
		ci.draw_colored_polygon(chunk_poly, Color("4e342e"))
		
		# Vệt kiếm chém góc bàn rực lửa
		if dt_cut < 0.4:
			crescent(ci, Vector2(pos.x + 110, desk_y), 90.0, -0.9, 0.9, 0.6, Color("ff6f00"), Color("fff9c4"), 1.0 - dt_cut / 0.4)
			sparks(ci, Vector2(pos.x + 110, desk_y), 14, Vector2(1, 0.5), 1.0, 360.0, dt_cut, Color("ffd54f"), cyc)

# ==============================================================================
# 6. ÔM NGỰC HO KHỤ KHỤ THỔ HUYẾT GỤC NGÃ (COLLAPSE & BLOOD SPRAY)
# ==============================================================================
static func hoc_mau_guc_nga(ci: CanvasItem, pos: Vector2, t: float, opt: Dictionary = {}) -> void:
	var vai: String = opt.get("vai", "chudu")
	var F: float = opt.get("F", 120.0)
	var dur: float = opt.get("dur", 4.0)
	var cyc := fmod(t, dur)
	
	var char_pos := pos
	var pose := "omdau"
	var expr := "soc"
	var sh := 0.0
	
	if cyc < 1.2:
		# Hồi 1: Ôm ngực ho khụ khụ rung bần bật
		pose = "cam"
		expr = "soc"
		sh = sin(cyc * 34.0) * 4.0
		char_pos.x += sh
	elif cyc < 2.0:
		# Hồi 2: Thổ huyết bắn máu đỏ ra
		pose = "cui"
		expr = "gian"
		char_pos.x += sin(cyc * 20.0) * 2.0
	else:
		# Hồi 3: Ngã quỵ gối, gục xuống đất
		pose = "quy"
		expr = "buon"
		char_pos.y += 12.0
		
	var hR := Ng.ve(ci, vai, char_pos, F, pose, expr, t, 1.0)
	
	# Tia máu đỏ bắn ra từ miệng (Thổ huyết)
	if cyc >= 1.2:
		var dt_blood := cyc - 1.2
		var mouth_pt := char_pos + Vector2(18.0, -F * 0.95)
		
		# Vệt máu phun hình vòng cung
		for b in 16:
			var b_seed := float(b) * 1.618
			var b_t := clampf(dt_blood - float(b) * 0.02, 0.0, 1.0)
			if b_t > 0.0:
				var sp_x := 120.0 + _h(b_seed) * 140.0
				var bx := mouth_pt.x + sp_x * b_t
				var by := mouth_pt.y - 15.0 + b_t * b_t * 360.0 + (_h(b_seed + 1) - 0.5) * 15.0
				if by < pos.y + 4.0:
					ci.draw_circle(Vector2(bx, by), 3.2, Color("b71c1c"))
					
		# Vũng máu đọng trên mặt đất loang dần
		var puddle_w := minf(65.0, dt_blood * 40.0)
		var puddle_pos := pos + Vector2(65.0, 4.0)
		ci.draw_colored_polygon(B.elip(puddle_pos, puddle_w, puddle_w * 0.28, 16), Color("8a1010", 0.85))

# ==============================================================================
# 7. QUỲ GỐI DÂNG CUỘN CHIẾU THƯ PHÁT SÁNG (KNEEL & PRESENT DECREE)
# ==============================================================================
static func quy_goi_dang_thu(ci: CanvasItem, pos: Vector2, dir: float, t: float, opt: Dictionary = {}) -> void:
	var vai: String = opt.get("vai", "chudu")
	var F: float = opt.get("F", 115.0)
	
	var hR := Ng.ve(ci, vai, pos, F, "quy", "quyet-tam", t, dir)
	
	# Cuộn chiếu thư hoàng gia phát sáng
	var scroll_pos := hR + Vector2(dir * 22.0, -10.0)
	var pulse := sin(t * 4.0) * 8.0
	
	# Hào quang hoàng kim tỏa rộng
	ci.draw_circle(scroll_pos, 46.0 + pulse, Color("ffe082", 0.22))
	ci.draw_circle(scroll_pos, 28.0, Color("fff8e1", 0.45))
	
	# Tia sáng phát quang
	for r in 8:
		var ang := r * (TAU / 8.0) + t * 0.6
		var v := Vector2(cos(ang), sin(ang))
		ci.draw_line(scroll_pos, scroll_pos + v * (55.0 + pulse), Color("fff9c4", 0.4), 2.0)
		
	# Cuộn gấm vàng dải lụa
	var scroll_pts := PackedVector2Array([
		scroll_pos + Vector2(-28, -12),
		scroll_pos + Vector2(28, -12),
		scroll_pos + Vector2(24, 14),
		scroll_pos + Vector2(-24, 14)
	])
	ci.draw_colored_polygon(scroll_pts, Color("fbc02d"))
	ci.draw_polyline(scroll_pts, Color("f57f17"), 2.0)
	
	# Hai đầu trục gỗ mun nạm ngọc
	ci.draw_circle(scroll_pos + Vector2(-28, 0), 6.0, Color("2e7d32"))
	ci.draw_circle(scroll_pos + Vector2(28, 0), 6.0, Color("2e7d32"))
	
	# Dấu ngọc tỷ ấn đỏ chu sa
	ci.draw_rect(Rect2(scroll_pos.x - 6, scroll_pos.y - 6, 12, 12), Color("b71c1c"))

# ==============================================================================
# 8. NÂNG CHÉN RƯỢU CẠN LY SẢNG KHOÁI (DRINK WINE & SMILE)
# ==============================================================================
static func nhap_ruou_can_ly(ci: CanvasItem, pos: Vector2, t: float, opt: Dictionary = {}) -> void:
	var vai: String = opt.get("vai", "chudu")
	var F: float = opt.get("F", 115.0)
	var dur: float = opt.get("dur", 3.4)
	var cyc := fmod(t, dur)
	
	var pose := "cam"
	var expr := "binh"
	var tilt := 0.0
	
	if cyc < 1.0:
		# Giai đoạn 1: Nâng chén lên ngang miệng
		pose = "cam"
		expr = "binh"
	elif cyc < 2.2:
		# Giai đoạn 2: Ngửa đầu uống cạn chén rượu
		pose = "cuoi"
		expr = "cuoi"
		tilt = -0.22
	else:
		# Giai đoạn 3: Hạ chén xuống, mỉm cười sảng khoái
		pose = "noi"
		expr = "cuoi"
		
	var hR := Ng.ve(ci, vai, pos, F, pose, expr, t, 1.0, false, tilt)
	
	# Chén rượu đồng ba chân
	var cup_pos := hR + Vector2(10.0, -5.0)
	if cyc >= 1.0 and cyc < 2.2:
		# Chén nghiêng dốc vào miệng
		cup_pos = hR + Vector2(12.0, -18.0)
		var cup_poly := PackedVector2Array([
			cup_pos,
			cup_pos + Vector2(18, -12),
			cup_pos + Vector2(12, 8),
			cup_pos + Vector2(-4, 12)
		])
		ci.draw_colored_polygon(cup_poly, Color("3d5a45"))
		# Giọt rượu hổ phách rơi
		ci.draw_circle(cup_pos + Vector2(4, 10), 2.5, Color("ffb300"))
		# Hơi ấm rượu bốc lên
		ci.draw_circle(cup_pos + Vector2(0, -12 - sin(t * 8.0) * 4.0), 4.0, Color(1, 1, 1, 0.3))
	else:
		# Chén cầm ngay ngắn
		var cup_pts := PackedVector2Array([
			cup_pos + Vector2(-12, -8),
			cup_pos + Vector2(12, -8),
			cup_pos + Vector2(8, 10),
			cup_pos + Vector2(-8, 10)
		])
		ci.draw_colored_polygon(cup_pts, Color("3d5a45"))
		ci.draw_polyline(cup_pts, Color("7e9f85"), 1.8)

# ==============================================================================
# 9. VUNG QUẠT LÔNG TẠO LỐC XOÁY GIÓ (FEATHER FAN TORNADO)
# ==============================================================================
static func quat_long_tao_gio(ci: CanvasItem, pos: Vector2, dir: float, t: float, opt: Dictionary = {}) -> void:
	var vai: String = opt.get("vai", "khongminh")
	var F: float = opt.get("F", 120.0)
	var dur: float = opt.get("dur", 2.8)
	var cyc := fmod(t, dur)
	
	var pose := "noi"
	var expr := "tu-tin"
	
	if cyc < 0.6:
		pose = "cam"
		expr = "quyet-tam"
	elif cyc < 1.1:
		pose = "chi"
		expr = "tu-tin"
	else:
		pose = "noi"
		expr = "cuoi"
		
	var hR := Ng.ve(ci, vai, pos, F, pose, expr, t, dir)
	
	# Quạt lông hạc trắng (Bạch vũ phiến)
	var fan_tip := hR + Vector2(dir * 32.0, -22.0)
	ci.draw_line(hR, fan_tip, Color("8d6e63"), 3.5) # Cán quạt
	for f in 7:
		var f_ang := -0.6 + float(f) * 0.2
		var feather := fan_tip + Vector2(cos(f_ang) * dir, sin(f_ang)) * 36.0
		ci.draw_line(fan_tip, feather, Color("ffffff"), 4.0)
		ci.draw_circle(feather, 2.5, Color("e0f7fa"))
		
	# Luồng lốc xoáy gió màu lam xoay tít bay tới trước
	if cyc >= 0.7:
		var dt_vortex := cyc - 0.7
		var vx := pos.x + dir * (90.0 + dt_vortex * 720.0)
		var v_base := Vector2(vx, pos.y)
		var v_alpha := clampf(1.0 - dt_vortex / 2.1, 0.0, 1.0)
		
		# Phễu lốc xoáy nhiều tầng
		for layer in 6:
			var ly := -float(layer) * 42.0
			var lw := 25.0 + float(layer) * 22.0
			var spin := t * 18.0 + float(layer) * 0.8
			var off_x := sin(spin) * lw
			var p_left := v_base + Vector2(off_x - lw * 0.5, ly)
			var p_right := v_base + Vector2(off_x + lw * 0.5, ly)
			ci.draw_line(p_left, p_right, Color("80d8ff", v_alpha * 0.7), 4.0)
			ci.draw_circle(p_right, 4.0, Color("ffffff", v_alpha))
			
		# Lá phong / bùa chú cuốn theo lốc xoáy
		for leaf in 5:
			var leaf_ang := t * 14.0 + leaf * 1.3
			var leaf_y := -30.0 - float(leaf) * 40.0
			var leaf_x := sin(leaf_ang) * (30.0 + leaf * 14.0)
			ci.draw_circle(v_base + Vector2(leaf_x, leaf_y), 3.5, Color("ffab91", v_alpha))
			
		# Bụi gió quét trên sàn
		dust_puff(ci, v_base, 32.0, Color("b0bec5"), v_alpha * 0.4)

# ==============================================================================
# 10. PHẤT CỜ LỆNH XUẤT QUÂN (COMMAND FLAG BILLOWING)
# ==============================================================================
static func phat_co_lenh(ci: CanvasItem, pos: Vector2, dir: float, t: float, opt: Dictionary = {}) -> void:
	var vai: String = opt.get("vai", "chudu")
	var F: float = opt.get("F", 120.0)
	var hR := Ng.ve(ci, vai, pos, F, "giotay", "quyet-tam", t, dir)
	
	# Cán đại kỳ
	var flag_pole_top := hR + Vector2(dir * 15.0, -165.0)
	var flag_pole_bot := hR + Vector2(-dir * 15.0, 45.0)
	ci.draw_line(flag_pole_bot, flag_pole_top, Color("4e342e"), 7.0)
	ci.draw_circle(flag_pole_top, 8.0, Color("c9a24a")) # Đầu ngọc
	
	# Lá cờ lệnh hình tam giác lượn sóng tung bay
	var wave1 := sin(t * 8.0) * 16.0
	var wave2 := cos(t * 8.0) * 16.0
	var flag_pts := PackedVector2Array([
		flag_pole_top,
		flag_pole_top + Vector2(dir * (120.0 + wave1), 35.0),
		flag_pole_top + Vector2(dir * (165.0 + wave2), 70.0),
		flag_pole_top + Vector2(dir * 10.0, 95.0)
	])
	ci.draw_colored_polygon(flag_pts, Color("b71c1c"))
	ci.draw_polyline(flag_pts, Color("ffd54f"), 3.0)
	B.chu(ci, "LỆNH", flag_pole_top + Vector2(dir * 65.0, 45.0), 24, Color("fff8e1"), 2)

# ==============================================================================
# 11. GẢY ĐÀN PHÁT SÓNG ÂM KIẾM KHÍ (GUZHENG SONIC BLADE)
# ==============================================================================
static func gay_dan_song_am(ci: CanvasItem, pos: Vector2, t: float, opt: Dictionary = {}) -> void:
	var vai: String = opt.get("vai", "tieukieu")
	var F: float = opt.get("F", 110.0)
	
	# Bàn đàn cổ tranh
	var table_rect := Rect2(pos.x - 70.0, pos.y - 45.0, 140.0, 20.0)
	ci.draw_rect(table_rect, Color("4a2d18"))
	for s in 8:
		ci.draw_line(Vector2(pos.x - 65.0, pos.y - 42.0 + s * 2.2), Vector2(pos.x + 65.0, pos.y - 42.0 + s * 2.2), Color("e0c068"), 1.2)
		
	var hR := Ng.ve(ci, vai, pos, F, "ngoi", "cuoi", t, 1.0)
	
	# Các vòng sóng âm kiếm khí tỏa ra
	for w in 3:
		var w_t := fmod(t * 2.2 + w * 0.45, 1.4)
		var w_alpha := clampf(1.0 - w_t / 1.4, 0.0, 1.0)
		var w_r := 30.0 + w_t * 160.0
		ci.draw_arc(pos + Vector2(50, -45), w_r, -0.6, 0.6, 24, Color("d4af37", w_alpha), 3.0)
		ci.draw_arc(pos + Vector2(50, -45), w_r * 0.85, -0.4, 0.4, 18, Color(1, 1, 1, w_alpha * 0.8), 1.5)

# ==============================================================================
# 12. TỤ KHÍ PHÓNG CHƯỞNG NỘI CÔNG (QI BLAST WAVE)
# ==============================================================================
static func tu_khi_chuong(ci: CanvasItem, pos: Vector2, dir: float, t: float, opt: Dictionary = {}) -> void:
	var vai: String = opt.get("vai", "chudu")
	var F: float = opt.get("F", 120.0)
	var col: Color = opt.get("col", Color("00e5ff"))
	var dur: float = opt.get("dur", 2.2)
	var cyc := fmod(t, dur)
	
	var pose := "cam"
	if cyc < 0.8:
		pose = "cam" # Tụ khí
	elif cyc < 1.4:
		pose = "giotay" # Đẩy chưởng
	else:
		pose = "dung"
		
	var hR := Ng.ve(ci, vai, pos, F, pose, "quyet-tam", t, dir)
	
	if cyc < 0.8:
		# Quả cầu tụ khí xoay vần giữa 2 tay
		var k := cyc / 0.8
		var ball_pos := hR + Vector2(dir * 25.0, 0)
		var r := 15.0 + k * 28.0 + sin(t * 25.0) * 4.0
		ci.draw_circle(ball_pos, r, Color(col, 0.4))
		ci.draw_circle(ball_pos, r * 0.5, Color(1, 1, 1, 0.8))
	elif cyc < 1.6:
		# Phóng chùm tia chưởng rực sáng
		var dt_blast := cyc - 0.8
		var beam_start := hR + Vector2(dir * 20.0, 0)
		var beam_end := beam_start + Vector2(dir * (dt_blast * 900.0), 0)
		ci.draw_line(beam_start, beam_end, Color(col, 0.5), 24.0)
		ci.draw_line(beam_start, beam_end, Color(1, 1, 1), 8.0)
		shockwave(ci, beam_start, dt_blast * 180.0, col, 3.0, 1.0 - dt_blast / 0.8)
