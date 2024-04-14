rom = bytearray([0xff] * 0x20000)

with open('rom.bin', 'wb') as out_file:
    out_file.write(rom)
