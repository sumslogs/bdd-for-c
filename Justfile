[private]
default:
    just --list --unsorted

build_dir := "build"

# cmake configure + build
build:
    cmake -B {{build_dir}} -S .
    cmake --build {{build_dir}}

# remove the build directory
clean:
    rm -rf {{build_dir}}

# run the example (intentional failure, won't abort the recipe)
example: build
    {{build_dir}}/example_test || true

# build then run the self-tests
test: build
    {{build_dir}}/array_test
    {{build_dir}}/test_tree_test
    {{build_dir}}/dynamic_test
    {{build_dir}}/before_after

# build then run all tests under valgrind
test-valgrind: build
    valgrind --leak-check=full --error-exitcode=1 {{build_dir}}/array_test
    valgrind --leak-check=full --error-exitcode=1 {{build_dir}}/test_tree_test
    valgrind --leak-check=full --error-exitcode=1 {{build_dir}}/dynamic_test
    valgrind --leak-check=full --error-exitcode=1 {{build_dir}}/before_after

# compile and run all tests with AddressSanitizer + UBSan
test-asan:
    cc -std=c99 -Wall -Wextra -fsanitize=address,undefined -g -o {{build_dir}}/asan_array array.c
    cc -std=c99 -Wall -Wextra -fsanitize=address,undefined -g -o {{build_dir}}/asan_tree test-tree.c
    cc -std=c99 -Wall -Wextra -fsanitize=address,undefined -g -o {{build_dir}}/asan_dynamic dynamic-test.c
    cc -std=c99 -Wall -Wextra -fsanitize=address,undefined -g -o {{build_dir}}/asan_before before-after.c
    {{build_dir}}/asan_array
    {{build_dir}}/asan_tree
    {{build_dir}}/asan_dynamic
    {{build_dir}}/asan_before
