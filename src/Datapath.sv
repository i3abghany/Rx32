`timescale 1ns / 1ps

module Datapath(
    input logic clk, reset,
    RegWriteW,
    jumpM, branchM,
    input logic[1:0] ResultSrcW,
    input logic[2:0] ImmSrcD,
    input logic[1:0] ALUSrcAE,
    input logic ALUSrcBE,
    input logic[3:0] ALUControlE, 
    input logic[31:0] instrF,
    input logic[31:0] ReadDataM,
    output logic[6:0] opD,
    output logic[2:0] funct3D,
    output logic funct7b5D,
    output logic[31:0] PCF, 
    output logic[31:0] ALUOutM,
    output logic[31:0] WriteDataM,
    output logic[3:0] ByteEnableM
);
    logic[31:0] PCNextM;
    logic[31:0] instrD;
    logic[31:0] instrE;
    logic[31:0] instrM;
    logic[4:0] Rs1D, Rs2D, RdD;
    logic[2:0] funct3E, funct3M;
    logic[2:0] selF;
    logic[2:0] selD;
    logic[2:0] selE;
    logic[2:0] selM;
    logic[2:0] selW;
    logic[4:0] RdE;
    logic[4:0] RdM;
    logic[4:0] RdW;
    
    logic[31:0] ResultW;
    logic[31:0] RD1D, RD2D;
    logic[31:0] RD1E, RD2E;
    logic[31:0] SrcAE, SrcBE;

    logic[31:0] PCD;
    logic[31:0] PCE;
    
    logic[31:0] PCPlus4F;
    logic[31:0] PCPlus4D;
    logic[31:0] PCPlus4E;
    logic[31:0] PCPlus4M;
    logic[31:0] PCPlus4W;
    
    logic[31:0] ImmExtD;
    logic[31:0] ImmExtE;
    
    logic BranchTakenE;
    logic BranchTakenM;
     
    logic[31:0] ALUOutE;
    logic[31:0] ALUOutW;
    
    logic[31:0] StoreDataM;
    logic[31:0] LoadDataM;
    logic[31:0] ReadDataW;
    
    logic PCSrcM;
    
    // Instruction fields. 
    assign opD       = instrD[6:0];
    assign RdD       = instrD[11:7];
    assign funct3D   = instrD[14:12];
    assign Rs1D      = instrD[19:15];
    assign Rs2D      = instrD[24:20];
    assign funct7b5D = instrD[30];
    assign funct3E   = instrE[14:12];
    assign funct3M   = instrM[14:12];
    
    /*******************************************************************/
    /*                           Fetch Stage.                          */
    /*******************************************************************/
    
    // Thread selection.
    ThreadSelector TS(.reset(reset), .clk(clk), .sel(selF)); 
    
    // Jumps and taken branches go to the target computed by the ALU, with bit 0
    // cleared as JALR requires.
    Mux #(32, 2) PCMux(.data_in({PCPlus4M, {ALUOutM[31:1], 1'b0}}), .sel(PCSrcM), .Y(PCNextM));

    PCRepository PCRepo( .reset(reset), .clk(clk),
                         .en(PCPlus4M != 0), .clear(1'b0),
                         .sel_read(selF),
                         .sel_write(selM),
                         .d_g(PCNextM),
                         .q_g(PCF));

    Adder PCAdder(.A(PCF), .B(32'h00000004), .Y(PCPlus4F));
    
    /*******************************************************************/
    /*                          Decode Stage.                          */
    /*******************************************************************/
    
    RegRCEn #(32) PRegD1(.clk(clk), .reset(reset), .en(1'b1), .clear(1'b0), .d(instrF), .q(instrD));
    RegRCEn #(32) PRegD2(.clk(clk), .reset(reset), .en(1'b1), .clear(1'b0), .d(PCPlus4F), .q(PCPlus4D));
    RegRCEn #(32) PRegD3(.clk(clk), .reset(reset), .en(1'b1), .clear(1'b0), .d(PCF), .q(PCD));

    RegRCEn #(3) PRegD4(.clk(clk), .reset(reset), .en(1'b1), .clear(1'b0), .d(selF), .q(selD));
    
    ImmExtend Ext(.instr(instrD[31:7]), .ImmSrc(ImmSrcD), .ImmExt(ImmExtD));
    
    // Register files repository. Reading is done in the decode stage, writing is done in the 
    // Writeback stage.
    RegFileRepository RegfileRepo(.clk(clk), 
                                  .WE3_g(RegWriteW), 
                                  .sel_read(selD), 
                                  .sel_write(selW),
                                  .RA1_g(Rs1D),
                                  .RA2_g(Rs2D),
                                  .WA3_g(RdW),
                                  .WD3_g(ResultW),
                                  .RD1_g(RD1D), .RD2_g(RD2D));
    
    /*******************************************************************/
    /*                          Execute Stage.                         */
    /*******************************************************************/
    
    RegRCEn #(32) PRegInstE(.clk(clk), .reset(reset), .clear(1'b0), .en(1'b1), .d(instrD), .q(instrE));
    
    RegRCEn #(5) PRegE1(.clk(clk), .reset(reset), .clear(1'b0), .en(1'b1), .d(RdD), .q(RdE));
    
    RegRCEn #(32) PRegE2(.clk(clk), .reset(reset), .clear(1'b0), .en(1'b1), .d(RD1D), .q(RD1E));
    RegRCEn #(32) PRegE3(.clk(clk), .reset(reset), .clear(1'b0), .en(1'b1), .d(RD2D), .q(RD2E));
    
    RegRCEn #(32) PRegE4(.clk(clk), .reset(reset), .clear(1'b0), .en(1'b1), .d(ImmExtD), .q(ImmExtE));
    
    RegRCEn #(32) PRegE5(.clk(clk), .reset(reset), .clear(1'b0), .en(1'b1), .d(PCD), .q(PCE));
    RegRCEn #(32) PRegE6(.clk(clk), .reset(reset), .clear(1'b0), .en(1'b1), .d(PCPlus4D), .q(PCPlus4E));
    
    RegRCEn #(3) PRegE7(.clk(clk), .reset(reset), .en(1'b1), .clear(1'b0), .d(selD), .q(selE));
    
    Mux #(32, 3) SrcAMux(.data_in({RD1E, PCE, 32'b0}), .sel(ALUSrcAE), .Y(SrcAE));
    Mux #(32, 2) SrcBMux(.data_in({RD2E, ImmExtE}), .sel(ALUSrcBE), .Y(SrcBE));
    
    ALU MainALU(.A(SrcAE), .B(SrcBE), 
                .ALUControl(ALUControlE),
                .result(ALUOutE));

    BranchUnit BU(.A(RD1E), .B(RD2E), .funct3(funct3E), .taken(BranchTakenE));
    
    /*******************************************************************/
    /*                          Memory Stage.                          */
    /*******************************************************************/
    
    RegRCEn #(32) PRegInstM(.clk(clk), .reset(reset), .clear(1'b0), .en(1'b1), .d(instrE), .q(instrM));

    RegRCEn #(32) PRegM1(.clk(clk), .reset(reset), .clear(1'b0), .en(1'b1), .d(ALUOutE), .q(ALUOutM));
    RegRCEn #(32) PRegM2(.clk(clk), .reset(reset), .clear(1'b0), .en(1'b1), .d(RD2E), .q(StoreDataM));
    
    FlipFlop PRegM3(.clk(clk), .reset(reset), .en(1'b1), .d(BranchTakenE), .q(BranchTakenM));
    RegRCEn #(32) PRegM4(.clk(clk), .reset(reset), .clear(1'b0), .en(1'b1), .d(PCPlus4E), .q(PCPlus4M));
    
    RegRCEn #(3) PRegM5(.clk(clk), .reset(reset), .en(1'b1), .clear(1'b0), .d(selE), .q(selM));
    RegRCEn #(5) PRegM6(.clk(clk), .reset(reset), .en(1'b1), .clear(1'b0), .d(RdE), .q(RdM));
    assign PCSrcM = jumpM | (branchM & BranchTakenM);

    StoreAlign SA(.WD(StoreDataM), .offset(ALUOutM[1:0]), .funct3(funct3M), .Y(WriteDataM), .BE(ByteEnableM));
    LoadExtend LE(.RD(ReadDataM), .offset(ALUOutM[1:0]), .funct3(funct3M), .Y(LoadDataM));
    
    /*******************************************************************/
    /*                       Writeback Stage.                          */
    /*******************************************************************/
    RegRCEn #(32) PRegW1(.clk(clk), .reset(reset), .clear(1'b0), .en(1'b1), .d(LoadDataM), .q(ReadDataW));
    RegRCEn #(32) PRegW2(.clk(clk), .reset(reset), .clear(1'b0), .en(1'b1), .d(ALUOutM), .q(ALUOutW));
    RegRCEn #(3)  PRegW3(.clk(clk), .reset(reset), .clear(1'b0), .en(1'b1), .d(selM), .q(selW));
    RegRCEn #(5)  PRegW4(.clk(clk), .reset(reset), .en(1'b1), .clear(1'b0), .d(RdM), .q(RdW));
    RegRCEn #(32) PRegW5(.clk(clk), .reset(reset), .clear(1'b0), .en(1'b1), .d(PCPlus4M), .q(PCPlus4W));

    Mux #(32, 3) ResMux(.data_in({ALUOutW, ReadDataW, PCPlus4W}), .sel(ResultSrcW), .Y(ResultW));
    
endmodule
