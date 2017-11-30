----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:16:05 11/24/2015 
-- Design Name: 
-- Module Name:    cpu - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cpu is
	port(
			--rst : in std_logic; --reset
			clk_in : in std_logic; --时钟�?  默认�?50M  可以通过修改绑定管教来改�?
			touch_btn : in std_logic_vector(31 downto 0);
			--串口
			uart_dataready : in std_logic;   
			uart_tbre : in std_logic;
			uart_tsre : in std_logic;
			uart_rdn : inout std_logic;
			uart_wrn : inout std_logic;
			
			--RAM1  存放数据
			base_ram_ce_n : out std_logic;
			base_ram_we_n : out std_logic;
			base_ram_oe_n : out std_logic;
			base_ram_data : inout std_logic_vector(15 downto 0);
			base_ram_addr : out std_logic_vector(15 downto 0);
			
			--RAM2 存放程序和指�?
			ext_ram_ce_n : out std_logic;
			ext_ram_we_n : out std_logic;
			ext_ram_oe_n : out std_logic;
			ext_ram_data : inout std_logic_vector(15 downto 0);
			ext_ram_addr : out std_logic_vector(17 downto 0);
			
			--debug  leds(31 downto 24)、leds(23 downto 16)显示PC值，led显示当前指令的编�?
			--leds(31 downto 24) : out std_logic_vector(6 downto 0);
			--leds(23 downto 16) : out std_logic_vector(6 downto 0);
			--led : out std_logic_vector(15 downto 0);
			leds : out std_logic_vector(31 downto 0)
			--hs,vs : out std_logic;
			--redOut, greenOut, blueOut : out std_logic_vector(2 downto 0)
	);
			
end cpu;

architecture Behavioral of cpu is
	
	component fontRom
		port (
				clka : in std_logic;
				addra : in std_logic_vector(10 downto 0);
				douta : out std_logic_vector(7 downto 0)
		);
	end component;
	
	component digit
		port (
				clka : in std_logic;
				addra : in std_logic_vector(14 downto 0);
				douta : out std_logic_vector(23 downto 0)
			);
	end component;
	
	component VGA_Controller
		port (
	--VGA Side
		hs,vs	: out std_logic;		--行同步�?�场同步信号
		oRed	: out std_logic_vector (2 downto 0);
		oGreen	: out std_logic_vector (2 downto 0);
		oBlue	: out std_logic_vector (2 downto 0);
	--RAM side
--		R,G,B	: in  std_logic_vector (9 downto 0);
--		addr	: out std_logic_vector (18 downto 0);
	-- data
		r0, r1, r2, r3, r4,r5,r6,r7 : in std_logic_vector(15 downto 0);
	-- font rom
		romAddr : out std_logic_vector(10 downto 0);
		romData : in std_logic_vector(7 downto 0);
	-- pc
		pc : in std_logic_vector(15 downto 0);
		cm : in std_logic_vector(15 downto 0);
		tdata : in std_logic_vector(3 downto 0);
	--Control Signals
		reset	: in  std_logic;
		CLK_in	: in  std_logic			--100M时钟输入
	);		
	end component;
	component MEMu
	    port ( clk 			:	in 	STD_LOGIC;
           rst 			: 	in  STD_LOGIC;
           MEMdata_i	:	in 	STD_LOGIC_VECTOR(15 downto 0);
           MEMaddr 		:	in 	STD_LOGIC_VECTOR(15 downto 0);
           MEMwe 		:	in 	STD_LOGIC;
           MEMre		:	in 	STD_LOGIC;
           --IFce			:	in 	STD_LOGIC;
           IFaddr		:	in 	STD_LOGIC_VECTOR(15 downto 0);
			  data_ready :	in STD_LOGIC;
			  tbre		:	in STD_LOGIC;
			  tsre 		:	in STD_LOGIC;

           Ramoe		:	out STD_LOGIC;
           Ramwe		:	out STD_LOGIC;
           Ramen		:	out STD_LOGIC;
           Ramaddr		:	out STD_LOGIC_VECTOR(17 downto 0);
           IFdata_o		:	out STD_LOGIC_VECTOR(15 downto 0);
           MEMdata_o 	:	out STD_LOGIC_VECTOR(15 downto 0);
			  ram1oe			:	out STD_LOGIC;
			  ram1we			:	out STD_LOGIC;
			  ram1en 		:	out STD_LOGIC;
			  ram1data		:	inout STD_LOGIC_VECTOR(7 downto 0);
			  wrn 			:	out STD_LOGIC;
			  rdn 			:	out STD_LOGIC;
           Ramdata		:	inout STD_LOGIC_VECTOR(15 downto 0)
        );
	end component;

	component StageDataUnit
	port(
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

	--时钟
	component Clock
	port(
		rst : in std_logic;
		clkIn : in std_logic;
		
		clk_8 : out std_logic;
		clk_15 : out std_logic
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
		tbre			: in std_logic;
		tsre			: in std_logic;
		rdn 			: inout std_logic;
		wrn				: inout std_logic;
		ram1_en 		: out std_logic;
		ram1_oe			: out std_logic;
		ram1_we			: out std_logic;
		ram1_addr		: out std_logic_vector(15 downto 0);
		ram1_data		: inout std_logic_vector(15 downto 0);
		ram2_en			: out std_logic;
		ram2_oe			: out std_logic;
		ram2_we			: out std_logic;
		ram2_addr		: out std_logic_vector(15 downto 0);
		ram2_data		: inout std_logic_vector(15 downto 0);
		data_ready		: in std_logic
	);
	end component;
	
	--ALU运算�?
	component ALU
			port(
		Asrc       :  in STD_LOGIC_VECTOR(15 downto 0);
		Bsrc       :  in STD_LOGIC_VECTOR(15 downto 0);
		ALUop		  :  in STD_LOGIC_VECTOR(3 downto 0);
		ALUresult  :  out STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000"; -- 默认设为�?0
		branchJudge : out std_logic
		);
	end component;
	
	--选择�?
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
	
	--选择�?
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
	
	--产生�?有控制信号的控制�?
	component Controller
		port(	commandIn : in std_logic_vector(15 downto 0);
			rst : in std_logic;
			imm : out std_logic_vector(2 downto 0);
			controllerOut :  out std_logic_vector(20 downto 0)
			-- RegWrite(1)	SpeReg(2) RegDst(3) Asrc(3) Bsrc(2) ALUOP(4) 
			-- MemRead(1) MemWrite(1) MemToReg(1)  branch(1) jump(1) dataSrc(1)
		);
	end component;
	
	--PC值计�?&选择�?
	component  ExAdderAndBranchMux
		port(
			PCIn : in std_logic_vector(15 downto 0);
			imm : in std_logic_vector(15 downto 0);
			dataA : in std_logic_vector(15 downto 0);
			
			jump : in std_logic;
			
			PCOut : out std_logic_vector(15 downto 0)
		);
	end component;
	
	--EX/MEM阶段寄存�?
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
	
	--ID/EX阶段寄存�?
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
	
	--IF/ID阶段寄存�?
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
	
	--立即数扩展单�?
	component ImmExtend
		port(
			 immIn : in std_logic_vector(10 downto 0);
			 immSele : in std_logic_vector(2 downto 0);
			 
			 immOut : out std_logic_vector(15 downto 0)
		);
	end component;
	
	--MEM/WB阶段寄存�?
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
	
	--PC加法�? 实现PC+1
	component PCAdder
		port( 
			adderIn : in std_logic_vector(15 downto 0);
			adderOut : out std_logic_vector(15 downto 0)
		);
	end component;
	
	--PC选择�? 顺序执行or跳转
	component PCMux
		port( branch : in std_logic;
			branchJudge : in std_logic;
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
	
	--目的寄存器�?�择�?
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
			
			r0Out, r1Out, r2Out,r3Out,r4Out,r5Out,r6Out,r7Out : out std_logic_vector(15 downto 0);
			
			dataA : out std_logic_vector(15 downto 0);
			dataB : out std_logic_vector(15 downto 0);
			dataT : out std_logic_vector(15 downto 0);
			dataSP : out std_logic_vector(15 downto 0);
			dataIH : out std_logic_vector(15 downto 0)
		);
	end component;
	
	--clock
	signal clk : std_logic;
	signal clk_8 : std_logic;
	
	--PCRegister
	signal PCOut : std_logic_vector(15 downto 0); 
	
	--PCAdder
	signal AddedPC : std_logic_vector(15 downto 0);
	
	--IfIdRegisters
	signal rx1, ry1, rz1 :std_logic_vector(2 downto 0);
	signal imm_10_0 : std_logic_vector(10 downto 0);
	signal IfIdCommand, IfIdPC : std_logic_vector(15 downto 0);
	
	--RdMux
	signal rdMuxOut : std_logic_vector(3 downto 0);
	
	--controller
	signal immChoose : std_logic_vector(2 downto 0);
	signal controllerOut : std_logic_vector(20 downto 0);
	
	--Registers
	signal dataA1, dataB1, dataT1, dataSP1, dataIH1 : std_logic_vector(15 downto 0);
	signal r0,r1,r2,r3,r4,r5,r6,r7 : std_logic_vector(15 downto 0);
	--ImmExtend
	signal extendedImm : std_logic_vector(15 downto 0);
	
	--IdExRegisters
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
	signal ExMemData : std_logic_vector(15 downto 0);
	signal ExMemRd : std_logic_vector(3 downto 0);
	signal ExMemRegWrite : std_logic;
	signal ExMemPC, ExMemAns : std_logic_vector(15 downto 0);
	signal ExMemBranch, ExMemBJ : std_logic;
	signal ExMemRead, ExMemWrite, ExMemToReg: std_logic;
	
	--ForwardController
	signal ForwardA, ForwardB, ForwardX, ForwardY : std_logic_vector(1 downto 0);
	
	--MemWbRegisters
	signal WbRd : std_logic_vector(3 downto 0);
	signal WbData : std_logic_vector(15 downto 0);
	signal WB : std_logic;
	
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
	signal IfIdFlush : std_logic;
	signal IdExFlush : std_logic;
	signal ExMemFlush :  std_logic;
	--IO
	signal ioCommand : std_logic_vector(15 downto 0);
	signal ioData : std_logic_vector(15 downto 0);
	--stage
	signal stageA : std_logic_vector(15 downto 0);
	signal stageB : std_logic_vector(15 downto 0);
	
	--digit rom
	signal digitRomAddr : std_logic_vector(14 downto 0);
	signal digitRomData : std_logic_vector(23 downto 0);
	
	--font rom
	signal fontRomAddr : std_logic_vector(10 downto 0);
	signal fontRomData : std_logic_vector(7 downto 0);
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
		
	u3 : 	IfIdRegisters
	port map(
			rst => touch_btn(5),
			clk => clk,
			commandIn => ioCommand,
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
			
			rdChoose => controllerOut(17 downto 15),
			
			rdOut => rdMuxOut
		);
		
	u5 : Controller
	port map(	commandIn => IfIdCommand,
			rst => touch_btn(5),
			imm => immChoose,
			controllerOut => controllerOut
			-- RegWrite(1)	SpeReg(2) RegDst(3) Asrc(3) Bsrc(2) ALUOP(4) 
			-- MemRead(1) MemWrite(1) MemToReg(1)  branch(1) jump(1) dataSrc(1)
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
			
			r0Out => r0,
			r1Out => r1,
			r2Out => r2,
			r3Out => r3,
			r4Out => r4,
			r5Out => r5,
			r6Out => r6,
			r7Out => r7,
			
			dataA => dataA1,
			dataB => dataB1,
			dataT => dataT1,
			dataSP => dataSP1,
			dataIH => dataIH1
		);
		
	u7 : ImmExtend
	port map(
			 immIn => imm_10_0,
			 immSele => immChoose,
			 
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
			ASrcIn => controllerOut(14 downto 12),
			BSrcIn => controllerOut (11 downto 10),
			
			dataAIn => dataA1,
			dataBIn => dataB1,
			dataTIn => dataT1,
			dataIHIn => dataIH1,
			dataSPIn => dataSP1,
			immIn => extendedImm,
			
			WriteKeep => WriteKeep,
			
			WBIn => controllerOut(20),
			memWriteIn => controllerOut(4),
			memReadIn => controllerOut(5),
			memToRegIn => controllerOut(3),
			branchIn => controllerOut(2),
			jumpIn => controllerOut(1),
			ALUOpIn => controllerOut(9 downto 6),
			dataSrcIn => controllerOut(0),
		
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
			dataA => DataA2,
			--dataA => stageA,
			
			jump => IdExJump,
			
			PCOut => BranchPC
		);
	
	u14 : ExMemRegisters
	port map(
			clk => clk,
			rst => touch_btn(5),
			
			--dataAIn => DataA2,
			--dataBIn => DataB2,
			dataAIn => stageA,
			dataBIn => stageB,
			
			rdIn => IdExRd,
			PCIn => BranchPC,
			ansIn => ALUAns,
			branchIn => IdExBranch,
			branchJudgeIn => ALUBJ,
			
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
	 u16 : ConflictController
	 port map(
			rst => touch_btn(5),
			clk => clk,
			branch => ExMemBranch,
			branchJudge => ExMemBj,
			
			IdExMemRead => IdExMemRead,
			IdExRd => IdExRd,
			
			IfIdRx => rx1,
			IfIdRy => ry1,
			IfIdASrc => controllerOut(14 downto 12),
			IfIdBSrc => controllerOut(11 downto 10),
			IfIdMemWrite => controllerOut(4),
			
			PCKeep => PCKeep,
			IfIdKeep => IfIdKeep,
			IfIdFlush => IfIdFlush,
			IdExFlush => IdExFlush,
			WriteKeep => WriteKeep,
			ExMemFlush => ExMemFlush
		);
		
	u17 : PCMux
	port map( 
			branch => ExMemBranch,
			branchJudge => ExMemBJ,
			PCAdd => AddedPC,
			PCJump => ExMemPC,
			
			PCNext => PCMuxOut
		);
	
--	u18 : IO
--	port map(
	--	rst => touch_btn(5),
	--	clk 			=> clk_in,
	--	MemWrite		=> ExMemWrite,
	--	MemRead		=> ExMemRead,
	--	ram_data		=> ExMemData,
		--ram_data => "0000000001001111",
	--	ram_addr		=> ExMemAns,
	--	ins_addr 	=> PcOut,
	--	data_out		=> ioData,
	--	ins_out 		=> ioCommand,
	--	tbre			=> tbre,
	--	tsre			=> tsre,
	--	rdn 			=> rdn,
	--	wrn			=> wrn,
	--	ram1_en 		=> ram1En,
	--	ram1_oe		=> ram1Oe,
	--	ram1_we		=> ram1We,
	--	ram1_addr	=> ram1Addr,
	--	ram1_data	=> ram1Data,
	--	ram2_en	   => ram2En,
	--	ram2_oe		=> ram2Oe,
	--	ram2_we		=> ram2We,
	--	ram2_addr	=> ram2Addr,
	--	ram2_data	=> ram2Data,
	--	data_ready	=> dataReady
	--);
	u18 : MEMU
	    Port map( 
			clk 		 => clk_in,
           rst   	 => touch_btn(5),
           MEMdata_i	=>ExMemData,
           MEMaddr 	=> ExMemAns,
           MEMwe 		=> ExMemWrite,
           MEMre		=> ExMemRead,
           --IFce			:	in 	STD_LOGIC;
           IFaddr		=> PcOut,
			  data_ready => uart_dataReady,
			  tbre		=> uart_tbre,
			  tsre 		=> uart_tsre,

           Ramoe		=> ext_ram_oe_n,
           Ramwe		=> ext_ram_we_n,
           Ramen		=> ext_ram_ce_n,
           Ramaddr	=> ext_ram_Addr,
           IFdata_o	=> ioCommand,
           MEMdata_o => ioData,
			  ram1oe		=> base_ram_Oe_n,
			  ram1we		=> base_ram_We_n,
			  ram1en 	=> base_ram_ce_n,
			  ram1data	=> base_ram_Data( 7 downto 0),
			  wrn 		=> uart_wrn,
			  rdn 		=> uart_rdn,
           Ramdata	=> ext_ram_Data
        );

	u19 : Clock
	port map(
		rst => touch_btn(5),
		clkIn => clk_in,
		
		clk_8 => clk_8,
		clk_15 => clk
	);
	
	
	u20 : StageDataUnit
	port map(
			dataAIn => dataA2,
			dataBIn => dataB2,
			
			forwardA => ForwardX,
			forwardB => ForwardY,
			
			dataEx => ExMemAns,
			dataMem => WbData,
			
			dataAOut => stageA,
			dataBOut => stageB
	);

--	u21 : VGA_Controller
--	port map(
--	--VGA Side
--		hs => hs,
--		vs => vs,
--		oRed => redOut,
--		oGreen => greenOut,
--		oBlue	=> blueOut,
--	--RAM side
----		R,G,B	: in  std_logic_vector (9 downto 0);
----		addr	: out std_logic_vector (18 downto 0);
--	-- data
--		r0 => r0,
--		r1 => r1,
--		r2 => r2,
--		r3 => r3,
--		r4 => r4,
--		r5 => r5,
--		r6 => r6,
--		r7 => r7,
--	--font rom
--		romAddr => fontRomAddr,
--		romData => fontRomdata,
--	--pc
--		pc => PCOut,
--		cm => ioCommand,
--		tdata => dataT1(3 downto 0),
--	--Control Signals
--		reset	=> touch_btn(5),
--		CLK_in => clk_in
--	);		
--	--r0 <= "0110101010010111";
--	--r1 <= "1011100010100110";
--	u22 : digit
--	port map(
--			clkA => clk_in,
--			addra => digitRomAddr,
--			douta => digitRomData
--	);
	
--	u23 : fontRom
--	port map(
--		clka => clk_in,
--		addra => fontRomAddr,
--		douta => fontRomData
--		);
		
	leds(15 downto 0) <= wbdata;
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
	base_ram_Addr <= (others => '0');
end Behavioral;

