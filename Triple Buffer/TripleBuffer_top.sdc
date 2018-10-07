create_clock -period 20.000 -name clk_in_raw clk_in_raw
create_clock -period 40.000 -name pclk camera_pclk
create_clock -period 40.000 -name xclk camera_xclk
create_clock -period 100.00 -name cam_vsync camera_vsync
create_clock -period 40.000 -name mhz25 MHz_25:m25|clk_out
create_clock -period 40.000 -name vga_clk VGA_clkout 
create_clock -period 100.00 -name vga_vsync VGA:vga|Vsync
derive_pll_clocks
derive_clock_uncertainty

