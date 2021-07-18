library verilog;
use verilog.vl_types.all;
entity top is
    port(
        CLOCK_50        : in     vl_logic;
        KEY             : in     vl_logic_vector(3 downto 0);
        \miso_\         : in     vl_logic;
        \sclk_\         : out    vl_logic;
        \mosi_\         : out    vl_logic;
        \cs_\           : out    vl_logic;
        tx_dv_o         : out    vl_logic;
        rx_dv_o         : out    vl_logic;
        rdy             : out    vl_logic;
        GPIO_1          : inout  vl_logic_vector(3 downto 0)
    );
end top;
