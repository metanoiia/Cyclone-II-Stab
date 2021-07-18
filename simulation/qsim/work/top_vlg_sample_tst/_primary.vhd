library verilog;
use verilog.vl_types.all;
entity top_vlg_sample_tst is
    port(
        CLOCK_50        : in     vl_logic;
        GPIO_1          : in     vl_logic_vector(3 downto 0);
        KEY             : in     vl_logic_vector(3 downto 0);
        \miso_\         : in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end top_vlg_sample_tst;
