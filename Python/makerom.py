# Make code array
code = bytearray([
    0xa9, 0xff,         # lda #$ff
    0x8d, 0x02, 0x60,   # sta $6002

    0xa9, 0x55,         # lda #$55
    0x8d, 0x00, 0x60,   # sta $6000

    0xa9, 0xaa,         # lda #$aa
    0x8d, 0x00, 0x60,   # sta $6000

    0x4c, 0x05, 0x80    # jmp $8005
])


# Make ROM array with NOP instruction and add code array to ROM array
rom = code + bytearray([0xea] * (0x20000 - len(code)))

# Reset Vector
rom[0x7ffc] = 0x00
rom[0x7ffd] = 0x80

with open('rom.bin', 'wb') as out_file:
    out_file.write(rom)
