--
-- Utilities for decoding instructions

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

package riscv_decodeutil is

subtype t_opcode is std_logic_vector(6 downto 0);
subtype t_funct3 is std_logic_vector(2 downto 0);

-- Opcodes
constant OP_IMM : t_opcode := "0010011";
constant OP_OP :  t_opcode := "0110011";
constant OP_JAL : t_opcode := "1101111";
constant OP_LOAD   : t_opcode := "0000011";
constant OP_STORE  : t_opcode := "0100011";
 
constant ADD :  t_funct3  :="000";
constant SLTI : t_funct3  :="010";
constant SLTIU : t_funct3 :="011";
constant F_XOR :  t_funct3  :="100";
constant F_OR  :  t_funct3  :="110";
constant F_AND  : t_funct3  :="111";
constant SL   : t_funct3  :="001";
constant SR   : t_funct3  :="101";

constant XLEN : natural := 32;

subtype xword is  std_logic_vector(XLEN-1 downto 0);
subtype xsigned is signed(XLEN-1 downto 0);


function get_I_immediate(signal instr: in xword) return xsigned;
function get_U_immediate(signal instr: in xword) return xsigned;
function get_J_immediate(signal instr: in xword) return xsigned;
function get_S_immediate(signal instr: in xword) return xsigned;

function get_UJ_immediate(signal instr: in xword) return xsigned;


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


function get_S_immediate(signal instr: in xword) return xsigned is
variable temp : xsigned;
variable t2 : signed(11 downto 0);
begin
  t2 := signed(instr(31 downto 25)&instr(11 downto 7));
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


 
end riscv_decodeutil;
