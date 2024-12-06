package day4

import "core:fmt"
import "core:mem"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:unicode"

LetterGrid :: struct {
	letters: []u8,
	width:   int,
	height:  int,
}

DIRECTIONS :: [?][2]int{{1, 1}, {1, 0}, {1, -1}, {0, 1}, {0, -1}, {-1, 1}, {-1, 0}, {-1, -1}}

letter_grid_init :: proc(lg: ^LetterGrid, text: string) {
	// Get line width by finding first newline in text.
	// If there is no newline, then the grid is just one big line.
	width := strings.index_rune(text, '\n')
	if width == -1 {width = len(text)}
	height := len(text) / (width + 1)
	height += int(text[len(text) - 1] != '\n')
	assert(len(text) >= width * height)

	lg.width = width
	lg.height = height
	lg.letters = make([]u8, width * height)

	// Put rows from text into lg.letters
	for row := 0; row < height; row += 1 {
		start := row * width
		end := start + width
		copy(
			lg.letters[row * width:(row + 1) * width],
			text[row * (width + 1):(row + 1) * (width + 1)],
		)
	}
}

letter_grid_match_direction :: proc(
	lg: LetterGrid,
	x, y: int,
	direction: [2]int,
	word: string,
) -> bool {
	if (direction.x < 0 && x < len(word) - 1) ||
	   (direction.x > 0 && x > lg.width - len(word)) ||
	   (direction.y < 0 && y < len(word) - 1) ||
	   (direction.y > 0 && y > lg.height - len(word)) {
		return false
	}
	stride := direction.x + lg.width * direction.y
	letter_idx := x + lg.width * y
	for c in word {
		if lg.letters[letter_idx] != u8(c) {
			return false
		}
		letter_idx += stride
	}
	return true
}

letter_grid_num_matches :: proc(lg: LetterGrid, x, y: int, word: string) -> int {
	num_matches := 0
	for direction in DIRECTIONS {
		num_matches += int(letter_grid_match_direction(lg, x, y, direction, word))
	}
	return num_matches
}

letter_grid_cross_mas :: proc(lg: LetterGrid, x, y: int) -> bool {
	if (x < 1) || (y < 1) || (x > lg.width - 2) || (y > lg.height - 2) {
		return false
	}
	return(
		(letter_grid_match_direction(lg, x - 1, y - 1, {1, 1}, "MAS") ||
			letter_grid_match_direction(lg, x - 1, y - 1, {1, 1}, "SAM")) &&
		(letter_grid_match_direction(lg, x + 1, y - 1, {-1, 1}, "MAS") ||
				letter_grid_match_direction(lg, x + 1, y - 1, {-1, 1}, "SAM")) \
	)
}

main :: proc() {
	filename := "input"
	if len(os.args) > 1 {
		filename = os.args[1]
	}
	data, ok := os.read_entire_file(filename)
	if !ok {return}
	defer delete(data)

	grid: LetterGrid
	letter_grid_init(&grid, string(data))

	// PART 1
	total := 0
	for i in 0 ..< len(grid.letters) {
		x := i % grid.width
		y := i / grid.width
		total += letter_grid_num_matches(grid, x, y, "XMAS")
	}
	fmt.println(total)

	// PART 2
	total = 0
	for i in 0 ..< len(grid.letters) {
		x := i % grid.width
		y := i / grid.width
		total += int(letter_grid_cross_mas(grid, x, y))
	}
	fmt.println(total)
}

