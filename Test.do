force clk 0 0, 1 50 -repeat 100
force reset 1
run 200
force reset 0

# Load reference vector
force key_in x"131211100B0A090803020100"
force y_in   x"736E6165"
force x_in   x"74614620"

# Pulse start
force start 1
run 100
force start 0

# Let it run for enough time (26 rounds)
run 7000

