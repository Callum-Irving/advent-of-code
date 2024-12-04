package part1

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:text/scanner"

read_two_arrays :: proc(filename: string) -> ([dynamic]int, [dynamic]int, bool) {
	data, ok := os.read_entire_file(filename)
	if !ok {return nil, nil, false}
	defer delete(data)
	input := string(data)

	s: scanner.Scanner
	scanner.init(&s, input, filename)

	arr1, arr2: [dynamic]int
	for scanner.peek_token(&s) != scanner.EOF {
		scanner.scan(&s)
		id1, ok1 := strconv.parse_int(scanner.token_text(&s))
		scanner.scan(&s)
		id2, ok2 := strconv.parse_int(scanner.token_text(&s))

		if !ok1 || !ok2 {
			delete(arr1)
			delete(arr2)
			return nil, nil, false
		}

		append(&arr1, id1)
		append(&arr2, id2)
	}

	return arr1, arr2, true
}

main :: proc() {
	filename := "input"
	if len(os.args) > 1 {
		filename = os.args[1]
	}

	ids_1, ids_2, ok := read_two_arrays(filename)
	if !ok {return}
	defer delete(ids_1)
	defer delete(ids_2)

	slice.sort(ids_1[:])
	slice.sort(ids_2[:])

	distance := 0
	for i in 0 ..< len(ids_1) {
		distance += abs(ids_1[i] - ids_2[i])
	}

	fmt.println(distance)
}

