package day3

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:unicode"

Scanner :: struct {
	src:     string,
	pos:     int,
	enabled: bool,
}

expect :: proc(s: ^Scanner, tag: string) -> bool {
	if len(s.src) - s.pos < len(tag) {
		return false
	}
	if s.src[s.pos:s.pos + len(tag)] == tag {
		s.pos += len(tag)
		return true
	}
	return false
}

expect_int :: proc(s: ^Scanner) -> (int, bool) {
	if s.pos >= len(s.src) {return -1, false}
	num_digits := 0
	for unicode.is_digit(rune(s.src[s.pos + num_digits])) && num_digits < 3 {
		num_digits += 1
	}
	if num_digits == 0 {return -1, false}
	value, ok := strconv.parse_int(s.src[s.pos:s.pos + num_digits])
	// assert(ok, "parse_int should not fail")
	s.pos += num_digits
	return value, true
}

// Parse mul(a,b) and return the product.
expect_mul :: proc(s: ^Scanner) -> (prod: int, ok: bool) {
	// NOTE: if parsing fails partway through, the scanner position doesn't get
	// reset.
	expect(s, "mul(") or_return
	val_1 := expect_int(s) or_return
	expect(s, ",") or_return
	val_2 := expect_int(s) or_return
	expect(s, ")") or_return
	prod = val_1 * val_2
	return prod, true
}

// Jump to the next occurence of any string in options.
jump_to_next_of :: proc(s: ^Scanner, options: []string) -> (string, bool) {
	found: string
	found_idx := -1
	for option in options {
		idx := strings.index(s.src[s.pos:], option)
		if idx == -1 {continue}
		if found_idx == -1 || idx < found_idx {
			found = option
			found_idx = idx
		}
	}
	if found_idx == -1 {return "", false}

	s.pos += found_idx
	return found, true
}

main :: proc() {
	filename := "input"
	if len(os.args) > 1 {
		filename = os.args[1]
	}
	data, ok := os.read_entire_file(filename)
	if !ok {return}
	defer delete(data)
	input := string(data)

	s := Scanner {
		src     = input,
		pos     = 0,
		enabled = true,
	}

	// PART 1
	total := 0
	for strings.index(s.src[s.pos:], "mul(") >= 0 {
		// Jump to next mul(
		s.pos += strings.index(s.src[s.pos:], "mul(")
		prod, ok := expect_mul(&s)
		if !ok {continue}
		total += prod
	}
	fmt.println("Part 1:", total)

	// PART 2
	s.pos = 0
	total = 0
	for {
		instrs := []string{"do()", "don't()", "mul("}
		instruction := jump_to_next_of(&s, instrs) or_break
		switch instruction {
		case "do()":
			ok := expect(&s, "do()")
			assert(ok)
			s.enabled = true
		case "don't()":
			ok := expect(&s, "don't()")
			assert(ok)
			s.enabled = false
		case "mul(":
			prod, ok := expect_mul(&s)
			if !ok {continue}
			total += prod * int(s.enabled)
		case:
			assert(false, "invalid instruction")
		}
	}
	fmt.println("Part 2:", total)
}

