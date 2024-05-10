# Generates constants for pattern tables from 4-color BMP images
# Takes an 8X*8Y bmp image, consisting of white, red, green and blue and generates a
# header with array constants that can be used to fill the pattern table

from PIL import Image
import argparse
import os
import os.path

palette = [(0, 0, 0), (255, 0, 0), (0, 255, 0), (0, 0, 255)]


def transform(path):
    tiles = []
    with Image.open(path) as img:
        (width, height) = img.size
        assert (width % 8 == 0) and (
                height % 8 == 0), f"Image {path} dimensions {(width, height)} are not divisible by 8"
        for vert_tile in range(height // 8):
            for hor_tile in range(width // 8):
                tile_data = [0] * 16
                for row in range(8):
                    low_bits = 0
                    high_bits = 0
                    for pixel in range(8):
                        x = hor_tile * 8 + pixel
                        y = vert_tile * 8 + row
                        color = img.getpixel((x, y))
                        assert color in palette, f"Image {path} pixel at {x, y} color {color} not valid - must be red, green, blue or black"
                        color_index = palette.index(color)
                        low_bits <<= 1
                        high_bits <<= 1
                        low_bits |= color_index & 1
                        high_bits |= ((color_index & 2) >> 1)
                    tile_data[row] = low_bits
                    tile_data[row + 8] = high_bits
                tiles.append((vert_tile, hor_tile, tile_data))
    return tiles


def main():
    parser = argparse.ArgumentParser(description="Dendy CHR generator tool")
    parser.add_argument("IMAGE_DIR", help="Folder with images in BMP format - width and height must be divisible by 8")
    parser.add_argument("GENERATED", help="Output header file with constants used to fill the pattern table")

    args = parser.parse_args()
    assert os.path.isdir(args.IMAGE_DIR), f"{args.IMAGE_DIR} is not a directory"

    files = os.listdir(args.IMAGE_DIR)
    pattern_table = []
    tile_addresses = []
    for file_name in files:
        full_path = os.path.join(args.IMAGE_DIR, file_name)
        file_name = os.path.split(full_path)[-1]
        file_name = file_name[:file_name.rfind(".")]
        if os.path.isfile(full_path) and (full_path.endswith(".BMP") or full_path.endswith(".bmp")):
            tiles = transform(full_path)
            for tile in tiles:
                (row, column, data) = tile
                tile_name = f"{file_name}_{row}_{column}"
                tile_addresses.append((tile_name, len(pattern_table)))
                pattern_table += data

    with open(args.GENERATED, "w") as generated_header:
        for tile in tile_addresses:
            print(f"#define TILE_{tile[0].upper()} ({hex(tile[1] // 16)})", file=generated_header)

        print(f"#define PATTERN_TABLE_LENGTH ({hex(len(pattern_table))})", file=generated_header)

        pattern_table_string = "const unsigned char pattern_table_content[PATTERN_TABLE_LENGTH] = {" + ",".join(
            [hex(x) for x in pattern_table]) + "};"
        print("extern const unsigned char pattern_table_content[PATTERN_TABLE_LENGTH];", file=generated_header)

        print(f"#define PATTERN_TABLE_DEFINITION {pattern_table_string}", file=generated_header)


if __name__ == "__main__":
    main()
