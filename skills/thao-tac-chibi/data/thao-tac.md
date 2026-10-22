# Sổ thao tác chibi (Godot 2D, engine `canh.gd` + `chibi.gd`)

Mỗi thao tác gồm: **id** · làm gì · công thức (dán vào `_story`) · cảnh mẫu trong `engine/canh/` · bài học.
Mọi khoảng thời gian dùng `smooth(t0, t1, t)` (0→1 mượt). `a` = actor. Toạ độ "thân" = hệ torso của chibi (đơn vị chibi, +x = phía mặt, −y = lên).
Thao tác mới làm xong và đạt sheet → **thêm vào cuối sổ này** (đúng khuôn).

---

## A. Di chuyển

### di — đi bộ 4 nhịp
- `a.go = Vector2(x, ground_y); a.speed = 95..120` → tự quay mặt, tự chạy chu kỳ chạm gót → nhún → lướt qua → nhấc. Tới nơi thì `a.go = INF` và `a.walk` tự về 0 (dừng mượt).
- Chân không trượt: STRIDE 17 px/rad đã khớp với `speed`. Đi chậm 60–90 = thong thả, 110 = bình thường, 200+ = rảo (nên thêm extra `"run"` 0.3–0.6).
- Đi tiếp sau khi dừng: `if t > t1 and a.go == Vector2.INF and a.pos.x < X: a.go = Vector2(X2, ground_y)`.
- Mẫu: `duong_dem`, `o_mua`, `rung_truc`.

### di_tai_cho — đi tại chỗ (soi dáng)
- `a.inplace = 110.0` (nền tự trôi bằng `sc += dt*speed*a.walk`). Dùng cho cảnh thử / cảnh camera bám theo.
- Mẫu: `vat_ao`.

### dung — dừng, vạt áo lắc rồi lặng
- Không cần làm gì: hết `go` thì vạt lò xo tự lắc rồi tắt. Muốn dừng sớm: `a.go = Vector2.INF`.

### quay_lai / ngoai_lai
- Ngoái nhìn sau: `if t > t0 and t < t1: a.face = -1.0 else a.face = 1.0` (lật tức thì, chibi nên lật dứt khoát; kèm `expr` "soc").
- Mẫu: `duong_dem` (5.9–6.5).

### chay — chạy
- `a.speed = 220..260` + `a.extra = [["run", 0.6]]`, `a.expr = "quyet-tam"`; thêm `spawn("dust", a.pos, …)` mỗi bước (xem bước tóe nước ở `o_mua`).

---

## B. Tư thế & cử chỉ (pose có sẵn trong `Chibi.POSES`)

`rest, stance, charge, palm, point, raise, windup, slash, guard, fly, kneel, run`.
Pha pose: `a.extra = [[pose_cũ, 1-k], [pose_mới, k]]`; pose nền: `a.base = "stance"`. Pose riêng = dict khớp (độ, + = chiều kim đồng hồ):
`uaF/faF` cánh/cẳng tay trước, `uaB/faB` tay sau, `head`, `torso`, `thF/shF/thB/shB` đùi/ống chân, `ftF/ftB`, `all=[dx, dy, bob]`.
Quy ước: đùi **âm = bước ra trước**; cánh tay **âm = vung ra trước/lên**, dương = ra sau.

### chuoi_tu_the — chuỗi thế võ nối nhau
```gdscript
var seq := [[5.2, "stance"], [6.3, "kneel"], [7.5, "windup"], [7.95, "slash"], [8.7, "rest"]]
# tìm cur theo t, prv = seq[cur-1]; dur = 0.12 cho slash (đòn nhanh), 0.3 cho thế thường
a.extra = [[prv, 1.0 - k], [cur, k]]
```
- Mẫu: `vat_ao` (5.2–10.2).

### noi — nói chuyện
- `a.talk = smooth(t0, t0+0.4, t) * (1.0 - smooth(t1, t1+0.3, t))`; người nghe `expr` đổi theo câu. Engine tự thêm khoa tay + gật đầu.
- Mẫu: `rung_truc` (ban.talk 4.4–7.3).

### chi_tay — chỉ / chĩa
- `["point", k]` → tay F duỗi, bàn tay dạng `chi`. Cầm kiếm thì thành chĩa kiếm.

### xoe_chuong — đẩy chưởng: `["palm", k]` (cả 2 bàn tay `xoe`). Tụ khí: `["charge", k]` (2 tay nắm).
### the_thu — thủ thế: `a.base = "stance"` hoặc `["guard", k]` (đỡ đòn).
### quy — quỳ: `["kneel", k]` (vạt áo vắt qua gối tự động).
### gio_tay — giơ 2 tay: `["raise", k]` (bàn tay xoè). Bay/khinh công: `["fly", k]`.
### vung_chem_doc — giương cao rồi bổ dọc: `windup` (0.3 s) → `slash` (0.12 s). **Không dùng khi có kiếm dài sát mặt** (xem chem_hat).

### ngua_mat — ngửa mặt nhìn trời
- `a.extra = [[{"head": -14.0, "torso": -3.0}, k]]` (nhẹ) / `{"head": -18, "torso": -7}` (tu rượu).
- Mẫu: `o_mua`, `duong_dem`.

### cuoi_lac_nguoi — cười rung người
```gdscript
var s16 := sin(t * 16.0)
[{"all": [0.0, 0.0, absf(s16) * -8.0], "head": s16 * 5.0, "torso": 4.0 + s16 * 3.0, "uaB": -30.0, "faB": -60.0}, laugh]
```
- Mẫu: `uong_ruou`.

### gio_thoi_vat — gió thổi áo
- `a.sway = 1.0` thường, `3.0–4.0` cơn gió mạnh (pha mượt bằng smooth). Gió cảnh: `wind_base`, `wind_gust` trong `_palette`.

### bieu_cam — `a.expr` ∈ vui, binh, gian, soc, quyet-tam, ko, dac-y, ngai. Đổi đúng nhịp: bình → sốc (bất ngờ) → vui/đắc ý.

### ngoi_ghe_v2 — ghế là đồ diễn (mẫu: tap-10 `godot/canh.gd` + `xem/ngoi.gd`, `xem/hook.gd`)
```gdscript
var g := ghe_moi(p, face, wood, lung)   # {rock, lean, dx, fall, seal, tear}
ngoi(a, g, edge)          # người bám ghế: ghế nghiêng/trượt thì người theo (a.rot); edge>0 = nhích ra mép
ghe_ve(c, g)              # _ground  · ghe_vet(c, g, col) vết cày sàn theo g.dx
ghe_niem(c, g)            # _near: dải niêm "DÍNH" (seal 0..1 đóng dấu, tear 0..1 rách 2 nửa văng)
# rock = bập bênh trên 2 chân sau · lean = chúi trên 2 chân trước · fall 0..1 = đổ ngửa (thêm nảy nhỏ khi chạm sàn)
# dội sau cú đánh: rock += A*exp(-3.5e)*|sin 8e|  · trượt lùi: dx -= 22*smooth(h, h+0.16)
```
Mỗi người một kiểu ngồi theo tính cách (const pose, dùng `[[NGOI_X, 1.0], [cử động nhỏ, 1.0]]`):
- `NGOI_BAP_BENH` lãng tử: ngả lưng, chân vắt cao, ghế rock 0.1–0.25 + gật đầu.
- `NGOI_CHOM` hung hăng: chồm tới, đao chống mũi xuống sàn (IK tay tới điểm cách sàn 150 px, lockdir xuống), chân gõ nhịp.
- `NGOI_MEP` rụt rè: `ngoi(a, g, 26)` nửa mông mép ghế, cúi đầu, tay ôm trước ngực, thỉnh thoảng ngước rồi cúi vội.
- `NGOI_XOM` sợ hãi: ngồi xổm ôm vò, run `all.x = sin(47t)*1.6`, nhổm lên ngó (`all.bob` 52 → 22).
- `NGOI_TUONG` đạo mạo: thẳng như tượng, IK 2 tay lên gối (`to_w(J["shF"], (0,-8))`), sway 0.25, ghế cao lưng 190 trên bục.
- `NGOI_XEP_BANG` ẩn sĩ: xếp bằng trên đá (bob 92), thở chậm, sway 2.2.
- Bung khỏi ghế: `ngoi` dừng, người nhảy cung `sin(e/0.45·π)*90`, `tear` 0→1 cùng lúc, `fall` 0→1 trễ 0.08 s.
- Tay chibi ngắn: không chắp kín 2 tay trước ngực được — đặt 2 điểm IK gần nhau (66,-84)/(60,-80) là đủ đọc.

### nhin_qua_khe — góc nhìn lén qua khe ván (mẫu: tap-10 `xem/hook.gd`)
- `_d_screen` phủ 2 tấm ván (mép răng cưa, vân, viền sáng) chừa khe ngang; độ mở khe là hàm của t (mở dần → bung rộng khi cao trào).
- Máy quay thấp zoom 1.55 tâm gần sàn: khe chỉ lộ chân ghế, mông, niêm → người xem đoán trận đấu qua tiếng + chân ghế.
- Cắt ngược: cam nhảy tới Tèo đặt ngoài cảnh (x = -1300), ván vẽ trong `_near` quanh mắt Tèo, khe ±16/+40 quanh `_eye_y()`.
- Chữ luật chơi viết phấn lên tấm ván trên (`nhan` trong `_d_screen`), không đặt trong thế giới (bị ván che).

---

## C. Tay cầm / IK

### giu_tay — đưa lòng bàn tay tới một điểm
- `a.hold["F"] = [Vector2(x, y), w]` (toạ độ thân, w 0..1, khuỷu luôn chĩa xuống). Hạ tay: w → 0.
- Điểm hay dùng: trước ngực thấp `(54,-44)`, cầm đèn `(66,-40)`, giơ cao soi `(62,-170)`, cầm ô `(72,-50)`, hứng mưa tay B `(36,-64)`, chuôi kiếm hông `hong - sheath*22`.
- Điểm theo mặt (môi): `from_w(torso, to_w(a.node.J["head"], Vector2(0,-30))) + off` (xem `_lips_t` trong `uong_ruou`).

### dang_ban_tay — `a.hands = {"F": "tha|nam|xoe|chi", "B": …}` ghi đè. Tự động: cầm vật → `nam`; theo pose (FORM_OF) → palm `xoe`, point `chi`, thế võ `nam`; còn lại `tha`. Xoá ghi đè: `a.hands = {}`.

---

## D. Vật phẩm (`prop(a, kind, at, side, extra)` · đổi chỗ `prop_to(v, at, side)`)

Chỗ gắn: `tay` (kẹp giữa lòng bàn tay và ngón) · `hong` (thắt lưng, dưới tay) · `lung` (sau lưng) · `mat` (lớp mặt, vd má đỏ) · `world` (rơi/đặt trên đất, `pos`).

### rut_kiem — rút kiếm khỏi vỏ
```gdscript
kiem = prop(a, "kiem", "hong", "F", {"vo": true, "hong": Vector2(34, 4), "pull_k": 1.7, "sheath": Vector2(-0.9, 0.42).normalized()})
# 1) tay tới chuôi:  a.hold["F"] = [hong - sheath*22, smooth(..)]
# 2) nắm + rút dọc vỏ: prop_to(kiem,"tay","F"); kiem.lock=1; kiem.out=0; kiem.lockdir = ldir(torso, sheath)
#    a.hold["F"] = [grip_pt - sheath*120*k, 1]   (lưỡi lộ dần theo khoảng cách tới miệng vỏ)
# 3) lóe sáng: kiem.glint = t_now; buông khoá: kiem.lock = 1 - smooth(..); kiem.grip lerp(-60 → 0)
```
- Mẫu: `rut_kiem` (0–3.12).

### chem_hat — lấy đà thấp + chém hất chéo lên (có vệt kiếm)
- Pose riêng `WIND` (kiếm kéo ra sau hông, tay F vòng **dưới**) → `RISE` (hất lên chéo trước ngực), 0.2 s; `kiem.grip` 0 → −10 (lưỡi nối dài cẳng tay).
- Vệt: `kiem.trail_on = t > t_vao and t < t_ra`; khi tắt **phải** `kiem.trail.clear()` (không thì vệt kéo thành nêm trắng xuống đất).
- Chẻ vật đang rơi: kiểm điểm trong đa giác `[prev_guard, trail[1][0], tipw, guardw]` (xem `_leaf`).
- Thu thế: `[[RISE,1-k],["point",k]]`, grip −4.
- Mẫu: `rut_kiem` (2.1–4.8). Hằng `WIND`/`RISE` ở đầu file.

### cam_o_mua — cầm ô đi trong mưa
```gdscript
a.hold["F"] = [Vector2(72, -50), 1.0]          # cán đứng TRƯỚC mặt, không cắt ngang mặt
o = prop(a, "o", "tay", "F", {"col": Color("#e0a640"), "shaft": 410.0, "tilt": 0.2})
```
- Tán tự nghiêng theo gió + quán tính (lò xo). Hạt mưa trúng tán bật tung (`_umbrella_hit`). Mép ô nhỏ giọt: spawn `"drop"` tại `o.rim[i]`.
- Mẫu: `o_mua`.

### hung_mua — chìa tay hứng: `a.hold["B"] = [Vector2(36,-64), k]` + splash nhỏ tại `a.node.hand(world,"B")`.

### uong_ruou — uống rượu hồ lô
```gdscript
ho = prop(a, "ho_lo", "hong", "F", {"hong": Vector2(40, 4)})   # đeo hông, đung đưa dây
ma = prop(a, "ma_do", "mat", "F", {"cheek": Vector2(62, -54)})   # má đỏ: ma.amount 0..1
# cầm lên: prop_to(ho,"tay","F"); ho.lock=1; ho.lockdir = DOWN.lerp(Vector2(face*0.75,-0.66), tip)
# đưa lên môi: hold F → _lips_t(Vector2(12,-12)); ho.aim = Vector2(0,-30); ho.pour = 0..1 (dòng rượu)
# ngửa cổ: [{"head":-18,"torso":-7}, tip]; xong: prop_to(ho,"hong","F")
```
- Phụ: phà hơi khói (6 `smoke`), nấc bong bóng (`bubble`), rượu sánh mép (`drop` màu hổ phách).
- Mẫu: `uong_ruou`.

### cam_den_long — cầm đèn lồng đi đêm
```gdscript
a.hold["F"] = [Vector2(66, -40), 1.0]
den = prop(a, "den", "tay", "F", {"lcol": Color(1.45, 0.86, 0.48)})   # kênh >1 để bloom
# thiêu thân: spawn("moth", den.lw, {"o": den, ...}) ×3   · đèn treo dây mềm (rope) tự đung đưa theo bước
# giơ đèn soi quanh: hold F lerp tới (62,-170) + [{"head":-8,"torso":-4}, raise]
```
- Mẫu: `duong_dem`.

### deo_sau_lung — `prop_to(v, "lung")`; đặt xuống đất — `prop_to(v, "world")` với `v.pos`.

---

## E. Khí trời / hạt (`spawn(kind, p, extra)`, `rain_of(kind, rate/s, Rect2, extra)`)

Kind: `leaf petal maple snow drift firefly dust smoke ripple rain drop splash bubble moth`.
Extra: `col, life, land (y chạm đất), on_land (Callable nhận q), z (0.45 sau → 1.35 trước), s (cỡ), v (vận tốc)`.
- Lá trúc bay: `rain_of("leaf", 7, Rect2(-500,-150,1500,300), {"col":…, "land": ground_y+rand, "life":14})` — `rung_truc._weather`.
- Mưa có điểm rơi riêng (mặt hồ → ripple, bờ → splash) — `o_mua._rain_land`.
- Tuyết — `nui_tuyet`; đom đóm — `duong_dem`; lá phong rơi mặt hồ — `ho_thu`; trời đêm sao/trăng — `tran_dem`, `duong_dem`.
- Bước chân tóe: khi `floori(ph/PI)` đổi → spawn splash/dust tại `a.pos`.

---

## F. Bài học (đừng lặp lỗi)
- **Tay F không giơ ngang qua mặt** khi đang cầm vật dài: lấy đà thấp ra sau hông, vung từ dưới lên.
- Kiếm cầm thuận: `grip ≈ 0..−10` (lưỡi nối dài cẳng tay). Grip −90 = lưỡi vuông góc cẳng tay, dễ cắt qua đầu.
- Cán ô / cán đèn đặt **trước** mặt (x ≥ 66), cán nghiêng ra trước `tilt 0.2`.
- Cảnh đêm: sky_bot không quá tối (#3d3d78), `char_tint` (0.8,0.82,1.0), vign ≤ 0.45, nếu không nhân vật chìm.
- Hình trăng khuyết: dùng `crescent()` (polygon thật trong `duong_dem`), không vẽ hình tròn màu nền đè lên.
- Đa giác có đỉnh trùng → không vẽ (tam giác hoá hỏng): bỏ điểm trùng ở mũi.
- Vệt sáng (trail) chỉ bật trong đoạn quét đẹp, tắt thì clear lịch sử.
- Cảnh có lớp phủ màn hình (ván, khung): màu phủ ≥ #8a5e38, vign ≤ 0.25, thêm quầng đèn sau nhân vật, nếu không cả khung đen kịt.
- Đọc giá trị Variant từ dict: khai kiểu rõ `var x: float = v.pour` (`:=` → parse error).
