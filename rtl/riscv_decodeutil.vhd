--
-- Utilities for decoding instructions

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

package riscv_decodeutil is

subtype t_opcode is std_logic_vector(6 downto 2);
subtype t_funct3 is std_logic_vector(2 downto 0);
subtype t_funct7 is std_logic_vector(6 downto 0);

-- Opcodes
constant OP_IMM : t_opcode := "00100";
constant OP_OP :  t_opcode := "01100";
constant OP_JAL    : t_opcode := "11011";
constant OP_JALR   : t_opcode := "11001";
constant OP_LOAD   : t_opcode := "00000";
constant OP_STORE  : t_opcode := "01000";
constant OP_BRANCH : t_opcode := "11000";
constant OP_LUI    : t_opcode := "01101";
constant OP_AUIPC  : t_opcode := "00101";
constant OP_SYSTEM : t_opcode := "11100";
constant OP_MISCMEM :t_opcode := "00011";

type t_riscv_op is (rv_imm,rv_op,rv_jal,rv_jalr,rv_load,rv_store,rv_branch,rv_lui,rv_auipc,rv_system,rv_miscmem,rv_invalid);
 
constant ADD :  t_funct3  :="000";
constant SLT :  t_funct3  :="010";
constant SLTU : t_funct3  :="011";
constant F_XOR :  t_funct3  :="100";
constant F_OR  :  t_funct3  :="110";
constant F_AND  : t_funct3  :="111";
constant SL   : t_funct3  :="001";
constant SR   : t_funct3  :="101";

constant MULEXT : t_funct7 := "0000001";

constant MUL  : t_funct3 := "000";
constant MULH : t_funct3 := "001";
constant DIV  : t_funct3 := "100";
constant DIVU : t_funct3 := "101";
constant F_REM  :  t_funct3  :="110";
constant REMU  : t_funct3  :="111";



constant XLEN : natural := 32;

subtype xword is  std_logic_vector(XLEN-1 downto 0);
subtype xsigned is signed(XLEN-1 downto 0);
subtype t_displacement is std_logic_vector(11 downto 0);


function get_I_immediate(signal instr: in xword) return xsigned;
function get_I_displacement(signal instr: in xword) return t_displacement;
function get_U_immediate(signal instr: in xword) return xsigned;
function get_J_immediate(signal instr: in xword) return xsigned;
function get_S_immediate(signal instr: in xword) return xsigned;
function get_S_displacement(signal instr: in xword) return t_displacement;
function get_SB_immediate(signal instr: in xword) return xsigned;

function get_UJ_immediate(signal instr: in xword) return xsigned;

function decode_op(signal opcode : in t_opcode) return t_riscv_op;

end riscv_decodeutil;

package body riscv_decodeutil is

function get_I_immediate(signal instr: in xword) return xsigned is
variable temp : xsigned;
variable t2 : signed(11 downto 0);
begin
  t2 := signed(instr(31 downto 20));
  temp := resize(t2,XLEN);
  return temp;             
end;

function get_I_displacement(signal instr: in xword) return t_displacement is
variable t: t_displacement;
begin
   t:=instr(31 downto 20);
   return t;
end;

function get_U_immediate(signal instr: in xword) return xsigned is
variable temp : xsigned; 
variable t2 : std_logic_vector(31 downto 0) := (others=>'0');
begin
  t2(31 downto 12) := instr(31 downto 12);
  temp := signed(t2);
  return temp;             

end;

function get_J_immediate(signal instr: in xword) return xsigned is
variable temp : xsigned;
variable t2 : std_logic_vector(31 downto 0);
begin
  t2 := instr(31 downto 1) & '0';
  temp := signed(t2);
  return temp;             

end;

function get_S_displacement(signal instr: in xword) return t_displacement is
begin
  return instr(31 downto 25)&instr(11 downto 7);
end;


function get_S_immediate(signal instr: in xword) return xsigned is
variable temp : xsigned;
variable t2 : signed(11 downto 0);
begin
  t2 := signed(get_S_displacement(instr));
  temp := resize(t2,XLEN);
  return temp;             
end;


function get_SB_immediate(signal instr: in xword) return xsigned is
variable temp : xsigned;
variable t2 : signed(12 downto 0);
begin
  t2 := signed(instr(31) & instr(7) & instr(30 downto 25)&instr(11 downto 8) & '0');
  temp := resize(t2,XLEN);
  return temp;             
end;

function get_UJ_immediate(signal instr: in xword) return xsigned is
variable temp : xsigned;
variable t2 : signed(20 downto 0);
begin
  t2 := signed(instr(31) & instr(19 downto 12) & instr(20) & instr(30 downto 21) & '0'); 
  temp := resize(t2,XLEN);
  return temp;             

end;

function decode_op(signal opcode : in t_opcode) return t_riscv_op is
begin
  case opcode is 
    when OP_IMM => return rv_imm;
    when OP_OP => return rv_op;
    when OP_JAL => return rv_jal;
    when OP_JALR => return rv_jalr;
    when OP_LOAD => return rv_load;
    when OP_STORE => return rv_store;
    when OP_BRANCH => return rv_branch;
    when OP_LUI => return rv_lui;
    when OP_AUIPC => return rv_auipc;
    when OP_SYSTEM => return rv_system;
    when OP_MISCMEM => return rv_miscmem;
    when others => return rv_invalid;
       
  end case;

end;

 
end riscv_decodeutil;
