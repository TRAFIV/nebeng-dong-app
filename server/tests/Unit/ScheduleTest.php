<?php

namespace Tests\Unit;

use App\Support\Schedule;
use PHPUnit\Framework\TestCase;

/** Teks jadwal lama ↔ daftar hari (sama dengan ride_schedule.dart di aplikasi). */
class ScheduleTest extends TestCase
{
    public function test_parse_reads_ranges_lists_and_every_day(): void
    {
        $this->assertSame([1, 2, 3, 4, 5], Schedule::parse('Senin–Jumat'));
        $this->assertSame([1, 2, 3, 4, 5, 6], Schedule::parse('Senin - Sabtu'));
        $this->assertSame([1, 3], Schedule::parse('Senin, Rabu'));
        $this->assertSame([1, 6, 7], Schedule::parse('Sabtu–Senin'));
        $this->assertSame([1, 2, 3, 4, 5, 6, 7], Schedule::parse('Setiap hari'));
        $this->assertSame([5], Schedule::parse("Jum'at"));
        $this->assertNull(Schedule::parse('Kalau sempat'));
    }

    public function test_label_is_readable(): void
    {
        $this->assertSame('Senin–Jumat', Schedule::label(['1', '2', '3', '4', '5']));
        $this->assertSame('Sabtu, Minggu', Schedule::label([7, 6]));
        $this->assertSame('Setiap hari', Schedule::label([1, 2, 3, 4, 5, 6, 7]));
        $this->assertSame('Senin, Rabu', Schedule::label([3, 1, 3]));
    }
}
