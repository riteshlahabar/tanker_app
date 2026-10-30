import math, struct, wave

RATE = 44100

def beep(freq, secs, amp=0.55):
    n = int(RATE * secs)
    fade = int(RATE * 0.008)          # 8 ms ramps, or each beep starts with a click
    out = []
    for i in range(n):
        g = amp
        if i < fade:
            g *= i / fade
        elif i > n - fade:
            g *= (n - i) / fade
        out.append(g * math.sin(2 * math.pi * freq * i / RATE))
    return out

def silence(secs):
    return [0.0] * int(RATE * secs)

# Two-tone, twice, then a gap — a 2 s loop that reads as "answer me" rather
# than as a ringtone, and whose gap leaves room to hear someone speak.
pattern = (beep(880, 0.18) + silence(0.07) + beep(1175, 0.18) + silence(0.25)) * 2 + silence(0.84)

frames = b''.join(struct.pack('<h', max(-32767, min(32767, int(s * 32767)))) for s in pattern)

with wave.open(r'C:\All Project\Tanker Project\project\tanker_app_wtms\assets\sounds\buzzer.wav', 'wb') as w:
    w.setnchannels(1)
    w.setsampwidth(2)
    w.setframerate(RATE)
    w.writeframes(frames)

print('frames', len(frames), 'seconds', round(len(pattern) / RATE, 3))
