library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;

LIBRARY altera;
USE altera.altera_primitives_components.all;


entity DE10_NANO_Top_Level is
	port(
		------------------------------------------------------------
		--  CLOCK Inputs 
		------------------------------------------------------------
		FPGA_CLK1_50  :  in std_logic;	--50MHz clock 				 
		FPGA_CLK2_50  :  in std_logic;	--50MHz clock 
		FPGA_CLK3_50  :  in std_logic;	--50MHz clock 

		------------------------------------------------------------
		--  Push Button Inputs (KEY) - 2 inputs
		--  The KEY inputs produce a '0' when pressed (asserted)
		--  and produce a '1' in the rest state
		--  A better signal name for KEY would be Push_Button_n 
		------------------------------------------------------------
		KEY : in std_logic_vector(1 downto 0);  

		------------------------------------------------------------
		--  Slide Switch Inputs (SW) - 4 inputs
		------------------------------------------------------------
		SW  : in std_logic_vector(3 downto 0);								

		------------------------------------------------------------
		--  LED Outputs - 8 outputs
		------------------------------------------------------------
		LED : out std_logic_vector(7 downto 0);							

		------------------------------------------------------------
		--  GPIO
		------------------------------------------------------------
		GPIO_0 : inout std_logic_vector(35 downto 0);	-- The 40 pin header on the top of the board
		GPIO_1 : inout std_logic_vector(35 downto 0);	-- The 40 pin header on the bottom of the board
		
		------------------------------------------------------------
		--  ADC
		------------------------------------------------------------
      ADC_CONVST	: out STD_LOGIC;
		ADC_SCK		: out STD_LOGIC;
		ADC_SDI		: out STD_LOGIC;
		ADC_SDO		: in  STD_LOGIC;
		
		------------------------------------------------------------
		--  ARDUINO
		------------------------------------------------------------
		ARDUINO_IO			: inout STD_LOGIC_VECTOR(15 downto 0);
		ARDUINO_RESET_N	: inout STD_LOGIC;
		
		------------------------------------------------------------
		--  HDMI
		------------------------------------------------------------
      HDMI_I2C_SCL  : inout STD_LOGIC;
      HDMI_I2C_SDA  : inout STD_LOGIC;
      HDMI_I2S	     : inout STD_LOGIC;
      HDMI_LRCLK	  : inout STD_LOGIC;
      HDMI_MCLK	  : inout STD_LOGIC;
      HDMI_SCLK	  : inout STD_LOGIC;
      HDMI_TX_CLK   : out   STD_LOGIC;
      HDMI_TX_D     : out   STD_LOGIC_VECTOR(23 downto 0);
      HDMI_TX_DE    : out   STD_LOGIC;
      HDMI_TX_HS    : out   STD_LOGIC;
      HDMI_TX_VS    : out   STD_LOGIC;
      HDMI_TX_INT   : in    STD_LOGIC;
      
		------------------------------------------------------------
		--  HPS
		------------------------------------------------------------
      HPS_CONV_USB_N				: inout STD_LOGIC;
      HPS_DDR3_ADDR				: out STD_LOGIC_VECTOR(14 downto 0);
      HPS_DDR3_BA					: out STD_LOGIC_VECTOR(2 downto 0);
      HPS_DDR3_CAS_N				: out STD_LOGIC;
      HPS_DDR3_CKE				: out STD_LOGIC;
      HPS_DDR3_CK_N				: out STD_LOGIC;
      HPS_DDR3_CK_P				: out STD_LOGIC;
      HPS_DDR3_CS_N				: out STD_LOGIC;
      HPS_DDR3_DM					: out STD_LOGIC_VECTOR(3 downto 0);
      HPS_DDR3_DQ					: inout STD_LOGIC_VECTOR(31 downto 0);
      HPS_DDR3_DQS_N				: inout STD_LOGIC_VECTOR(3 downto 0);
      HPS_DDR3_DQS_P				: inout STD_LOGIC_VECTOR(3 downto 0);
      HPS_DDR3_ODT				: out STD_LOGIC;
      HPS_DDR3_RAS_N				: out STD_LOGIC;
      HPS_DDR3_RESET_N			: out STD_LOGIC;
      HPS_DDR3_RZQ				: in STD_LOGIC;
      HPS_DDR3_WE_N				: out STD_LOGIC;
      HPS_ENET_GTX_CLK			: out STD_LOGIC;
      HPS_ENET_INT_N				: inout STD_LOGIC;
      HPS_ENET_MDC				: out STD_LOGIC;
      HPS_ENET_MDIO				: inout STD_LOGIC;
      HPS_ENET_RX_CLK			: in STD_LOGIC;
      HPS_ENET_RX_DATA			: in STD_LOGIC_VECTOR(3 downto 0);
      HPS_ENET_RX_DV				: in STD_LOGIC;
      HPS_ENET_TX_DATA			: out STD_LOGIC_VECTOR(3 downto 0);
      HPS_ENET_TX_EN				: out STD_LOGIC;
      HPS_GSENSOR_INT			: inout STD_LOGIC;
      HPS_I2C0_SCLK				: inout STD_LOGIC;
      HPS_I2C0_SDAT				: inout STD_LOGIC;
      HPS_I2C1_SCLK				: inout STD_LOGIC;
      HPS_I2C1_SDAT				: inout STD_LOGIC;
      HPS_KEY						: inout STD_LOGIC;
      HPS_LED						: inout STD_LOGIC;
      HPS_LTC_GPIO				: inout STD_LOGIC;
      HPS_SD_CLK					: out STD_LOGIC;
      HPS_SD_CMD					: inout STD_LOGIC;
      HPS_SD_DATA					: inout STD_LOGIC_VECTOR(3 downto 0);
      HPS_SPIM_CLK				: out STD_LOGIC;
      HPS_SPIM_MISO				: in STD_LOGIC;
      HPS_SPIM_MOSI				: out STD_LOGIC;
      HPS_SPIM_SS					: inout STD_LOGIC;
      HPS_UART_RX					: in STD_LOGIC;
      HPS_UART_TX					: out STD_LOGIC;
      HPS_USB_CLKOUT				: in STD_LOGIC;
      HPS_USB_DATA				: inout STD_LOGIC_VECTOR(7 downto 0);
      HPS_USB_DIR					: in STD_LOGIC;
      HPS_USB_NXT					: in STD_LOGIC;
      HPS_USB_STP					: out STD_LOGIC
	
	);
end entity DE10_NANO_Top_Level;


architecture DE10_NANO_Top_Level_arch of DE10_NANO_Top_Level is

	---------------------------------------------------------
	-- Signal declarations
	---------------------------------------------------------

	signal hps_fpga_reset_n					: STD_LOGIC;
	signal fpga_debounced_buttons			: STD_LOGIC_VECTOR(3 downto 0);
	signal hps_reset_req						: STD_LOGIC_VECTOR(2 downto 0);
	signal hps_cold_reset					: STD_LOGIC;
	signal hps_warm_reset					: STD_LOGIC;
	signal hps_debug_reset					: STD_LOGIC;
	signal stm_hw_events						: STD_LOGIC_VECTOR(27 downto 0);
	signal fpga_clk_50					 	: STD_LOGIC;
	
   ---------------------------------------------------------------------------------------
   -- Qsys component declaration
   ---------------------------------------------------------------------------------------
   component soc_system is
        port (
            clk_clk                               : in    std_logic                     := 'X';             -- clk
            hps_0_f2h_cold_reset_req_reset_n      : in    std_logic                     := 'X';             -- reset_n
            hps_0_f2h_debug_reset_req_reset_n     : in    std_logic                     := 'X';             -- reset_n
            hps_0_f2h_stm_hw_events_stm_hwevents  : in    std_logic_vector(27 downto 0) := (others => 'X'); -- stm_hwevents
            hps_0_f2h_warm_reset_req_reset_n      : in    std_logic                     := 'X';             -- reset_n
            hps_0_h2f_reset_reset_n               : out   std_logic;                                        -- reset_n
            hps_0_hps_io_hps_io_emac1_inst_TX_CLK : out   std_logic;                                        -- hps_io_emac1_inst_TX_CLK
            hps_0_hps_io_hps_io_emac1_inst_TXD0   : out   std_logic;                                        -- hps_io_emac1_inst_TXD0
            hps_0_hps_io_hps_io_emac1_inst_TXD1   : out   std_logic;                                        -- hps_io_emac1_inst_TXD1
            hps_0_hps_io_hps_io_emac1_inst_TXD2   : out   std_logic;                                        -- hps_io_emac1_inst_TXD2
            hps_0_hps_io_hps_io_emac1_inst_TXD3   : out   std_logic;                                        -- hps_io_emac1_inst_TXD3
            hps_0_hps_io_hps_io_emac1_inst_RXD0   : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD0
            hps_0_hps_io_hps_io_emac1_inst_MDIO   : inout std_logic                     := 'X';             -- hps_io_emac1_inst_MDIO
            hps_0_hps_io_hps_io_emac1_inst_MDC    : out   std_logic;                                        -- hps_io_emac1_inst_MDC
            hps_0_hps_io_hps_io_emac1_inst_RX_CTL : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RX_CTL
            hps_0_hps_io_hps_io_emac1_inst_TX_CTL : out   std_logic;                                        -- hps_io_emac1_inst_TX_CTL
            hps_0_hps_io_hps_io_emac1_inst_RX_CLK : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RX_CLK
            hps_0_hps_io_hps_io_emac1_inst_RXD1   : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD1
            hps_0_hps_io_hps_io_emac1_inst_RXD2   : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD2
            hps_0_hps_io_hps_io_emac1_inst_RXD3   : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD3
            hps_0_hps_io_hps_io_sdio_inst_CMD     : inout std_logic                     := 'X';             -- hps_io_sdio_inst_CMD
            hps_0_hps_io_hps_io_sdio_inst_D0      : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D0
            hps_0_hps_io_hps_io_sdio_inst_D1      : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D1
            hps_0_hps_io_hps_io_sdio_inst_CLK     : out   std_logic;                                        -- hps_io_sdio_inst_CLK
            hps_0_hps_io_hps_io_sdio_inst_D2      : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D2
            hps_0_hps_io_hps_io_sdio_inst_D3      : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D3
            hps_0_hps_io_hps_io_usb1_inst_D0      : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D0
            hps_0_hps_io_hps_io_usb1_inst_D1      : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D1
            hps_0_hps_io_hps_io_usb1_inst_D2      : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D2
            hps_0_hps_io_hps_io_usb1_inst_D3      : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D3
            hps_0_hps_io_hps_io_usb1_inst_D4      : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D4
            hps_0_hps_io_hps_io_usb1_inst_D5      : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D5
            hps_0_hps_io_hps_io_usb1_inst_D6      : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D6
            hps_0_hps_io_hps_io_usb1_inst_D7      : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D7
            hps_0_hps_io_hps_io_usb1_inst_CLK     : in    std_logic                     := 'X';             -- hps_io_usb1_inst_CLK
            hps_0_hps_io_hps_io_usb1_inst_STP     : out   std_logic;                                        -- hps_io_usb1_inst_STP
            hps_0_hps_io_hps_io_usb1_inst_DIR     : in    std_logic                     := 'X';             -- hps_io_usb1_inst_DIR
            hps_0_hps_io_hps_io_usb1_inst_NXT     : in    std_logic                     := 'X';             -- hps_io_usb1_inst_NXT
            hps_0_hps_io_hps_io_spim1_inst_CLK    : out   std_logic;                                        -- hps_io_spim1_inst_CLK
            hps_0_hps_io_hps_io_spim1_inst_MOSI   : out   std_logic;                                        -- hps_io_spim1_inst_MOSI
            hps_0_hps_io_hps_io_spim1_inst_MISO   : in    std_logic                     := 'X';             -- hps_io_spim1_inst_MISO
            hps_0_hps_io_hps_io_spim1_inst_SS0    : out   std_logic;                                        -- hps_io_spim1_inst_SS0
            hps_0_hps_io_hps_io_uart0_inst_RX     : in    std_logic                     := 'X';             -- hps_io_uart0_inst_RX
            hps_0_hps_io_hps_io_uart0_inst_TX     : out   std_logic;                                        -- hps_io_uart0_inst_TX
            hps_0_hps_io_hps_io_i2c0_inst_SDA     : inout std_logic                     := 'X';             -- hps_io_i2c0_inst_SDA
            hps_0_hps_io_hps_io_i2c0_inst_SCL     : inout std_logic                     := 'X';             -- hps_io_i2c0_inst_SCL
            hps_0_hps_io_hps_io_i2c1_inst_SDA     : inout std_logic                     := 'X';             -- hps_io_i2c1_inst_SDA
            hps_0_hps_io_hps_io_i2c1_inst_SCL     : inout std_logic                     := 'X';             -- hps_io_i2c1_inst_SCL
            hps_0_hps_io_hps_io_gpio_inst_GPIO09  : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO09
            hps_0_hps_io_hps_io_gpio_inst_GPIO35  : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO35
            hps_0_hps_io_hps_io_gpio_inst_GPIO40  : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO40
            hps_0_hps_io_hps_io_gpio_inst_GPIO53  : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO53
            hps_0_hps_io_hps_io_gpio_inst_GPIO54  : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO54
            hps_0_hps_io_hps_io_gpio_inst_GPIO61  : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO61
            led_control_leds                      : out   std_logic_vector(7 downto 0);                     -- leds
            memory_mem_a                          : out   std_logic_vector(14 downto 0);                    -- mem_a
            memory_mem_ba                         : out   std_logic_vector(2 downto 0);                     -- mem_ba
            memory_mem_ck                         : out   std_logic;                                        -- mem_ck
            memory_mem_ck_n                       : out   std_logic;                                        -- mem_ck_n
            memory_mem_cke                        : out   std_logic;                                        -- mem_cke
            memory_mem_cs_n                       : out   std_logic;                                        -- mem_cs_n
            memory_mem_ras_n                      : out   std_logic;                                        -- mem_ras_n
            memory_mem_cas_n                      : out   std_logic;                                        -- mem_cas_n
            memory_mem_we_n                       : out   std_logic;                                        -- mem_we_n
            memory_mem_reset_n                    : out   std_logic;                                        -- mem_reset_n
            memory_mem_dq                         : inout std_logic_vector(31 downto 0) := (others => 'X'); -- mem_dq
            memory_mem_dqs                        : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs
            memory_mem_dqs_n                      : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs_n
            memory_mem_odt                        : out   std_logic;                                        -- mem_odt
            memory_mem_dm                         : out   std_logic_vector(3 downto 0);                     -- mem_dm
            memory_oct_rzqin                      : in    std_logic                     := 'X';             -- oct_rzqin
            reset_reset_n                         : in    std_logic                     := 'X'              -- reset_n
        );
    end component soc_system;
	 

	
	--------------------------------------------------------------------------
   -- Debounce logic to clean out glitches within 1ms  GHRD/ip/debounce
	--------------------------------------------------------------------------
	COMPONENT debounce is
		GENERIC ( WIDTH : INTEGER := 2; POLARITY : STRING := "LOW"; TIMEOUT : INTEGER := 50000; TIMEOUT_WIDTH : INTEGER := 16 );
		PORT
		(
			clk			:	 IN STD_LOGIC;
			reset_n		:	 IN STD_LOGIC;
			data_in		:	 IN STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
			data_out		:	 OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0)
		);
	END COMPONENT;
	
	--------------------------------------------------------------------------
   -- GHRD/ip/altsource_probe
	--------------------------------------------------------------------------
	COMPONENT hps_reset is
		PORT
		(
			source_clk	: IN STD_LOGIC;
			source	 	: IN STD_LOGIC_VECTOR(3 DOWNTO 0)
      );
	END COMPONENT;
	
	--------------------------------------------------------------------------
   -- GHRD/ip/edge_detect
	--------------------------------------------------------------------------
	COMPONENT altera_edge_detector
	GENERIC ( PULSE_EXT : INTEGER := 6; EDGE_TYPE : INTEGER := 1; IGNORE_RST_WHILE_BUSY : INTEGER := 1 );
	PORT
	(
		clk		:	 IN STD_LOGIC;
		rst_n		:	 IN STD_LOGIC;
		signal_in		:	 IN STD_LOGIC;
		pulse_out		:	 OUT STD_LOGIC
	);
	END COMPONENT;
	
begin
		
   U0 : component soc_system
        port map (
            clk_clk                               => FPGA_CLK1_50,
            hps_0_f2h_cold_reset_req_reset_n      => not hps_cold_reset,
            hps_0_f2h_debug_reset_req_reset_n     => not hps_debug_reset ,
            hps_0_f2h_stm_hw_events_stm_hwevents  => stm_hw_events,
            hps_0_f2h_warm_reset_req_reset_n      => not hps_warm_reset,
            hps_0_h2f_reset_reset_n               => hps_fpga_reset_n,
            hps_0_hps_io_hps_io_emac1_inst_TX_CLK => HPS_ENET_GTX_CLK,
            hps_0_hps_io_hps_io_emac1_inst_TXD0   => HPS_ENET_TX_DATA(0),
            hps_0_hps_io_hps_io_emac1_inst_TXD1   => HPS_ENET_TX_DATA(1),
            hps_0_hps_io_hps_io_emac1_inst_TXD2   => HPS_ENET_TX_DATA(2), 
            hps_0_hps_io_hps_io_emac1_inst_TXD3   => HPS_ENET_TX_DATA(3),
            hps_0_hps_io_hps_io_emac1_inst_RXD0   => HPS_ENET_RX_DATA(0),
            hps_0_hps_io_hps_io_emac1_inst_MDIO   => HPS_ENET_MDIO,
            hps_0_hps_io_hps_io_emac1_inst_MDC    => HPS_ENET_MDC,
            hps_0_hps_io_hps_io_emac1_inst_RX_CTL => HPS_ENET_RX_DV,
            hps_0_hps_io_hps_io_emac1_inst_TX_CTL => HPS_ENET_TX_EN,
            hps_0_hps_io_hps_io_emac1_inst_RX_CLK => HPS_ENET_RX_CLK,
            hps_0_hps_io_hps_io_emac1_inst_RXD1   => HPS_ENET_RX_DATA(1),
            hps_0_hps_io_hps_io_emac1_inst_RXD2   => HPS_ENET_RX_DATA(2),
            hps_0_hps_io_hps_io_emac1_inst_RXD3   => HPS_ENET_RX_DATA(3),
            hps_0_hps_io_hps_io_sdio_inst_CMD     => HPS_SD_CMD,
            hps_0_hps_io_hps_io_sdio_inst_D0      => HPS_SD_DATA(0),
            hps_0_hps_io_hps_io_sdio_inst_D1      => HPS_SD_DATA(1),
            hps_0_hps_io_hps_io_sdio_inst_CLK     => HPS_SD_CLK,
            hps_0_hps_io_hps_io_sdio_inst_D2      => HPS_SD_DATA(2),
            hps_0_hps_io_hps_io_sdio_inst_D3      => HPS_SD_DATA(3),
            hps_0_hps_io_hps_io_usb1_inst_D0      => HPS_USB_DATA(0),
            hps_0_hps_io_hps_io_usb1_inst_D1      => HPS_USB_DATA(1),
            hps_0_hps_io_hps_io_usb1_inst_D2      => HPS_USB_DATA(2),
            hps_0_hps_io_hps_io_usb1_inst_D3      => HPS_USB_DATA(3),
            hps_0_hps_io_hps_io_usb1_inst_D4      => HPS_USB_DATA(4),
            hps_0_hps_io_hps_io_usb1_inst_D5      => HPS_USB_DATA(5),
            hps_0_hps_io_hps_io_usb1_inst_D6      => HPS_USB_DATA(6),
            hps_0_hps_io_hps_io_usb1_inst_D7      => HPS_USB_DATA(7),
            hps_0_hps_io_hps_io_usb1_inst_CLK     => HPS_USB_CLKOUT,
            hps_0_hps_io_hps_io_usb1_inst_STP     => HPS_USB_STP,
            hps_0_hps_io_hps_io_usb1_inst_DIR     => HPS_USB_DIR,
            hps_0_hps_io_hps_io_usb1_inst_NXT     => HPS_USB_NXT,
            hps_0_hps_io_hps_io_spim1_inst_CLK    => HPS_SPIM_CLK,
            hps_0_hps_io_hps_io_spim1_inst_MOSI   => HPS_SPIM_MOSI,
            hps_0_hps_io_hps_io_spim1_inst_MISO   => HPS_SPIM_MISO,
            hps_0_hps_io_hps_io_spim1_inst_SS0    => HPS_SPIM_SS,
            hps_0_hps_io_hps_io_uart0_inst_RX     => HPS_UART_RX,
            hps_0_hps_io_hps_io_uart0_inst_TX     => HPS_UART_TX,
            hps_0_hps_io_hps_io_i2c0_inst_SDA     => HPS_I2C0_SDAT,
            hps_0_hps_io_hps_io_i2c0_inst_SCL     => HPS_I2C0_SCLK,
            hps_0_hps_io_hps_io_i2c1_inst_SDA     => HPS_I2C1_SDAT,
            hps_0_hps_io_hps_io_i2c1_inst_SCL     => HPS_I2C1_SCLK,
            hps_0_hps_io_hps_io_gpio_inst_GPIO09  => HPS_CONV_USB_N,
            hps_0_hps_io_hps_io_gpio_inst_GPIO35  => HPS_ENET_INT_N,
            hps_0_hps_io_hps_io_gpio_inst_GPIO40  => HPS_LTC_GPIO,
            hps_0_hps_io_hps_io_gpio_inst_GPIO53  => HPS_LED,
            hps_0_hps_io_hps_io_gpio_inst_GPIO54  => HPS_KEY,
            hps_0_hps_io_hps_io_gpio_inst_GPIO61  => HPS_GSENSOR_INT,
            led_control_leds                      => LED,
            memory_mem_a                          => HPS_DDR3_ADDR,
            memory_mem_ba                         => HPS_DDR3_BA,
            memory_mem_ck                         => HPS_DDR3_CK_P,
            memory_mem_ck_n                       => HPS_DDR3_CK_N,
            memory_mem_cke                        => HPS_DDR3_CKE,
            memory_mem_cs_n                       => HPS_DDR3_CS_N,
            memory_mem_ras_n                      => HPS_DDR3_RAS_N,
            memory_mem_cas_n                      => HPS_DDR3_CAS_N,
            memory_mem_we_n                       => HPS_DDR3_WE_N,
            memory_mem_reset_n                    => HPS_DDR3_RESET_N,
            memory_mem_dq                         => HPS_DDR3_DQ,
            memory_mem_dqs                        => HPS_DDR3_DQS_P,
            memory_mem_dqs_n                      => HPS_DDR3_DQS_N,
            memory_mem_odt                        => HPS_DDR3_ODT,
            memory_mem_dm                         => HPS_DDR3_DM,
            memory_oct_rzqin                      => HPS_DDR3_RZQ,		
            reset_reset_n                         => hps_fpga_reset_n
		);

	--! Debounce a the reset button on the development board
	debounce_inst: component debounce
	port map (	
		clk			=> fpga_clk_50,
		reset_n		=> hps_fpga_reset_n,  
		data_in		=> KEY,
		data_out		=> fpga_debounced_buttons(1 downto 0)
	);
   
	--! These look like syncronizers for the various reset types (Altera/Intel code)
	--! @todo What exactly does this do?
	pulse_cold_reset: component altera_edge_detector 
	generic map ( PULSE_EXT => 6, EDGE_TYPE => 1, IGNORE_RST_WHILE_BUSY => 1 )
	port map (	
		clk       => fpga_clk_50,
		rst_n     => hps_fpga_reset_n,
		signal_in => hps_reset_req(0),
		pulse_out => hps_cold_reset
	);
   
	
	--! These look like syncronizers for the various reset types (Altera/Intel code)
	--! @todo What exactly does this do?
	pulse_warm_reset: component altera_edge_detector 
	generic map ( PULSE_EXT => 2, EDGE_TYPE => 1, IGNORE_RST_WHILE_BUSY => 1 )
	port map (	
		clk       => fpga_clk_50,
		rst_n     => hps_fpga_reset_n,
		signal_in => hps_reset_req(1),
		pulse_out => hps_warm_reset
	);
   
	--! These look like syncronizers for the various reset types (Altera/Intel code)
	--! @todo What exactly does this do?
	pulse_debug_reset: component altera_edge_detector 
	generic map ( PULSE_EXT => 32, EDGE_TYPE => 1, IGNORE_RST_WHILE_BUSY => 1 )
	port map (	
		clk       => fpga_clk_50,
		rst_n     => hps_fpga_reset_n,
		signal_in => hps_reset_req(2),
		pulse_out => hps_debug_reset
	);	

end architecture DE10_NANO_Top_Level_arch;