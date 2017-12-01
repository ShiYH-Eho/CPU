library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cpu is
	port(
--			rst : in std_logic; --reset
			clk_in : in std_logic; --时钟�???????????  默认�???????????50M  可以通过修改绑定管教来改�???????????
			clk_uart_in : in std_logic;
			touch_btn : in std_logic_vector(5 downto 0);		
			dip_sw : in std_logic_vector(31 downto 0);	
			--串口
			uart_dataready : in std_logic;   
			uart_tbre : in std_logic;
			uart_tsre : in std_logic;
			uart_rdn : out std_logic;
			uart_wrn : out std_logic;
			
			--RAM1  存放数据
			base_ram_ce_n : out std_logic;
			base_ram_we_n : out std_logic;
			base_ram_oe_n : out std_logic;
			base_ram_data : inout std_logic_vector(31 downto 0);
			base_ram_addr : out std_logic_vector(19 downto 0);
			
			--RAM2 存放程序和指�???????????
			ext_ram_ce_n : out std_logic;
			ext_ram_we_n : out std_logic;
			ext_ram_oe_n : out std_logic;
			ext_ram_data : inout std_logic_vector(31 downto 0);
			ext_ram_addr : out std_logic_vector(19 downto 0);
			
			--debug  leds(31 downto 24)、leds(31 downto 24)显示PC值，led显示当前指令的编�???????????
			leds : out std_logic_vector(31 downto 0)
	);
			
end cpu;

architecture Behavioral of cpu is
	
	--时钟
	component Clock
	port(
	   rst : in std_logic;
		clkIn : in std_logic;
		clk_2 : out std_logic;
		clk_4 : out std_logic;
		clk_6 : out std_logic
	);
	end component;
	
	--访存
	component IO
	port(
		rst : in std_logic;
		clk 			: in std_logic;
		MemWrite		: in std_logic;
		MemRead			: in std_logic;
		ram_data		: in std_logic_vector(15 downto 0);
		ram_addr		: in std_logic_vector(15 downto 0);
		ins_addr 		: in std_logic_vector(15 downto 0);
		data_out		: out std_logic_vector(15 downto 0);
		ins_out 		: out std_logic_vector(15 downto 0);
		uart_tbre			: in std_logic;
		uart_tsre			: in std_logic;
		uart_rdn 			: out std_logic;
		uart_wrn			: out std_logic;
		base_ram_ce_n 		: out std_logic;
		base_ram_oe_n			: out std_logic;
		base_ram_we_n			: out std_logic;
		base_ram_addr		: out std_logic_vector(19 downto 0);
		base_ram_data		: inout std_logic_vector(31 downto 0);
		ext_ram_ce_n			: out std_logic;
		ext_ram_oe_n			: out std_logic;
		ext_ram_we_n			: out std_logic;
		ext_ram_addr		: out std_logic_vector(19 downto 0);
		ext_ram_data		: inout std_logic_vector(31 downto 0);
		uart_dataready		: in std_logic
	);
	end component;
	
	--ALU运算�???????????
	component ALU
			port(
		Asrc       :  in STD_LOGIC_VECTOR(15 downto 0);
		Bsrc       :  in STD_LOGIC_VECTOR(15 downto 0);
		ALUop		  :  in STD_LOGIC_VECTOR(3 downto 0);
		ALUresult  :  out STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000"; -- 默认设为�???????????0
		branchJudge : out std_logic
		);
	end component;
	
	--选择�???????????
	component AMux
		port(
			forwardA : in std_logic_vector(1 downto 0);
			forwardB : in std_logic_vector(1 downto 0);
			ASrc : in std_logic_vector(2 downto 0);
			
			dataA : in std_logic_vector(15 downto 0);
			dataB : in std_logic_vector(15 downto 0);
			dataT : in std_logic_vector(15 downto 0);
			dataIH : in std_logic_vector(15 downto 0);
			dataSP : in std_logic_vector(15 downto 0);
			PCIn : in std_logic_vector(15 downto 0);
			imm : in std_logic_vector(15 downto 0);
			
			dataEx : in std_logic_vector(15 downto 0);
			dataMem : in std_logic_vector(15 downto 0);
			
			AsrcOut : out std_logic_vector(15 downto 0)
		);
	end component;
	
	--选择�???????????
	component BMux
		port(
			forwardA : in std_logic_vector(1 downto 0);
			forwardB : in std_logic_vector(1 downto 0);
			BSrc : in std_logic_vector(1 downto 0);
			
			dataA : in std_logic_vector(15 downto 0);
			dataB : in std_logic_vector(15 downto 0);
			imm : in std_logic_vector(15 downto 0);
			
			dataEx : in std_logic_vector(15 downto 0);
			dataMem : in std_logic_vector(15 downto 0);
			
			BsrcOut : out std_logic_vector(15 downto 0)
		);	
	end component;
	
	--冲突控制
	component ConflictController
		port(
			rst : in std_logic;
			clk : in std_logic;
			
			branch : in std_logic;
			branchJudge : in std_logic;
			jump : in std_logic;
			
			IdExMemRead : in std_logic;
			IdExRd : in std_logic_vector(3 downto 0);
			
			IfIdRx : in std_logic_vector(2 downto 0);
			IfIdRy : in std_logic_vector(2 downto 0);
			IfIdASrc : in std_logic_vector(2 downto 0);
			IfIdBSrc : in std_logic_vector(1 downto 0);
			IfIdMemWrite : in std_logic;
			
			PCKeep : out std_logic;
			IfIdKeep : out std_logic;
			IfIdFlush : out std_logic;
			IdExFlush : out std_logic;
			WriteKeep : out std_logic;
			ExMemFlush : out std_logic
		);
	end component;
	
	--产生�???????????有控制信号的控制�???????????
	component Controller
		port(	
			commandIn : in std_logic_vector (15 downto 0);
        	rst : in std_logic;
        	ControllerOut : out std_logic_vector(19 downto 0) := x"00000";

--        ALUOP : out std_logic_vector(3 downto 0) := "0000";
--        choose_A : out std_logic_vector(2 downto 0) := "000"
--        choose_B : out std_logic_vector(1 downto 0) := "00";
--        choose_Dst : out std_logic_vector (2 downto 0) := "000";
--        special_Reg : out std_logic_vector(1 downto 0) := "00"
--        RegWrite , MemRead , MemWrite  ,MemtoReg : out std_logic := "0";
--        branch , jump : out std_logic := "0";
       	 	choose_imm : out std_logic_vector(2 downto 0) := "000";
        	choose_data : out std_logic := '0'
		);
	end component;
	
	--PC值计�???????????&选择�???????????
	component ExAdderAndBranchMux
		port(
			PCIn : in std_logic_vector(15 downto 0);
			imm : in std_logic_vector(15 downto 0);
			dataA : in std_logic_vector(15 downto 0);
			
			jump : in std_logic;
			
			PCOut : out std_logic_vector(15 downto 0)
		);
	end component;
	
	--EX/MEM阶段寄存�???????????
	component ExMemRegisters
		port(
			clk : in std_logic;
			rst : in std_logic;
			
			dataAIn : in std_logic_vector(15 downto 0);
			dataBIn : in std_logic_vector(15 downto 0);
			rdIn : in std_logic_vector(3 downto 0);
			PCIn : in std_logic_vector(15 downto 0);
			ansIn : in std_logic_vector(15 downto 0);
			branchIn : in std_logic;
			branchJudgeIn : in std_logic;
			jumpIn : in std_logic;
			
			WBIn : in std_logic;
			memReadIn : in std_logic;
			memWriteIn : in std_logic;
			memToRegIn : in std_logic;
			dataSrcIn : in std_logic;
			
			wbKeep : in std_logic;

			rdOut : out std_logic_vector(3 downto 0);
			PCOut : out std_logic_vector(15 downto 0);
			ansOut : out std_logic_vector(15 downto 0);
			branchOut : out std_logic;
			branchJudgeOut : out std_logic;
			jumpOut : out std_logic;
			
			WBOut : out std_logic;
			memReadOut : out std_logic;
			memWriteOut : out std_logic;
			memToRegOut : out std_logic;
			dataOut : out std_logic_vector(15 downto 0)
		);
	end component;
	
	--转发单元
	component ForwardController
		port(
			ExMemRd : in std_logic_vector(3 downto 0);
			MemWbRd : in std_logic_vector(3 downto 0);
			
			ExMemRegWrite : in std_logic;
			MemWbRegWrite : in std_logic;
			
			IdExAsrc : in std_logic_vector(2 downto 0);
			IdExBsrc : in std_logic_vector(1 downto 0);
			IdExRx : in std_logic_vector(2 downto 0);
			IdExRy : in std_logic_vector(2 downto 0);
			
			
			ForwardA : out std_logic_vector(1 downto 0);
			ForwardB : out std_logic_vector(1 downto 0);
			
			ForwardX : out std_logic_vector(1 downto 0);
			ForwardY : out std_logic_vector(1 downto 0)
		);
	end component;
	
	--ID/EX阶段寄存�???????????
	component IdExRegisters
		port(
			clk : in std_logic;
			rst : in std_logic;

			IdExFlush : in std_logic;
			
			PCIn : in std_logic_vector(15 downto 0);
			rdIn : in std_logic_vector(3 downto 0);
			rxIn : in std_logic_vector(2 downto 0);
			ryIn : in std_logic_vector(2 downto 0);
			ASrcIn : in std_logic_vector(2 downto 0);
			BSrcIn : in std_logic_vector(1 downto 0);
			
			dataAIn : in std_logic_vector(15 downto 0);
			dataBIn : in std_logic_vector(15 downto 0);			
			dataTIn : in std_logic_vector(15 downto 0);
			dataIHIn : in std_logic_vector(15 downto 0);
			dataSPIn : in std_logic_vector(15 downto 0);
			immIn : in std_logic_vector(15 downto 0);
			
			WriteKeep : in std_logic;
			
			WBIn : in std_logic;
			memWriteIn : in std_logic;
			memReadIn : in std_logic;
			memToRegIn : in std_logic;
			branchIn : in std_logic;
			jumpIn : in std_logic;
			ALUOpIn : in std_logic_vector(3 downto 0);
			dataSrcIn : in std_logic;
		
			PCOut : out std_logic_vector(15 downto 0);
			rdOut : out std_logic_vector(3 downto 0);
			rxOut : out std_logic_vector(2 downto 0);
			ryOut : out std_logic_vector(2 downto 0);
			ASrcOut : out std_logic_vector(2 downto 0);
			BSrcOut : out std_logic_vector(1 downto 0);
			
			dataAOut : out std_logic_vector(15 downto 0);
			dataBOut : out std_logic_vector(15 downto 0);			
			dataTOut : out std_logic_vector(15 downto 0);
			dataIHOut : out std_logic_vector(15 downto 0);
			dataSPOut : out std_logic_vector(15 downto 0);
			immOut : out std_logic_vector(15 downto 0);
			
			WBOut : out std_logic;
			memWriteOut : out std_logic;
			memReadOut : out std_logic;
			memToRegOut : out std_logic;
			branchOut : out std_logic;
			jumpOut : out std_logic;
			ALUOpOut : out std_logic_vector(3 downto 0);
			dataSrcOut : out std_logic
		);
	end component;
	
	--IF/ID阶段寄存�???????????
	component IfIdRegisters
		port(
			rst : in std_logic;
			clk : in std_logic;
			commandIn : in std_logic_vector(15 downto 0);
			PCIn : in std_logic_vector(15 downto 0); 
			IfIdKeep : in std_logic;
			IfIdFlush : in std_logic;
			
			rx : out std_logic_vector(2 downto 0);
			ry : out std_logic_vector(2 downto 0);
			rz : out std_logic_vector(2 downto 0);
			imm_10_0 : out std_logic_vector(10 downto 0);
			
			
			commandOut : out std_logic_vector(15 downto 0);
			PCOut : out std_logic_vector(15 downto 0)
		);
	end component;
	
	--立即数扩展单�???????????
	component ImmExtend
		port(
			 immIn : in std_logic_vector(10 downto 0);
			 immSele : in std_logic_vector(2 downto 0);
			 immOut : out std_logic_vector(15 downto 0)
		);
	end component;
	
	--MEM/WB阶段寄存�???????????
	component MemWbRegisters
		port(
			clk : in std_logic;
			rst : in std_logic;
			
			dataIn : in std_logic_vector(15 downto 0);
			ansIn : in std_logic_vector(15 downto 0);
			rdIn : in std_logic_vector(3 downto 0);
			
			WBIn : in std_logic;
			memToReg : in std_logic;
			
			rdOut : out std_logic_vector(3 downto 0);
			WBOut : out std_logic;
			dataToWB : out std_logic_vector(15 downto 0)
		);
	end component;
	
	--PC加法�??????????? 实现PC+1
	component PCAdder
		port( 
			adderIn : in std_logic_vector(15 downto 0);
			adderOut : out std_logic_vector(15 downto 0)
		);
	end component;
	
	--PC选择�??????????? 顺序执行or跳转
	component PCMux
		port( branch : in std_logic;
			branchJudge : in std_logic;
			jump : in std_logic;
			PCAdd : in std_logic_vector(15 downto 0);
			PCJump : in std_logic_vector(15 downto 0);
			
			PCNext : out std_logic_vector(15 downto 0)
		);
	end component;
	
	component PCRegister
		port(	rst,clk : in std_logic;
			PCKeep : in std_logic;
			PCIn : in std_logic_vector(15 downto 0);
			PCOut : out std_logic_vector(15 downto 0)
		);
	end component;
	
	--目的寄存器�?�择�???????????
	component RdMux
		port(
			rx : in std_logic_vector(2 downto 0);
			ry : in std_logic_vector(2 downto 0);
			rz : in std_logic_vector(2 downto 0);
			
			rdChoose : in std_logic_vector(2 downto 0);
			
			rdOut : out std_logic_vector(3 downto 0)
		);
	end component;
	
	--寄存器堆
	component Registers
		port(
			clk : in std_logic;
			rst : in std_logic;
			
			rx : in std_logic_vector(2 downto 0);
			ry : in std_logic_vector(2 downto 0);
			
			WbRd : in std_logic_vector(3 downto 0);
			WbData : in std_logic_vector(15 downto 0);
			WB : in std_logic;
			
			dataA : out std_logic_vector(15 downto 0);
			dataB : out std_logic_vector(15 downto 0);
			dataT : out std_logic_vector(15 downto 0);
			dataSP : out std_logic_vector(15 downto 0);
			dataIH : out std_logic_vector(15 downto 0)
		);
	end component;
	component StageDataUnit
	port(
			rst : in std_logic;

			dataAIn : in std_logic_vector(15 downto 0);
			dataBIn : in std_logic_vector(15 downto 0);
			
			forwardA : in std_logic_vector(1 downto 0);
			forwardB : in std_logic_vector(1 downto 0);
			
			dataEx : in std_logic_vector(15 downto 0);
			dataMem : in std_logic_vector(15 downto 0);
			
			dataAOut : out std_logic_vector(15 downto 0);
			dataBOut : out std_logic_vector(15 downto 0)
	);
	end component;
	component ledDebug
	port(
		rst              : In  STD_LOGIC;
		clk              : IN  STD_LOGIC;
		SW               : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		DebugEnable      : IN  STD_LOGIC;
		LedOut           : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		Number           : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0);

		if_PCKeep        : IN  STD_LOGIC := '1';
		if_NewPC         : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		if_PCToIM        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		if_PCPlus1       : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		if_PCRx          : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		if_PCAddImm      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		if_Inst          : IN  STD_LOGIC_VECTOR(15 DOWNTO 0); --instruction from ram2

		id_Inst          : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		id_PCPlus1       : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		id_PCAddImm      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		id_Imme          : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
		ext_Imme         : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);

		ctrl_CurPC       : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		ctrl_ImmeSrc     : IN  STD_LOGIC_VECTOR( 2 DOWNTO 0);
		ctrl_ZeroExt     : IN  STD_LOGIC;
		ctrl_ALUOp       : IN  STD_LOGIC_VECTOR( 3 DOWNTO 0);
		ctrl_ASrc        : IN  STD_LOGIC_VECTOR( 2 DOWNTO 0);
		ctrl_BSrc        : IN  STD_LOGIC_VECTOR( 1 DOWNTO 0);
		ctrl_MemRead     : IN  STD_LOGIC;
		ctrl_MemWE       : IN  STD_LOGIC;
		ctrl_DstReg      : IN  STD_LOGIC_VECTOR( 3 DOWNTO 0);
		ctrl_RegWE       : IN  STD_LOGIC;
		ctrl_ASrc4       : IN  STD_LOGIC_VECTOR( 3 DOWNTO 0);
		ctrl_BSrc4       : IN  STD_LOGIC_VECTOR( 3 DOWNTO 0);
		ctrl_PCMuxSel    : IN  STD_LOGIC_VECTOR( 1 DOWNTO 0);
		ctrl_ExceptPC    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		ctrl_NowPC       : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		ctrl_InDelayslot : IN  STD_LOGIC;
		ctrl_BranchFlag  : IN  STD_LOGIC;

		rf_Data1         : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		rf_Data2         : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		id_data1         : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		id_data2         : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);

		exe_Data1        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		exe_Data2        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		exe_Imme         : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		exe_DstReg       : IN  STD_LOGIC_VECTOR( 3 DOWNTO 0);
		exe_RegWE        : IN  STD_LOGIC;
		exe_MemRead      : IN  STD_LOGIC;
		exe_MemWE        : IN  STD_LOGIC;
		exe_ALUOp        : IN  STD_LOGIC_VECTOR( 3 DOWNTO 0);
		exe_ASrc         : IN  STD_LOGIC_VECTOR( 1 DOWNTO 0);
		exe_BSrc         : IN  STD_LOGIC_VECTOR( 1 DOWNTO 0);
		exe_BOp          : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		exe_ASrc4        : IN  STD_LOGIC_VECTOR( 3 DOWNTO 0);
		exe_BSrc4        : IN  STD_LOGIC_VECTOR( 3 DOWNTO 0);
		exe_MemWriteData : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		exe_InDelayslot  : IN  STD_LOGIC;
		exe_PCSel        : IN  STD_LOGIC_VECTOR( 1 DOWNTO 0);

		alu_F            : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		alu_T            : IN  STD_LOGIC;

		mem_DstReg       : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		mem_RegWE        : IN  STD_LOGIC;
		mem_MemWE        : IN  STD_LOGIC;
		mem_MemRead      : IN  STD_LOGIC;
		mem_ALUOut       : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		mem_MemWriteData : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		mem_ReadData     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		mem_DstVal       : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		mem_MemSignal    : IN  STD_LOGIC_VECTOR( 2 DOWNTO 0);

		mem_vga_wrn      : IN  STD_LOGIC;
		mem_vga_data     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		mem_vgaR         : IN  STD_LOGIC_VECTOR( 2 DOWNTO 0);
		mem_vgaG         : IN  STD_LOGIC_VECTOR( 2 DOWNTO 0);
		mem_vgaB         : IN  STD_LOGIC_VECTOR( 2 DOWNTO 0);

		wb_DstReg        : IN  STD_LOGIC_VECTOR( 3 DOWNTO 0);
		wb_RegWE         : IN  STD_LOGIC;
		wb_DstVal        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);    

		ram1_en          : IN  STD_LOGIC;
		ram1_oe          : IN  STD_LOGIC;
		ram1_we          : IN  STD_LOGIC;
		ram2_en          : IN  STD_LOGIC;
		ram2_oe          : IN  STD_LOGIC;
		ram2_we          : IN  STD_LOGIC;
		ram1_data        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0); 
		ram1_addr        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		ram2_data        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0); 
		ram2_addr        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);

		ram1_InstRead    : IN  STD_LOGIC;
		ram1_NowPC       : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		ram1_Except      : IN  STD_LOGIC;
		ram1_ExceptPC    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		ram1_LED         : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		ram1_numout      : IN  STD_LOGIC_VECTOR( 7 DOWNTO 0);
		ram2_LED         : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		ram2_numout      : IN  STD_LOGIC_VECTOR( 7 DOWNTO 0);
		UartOut          : IN  STD_LOGIC_VECTOR(15 downto 0);
		

		fwd_ForwardA     : IN  STD_LOGIC_VECTOR( 1 DOWNTO 0);
		fwd_ForwardB     : IN  STD_LOGIC_VECTOR( 1 DOWNTO 0);

		hdu_IFID_Keep    : IN  STD_LOGIC;
		hdu_IDEX_Stall   : IN  STD_LOGIC;

		data_ready       : in STD_LOGIC;
		keyboard_key_value: in STD_LOGIC_VECTOR(15 downto 0);

		R0, R1, R2, R3   : IN  STD_LOGIC_VECTOR(15 downto 0);
		R4, R5, R6, R7   : IN  STD_LOGIC_VECTOR(15 downto 0);
		SP, T, IH        : IN  STD_LOGIC_VECTOR(15 downto 0)
	);
	end component;
	--clock
	signal clk : std_logic;
	signal clk_4 : std_logic;
	signal clk_2 : std_logic;
	
	--PCRegister
	signal PCOut : std_logic_vector(15 downto 0); 
	
	--PCAdder
	signal AddedPC : std_logic_vector(15 downto 0);
	
	--IfIdRegisters
	signal IfIdFlush : std_logic;
	signal rx1, ry1, rz1 :std_logic_vector(2 downto 0);
	signal imm_10_0 : std_logic_vector(10 downto 0);
	signal IfIdCommand, IfIdPC : std_logic_vector(15 downto 0);
	
	--RdMux
	signal rdMuxOut : std_logic_vector(3 downto 0);
	
	--controller
	signal choose_imm : std_logic_vector(2 downto 0);
	signal choose_data : std_logic;
	signal controllerOut : std_logic_vector(19 downto 0);
	
	--Registers
	signal dataA1, dataB1, dataT1, dataSP1, dataIH1 : std_logic_vector(15 downto 0);
	
	--ImmExtend
	signal extendedImm : std_logic_vector(15 downto 0);
	
	--IdExRegisters
	signal IdExFlush : std_logic;
	signal IdExPC : std_logic_vector(15 downto 0);
	signal IdExRd : std_logic_vector(3 downto 0);
	signal rx2,ry2 : std_logic_vector(2 downto 0);
	signal ASrc : std_logic_vector(2 downto 0);
	signal BSrc : std_logic_vector(1 downto 0);
	signal dataA2,dataB2,dataT2,dataIH2,dataSP2 : std_logic_vector(15 downto 0);
	signal imm2 : std_logic_vector(15 downto 0);
	signal IdExWB,IdExMemWrite,IdExMemRead,IdExMemToReg,IdExBranch,IdExDataSrc,IdExJump : std_logic;
	signal IdExALUOP : std_logic_vector(3 downto 0);
	
	--ExMemRegisters
	signal ExMemFlush : std_logic;
	signal ExMemData : std_logic_vector(15 downto 0);
	signal ExMemRd : std_logic_vector(3 downto 0);
	signal ExMemRegWrite : std_logic;
	signal ExMemPC, ExMemAns : std_logic_vector(15 downto 0);
	signal ExMemBranch, ExMemBJ , ExMemJump : std_logic;
	signal ExMemRead, ExMemWrite, ExMemToReg: std_logic;
	
	--ForwardController
	signal ForwardA, ForwardB ,ForwardX, ForwardY: std_logic_vector(1 downto 0);
	
	--MemWbRegisters
	signal WbRd : std_logic_vector(3 downto 0);
	signal WbData : std_logic_vector(15 downto 0);
	signal WB : std_logic;
	
	signal stageA : std_logic_vector(15 downto 0);
	signal stageB : std_logic_vector(15 downto 0);

	--AMux
	signal AMuxOut : std_logic_vector(15 downto 0);
	
	--BMux
	signal BMuxOut : std_logic_vector(15 downto 0);
	
	--ALU
	signal ALUAns : std_logic_vector(15 downto 0);
	signal ALUBJ : std_logic;
	
	--ExAdder&BranchMux
	signal BranchPC : std_logic_vector(15 downto 0);
	
	--PCMux
	signal PCMuxOut : std_logic_vector(15 downto 0);
	
	--ConflictController
	signal PCKeep : std_logic;
	signal IfIdKeep : std_logic;
	signal WriteKeep : std_logic;
	
	--IO
	signal ioCommand : std_logic_vector(15 downto 0);
	signal ioData : std_logic_vector(15 downto 0);
begin
	u1 : PCRegister
	port map(	rst => touch_btn(5),
			clk => clk,
			PCKeep => PCKeep,
			PCIn => PCMuxOut,
			PCOut => PCOut
	);
		
	u2 : PCAdder
	port map( 
			adderIn => PCOut,
			adderOut => AddedPC
	);
		
	u3 : IfIdRegisters
	port map(
			rst => touch_btn(5),
			clk => clk,
			commandIn => dip_sw(31 downto 16),
			--commandIn => ioCommand,
			PCIn => AddedPc,
			IfIdKeep => IfIdKeep,
			IfIdFlush => IfIdFlush,
			
			rx => rx1,
			ry => ry1,
			rz => rz1,
			imm_10_0 => imm_10_0,
					
			commandOut => IfIdCommand,
			PCOut => IfIdPC
		);
		
	u4 : RdMux
	port map(
			rx => rx1,
			ry => ry1,
			rz => rz1,
			
			rdChoose => controllerOut(10 downto 8),
			
			rdOut => rdMuxOut
		);
		
	u5 : Controller
	port map(	commandIn => IfIdCommand,
			rst => touch_btn(5),
			controllerOut => controllerOut,
			choose_imm => choose_imm,
			choose_data =>choose_data
		);
		
	u6 : Registers
	port map(
			clk => clk,
			rst => touch_btn(5),
			
			rx => rx1,
			ry => ry1,
			
			WbRd => WbRd,
			WbData => WbData,
			WB => WB,
			
			dataA => dataA1,
			dataB => dataB1,
			dataT => dataT1,
			dataSP => dataSP1,
			dataIH => dataIH1
		);
		
	u7 : ImmExtend
	port map(
			 immIn => imm_10_0,
			 immSele => choose_imm,
			 
			 immOut => extendedImm
		);
		
	u8 : IdExRegisters
	port map(
			clk => clk,
			rst => touch_btn(5),

			IdExFlush => IdExFlush,
			
			PCIn => IfIdPC,
			rdIn => rdMuxOut,
			rxIn => rx1,
			ryIn => ry1,
			ASrcIn => controllerOut(15 downto 13),
			BSrcIn => controllerOut (12 downto 11),
			
			dataAIn => dataA1,
			dataBIn => dataB1,
			dataTIn => dataT1,
			dataIHIn => dataIH1,
			dataSPIn => dataSP1,
			immIn => extendedImm,
			
			WriteKeep => WriteKeep,
			
			WBIn => controllerOut(5),
			memWriteIn => controllerOut(3),
			memReadIn => controllerOut(4),
			memToRegIn => controllerOut(2),
			branchIn => controllerOut(1),
			jumpIn => controllerOut(0),
			ALUOpIn => controllerOut(19 downto 16),
			dataSrcIn => choose_data,
		
			PCOut => IdExPC,
			rdOut => IdExRd,
			rxOut => rx2,
			ryOut => ry2,
			ASrcOut => ASrc,
			BSrcOut => BSrc,
			
			dataAOut => dataA2,
			dataBOut => dataB2,
			dataTOut => dataT2,
			dataIHOut => dataIH2,
			dataSPOut => dataSP2,
			immOut => imm2,
			
			WBOut => IdExWB,
			memWriteOut => IdExMemWrite,
			memReadOut => IdExMemRead,
			memToRegOut => IdExMemToReg,
			branchOut => IdExBranch,
			jumpOut => IdExJump,
			ALUOpOut => IdExALUOP,
			dataSrcOut => IdExDataSrc
		);
		
	u9 : AMux
		port map(
			forwardA => ForwardA,
			forwardB => ForwardB,
			ASrc => ASrc,
			
			dataA => dataA2,
			dataB => dataB2,
			dataT => dataT2,
			dataIH => dataIH2,
			dataSP => dataSP2,
			PCIn => IdExPC,
			imm => imm2,
			
			dataEx => ExMemAns,
			dataMem => WbData,
			
			AsrcOut => AMuxOut
		);
		
	u10 : BMux
	port map(
			forwardA => ForwardA,
			forwardB => ForwardB,
			BSrc => BSrc,
			
			dataA => dataA2,
			dataB => dataB2,
			imm => imm2,
			
			dataEx => ExMemAns,
			dataMem => WbData,
			
			BsrcOut => BMuxOut
		);	
		
	u11 : ForwardController
	port map(
			ExMemRd => ExMemRd,
			MemWbRd => WbRd,
			
			ExMemRegWrite => ExMemRegWrite,
			MemWbRegWrite => WB,
			
			IdExAsrc => ASrc,
			IdExBsrc => Bsrc,
			
			IdExRx => rx2,
			IdExRy => ry2,
			
			ForwardA => ForwardA,
			ForwardB => ForWardB,
			
			ForwardX => ForwardX,
			ForwardY => ForwardY
		);
	
	u12 : ALU
	port map(
		Asrc      	=> AMuxOut,
		Bsrc        => BMuxOut,
		ALUop		  	=> IdExALUOP,
		ALUresult  	=> ALUAns,
		branchJudge => ALUBJ
	);
	
	u13 : ExAdderAndBranchMux
	port map(
			PCIn => IdExPC,
			imm => imm2,
			dataA => stageA,
			--dataA => DataA2,
			
			jump => IdExJump,
			
			PCOut => BranchPC
		);
	
	u14 : ExMemRegisters
	port map(
			clk => clk,
			rst => touch_btn(5),
			dataAIn => stageA,
			dataBIn => stageB,
			rdIn => IdExRd,
			PCIn => BranchPC,
			ansIn => ALUAns,
			branchIn => IdExBranch,
			branchJudgeIn => ALUBJ,
			jumpIn => IdExJump,
			
			WBIn => IdExWb,
			memReadIn => IdExMemRead,
			memWriteIn => IdExMemWrite,
			memToRegIn => IdExMemToReg,
			dataSrcIn => IdExDataSrc,
			
			wbKeep => ExMemFlush,

			rdOut => ExMemRd,
			PCOut => ExMemPC,
			ansOut => ExMemAns,
			branchOut => ExMemBranch,
			branchJudgeOut => ExMemBJ,
			jumpOut => ExMemJump,
			
			WBOut => ExMemRegWrite,
			memReadOut => ExMemRead,
			memWriteOut => ExMemWrite,
			memToRegOut => ExMemToReg,
			dataOut => ExMemData
		);
	
	u15 : MemWbRegisters
	port map(
			clk => clk,
			rst => touch_btn(5),
			
			dataIn => ioData,
			ansIn => ExMemAns,
			rdIn => ExMemRd,
			
			WBIn => ExMemRegWrite,
			memToReg => ExMemToReg,
			
			rdOut => WbRd,
			WBOut => WB,
			dataToWB => WbData
		);
---
	 u16 : ConflictController
	 port map(
			rst => touch_btn(5),
			clk => clk,

			branch =>ExMemBranch,
			branchJudge => ExMemBJ,
			jump => ExMemJump,

			IdExMemRead => IdExMemRead,
			IdExRd => IdExRd,
			
			IfIdRx => rx1,
			IfIdRy => ry1,
			IfIdASrc => controllerOut(15 downto 13),
			IfIdBSrc => controllerOut(12 downto 11),
			
			IfIdMemWrite => ControllerOut(3),

			PCKeep => PCKeep,
			IfIdKeep => IfIdKeep,
			IfIdFlush => IfIdFlush,
			IdExFlush => IdExFlush,
			WriteKeep => WriteKeep,
			ExMemFlush => ExMemFlush
		);
---		
	u17 : PCMux
	port map( 
			branch => ExMemBranch,
			branchJudge => ExMemBJ,
			jump => ExMemJump,
			PCAdd => AddedPC,
			PCJump => ExMemPC,
			
			PCNext => PCMuxOut
		);
---
	
	u18 : IO
	port map(
		rst => touch_btn(5),
		clk 			=> touch_btn(4),
		MemWrite		=> ExMemWrite,
		MemRead		=> ExMemRead,
		ram_data		=> ExMemData,
		ram_addr		=> ExMemAns,
		ins_addr 	=> PcOut,
		data_out		=> ioData,
		ins_out 		=> ioCommand,
		uart_tbre			=> uart_tbre,
		uart_tsre			=> uart_tsre,
		uart_rdn 			=> uart_rdn,
		uart_wrn			=> uart_wrn,
		base_ram_ce_n		=> base_ram_ce_n,
		base_ram_oe_n		=> base_ram_oe_n,
		base_ram_we_n		=> base_ram_we_n,
		base_ram_addr	=> base_ram_addr,
		base_ram_data	=> base_ram_data,
		ext_ram_ce_n	   => ext_ram_ce_n,
		ext_ram_oe_n		=> ext_ram_oe_n,
		ext_ram_we_n	=> ext_ram_we_n,
		ext_ram_addr	=> ext_ram_addr,
		ext_ram_data	=> ext_ram_data,
		uart_dataready	=> uart_dataready
	);
	
	u19 : Clock
	port map(
		rst => touch_btn(5),
		clkIn => touch_btn(4),--clk_in,
		clk_2 => clk_2,
		clk_4 => clk_4,
		clk_6 => clk
	);

	u20 : StageDataUnit
	port map(
			rst => touch_btn(5),

			dataAIn => dataA2,
			dataBIn => dataB2,
			
			forwardA => ForwardX,
			forwardB => ForwardY,
			
			dataEx => ExMemAns,
			dataMem => WbData,
			
			dataAOut => stageA,
			dataBOut => stageB
	);
	
	u21 : ledDebug
	port map(
		rst              => touch_btn(5),
		clk              => touch_btn(4),
		SW               => dip_sw(15 downto 0),
		DebugEnable      => touch_btn(0),
		LedOut           => leds(15 downto 0),
		--Number           : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0);

		if_PCKeep        => PCKeep,
		if_NewPC         => PCMuxOut,
		if_PCToIM        => PcOut,--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		if_PCPlus1       => addedPC,
		if_PCRx          => x"0000" ,--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		if_PCAddImm      => x"0000",--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		--if_Inst          => ioCommand, --instruction from ram2
		if_Inst			=> dip_sw(31 downto 16),
		id_Inst          => ifidcommand,--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		id_PCPlus1       => addedPC,--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		id_PCAddImm      => BranchPC,--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		id_Imme          => "00000000000",--: IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
		ext_Imme          => extendedimm,--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);

		ctrl_CurPC       => PCOut,--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		ctrl_ImmeSrc     => choose_imm,--: IN  STD_LOGIC_VECTOR( 2 DOWNTO 0);
		ctrl_ZeroExt     => choose_imm(2),--: IN  STD_LOGIC;
		ctrl_ALUOp       => controllerOut(19 downto 16),--: IN  STD_LOGIC_VECTOR( 3 DOWNTO 0);
		ctrl_ASrc        => controllerOut(15 downto 13),--: IN  STD_LOGIC_VECTOR( 1 DOWNTO 0);
		ctrl_BSrc        => controllerOut(12 downto 11),--: IN  STD_LOGIC_VECTOR( 1 DOWNTO 0);
		ctrl_MemRead     => controllerOut(4),--: IN  STD_LOGIC;
		ctrl_MemWE       => controllerOut(3),--: IN  STD_LOGIC;
		ctrl_DstReg      => rdMuxOut,--: IN  STD_LOGIC_VECTOR( 3 DOWNTO 0);
		ctrl_RegWE       => controllerOut(5),--: IN  STD_LOGIC;
		ctrl_ASrc4        => "0000",--: IN  STD_LOGIC_VECTOR( 3 DOWNTO 0);
		ctrl_BSrc4        => "0000",--: IN  STD_LOGIC_VECTOR( 3 DOWNTO 0);
		ctrl_PCMuxSel    => "00",--: IN  STD_LOGIC_VECTOR( 1 DOWNTO 0);
		ctrl_ExceptPC    => x"0000",--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		ctrl_NowPC       => x"0000",--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		ctrl_InDelayslot => '0',--: IN  STD_LOGIC;
		ctrl_BranchFlag  => controllerOut(1),--=> : IN  STD_LOGIC;

		rf_Data1         => dataa1,--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		rf_Data2         => datab1,--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		id_data1         => stagea,--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		id_data2         => stageb,--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);

		exe_Data1        => AmuxOut,--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		exe_Data2        => BmuxOut,--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		exe_Imme         => imm2,--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		exe_DstReg       => idexrd,--,: IN  STD_LOGIC_VECTOR( 3 DOWNTO 0);
		exe_RegWE        => idexwb,--: IN  STD_LOGIC;
		exe_MemRead      => idexmemread,--: IN  STD_LOGIC;
		exe_MemWE        => idexmemwrite,--: IN  STD_LOGIC;
		exe_ALUOp        => idexALUOP,--: IN  STD_LOGIC_VECTOR( 3 DOWNTO 0);
		exe_ASrc         => Asrc(1 downto 0),--: IN  STD_LOGIC_VECTOR( 1 DOWNTO 0);
		exe_BSrc         => Bsrc,--: IN  STD_LOGIC_VECTOR( 1 DOWNTO 0);
		exe_BOp          => x"0000",--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		exe_ASrc4        => "0000",--: IN  STD_LOGIC_VECTOR( 3 DOWNTO 0);
		exe_BSrc4        => "0000",--: IN  STD_LOGIC_VECTOR( 3 DOWNTO 0);
		exe_MemWriteData => x"0000",--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		exe_InDelayslot  => '0',--: IN  STD_LOGIC;
		exe_PCSel        => "00",--: IN  STD_LOGIC_VECTOR( 1 DOWNTO 0);

		alu_F            => x"0000",--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		alu_T            => '0',--: IN  STD_LOGIC;

		mem_DstReg       => ExmemRd,--: IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		mem_RegWE        => Exmemregwrite,--: IN  STD_LOGIC;
		mem_MemWE        => exmemwrite,--: IN  STD_LOGIC;
		mem_MemRead      => exmemread,--: IN  STD_LOGIC;
		mem_ALUOut       => exmemans,--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		mem_MemWriteData => exmemdata,--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		mem_ReadData     => x"0000",--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		mem_DstVal       => x"0000",--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		mem_MemSignal    => "000",--: IN  STD_LOGIC_VECTOR( 2 DOWNTO 0);

		mem_vga_wrn      => '0',--: IN  STD_LOGIC;
		mem_vga_data     => x"0000",--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		mem_vgaR         => "000",--: IN  STD_LOGIC_VECTOR( 2 DOWNTO 0);
		mem_vgaG         => "000",--: IN  STD_LOGIC_VECTOR( 2 DOWNTO 0);
		mem_vgaB         => "000",--: IN  STD_LOGIC_VECTOR( 2 DOWNTO 0);

		wb_DstReg        => wbrd,--: IN  STD_LOGIC_VECTOR( 3 DOWNTO 0);
		wb_RegWE         => wb,--: IN  STD_LOGIC;
		wb_DstVal        => x"0000",--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);    

		ram1_en           => '0',--=> base_ram_ce_n,--: IN  STD_LOGIC;
		ram1_oe          => '0',-- => base_ram_oe_n,--: IN  STD_LOGIC;
		ram1_we          => '0',-- => base_ram_we_n,--: IN  STD_LOGIC;
		ram2_en           => '0',--=> ext_ram_ce_n,--: IN  STD_LOGIC;
		ram2_oe           => '0',--=> ext_ram_oe_n,--: IN  STD_LOGIC;
		ram2_we          => '0',-- => ext_ram_we_n,--: IN  STD_LOGIC;
		ram1_data        => x"0000",--=> base_ram_data(15 downto 0),--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0); 
		ram1_addr        => x"0000",--=> base_ram_addr(15 downto 0),--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		ram2_data        => x"0000",--=> ext_ram_data(15 downto 0),--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0); 
		ram2_addr        => x"0000",--=> ext_ram_addr(15 downto 0),--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);

        ram1_InstRead     => '0',--: IN  STD_LOGIC;
		ram1_NowPC       => x"0000",--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		ram1_Except      => '0',-- : IN  STD_LOGIC;
		ram1_ExceptPC    => x"0000",--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		ram1_LED         => x"0000",--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		ram1_numout      => x"00",--: IN  STD_LOGIC_VECTOR( 7 DOWNTO 0);
		ram2_LED         => x"0000",--: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		ram2_numout      => x"00",--: IN  STD_LOGIC_VECTOR( 7 DOWNTO 0);
		UartOut          => x"0000",--: IN  STD_LOGIC_VECTOR(15 downto 0);
		

		fwd_ForwardA     => forwardA,--: IN  STD_LOGIC_VECTOR( 1 DOWNTO 0);
		fwd_ForwardB     => forwardB,--: IN  STD_LOGIC_VECTOR( 1 DOWNTO 0);

		hdu_IFID_Keep     => '0',--: IN  STD_LOGIC;
		hdu_IDEX_Stall   => '0',-- : IN  STD_LOGIC;

		data_ready       => uart_dataready,--: in STD_LOGIC;
		keyboard_key_value => x"0000",--: in STD_LOGIC_VECTOR(15 downto 0);
		
		R0=> x"0000",
		R1=> x"0000",
		R2=> x"0000",
		R3   => x"0000",--: IN  STD_LOGIC_VECTOR(15 downto 0);
		R4=> x"0000",
		R5=> x"0000",
		R6=> x"0000",
		R7   => x"0000",--: IN  STD_LOGIC_VECTOR(15 downto 0);
		SP=> x"0000",
		 T=> x"0000",
		IH        => x"0000"--: IN  STD_LOGIC_VECTOR(15 downto 0)
	);

	ext_ram_addr(19 downto 16) <= "0000";
	--leds(15 downto 0) <= iodata;
	--jing <= PCOut;
	process(PCOut)
		begin
		case PCOut(7 downto 4) is
			when "0000" => leds(31 downto 24) <= "01111110";--0
			when "0001" => leds(31 downto 24) <= "00010010";--1
			when "0010" => leds(31 downto 24) <= "10111100";--2
			when "0011" => leds(31 downto 24) <= "10110110";--3
			when "0100" => leds(31 downto 24) <= "11010010";--4
			when "0101" => leds(31 downto 24) <= "11100110";--5
			when "0110" => leds(31 downto 24) <= "11101110";--6
			when "0111" => leds(31 downto 24) <= "00110010";--7
			when "1000" => leds(31 downto 24) <= "11111110";--8
			when "1001" => leds(31 downto 24) <= "11110110";--9
			when "1010" => leds(31 downto 24) <= "11111010";--A
			when "1011" => leds(31 downto 24) <= "11001110";--B
			when "1100" => leds(31 downto 24) <= "01101100";--C
			when "1101" => leds(31 downto 24) <= "10011110";--D
			when "1110" => leds(31 downto 24) <= "11101100";--E
			when "1111" => leds(31 downto 24) <= "11101000";--F
			when others => leds(31 downto 24) <= "00000000";
		end case;
		
		case PCOut(3 downto 0) is
			when "0000" => leds(23 downto 16) <= "01111110";--0
			when "0001" => leds(23 downto 16) <= "00010010";--1
			when "0010" => leds(23 downto 16) <= "10111100";--2
			when "0011" => leds(23 downto 16) <= "10110110";--3
			when "0100" => leds(23 downto 16) <= "11010010";--4
			when "0101" => leds(23 downto 16) <= "11100110";--5
			when "0110" => leds(23 downto 16) <= "11101110";--6
			when "0111" => leds(23 downto 16) <= "00110010";--7
			when "1000" => leds(23 downto 16) <= "11111110";--8
			when "1001" => leds(23 downto 16) <= "11110110";--9
			when "1010" => leds(23 downto 16) <= "11111010";--A
			when "1011" => leds(23 downto 16) <= "11001110";--B
			when "1100" => leds(23 downto 16) <= "01101100";--C
			when "1101" => leds(23 downto 16) <= "10011110";--D
			when "1110" => leds(23 downto 16) <= "11101100";--E
			when "1111" => leds(23 downto 16) <= "11101000";--F
			when others => leds(23 downto 16) <= "00000000";
		end case;
	end process;
end Behavioral;

