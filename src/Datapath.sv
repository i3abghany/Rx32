`timescale 1ns / 1ps

module Datapath(
    input logic clk, reset,
    MemToRegW,
    RegWriteW, RegDistE, 
    jumpM, branchM,
    input logic ALUSrcE, 
    input logic[3:0] ALUControlE, 
    input logic[31:0] instrF,
    input logic[31:0] ReadDataM,
    output logic[5:0] OPD, functD,
    output logic[31:0] PCF, 
    output logic[31:0] ALUOutM,
    output logic[31:0] WriteDataM
);
    logic[31:0] PCNextFD;
    logic[31:0] instrD;
    logic[31:0] instrE;
    logic[31:0] instrM;
    logic[15:0] immD;
    logic[4:0] shamtD;
    logic[4:0] shamtE;
    logic[4:0] RSD, RTD, RDD;
    logic[4:0] RSE, RTE, RDE;
    logic[2:0] selF;
    logic[2:0] selD;
    logic[2:0] selE;
    logic[2:0] selM;
    logic[2:0] selW;
    logic[4:0] WriteRegE;
    logic[4:0] WriteRegM;
    logic[4:0] WriteRegW;
    
    logic[31:0] ResultW;
    logic[31:0] SrcAD, SrcBD;
    logic[31:0] SrcAE, SrcBE;
    logic[31:0] RegSrcBE;
    
    logic[31:0] PCPlus4F;
    logic[31:0] PCPlus4D;
    logic[31:0] PCPlus4E;
    logic[31:0] PCPlus4M;
    
    logic[31:0] PCBranchE;
    logic[31:0] PCBranchM;
    logic[31:0] PCJumpM;
    
    logic[31:0] SignImmD;
    logic[31:0] SignImmE;
    logic[31:0] ShiftedSignImmE;
    
    logic ZeroFlagE;
    logic ZeroFlagM;
     
    logic[31:0] ALUOutE;
    logic[31:0] ALUOutW;
    
    logic[31:0] ReadDataW;
    
    logic PCSrcM;
    
    // Instruction fields. 
    assign OPD    = instrD[31:26];
    assign functD =   instrD[5:0];
    assign shamtD =  instrD[10:6];
    assign immD   =  instrD[15:0];
    assign RSD    = instrD[25:21]; 
    assign RTD    = instrD[20:16]; 
    assign RDD    = instrD[15:11];
    
    /*******************************************************************/
    /*                           Fetch Stage.                          */
    /*******************************************************************/
    
    // Thread selection.
    ThreadSelector TS(.reset(reset), .clk(clk), .sel(selF)); 
    
    assign PCJumpM = { PCPlus4M[31:28], instrM[25:0], 2'b00 };
    Mux3 PCMux(.d0(PCPlus4M), .d1(PCBranchM), .d2(PCJumpM), .sel({jumpM, PCSrcM}), .Y(PCNextFD));
    PCRepository PCRepo( .reset(reset), .clk(clk),                          
                         .en(PCPlus4M != 0), .clear(1'b0), 
                         .sel_read(selF), 
                         .sel_write(selM), 
                         .d_g(PCNextFD), 
                         .q_g(PCF));
    
    Adder PCAdder(.A(PCF), .B(32'h00000004), .Y(PCPlus4F));
    
    /*******************************************************************/
    /*                          Decode Stage.                          */
    /*******************************************************************/
    
    RegRCEn #(32) PRegD1(.clk(clk), .reset(reset), .en(1'b1), .clear(1'b0), .d(instrF), .q(instrD));
    RegRCEn #(32) PRegD2(.clk(clk), .reset(reset), .en(1'b1), .clear(1'b0), .d(PCPlus4F), .q(PCPlus4D));

    RegRCEn #(3) PRegD4(.clk(clk), .reset(reset), .en(1'b1), .clear(1'b0), .d(selF), .q(selD));
    
    SignExtend SEI(.A(immD), .Y(SignImmD));
    
    // Register files repository. Reading is done in the decode stage, writing is done in the 
    // Writeback stage.
    RegFileRepository RegfileRepo(.clk(clk), 
                                  .WE3_g(RegWriteW), 
                                  .sel_read(selD), 
                                  .sel_write(selW),
                                  .RA1_g(RSD), 
                                  .RA2_g(RTD),
                                  .WA3_g(WriteRegW),
                                  .WD3_g(ResultW),
                                  .RD1_g(SrcAD), .RD2_g(SrcBD));
    
    /*******************************************************************/
    /*                          Execute Stage.                         */
    /*******************************************************************/
    
    RegRCEn #(32) PRegInstE(.clk(clk), .reset(reset), .clear(1'b0), .en(1'b1), .d(instrD), .q(instrE));
    
    
    RegRCEn #(5) PRegE1(.clk(clk), .reset(reset), .clear(1'b0), .en(1'b1), .d(RSD), .q(RSE));
    RegRCEn #(5) PRegE2(.clk(clk), .reset(reset), .clear(1'b0), .en(1'b1), .d(RTD), .q(RTE));
    RegRCEn #(5) PRegE3(.clk(clk), .reset(reset), .clear(1'b0), .en(1'b1), .d(RDD), .q(RDE));
    
    
    RegRCEn #(32) PRegE4(.clk(clk), .reset(reset), .clear(1'b0), .en(1'b1), .d(SrcAD), .q(SrcAE));
    RegRCEn #(32) PRegE5(.clk(clk), .reset(reset), .clear(1'b0), .en(1'b1), .d(SrcBD), .q(RegSrcBE));
    
    Mux2 #(32) SrcBMux(.d0(RegSrcBE), .d1(SignImmE), .s(ALUSrcE), .Y(SrcBE));
    
    RegRCEn #(32) PRegE6(.clk(clk), .reset(reset), .clear(1'b0), .en(1'b1), .d(SignImmD), .q(SignImmE));
    
    RegRCEn #(32) PRegE7(.clk(clk), .reset(reset), .clear(1'b0), .en(1'b1), .d(PCPlus4D), .q(PCPlus4E));
    
    RegRCEn #(5)  PRegE8(.clk(clk), .reset(reset), .clear(1'b0), .en(1'b1), .d(shamtD), .q(shamtE));
    
    RegRCEn #(3) PRegE9(.clk(clk), .reset(reset), .en(1'b1), .clear(1'b0), .d(selD), .q(selE));
    
    Mux2 #(5) DstMux(.d0(RTE), .d1(RDE), .s(RegDistE), .Y(WriteRegE));
    
    SL2 ADDRShifter(.A(SignImmE), .Y(ShiftedSignImmE));
    Adder BranchAddrAdder(.A(PCPlus4E), .B(ShiftedSignImmE), .Y(PCBranchE));
    
    ALU MainALU(.A(SrcAE), .B(SrcBE), 
                .ZeroFlag(ZeroFlagE), 
                .shamt(shamtE),
                .ALUControl(ALUControlE),
                .result(ALUOutE));
    
    /*******************************************************************/
    /*                          Memory Stage.                          */
    /*******************************************************************/
    
    RegRCEn #(32) PRegInstM(.clk(clk), .reset(reset), .clear(1'b0), .en(1'b1), .d(instrE), .q(instrM));

    RegRCEn #(32) PRegM1(.clk(clk), .reset(reset), .clear(1'b0), .en(1'b1), .d(ALUOutE), .q(ALUOutM));
    RegRCEn #(32) PRegM2(.clk(clk), .reset(reset), .clear(1'b0), .en(1'b1), .d(RegSrcBE), .q(WriteDataM));
    
    FlipFlop PRegM3(.clk(clk), .reset(reset), .en(1'b1), .d(ZeroFlagE), .q(ZeroFlagM));
    RegRCEn #(32) PRegM4(.clk(clk), .reset(reset), .clear(1'b0), .en(1'b1), .d(PCBranchE), .q(PCBranchM));
    RegRCEn #(32) PRegM5(.clk(clk), .reset(reset), .clear(1'b0), .en(1'b1), .d(PCPlus4E), .q(PCPlus4M));
    
    RegRCEn #(3) PRegM6(.clk(clk), .reset(reset), .en(1'b1), .clear(1'b0), .d(selE), .q(selM));
    RegRCEn #(5) PRegM7(.clk(clk), .reset(reset), .en(1'b1), .clear(1'b0), .d(WriteRegE), .q(WriteRegM));
    assign PCSrcM = ZeroFlagM & branchM;
    
    /*******************************************************************/
    /*                       Writeback Stage.                          */
    /*******************************************************************/
    RegRCEn #(32) PRegW1(.clk(clk), .reset(reset), .clear(1'b0), .en(1'b1), .d(ReadDataM), .q(ReadDataW));
    RegRCEn #(32) PRegW2(.clk(clk), .reset(reset), .clear(1'b0), .en(1'b1), .d(ALUOutM), .q(ALUOutW));
    RegRCEn #(3)  PRegW3(.clk(clk), .reset(reset), .clear(1'b0), .en(1'b1), .d(selM), .q(selW));
    RegRCEn #(5)  PRegW4(.clk(clk), .reset(reset), .en(1'b1), .clear(1'b0), .d(WriteRegM), .q(WriteRegW));
        
    Mux2 #(32) ResMux(.d0(ALUOutW), .d1(ReadDataW), .s(MemToRegW), .Y(ResultW));
    
endmodule
