# Fixture praktikum, bukan backend

Empat contoh deterministik: Khatib → Unand tersedia, Veteran → Unand tersedia,
Khatib → Unand penuh, dan Unand → Khatib arah pulang. Nama/rating/ongkos adalah contoh,
bukan tawaran perjalanan nyata. UI menampilkan status data latihan.

Koordinat/alamat diambil dari Photon/OpenStreetMap, 8 Oktober 2026.
Geometry mobil diambil satu kali dari OSRM/FOSSGIS pada tanggal yang sama,
overview=full, geometries=geojson, steps=false; semua respons Ok,
snap endpoint maksimum 0,25 meter. Geometry disimpan, tanpa routing jaringan saat startup.

| Jalur | Titik | Panjang (m) | Sumber |
|---|---:|---:|---|
| khatib | 475 | 16812.4 | [OSRM](https://routing.openstreetmap.de/routed-car/route/v1/driving/100.3548088,-0.9099249;100.4627099,-0.9148733?overview=full&geometries=geojson&steps=false) |
| veteran | 430 | 14282.9 | [OSRM](https://routing.openstreetmap.de/routed-car/route/v1/driving/100.3545128,-0.9376233;100.4627099,-0.9148733?overview=full&geometries=geojson&steps=false) |
| pulang | 443 | 15141.6 | [OSRM](https://routing.openstreetmap.de/routed-car/route/v1/driving/100.4627099,-0.9148733;100.3548088,-0.9099249?overview=full&geometries=geojson&steps=false) |

[© OpenStreetMap contributors](https://www.openstreetmap.org/copyright);
[OSRM / FOSSGIS](https://routing.openstreetmap.de/about.html).
Bukan navigasi real-time, jaminan rute terkini atau data privat pengguna.
Geometry sintetis dalam tes diisolasi dan tidak dipakai oleh fixture aplikasi.
