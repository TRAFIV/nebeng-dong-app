<?php

namespace App\Support;

/**
 * Hari jalan rute: angka ISO 1 = Senin … 7 = Minggu.
 *
 * Aplikasi memakai daftar hari (schedule_days) untuk pilihan "Hari ini/Besok";
 * teks (schedule) tetap dikirim sebagai label yang mudah dibaca.
 */
final class Schedule
{
    public const DAYS = [
        1 => 'Senin',
        2 => 'Selasa',
        3 => 'Rabu',
        4 => 'Kamis',
        5 => 'Jumat',
        6 => 'Sabtu',
        7 => 'Minggu',
    ];

    /**
     * Membaca teks jadwal lama, mis. "Senin–Jumat", "Senin, Rabu",
     * "Setiap hari". Null bila tidak terbaca.
     *
     * @return list<int>|null
     */
    public static function parse(string $text): ?array
    {
        $text = str_replace("jum'at", 'jumat', mb_strtolower($text));
        if (str_contains($text, 'setiap hari') || str_contains($text, 'tiap hari')) {
            return array_keys(self::DAYS);
        }

        $names = array_map('mb_strtolower', self::DAYS);
        $pattern = implode('|', $names);
        if (preg_match("/($pattern)\s*(?:–|—|-|s\.?d\.?|sampai)\s*($pattern)/u", $text, $match)) {
            $from = array_search($match[1], $names, true);
            $to = array_search($match[2], $names, true);
            $days = [];
            for ($day = $from; ; $day = $day % 7 + 1) {
                $days[] = $day;
                if ($day === $to) {
                    break;
                }
            }

            return self::normalize($days);
        }

        $days = [];
        foreach ($names as $day => $name) {
            if (str_contains($text, $name)) {
                $days[] = $day;
            }
        }

        return $days === [] ? null : self::normalize($days);
    }

    /**
     * Label dari daftar hari: "Setiap hari", "Senin–Jumat", atau "Senin, Rabu".
     *
     * @param  array<int|string>  $days
     */
    public static function label(array $days): string
    {
        $days = self::normalize($days);
        if (count($days) === 7) {
            return 'Setiap hari';
        }
        $consecutive = count($days) >= 3
            && $days === range($days[0], $days[0] + count($days) - 1);
        if ($consecutive) {
            return self::DAYS[$days[0]].'–'.self::DAYS[end($days)];
        }

        return implode(', ', array_map(fn (int $day) => self::DAYS[$day], $days));
    }

    /**
     * Angka 1–7 unik dan urut (CheckboxList mengirim teks "1", "2", …).
     *
     * @param  array<int|string>  $days
     * @return list<int>
     */
    public static function normalize(array $days): array
    {
        $days = array_values(array_unique(array_filter(
            array_map('intval', $days),
            fn (int $day) => $day >= 1 && $day <= 7,
        )));
        sort($days);

        return $days;
    }
}
