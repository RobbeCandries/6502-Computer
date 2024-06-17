# This program combines 4 ROM images into 1 so that the image can be
# selected with dip switches on A16 and A17 on the SST39SF010A flash chip

import os

# Get file paths
print('Leave blank to skip')
rom00Path = input('Path to rom image 00: ')
rom01Path = input('Path to rom image 01: ')
rom10Path = input('Path to rom image 10: ')
rom11Path = input('Path to rom image 11: ')
outputPath = input('Path to output file: ')


# Check if input paths are valid
if not (rom00Path.strip() == '' or os.path.isfile(rom00Path)):
    raise Exception('Path to rom image 00 is invalid')

if not (rom01Path.strip() == '' or os.path.isfile(rom01Path)):
    raise Exception('Path to rom image 01 is invalid')

if not (rom10Path.strip() == '' or os.path.isfile(rom10Path)):
    raise Exception('Path to rom image 10 is invalid')

if not (rom11Path.strip() == '' or os.path.isfile(rom11Path)):
    raise Exception('Path to rom image 11 is invalid')


# check if output path is given
if outputPath.strip() == '':
    raise Exception('The output file path cannot be empty')


# Check if output file already exists
if os.path.isfile(outputPath):
    print('The output file already exists')
    print('Do you want to overwrite the file')
    option = input('Y/N: ').strip().lower()
    if option != 'y':
        exit()


if rom00Path.strip() != '':
    # Read files if given
    with open(rom00Path, 'rb') as rom00File:
        rom00Image = list(rom00File.read())
    # Check if file length is correct
    if len(rom00Image) != 0x8000:
        raise Exception('Size of rom image 00 is incorrect Must be 0x8000 bytes long')
else:
    # Generate dummy values if no file path was given
    rom00Image = [0xff] * 0x8000

if rom01Path.strip() != '':
    with open(rom01Path, 'rb') as rom01File:
        rom01Image = list(rom01File.read())
    if len(rom00Image) != 0x8000:
        raise Exception('Size of rom image 01 is incorrect Must be 0x8000 bytes long')
else:
    rom01Image = [0xff] * 0x8000

if rom10Path.strip() != '':
    with open(rom10Path, 'rb') as rom10File:
        rom10Image = list(rom10File.read())
    if len(rom00Image) != 0x8000:
        raise Exception('Size of rom image 10 is incorrect Must be 0x8000 bytes long')
else:
    rom10Image = [0xff] * 0x8000

if rom11Path.strip() != '':
    with open(rom11Path, 'rb') as rom11File:
        rom11Image = list(rom11File.read())
    if len(rom00Image) != 0x8000:
        raise Exception('Size of rom image 11 is incorrect. Must be 0x8000 bytes long')
else:
    rom11Image = [0xff] * 0x8000


# Combine ROM images
outputImage = rom00Image + rom01Image + rom10Image + rom11Image


# Write the combined ROM image ro the passed output file
with open(outputPath, 'wb') as outputFile:
    outputFile.write(bytearray(outputImage))
