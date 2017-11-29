library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cpu is
	port(
			rst : in std_logic; --reset
			clkIn : in std_logic; --时钟�?  默认�?50M  可以通过修改绑定管教来改�?
			
			--串口
			dataReady : in std_logic;   
			tbre : in std_logic;
			tsre : in std_logic;
			rdn : inout std_logic;
			wrn : inout std_logic;
			
			--RAM1  存放数据
			ram1En : out std_logic;
			ram1We : out std_logic;
			ram1Oe : out std_logic;
			ram1Data : inout std_logic_vector(15 downto 0);
			ram1Addr : out std_logic_vector(15 downto 0);
			
			--RAM2 存放程序和指�?
			ram2En : out std_logic;
			ram2We : out std_logic;
			ram2Oe : out std_logic;
			ram2Data : inout std_logic_vector(15 downto 0);
			ram2Addr : out std_logic_vector(15 downto 0);
			
			--debug  digit1、digit2显示PC值，led显示当前指令的编�?
			digit1 : out std_logic_vector(6 downto 0);
			digit2 : out std_logic_vector(6 downto 0);
			led : out std_logic_vector(15 downto 0)
	);
			
end cpu;

architecture Behavioral of cpu is
	
	--时钟
	component Clock
	port(
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
	
	--产生�?有控制信号的控制�?
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
			jumpIn : in std_logic;
			
			WBIn : in std_logic;
			memReadIn : in std_logic;
			memWriteIn : in std_logic;
			memToRegIn : in std_logic;
			dataSrcIn : in std_logic;
			

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
	port map(	rst => rst,
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
			rst => rst,
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
			
			rdChoose => controllerOut(10 downto 8),
			
			rdOut => rdMuxOut
		);
		
	u5 : Controller
	port map(	commandIn => IfIdCommand,
			rst => rst,
			controllerOut => controllerOut,
			choose_imm => choose_imm,
			choose_data =>choose_data
		);
		
	u6 : Registers
	port map(
			clk => clk,
			rst => rst,
			
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
			rst => rst,

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
			
			dataEx => ExMemData,
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
			
			dataEx => ExMemData,
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
			
			jump => IdExJump,
			
			PCOut => BranchPC
		);
	
	u14 : ExMemRegisters
	port map(
			clk => clk,
			rst => rst,
			--dataAIn => DataA2,
			--dataBIn => DataB2,
			dataAIn => AMuxOut,
			dataBIn => BMuxOut,
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
			rst => rst,
			
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
			rst => rst,
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
		rst => rst,
		clk 			=> clkIn,
		MemWrite		=> ExMemWrite,
		MemRead		=> ExMemRead,
		ram_data		=> ExMemData,
		ram_addr		=> ExMemAns,
		ins_addr 	=> PcOut,
		data_out		=> ioData,
		ins_out 		=> ioCommand,
		tbre			=> tbre,
		tsre			=> tsre,
		rdn 			=> rdn,
		wrn			=> wrn,
		ram1_en 		=> ram1En,
		ram1_oe		=> ram1Oe,
		ram1_we		=> ram1We,
		ram1_addr	=> ram1Addr,
		ram1_data	=> ram1Data,
		ram2_en	   => ram2En,
		ram2_oe		=> ram2Oe,
		ram2_we		=> ram2We,
		ram2_addr	=> ram2Addr,
		ram2_data	=> ram2Data,
		data_ready	=> dataReady
	);
	
	u19 : Clock
	port map(
		clkIn => clkIn,
		
		clk_8 => clk_8,
		clk_15 => clk
	);
	
	led <= ioCommand;
	--jing <= PCOut;
	process(PCOut)
		begin
		case PCOut(7 downto 4) is
			when "0000" => digit1 <= "0111111";--0
			when "0001" => digit1 <= "0001001";--1
			when "0010" => digit1 <= "1011110";--2
			when "0011" => digit1 <= "1011011";--3
			when "0100" => digit1 <= "1101001";--4
			when "0101" => digit1 <= "1110110";--5
			when "0110" => digit1 <= "1110111";--6
			when "0111" => digit1 <= "0011001";--7
			when "1000" => digit1 <= "1111111";--8
			when "1001" => digit1 <= "1111111";--9
			when "1010" => digit1 <= "1111101";--A
			when "1011" => digit1 <= "1100111";--B
			when "1100" => digit1 <= "0110110";--C
			when "1101" => digit1 <= "1001111";--D
			when "1110" => digit1 <= "1110110";--E
			when "1111" => digit1 <= "1110100";--F
			when others => digit1 <= "0000000";
		end case;
		
		case PCOut(3 downto 0) is
			when "0000" => digit2 <= "0111111";--0
			when "0001" => digit2 <= "0001001";--1
			when "0010" => digit2 <= "1011110";--2
			when "0011" => digit2 <= "1011011";--3
			when "0100" => digit2 <= "1101001";--4
			when "0101" => digit2 <= "1110110";--5
			when "0110" => digit2 <= "1110111";--6
			when "0111" => digit2 <= "0011001";--7
			when "1000" => digit2 <= "1111111";--8
			when "1001" => digit2 <= "1111111";--9
			when "1010" => digit2 <= "1111101";--A
			when "1011" => digit2 <= "1100111";--B
			when "1100" => digit2 <= "0110110";--C
			when "1101" => digit2 <= "1001111";--D
			when "1110" => digit2 <= "1110110";--E
			when "1111" => digit2 <= "1110100";--F
			when others => digit2 <= "0000000";
		end case;
	end process;
end Behavioral;

