library verilog;
use verilog.vl_types.all;
entity top_vlg_check_tst is
    port(
        GPIO_1          : in     vl_logic_vector(3 downto 0);
        \cs_\           : in     vl_logic;
        \mosi_\         : in     vl_logic;
        rdy             : in     vl_logic;
        rx_dv_o         : in     vl_logic;
        \sclk_\         : in     vl_logic;
        tx_dv_o         : in     vl_logic;
        sampler_rx      : in     vl_logic
    );
end top_vlg_check_tst;
