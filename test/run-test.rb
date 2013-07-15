$VERBOSE = true

base_dir = File.expand_path(File.join(File.dirname(__FILE__), ".."))

lib_dir = File.join(base_dir, "lib")
test_dir = File.join(base_dir, "test")

$LOAD_PATH.unshift(lib_dir)

require "coveralls"
Coveralls.wear!

require "test-unit"

Thread.abort_on_exception = true
exit Test::Unit::AutoRunner.run(true, test_dir)
