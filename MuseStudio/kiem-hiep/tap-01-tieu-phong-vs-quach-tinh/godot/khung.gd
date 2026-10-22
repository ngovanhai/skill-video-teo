# Một khung tranh trên cuộn giấy (tập 01). Mỗi khung là một file khung/kNN.gd extends Khung, tự vẽ trong ve().
# Thời gian cục bộ lt: 0 = lúc câu đầu tiên của khung bắt đầu; âm = máy quay đang trôi tới; sau khi khung hết, lt cứ tăng
# (vẽ theo trạng thái cuối). Mọi thứ vẽ thuần theo lt nên nhảy tới giữa phim vẫn đúng.
class_name Khung
extends Node2D

var kid := ""            # "k01"
var t_first := 0.0       # giây (toàn phim) câu đầu bắt đầu
var t_end := 0.0         # giây (toàn phim) khung kết thúc
var ls: Array = []       # giờ bắt đầu cục bộ từng câu
var ld: Array = []       # độ dài từng câu
var lt := -999.0         # giờ cục bộ hiện tại (main đặt mỗi khung hình)
var tt := 0.0            # giờ toàn phim
var active := false      # đang là khung chính

# --- khung con ghi đè -------------------------------------------------------
var X := 0.0             # vị trí giữa khung trên cuộn (toạ độ thế giới)
var pre := 0.0           # thêm giây trước câu đầu
var post := 1.6          # giây nghỉ sau câu cuối
var gaps := {}           # {chỉ số câu: giây nghỉ thêm SAU câu đó}
var travel := 1.8        # giây máy quay trôi tới khung này
var keep := true         # false: thôi vẽ khi khung kết thúc (khung sau vẽ đè cùng chỗ)
var wide := false        # vẽ ở cả ngoài tầm X (khung trải dài)
var ben := 1.0           # Tèo đứng bên nào của màn hình (1 phải, -1 trái)

func cam(_lt: float) -> Array:      # [tâm (toạ độ cục bộ), zoom]
	return [Vector2.ZERO, 1.0]
func sfx() -> Array:                # [[lt, "tên file trong sfx/ không đuôi", dB], …]
	return []
func teo(_lt: float) -> Dictionary: # Tèo đứng ngoài tranh (toạ độ màn hình): {pos, s, pose, expr, a}; {} = vắng
	return teo_mac()
# Tèo mặc định: nửa người ở góc dưới, cầm bút lông, quay vào tranh; vẫy bút khi đổi câu
func teo_mac(expr := "binh", extra := {}) -> Dictionary:
	var k := 0.0
	for i in ls.size():
		k = maxf(k, 1.0 - absf(lt - ls[i]) / 0.5)
	var x := 1690.0 if ben > 0 else 230.0
	var pose := {"face": -ben, "prop": "but", "aF": 0.9 + 0.5 * k + 0.1 * sin(tt * 1.3), "eF": 0.9 - 0.4 * k, "aB": -0.1, "lean": 0.05 * sin(tt * 0.7)}
	pose.merge(extra, true)
	var a := clampf((lt + travel + pre) / 0.6, 0.0, 1.0)
	return {"pos": Vector2(x, 1200.0 + 420.0 * (1.0 - But.eo(a))), "s": 1.15, "pose": pose, "expr": expr, "a": 1.0}
func ve() -> void:
	pass
func done() -> float:               # độ dài phần có lời của khung (cục bộ)
	return ls[ls.size() - 1] + ld[ld.size() - 1] if ls.size() else 0.0

# --- tiện ích ----------------------------------------------------------------
# máy quay theo mốc: keys = [[giờ cục bộ, tâm, zoom], …]; mỗi mốc trôi tới trong d giây; thêm chút lắc thở
static func keycam(keys: Array, t: float, d := 2.0) -> Array:
	var pos: Vector2 = keys[0][1]; var z: float = keys[0][2]
	for i in range(1, keys.size()):
		var u := But.ez(But.pg(t, keys[i][0], keys[i][3] if keys[i].size() > 3 else d))
		pos = pos.lerp(keys[i][1], u); z = exp(lerpf(log(z), log(keys[i][2]), u))
	return [pos + Vector2(sin(t * 0.21) * 8.0, cos(t * 0.17) * 5.0), z]

func L(i: int) -> float: return ls[clampi(i, 0, ls.size() - 1)]
func E(i: int) -> float: return ls[clampi(i, 0, ls.size() - 1)] + ld[clampi(i, 0, ld.size() - 1)]
func pg(a: float, d: float) -> float: return But.pg(lt, a, d)
func ap(i: int, d := 0.8, off := 0.0) -> float: return But.pg(lt, L(i) + off, d)   # hiện dần từ đầu câu i
func nguoi(key: String, feet: Vector2, s: float, pose := {}, expr := "binh", alpha := 1.0) -> void:
	Nguoi.ve(self, key, feet, s, pose, expr, tt, alpha)

func _process(_d: float) -> void:
	queue_redraw()
func _draw() -> void:
	if lt < -travel - pre - 0.5: return
	if not keep and tt > t_end + 0.05: return
	ve()
