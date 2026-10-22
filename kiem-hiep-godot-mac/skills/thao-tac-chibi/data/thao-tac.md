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

### nang_trong_kiem / con_roi_bong / co_rieng / nen_bua_dong_so — (mẫu: kiem-hiep tap-02 `godot/canh/hang.gd`, `roi.gd`, `diem.gd`)
- **nang_trong_kiem**: quỳ `["kneel",1]` → tay nắm cán nhấc dần theo `_lift()` (0..1), thân run nhẹ `sin(t*23)*k`; kiếm nặng vẽ tay (đa giác đen mép cùn) bám `n.hand(world,"F")`, không dùng prop kiếm mảnh.
- **con_roi_bong**: `a.tint` gần đen (`bong(a, 0.95)`) + que điều khiển vẽ từ bàn tay/đầu lên mép trên; nền tấm thép đỏ dần theo câu. Nhân vật vẫn diễn pose bình thường.
- **co_rieng**: `a.sc` (0.7–0.8 cho trẻ con / cảnh đông người, 1.5 cho ảnh bìa) — canh.gd nhân vào `CS` (cần sửa 1 dòng `n.scale` như tap-02).
- **nen_bua_dong_so**: `["raise", sw]` với sw dâng 0.6 s trước mốc rồi rơi về 0 đúng mốc; búa vẽ `bua(c, hand, lerp(0.2,-1.6,sw))`; số chớp đỏ rồi nguội 2.5 s.

## C. Tay cầm / IK

### giu_tay — đưa lòng bàn tay tới một điểm
- `a.hold["F"] = [Vector2(x, y), w]` (toạ độ thân, w 0..1, khuỷu luôn chĩa xuống). Hạ tay: w → 0.
- Điểm hay dùng: trước ngực thấp `(54,-44)`, cầm đèn `(66,-40)`, giơ cao soi `(62,-170)`, cầm ô `(72,-50)`, hứng mưa tay B `(36,-64)`, chuôi kiếm hông `hong - sheath*22`.
- Điểm theo mặt (môi): `from_w(torso, to_w(a.node.J["head"], Vector2(0,-30))) + off` (xem `_lips_t` trong `uong_ruou`).

### dang_ban_tay — `a.hands = {"F": "tha|nam|xoe|chi", "B": …}` ghi đè. Tự động: cầm vật → `nam`; theo pose (FORM_OF) → palm `xoe`, point `chi`, thế võ `nam`; còn lại `tha`. Xoá ghi đè: `a.hands = {}`.

---

### chap_tay_le / quy_thu_le / lay_sat_dat / xach_hai_nguoi / cam_kinh_lup — (mẫu: kiem-hiep tap-06 `godot/canh_c.gd`, `canh_a.gd`)
```gdscript
const CHAP := {"uaF": -30, "faF": -118, "uaB": 14, "faB": -20, "torso": 2, "head": 4, "thF": -6, "shF": 8, "thB": 6, "shB": -8, "all": [0, 0, 4]}   # nhà sư dựng một bàn tay trước ngực, tay F "xoe"
const LE := {"uaF": -64, "faF": -78, "uaB": -54, "faB": -84, "torso": 14, "head": 10, "thF": -84, "shF": 84, "thB": 44, "shB": 52, "all": [0, 0, 70]}   # quỳ một gối ôm quyền thủ lễ (2 tay "nam")
const LAY := {"torso": 70, "head": 30, "thF": -100, "shF": 120, "thB": -96, "shB": 116, "uaF": -150, "faF": -20, "uaB": -150, "faB": -20, "all": [0, 0, 200]}   # lạy rạp, hai tay duỗi trước đầu
# xách hai người: ik hai tay về (80,-60)/(60,-70), hai tay "nam"; người bị xách = A(…, hand_w(F|B) + (±10,130), "rest", "ko", sc nhỏ hơn), rotation = PI/2
# cầm kính lúp: vẽ kính tại hand_w(key,"F") + (10,-40), r 42, góc 1.9 (cán theo cẳng tay); phóng to = kinh_lup(ctr, 120*k) + nội dung cắt trong vòng
```
- Bài học: CHAP chỉ dựng tay F; cầm thêm chổi thì cho tay B buông (uaB ~22, faB ~-30) và vẽ cán nghiêng ra sau lưng, cán không cắt qua mặt.
- Lạy LAY cần `all` y ~200 để đầu chạm sàn; kết hợp mx(rest, LAY, k) cho động tác cúi dần.

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

---

## G. Thêm từ tap-09 Dương Quá – Tiểu Long Nữ (2026-10-22, engine tập có khoá `sc/rot/hide/alpha/tint`)
- **Khoá actor mới (canh.gd tập 09)**: `a.sc` (co giãn, đi xa thì giảm 1→0.4), `a.rot` (rad, xoay cả người khi rơi), `a.hide` (ẩn hẳn cả bóng — dùng khi alpha≈0 vì bóng đất vẫn vẽ), `a.alpha`, `a.tint` (Color nhân thêm, vd chìm nước `Color(0.75,0.9,1.15)`).
- **Pha pose tuần tự**: `extra` trộn lần lượt, pose sau đè pose trước theo trọng số → muốn dao động giữa A và B dùng `[[A, m], [B, m*(1-ph)]]`, đừng đặt hai pose trọng số 1.
### khac_da — mũi kiếm tì vách, rung theo nét
- `{"uaF": -120 + row*14 + sin(t*14)*6, "faF": -10 + sin(t*14)*8, "head": -8}`; `row` = dòng đang khắc (hạ tay dần). Chữ hiện theo `substr(0, n)` đồng bộ. Mẫu: tap-09 `k13`.
### ve_tren_khong — ngón tay vẽ hình lơ lửng
- `["point", k]` + `a.hold["F"] = [Vector2(70,-160) + hướng tới điểm đang vẽ, k]`; nét vẽ ở `_glow`, nét đứt = bịa, liền = thật. Mẫu: tap-09 `k14`.
### lon_nhao / nhay_vuc — nhảy xuống vực, rơi theo
- `a.pos` nội suy tay: x trượt, `y = FL + f*f*(BOT-FL)`; `extra [["run",1-f],["fly",f]]`, `a.rot = f*0.6`; camera bám `p.y-120`. Chìm/trồi: `y = BOT + 160*sin(min(1,k*1.6)*PI)` + `tint` lam. Mẫu: tap-09 `k18`.
### nam_la / ngoi_thien — ngồi thiền trên đá lạnh
- `[["kneel",1],[{"uaF":20,"faF":-60,"uaB":20,"faB":-60,"head":6},1]]`, hạ `pos.y` 30 cho khớp mặt đá. Mẫu: tap-09 `k16`.
### ngoi_ghe — ngồi ghế đá
- `[["kneel",0.55],[{"uaF":20,"faF":-70,"uaB":10,"faB":-60},0.8]]`, pos = mặt ghế. Mẫu: tap-09 `k19`.
### leo_day — leo dây
- `["raise",1]` + đùi so le `thF/thB ± sin(t*6)*20`; tay giơ cao bị đầu chibi che → để camera xa (zoom 0.7). Mẫu: tap-09 `k18`.
### luoi_tay / gai_dau — gãi đầu
- `{"uaB": -170, "faB": -110 + sin(t*9)*12, "head": 8 + …}` trọng số theo câu thoại. Mẫu: tap-09 `k17`.
### om_dau — ôm đầu hai tay
- `{"uaF":-150,"faF":-120,"uaB":-150,"faB":-120,"head":10}`. Mẫu: tap-09 `k14`, `k17`.
### nhac_kiem_nang — huyền thiết trọng kiếm
- Kiếm nặng vẽ tay (`_heavy(c, g, ang)`) gắn `a.node.hand(world,"F")`, góc chúc xuống; nhân vật một tay (`duong-qua`) không có tay B. Mẫu: tap-09 `k15`.
- **oneArm**: char `duong-qua` (sau khi cụt tay) đã nướng sẵn kiếm đen + tay áo trống; trước cảnh chặt tay dùng `duong-qua-nho`, đổi actor (hide cái cũ) đúng khung lóe sáng.
- **Bài học tập 09**: thứ cần khớp chỗ đứng nhân vật phải vẽ ở `_ground`/`_near` (parallax 1.0); `_back` 0.7 và `_front` 1.3 làm lệch khi camera trượt (thác/bia/thẻ CTA chạy lệch).

---

## H. Thêm từ tap-08 Thiếu Lâm – Võ Đang (2026-10-22, mẫu: kiem-hiep `tap-08-thieu-lam-vo-dang/godot/ky.gd` + `canh/*.gd`)
### ganh_thung — gánh đòn hai thùng
- `var e := don(c, a.pos + Vector2(6,-134), 150.0, bend, 0.0)` → 2 đầu đòn; mỗi đầu `day(c,p,b±(34,-18))` + `thung(c,b,0.8)`, `b = p + (sin(t*5)*8, 70)`; vai nhún `sin(t*12)*4`. Tay: `hold F (44,-66)`, `B (-38,-64)`. Vẽ ở `_near`. Mẫu: `cay_co.gd`, `dem_co.gd` (k08-12, có đầu trẻ ló ra).
### ngoi_tua / ngoi_bo_goi — ngồi dựa / ngồi bó gối (pose dict trong ky.gd)
- `extra = [[NGOI_TUA, 1]]` hoặc `[[NGOI_BO_GOI, 1]]`, hạ `pos.y` theo mặt ngồi; ghép `chap(a)` để chắp tay thiền. Mẫu: `nui_lua.gd` (ba lão tăng trên cột đá).
### chap — chắp tay trước ngực: `chap(a, w)` (hold F/B cùng một điểm trước ngực). Cúi chào hàng: `chap` + `head` 14 lần lượt từng người lệch 0.15 s. Mẫu: `hoi_minh.gd`, `ben_song.gd` k07d-06.
### walk_to — đi/chạy từ A tới B trong [t0,t1]: `walk_to(a, p0, p1, t0, t1, run)` tự đặt face + walk. Mẫu: `dem_co.gd`, `hoi_minh.gd` (Vi Tiểu Bảo chạy vòng).
### ve_chu_khong — viết chữ trên không (Thuý Sơn): `["point",k]` + `hold F` chạy theo nét, chữ hiện dần ở `_glow`. Mẫu: `tran_do.gd`.
### ve_vong_ik — tay vẽ vòng tròn Thái Cực: `hold F = c + (cos θ, sin θ)*r`, `hold B` đối xứng lệch π. Mẫu: chiêu `thai_cuc`.
### dinh_tay — dính tay đối thủ (Thái Cực): hold F của hai người cùng một điểm trôi theo vòng.
### mua_kiem_go — kiếm gỗ múa vòng: vật vẽ tay gắn `a.node.hand(world,"F")`, góc = θ vòng + π/2. Mẫu: `kiem_go.gd` (k05d).
### bong_bong_nho — bong bóng ký ức trên đầu: elip mờ + 3 chấm nhỏ dẫn lên, nội dung vẽ trong elip ở `_ui`.
### quet_la — quét lá bằng chổi (Tảo Địa Tăng): chổi gắn hand F, `hold F/B` dao động `sin(t*3)*30` ngang, lá bay ở `_near`. Mẫu: `gia_sach.gd`.
### gai_dau_v2 — gãi đầu bằng hold: `hold F = (-6,-262)` (đủ cao để tay không che mặt) + `head` lắc nhẹ. Mẫu: `gia_sach.gd` k07-11.
### tho_doc — thở dốc: `torso` 10 + `head` 8 + `sin(t*7)*4` cả hai, tay chống gối `[["kneel",0.3]]`. Mẫu: `nui_lua.gd` k06d-01.
### roi_bong_tint — nhân vật chưa có sheet: mượn actor khác + `tint` (đỏ = Cưu Ma Trí, sẫm = Tiêu Viễn Sơn, lam = Mộ Dung Phục) và alpha 0.85 như bóng.
- **Bài học tập 08**: `_ground` vẽ sau `_mid` → thứ vẽ ở mid bị đất che; bộ đếm/nhãn phải ở `_ui`. Phần tử `extra` phải là `[pose, w]` (lỗi `["palm",1.0]` lồng sai báo "Invalid access to key"). `%` trên float cần ngoặc phần int.

---

## I. Thêm từ tap-03 Ngũ Tuyệt Hoa Sơn (2026-10-22, mẫu: kiem-hiep `tap-03-ngu-tuyet-hoa-son/godot/mam.gd` + `o/*.gd`, shorts `canh/*.gd`)
### the_coc — thế cóc Cáp Mô Công: `px(a, [[COC, sq]])`, COC = `{"thF":-105,"shF":118,"ftF":-10,"thB":-80,"shB":128,"ftB":-6,"torso":34,"head":-30,"uaF":-28,"faF":-8,"uaB":-18,"faB":-10,"all":[0,0,78]}`; thở nén: `a.sc = base + sin(t*4)*0.04*sq`; vòm độc khí ở `_glow` (`draw_arc` nửa trên + blob lục). Mẫu: `o/linh.gd`, short `01-quan-tai/canh/quan.gd`.
### hai_tay_tu_danh — Song Thủ Hỗ Bác (Chu Bá Thông): `hai_tay(t)` trả dict tay F/B lệch nhịp `sin(t*7)` / `sin(t*9.3+1.2)`. Mẫu: `mam.gd`, `o/dong.gd`.
### lon_nguoc — Âu Dương Phong lộn ngược: `a.rot = PI` + `a.pos.y -= chiều cao tượng`, tay `{"uaF":150,"uaB":150}` chống đất; lắc `sin(t*3)*0.05`. Mẫu: `o/hoason.gd` k21.
### tuong_moc — tượng bột mọc ra từ cục bột: `a.pop` 0→1 (`_pop_ease` nảy quá 1 rồi về), `_d_shadow` vẽ cục bột co lại dưới chân. Mẫu: mọi cảnh `o/*.gd`.
### nan_bot — Tèo nặn: `tay_tho(c, p, s, ang)` (tay bột to có vân tay) đưa vào/ra theo `kk(id)`; tượng `pop` cùng lúc. Mẫu: `o/quay.gd`, short `03-hai-ban/canh/sach.gd` (đặt sách).
### om_dau / om_tai / kiet — dict trong `mam.gd`: OM_DAU (bỏ chạy, ghép `["run",0.6]`), OM_TAI (nghe tiêu, `all` hạ 16), KIET (kiệt sức chống gối, `all` hạ 30; ôm nhau cười = tay `{-60,-40}` + `rot` ±`sin(t*9)*0.07`). Mẫu: `o/cuoi.gd` k22, short `02-oan-gia/canh/oan.gd`.
- **Bài học tập 03**: khối bột co về 0 (mộ, lá gói) làm `triangulate_polygon` lỗi → `bot()` lùi về bao lồi khi tam giác hoá rỗng. Short mới tạo phải chạy `--import` một lần, không thì font/mp3 null.
