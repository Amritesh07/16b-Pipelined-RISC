library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.components.all;
library std;
use std.textio.all;

----------------------------- HARSHVARDHAN ---------------------------------
-----** --------------------DATA FORWARDING LOGIC----------------
--  if stall, then put 1111 in stalled instruction opcode
-- this is also preserve priority rules
-- regFiledata(7) is connected to PC and not reg file
---------------------------------------------------
entity FwdCntrl is
port (
padder:       in matrix16(2 downto 0);       -- 0 - execute  1 - mem -- 2- for writeback for all
PC_1:         in matrix16(2 downto 0);
aluop:        in matrix16(2 downto 0);    -- alu output
regDest:      in matrix3(2 downto 0) ;
Iword:        in matrix16(2 downto 0);
Lm_mem:       in matrix16(7 downto 0);  -- mem stage
Lm_wb:        in matrix16(7 downto 0);   -- writeback stage ()
mem_out:      in matrix16(1 downto 0);   -- 0 - mem , 1- writeback (single output)
Lm_sel:       in matrix8(2 downto 0);    --0 - execute , 1- mem, 2- writeback (single output)
regFiledata:  in matrix16(7 downto 0);  -- regFiledata[7] has to be connected to PC brought by the pipeline register
carry :       in std_logic_vector(2 downto 0);   -- 0 - execute  1 - mem -- 2- for writeback
zero:         in std_logic_vector(3 downto 0); -- 0- LW_zero_signal, 1- alu_zero_sig, 2-zero_flag, 3- writeback
regDataout:   out matrix16(7 downto 0);
stallflag:    out std_logic
         ) ;
end FwdCntrl ;
-----
architecture comb of FwdCntrl is

----------
---Declarations
signal RegAll : matrix16(7 downto 0);
signal stall: std_logic_vector(7 downto 0):=(others=>'0');

----------------------
begin
  --- ------------------------------process for R0-----------------------------------
process (Iword,padder,PC_1,aluop,regDest,Lm_mem,Lm_sel,Lm_wb,mem_out,regFiledata,carry,zero)
          variable Reg0: std_logic_vector(15 downto 0):= (others=>'0');
          variable var_stall: std_logic:='0';
          begin

            ---------------- ----------------------------------------
            ------------ forwrding for R0 from execute stage----------
            var_stall:='0';
            if (Iword(0)(15 downto 12) = "0110" or Iword(0)(15 downto 12) = "0100" ) then   -- if LM of execute or LW of execute
                Reg0:=regFiledata(0);
                if (Lm_sel(0)(0)='1' or regDest(0)="000") then
                  var_stall:='1';
                end if;

            elsif (Iword(0)(15 downto 12) /= "1111") then

                    if(regDest(0)="000") then
                          if ( Iword(0)(15)='0' and Iword(0)(14)='0' and Iword(0)(12)='0') then ----- R type instruction
                                if (Iword(0)(1 downto 0) = "00" ) then
                                      Reg0:=aluop(0);
                                else
                                      if ( Iword(0)(1)='1' and carry(0)='1' ) then
                                        Reg0 := aluop(0);
                                      elsif (Iword(0)(0)='1' and
                                      ( (zero(0)='1' and Iword(1)(15 downto 12)="0100") or
                                        (zero(1)='1' and Iword(1)(15 downto 14)="00" and Iword(1)(13 downto 12)/="11" ) or
                                        (zero(2)='1' and not(Iword(1)(15 downto 12)="0100") and not(Iword(1)(15 downto 14)="00" and Iword(1)(13 downto 12)/="11"))))then
                                        Reg0 := aluop(0);
                                      else
                                          Reg0 := regFiledata(0);
                                      end if;
                               end if;

                          elsif (Iword(0)(15 downto 12) = "0001" ) then     ---------- ADI instruction
                                  Reg0 := aluop(0);
                          elsif ( Iword(0)(15)='1' and Iword(0)(14)='0' and Iword(0)(13)='0')  then ----  JAL and JLR
                              Reg0 := PC_1(0);
                          elsif (Iword(0)(15 downto 12) = "0011" ) then               ---- LHI instruction
                              Reg0 := padder(0);
                          end if;

                    else
                          Reg0 := regFiledata(0);
                    end if;

          ---------------- -------------------------------------------------------
          ------------ forwrding for R0 from memory stage------------------------

            elsif (Iword(1)(15 downto 12) = "0110") then   -- if LM of mem

                    if ( Lm_sel(1)(0)='1') then
                      Reg0 := Lm_mem(0);
                    else
                      Reg0 := regFiledata(0);
                    end if;

            elsif (Iword(1)(15 downto 12) /= "1111") then

                    if(regDest(1)="000") then
                      if ( Iword(1)(15)='0' and Iword(1)(14)='0' and Iword(1)(12)='0') then ----- R type instruction
                            if (Iword(1)(1 downto 0) = "00" ) then
                                  Reg0:=aluop(1);
                            else
                                  if ( Iword(1)(1)='1' and carry(1)='1' ) then
                                    Reg0 := aluop(1);
                                  elsif (Iword(1)(0)='1' and zero(2)='1' ) then
                                    Reg0 := aluop(1);
                                  else
                                      Reg0 := regFiledata(0);
                                  end if;
                           end if;

                      elsif (Iword(1)(15 downto 12) = "0001" ) then     ---------- ADI instruction
                              Reg0 := aluop(1);
                      elsif ( Iword(1)(15)='1' and Iword(1)(14)='0' and Iword(1)(13)='0')  then ----  JAL and JLR
                          Reg0 := PC_1(1);
                      elsif (Iword(1)(15 downto 12) = "0011" ) then               ---- LHI instruction
                          Reg0 := padder(1);
                      elsif (Iword(1)(15 downto 12) = "0100" ) then               ---- LW instruction
                          Reg0 := mem_out(0);
                      end if;

                else
                      Reg0 := regFiledata(0);
                    end if;
        ---------------- --------------------------------------------------
        ------------ forwrding for R0 from writeback stage---------------
            elsif (Iword(2)(15 downto 12) = "0110") then   -- if LM    of writeback

                    if ( Lm_sel(2)(0)='1') then
                      Reg0 := Lm_wb(0);       ---------- select R0 register
                    else
                      Reg0 := regFiledata(0);
                    end if;

            elsif (Iword(2)(15 downto 12) /= "1111") then

                    if(regDest(2)="000") then
                          if ( Iword(2)(15)='0' and Iword(2)(14)='0' and Iword(2)(12)='0') then ----- R type instruction
                                if (Iword(2)(1 downto 0) = "00" ) then
                                      Reg0:=aluop(2);
                                else
                                      if ( Iword(2)(1)='1' and carry(2)='1' ) then
                                        Reg0 := aluop(2);
                                      elsif (Iword(2)(0)='1' and zero(3)='1' ) then
                                        Reg0 := aluop(2);
                                      else
                                          Reg0 := regFiledata(0);
                                      end if;
                               end if;

                          elsif (Iword(2)(15 downto 12) = "0001" ) then     ---------- ADI instruction
                                  Reg0 := aluop(2);
                          elsif ( Iword(2)(15)='1' and Iword(2)(14)='0' and Iword(2)(13)='0')  then ----  JAL and JLR
                              Reg0 := PC_1(2);
                          elsif (Iword(2)(15 downto 12) = "0011" ) then               ---- LHI instruction
                              Reg0 := padder(2);
                          elsif (Iword(2)(15 downto 12) = "0100" ) then               ---- LW instruction
                              Reg0 := mem_out(1);
                          end if;

                    else
                          Reg0 := regFiledata(0);
                    end if;

            end if;
            stall(0)<=var_stall;
            RegAll(0)<=Reg0;
end process;
  ------------------------------------------------------------------------------------
  ------------------------------------- R1 PROCESS -----------------------------------------
  ------------------------------------------------------------------------------------
process (Iword,padder,PC_1,aluop,regDest,Lm_mem,Lm_sel,Lm_wb,mem_out,regFiledata,carry,zero)
  variable Reg1:std_logic_vector(15 downto 0):= (others=>'0');
  variable var_stall: std_logic:='0';
  begin

    ---------------- ----------------------------------------
    ------------ forwrding for R0 from execute stage----------
    var_stall:='0';
    if (Iword(0)(15 downto 12) = "0110" or Iword(0)(15 downto 12) = "0100" ) then   -- if LM of execute or LW of execute
        Reg1:=regFiledata(1);
        if (Lm_sel(0)(1)='1' or regDest(0)="001") then
          var_stall:='1';
        end if;

    elsif (Iword(0)(15 downto 12) /= "1111") then

            if(regDest(0)="001") then
                  if ( Iword(0)(15)='0' and Iword(0)(14)='0' and Iword(0)(12)='0') then ----- R type instruction
                        if (Iword(0)(1 downto 0) = "00" ) then
                                Reg1:=aluop(0);
                        else
                              if ( Iword(0)(1)='1' and carry(0)='1' ) then
                                Reg1 := aluop(0);
                              elsif (Iword(0)(0)='1' and
                              ( (zero(0)='1' and Iword(1)(15 downto 12)="0100") or
                                (zero(1)='1' and Iword(1)(15 downto 14)="00" and Iword(1)(13 downto 12)/="11" ) or
                                (zero(2)='1' and not(Iword(1)(15 downto 12)="0100") and not(Iword(1)(15 downto 14)="00" and Iword(1)(13 downto 12)/="11")))) then
                                Reg1 := aluop(0);
                              else
                                Reg1 := regFiledata(1);
                              end if;
                       end if;

                  elsif (Iword(0)(15 downto 12) = "0001" ) then     ---------- ADI instruction
                          Reg1 := aluop(0);
                  elsif ( Iword(0)(15)='1' and Iword(0)(14)='0' and Iword(0)(13)='0')  then ----  JAL and JLR
                          Reg1 := PC_1(0);
                  elsif (Iword(0)(15 downto 12) = "0011" ) then               ---- LHI instruction
                          Reg1 := padder(0);
                  end if;

            else
                  Reg1 := regFiledata(1);
            end if;

            ---------------- -------------------------------------------------------
            ------------ forwrding for R0 from memory stage------------------------

    elsif (Iword(1)(15 downto 12) = "0110") then   -- if LM of mem

            if ( Lm_sel(1)(1)='1') then
              Reg1 := Lm_mem(1);
            else
              Reg1 := regFiledata(1);
            end if;

    elsif (Iword(1)(15 downto 12) /= "1111") then

            if(regDest(1)="001") then
              if ( Iword(1)(15)='0' and Iword(1)(14)='0' and Iword(1)(12)='0') then ----- R type instruction
                    if (Iword(1)(1 downto 0) = "00" ) then
                              Reg1:=aluop(1);
                    else
                          if ( Iword(1)(1)='1' and carry(1)='1' ) then
                              Reg1 := aluop(1);
                          elsif (Iword(1)(0)='1' and zero(2)='1' ) then
                              Reg1 := aluop(1);
                          else
                              Reg1 := regFiledata(1);
                          end if;
                   end if;

              elsif (Iword(1)(15 downto 12) = "0001" ) then     ---------- ADI instruction
                      Reg1 := aluop(1);
              elsif ( Iword(1)(15)='1' and Iword(1)(14)='0' and Iword(1)(13)='0')  then ----  JAL and JLR
                      Reg1 := PC_1(1);
              elsif (Iword(1)(15 downto 12) = "0011" ) then               ---- LHI instruction
                      Reg1 := padder(1);
              elsif (Iword(1)(15 downto 12) = "0100" ) then               ---- LW instruction
                      Reg1 := mem_out(0);
              end if;

        else
              Reg1 := regFiledata(1);
            end if;
            ---------------- --------------------------------------------------
            ------------ forwrding for R0 from writeback stage---------------
    elsif (Iword(2)(15 downto 12) = "0110") then   -- if LM    of writeback

            if ( Lm_sel(2)(1)='1') then
              Reg1 := Lm_wb(1);       ---------- select R0 register
            else
              Reg1 := regFiledata(1);
            end if;

    elsif (Iword(2)(15 downto 12) /= "1111") then

            if(regDest(2)="001") then
                  if ( Iword(2)(15)='0' and Iword(2)(14)='0' and Iword(2)(12)='0') then ----- R type instruction
                        if (Iword(2)(1 downto 0) = "00" ) then
                                  Reg1:=aluop(2);
                        else
                              if ( Iword(2)(1)='1' and carry(2)='1' ) then
                                  Reg1 := aluop(2);
                              elsif (Iword(2)(0)='1' and zero(2)='1' ) then
                                  Reg1 := aluop(2);
                              else
                                  Reg1 := regFiledata(1);
                              end if;
                       end if;

                  elsif (Iword(2)(15 downto 12) = "0001" ) then     ---------- ADI instruction
                      Reg1 := aluop(2);
                  elsif ( Iword(2)(15)='1' and Iword(2)(14)='0' and Iword(2)(13)='0')  then ----  JAL and JLR
                      Reg1 := PC_1(2);
                  elsif (Iword(2)(15 downto 12) = "0011" ) then               ---- LHI instruction
                      Reg1 := padder(2);
                  elsif (Iword(2)(15 downto 12) = "0100" ) then               ---- LW instruction
                      Reg1 := mem_out(1);
                  end if;

            else
                  Reg1 := regFiledata(1);
            end if;

    end if;
    stall(1)<=var_stall;
    RegAll(1) <= Reg1;
end process;
------------------------------------------------------------------------------------
------------------------------------- R2 PROCESS -----------------------------------------
------------------------------------------------------------------------------------
process (Iword,padder,PC_1,aluop,regDest,Lm_mem,Lm_sel,Lm_wb,mem_out,regFiledata,carry,zero)
  variable Reg2:std_logic_vector(15 downto 0):= (others=>'0');
  variable var_stall: std_logic:='0';
  begin

    ---------------- ----------------------------------------
    ------------ forwrding for R0 from execute stage----------
    var_stall:='0';
    if (Iword(0)(15 downto 12) = "0110" or Iword(0)(15 downto 12) = "0100" ) then   -- if LM of execute or LW of execute
        Reg2:=regFiledata(2);
        if (Lm_sel(0)(2)='1' or regDest(0)="010") then
          var_stall:='1';
        end if;
    elsif (Iword(0)(15 downto 12) /= "1111") then

            if(regDest(0)="010") then
                  if ( Iword(0)(15)='0' and Iword(0)(14)='0' and Iword(0)(12)='0') then ----- R type instruction
                        if (Iword(0)(1 downto 0) = "00" ) then
                                Reg2:=aluop(0);
                        else
                              if ( Iword(0)(1)='1' and carry(0)='1' ) then
                                Reg2 := aluop(0);
                              elsif (Iword(0)(0)='1' and
                              ( (zero(0)='1' and Iword(1)(15 downto 12)="0100") or
                                (zero(1)='1' and Iword(1)(15 downto 14)="00" and Iword(1)(13 downto 12)/="11" ) or
                                (zero(2)='1' and not(Iword(1)(15 downto 12)="0100") and not(Iword(1)(15 downto 14)="00" and Iword(1)(13 downto 12)/="11")))) then
                                Reg2 := aluop(0);
                              else
                                Reg2 := regFiledata(2);
                              end if;
                       end if;

                  elsif (Iword(0)(15 downto 12) = "0001" ) then     ---------- ADI instruction
                          Reg2 := aluop(0);
                  elsif ( Iword(0)(15)='1' and Iword(0)(14)='0' and Iword(0)(13)='0')  then ----  JAL and JLR
                          Reg2 := PC_1(0);
                  elsif (Iword(0)(15 downto 12) = "0011" ) then               ---- LHI instruction
                          Reg2 := padder(0);
                  end if;

            else
                  Reg2 := regFiledata(2);
            end if;

            ---------------- -------------------------------------------------------
            ------------ forwrding for R0 from memory stage------------------------

    elsif (Iword(1)(15 downto 12) = "0110") then   -- if LM of mem

            if ( Lm_sel(1)(2)='1') then
              Reg2 := Lm_mem(2);
            else
              Reg2 := regFiledata(2);
            end if;

    elsif (Iword(1)(15 downto 12) /= "1111") then

            if(regDest(1)="010") then
              if ( Iword(1)(15)='0' and Iword(1)(14)='0' and Iword(1)(12)='0') then ----- R type instruction
                    if (Iword(1)(1 downto 0) = "00" ) then
                              Reg2:=aluop(1);
                    else
                          if ( Iword(1)(1)='1' and carry(1)='1' ) then
                              Reg2 := aluop(1);
                          elsif (Iword(1)(0)='1' and zero(2)='1' ) then
                              Reg2 := aluop(1);
                          else
                              Reg2 := regFiledata(2);
                          end if;
                   end if;

              elsif (Iword(1)(15 downto 12) = "0001" ) then     ---------- ADI instruction
                      Reg2 := aluop(1);
              elsif ( Iword(1)(15)='1' and Iword(1)(14)='0' and Iword(1)(13)='0')  then ----  JAL and JLR
                      Reg2 := PC_1(1);
              elsif (Iword(1)(15 downto 12) = "0011" ) then               ---- LHI instruction
                      Reg2 := padder(1);
              elsif (Iword(1)(15 downto 12) = "0100" ) then               ---- LW instruction
                      Reg2 := mem_out(0);
              end if;

        else
              Reg2 := regFiledata(2);
            end if;
            ---------------- --------------------------------------------------
            ------------ forwrding for R0 from writeback stage---------------
    elsif (Iword(2)(15 downto 12) = "0110") then   -- if LM    of writeback

            if ( Lm_sel(2)(2)='1') then
              Reg2 := Lm_wb(2);       ---------- select R0 register
            else
              Reg2 := regFiledata(2);
            end if;

    elsif (Iword(2)(15 downto 12) /= "1111") then

            if(regDest(2)="010") then
                  if ( Iword(2)(15)='0' and Iword(2)(14)='0' and Iword(2)(12)='0') then ----- R type instruction
                        if (Iword(2)(1 downto 0) = "00" ) then
                                  Reg2:=aluop(2);
                        else
                              if ( Iword(2)(1)='1' and carry(2)='1' ) then
                                  Reg2 := aluop(2);
                              elsif (Iword(2)(0)='1' and zero(3)='1' ) then
                                  Reg2 := aluop(2);
                              else
                                  Reg2 := regFiledata(2);
                              end if;
                       end if;

                  elsif (Iword(2)(15 downto 12) = "0001" ) then     ---------- ADI instruction
                      Reg2 := aluop(2);
                  elsif ( Iword(2)(15)='1' and Iword(2)(14)='0' and Iword(2)(13)='0')  then ----  JAL and JLR
                      Reg2 := PC_1(2);
                  elsif (Iword(2)(15 downto 12) = "0011" ) then               ---- LHI instruction
                      Reg2 := padder(2);
                  elsif (Iword(2)(15 downto 12) = "0100" ) then               ---- LW instruction
                      Reg2 := mem_out(1);
                  end if;

            else
                  Reg2 := regFiledata(2);
            end if;

    end if;
    stall(2)<=var_stall;
    RegAll(2) <= Reg2;
end process;
------------------------------------------------------------------------------------
------------------------------------- R3 PROCESS -----------------------------------------
------------------------------------------------------------------------------------
process (Iword,padder,PC_1,aluop,regDest,Lm_mem,Lm_sel,Lm_wb,mem_out,regFiledata,carry,zero)
  variable Reg3:std_logic_vector(15 downto 0):= (others=>'0');
  variable var_stall: std_logic:='0';
  begin

    ---------------- ----------------------------------------
    ------------ forwrding for R0 from execute stage----------
    var_stall:='0';
    if (Iword(0)(15 downto 12) = "0110" or Iword(0)(15 downto 12) = "0100" ) then   -- if LM of execute or LW of execute
        Reg3:=regFiledata(3);
        if (Lm_sel(0)(3)='1' or regDest(0)="011") then
          var_stall:='1';
        end if;

    elsif (Iword(0)(15 downto 12) /= "1111") then

            if(regDest(0)="011") then
                  if ( Iword(0)(15)='0' and Iword(0)(14)='0' and Iword(0)(12)='0') then ----- R type instruction
                        if (Iword(0)(1 downto 0) = "00" ) then
                                Reg3:=aluop(0);
                        else
                              if ( Iword(0)(1)='1' and carry(0)='1' ) then
                                Reg3 := aluop(0);
                              elsif (Iword(0)(0)='1' and
                              ( (zero(0)='1' and Iword(1)(15 downto 12)="0100") or
                                (zero(1)='1' and Iword(1)(15 downto 14)="00" and Iword(1)(13 downto 12)/="11" ) or
                                (zero(2)='1' and not(Iword(1)(15 downto 12)="0100") and not(Iword(1)(15 downto 14)="00" and Iword(1)(13 downto 12)/="11")))) then
                                Reg3 := aluop(0);
                              else
                                Reg3 := regFiledata(3);
                              end if;
                       end if;

                  elsif (Iword(0)(15 downto 12) = "0001" ) then     ---------- ADI instruction
                          Reg3 := aluop(0);
                  elsif ( Iword(0)(15)='1' and Iword(0)(14)='0' and Iword(0)(13)='0')  then ----  JAL and JLR
                          Reg3 := PC_1(0);
                  elsif (Iword(0)(15 downto 12) = "0011" ) then               ---- LHI instruction
                          Reg3 := padder(0);
                  end if;

            else
                  Reg3 := regFiledata(3);
            end if;

            ---------------- -------------------------------------------------------
            ------------ forwrding for R0 from memory stage------------------------

    elsif (Iword(1)(15 downto 12) = "0110") then   -- if LM of mem

            if ( Lm_sel(1)(3)='1') then
              Reg3 := Lm_mem(3);
            else
              Reg3 := regFiledata(3);
            end if;

    elsif (Iword(1)(15 downto 12) /= "1111") then

            if(regDest(1)="011") then
              if ( Iword(1)(15)='0' and Iword(1)(14)='0' and Iword(1)(12)='0') then ----- R type instruction
                    if (Iword(1)(1 downto 0) = "00" ) then
                              Reg3:=aluop(1);
                    else
                          if ( Iword(1)(1)='1' and carry(1)='1' ) then
                              Reg3 := aluop(1);
                          elsif (Iword(1)(0)='1' and zero(2)='1' ) then
                              Reg3 := aluop(1);
                          else
                              Reg3 := regFiledata(3);
                          end if;
                   end if;

              elsif (Iword(1)(15 downto 12) = "0001" ) then     ---------- ADI instruction
                      Reg3 := aluop(1);
              elsif ( Iword(1)(15)='1' and Iword(1)(14)='0' and Iword(1)(13)='0')  then ----  JAL and JLR
                      Reg3 := PC_1(1);
              elsif (Iword(1)(15 downto 12) = "0011" ) then               ---- LHI instruction
                      Reg3 := padder(1);
              elsif (Iword(1)(15 downto 12) = "0100" ) then               ---- LW instruction
                      Reg3 := mem_out(0);
              end if;

        else
              Reg3 := regFiledata(3);
            end if;
            ---------------- --------------------------------------------------
            ------------ forwrding for R0 from writeback stage---------------
    elsif (Iword(2)(15 downto 12) = "0110") then   -- if LM    of writeback

            if ( Lm_sel(2)(3)='1') then
              Reg3 := Lm_wb(3);       ---------- select R0 register
            else
              Reg3 := regFiledata(3);
            end if;

    elsif (Iword(2)(15 downto 12) /= "1111") then

            if(regDest(2)="011") then
                  if ( Iword(2)(15)='0' and Iword(2)(14)='0' and Iword(2)(12)='0') then ----- R type instruction
                        if (Iword(2)(1 downto 0) = "00" ) then
                                  Reg3:=aluop(2);
                        else
                              if ( Iword(2)(1)='1' and carry(2)='1' ) then
                                  Reg3 := aluop(2);
                              elsif (Iword(2)(0)='1' and zero(3)='1' ) then
                                  Reg3 := aluop(2);
                              else
                                  Reg3 := regFiledata(3);
                              end if;
                       end if;

                  elsif (Iword(2)(15 downto 12) = "0001" ) then     ---------- ADI instruction
                      Reg3 := aluop(2);
                  elsif ( Iword(2)(15)='1' and Iword(2)(14)='0' and Iword(2)(13)='0')  then ----  JAL and JLR
                      Reg3 := PC_1(2);
                  elsif (Iword(2)(15 downto 12) = "0011" ) then               ---- LHI instruction
                      Reg3 := padder(2);
                  elsif (Iword(2)(15 downto 12) = "0100" ) then               ---- LW instruction
                      Reg3 := mem_out(1);
                  end if;

            else
                  Reg3 := regFiledata(3);
            end if;

    end if;
    stall(3)<=var_stall;
    RegAll(3) <= Reg3;
end process;
------------------------------------------------------------------------------------
------------------------------------- R4 PROCESS -----------------------------------------
------------------------------------------------------------------------------------
process (Iword,padder,PC_1,aluop,regDest,Lm_mem,Lm_sel,Lm_wb,mem_out,regFiledata,carry,zero)
  variable Reg4:std_logic_vector(15 downto 0):= (others=>'0');
  variable var_stall: std_logic:='0';
  begin

    ---------------- ----------------------------------------
    ------------ forwrding for R0 from execute stage----------
    var_stall:='0';
    if (Iword(0)(15 downto 12) = "0110" or Iword(0)(15 downto 12) = "0100" ) then   -- if LM of execute or LW of execute
        Reg4:=regFiledata(4);
        if (Lm_sel(0)(4)='1' or regDest(0)="100") then
          var_stall:='1';
        end if;


    elsif (Iword(0)(15 downto 12) /= "1111") then

            if(regDest(0)="100") then
                  if ( Iword(0)(15)='0' and Iword(0)(14)='0' and Iword(0)(12)='0') then ----- R type instruction
                        if (Iword(0)(1 downto 0) = "00" ) then
                                Reg4:=aluop(0);
                        else
                              if ( Iword(0)(1)='1' and carry(0)='1' ) then
                                Reg4 := aluop(0);
                              elsif (Iword(0)(0)='1' and
                              ( (zero(0)='1' and Iword(1)(15 downto 12)="0100") or
                                (zero(1)='1' and Iword(1)(15 downto 14)="00" and Iword(1)(13 downto 12)/="11" ) or
                                (zero(2)='1' and not(Iword(1)(15 downto 12)="0100") and not(Iword(1)(15 downto 14)="00" and Iword(1)(13 downto 12)/="11"))) ) then
                                Reg4 := aluop(0);
                              else
                                Reg4 := regFiledata(4);
                              end if;
                       end if;

                  elsif (Iword(0)(15 downto 12) = "0001" ) then     ---------- ADI instruction
                          Reg4 := aluop(0);
                  elsif ( Iword(0)(15)='1' and Iword(0)(14)='0' and Iword(0)(13)='0')  then ----  JAL and JLR
                          Reg4 := PC_1(0);
                  elsif (Iword(0)(15 downto 12) = "0011" ) then               ---- LHI instruction
                          Reg4 := padder(0);
                  end if;

            else
                  Reg4 := regFiledata(4);
            end if;

            ---------------- -------------------------------------------------------
            ------------ forwrding for R0 from memory stage------------------------

    elsif (Iword(1)(15 downto 12) = "0110") then   -- if LM of mem

            if ( Lm_sel(1)(4)='1') then
              Reg4 := Lm_mem(4);
            else
              Reg4 := regFiledata(4);
            end if;

    elsif (Iword(1)(15 downto 12) /= "1111") then

            if(regDest(1)="100") then
              if ( Iword(1)(15)='0' and Iword(1)(14)='0' and Iword(1)(12)='0') then ----- R type instruction
                    if (Iword(1)(1 downto 0) = "00" ) then
                              Reg4:=aluop(1);
                    else
                          if ( Iword(1)(1)='1' and carry(1)='1' ) then
                              Reg4 := aluop(1);
                          elsif (Iword(1)(0)='1' and zero(2)='1' ) then
                              Reg4 := aluop(1);
                          else
                              Reg4 := regFiledata(4);
                          end if;
                   end if;

              elsif (Iword(1)(15 downto 12) = "0001" ) then     ---------- ADI instruction
                      Reg4 := aluop(1);
              elsif ( Iword(1)(15)='1' and Iword(1)(14)='0' and Iword(1)(13)='0')  then ----  JAL and JLR
                      Reg4 := PC_1(1);
              elsif (Iword(1)(15 downto 12) = "0011" ) then               ---- LHI instruction
                      Reg4 := padder(1);
              elsif (Iword(1)(15 downto 12) = "0100" ) then               ---- LW instruction
                      Reg4 := mem_out(0);
              end if;

        else
              Reg4 := regFiledata(4);
            end if;
            ---------------- --------------------------------------------------
            ------------ forwrding for R0 from writeback stage---------------
    elsif (Iword(2)(15 downto 12) = "0110") then   -- if LM    of writeback

            if ( Lm_sel(2)(4)='1') then
              Reg4 := Lm_wb(4);       ---------- select R0 register
            else
              Reg4 := regFiledata(4);
            end if;

    elsif (Iword(2)(15 downto 12) /= "1111") then

            if(regDest(2)="100") then
                  if ( Iword(2)(15)='0' and Iword(2)(14)='0' and Iword(2)(12)='0') then ----- R type instruction
                        if (Iword(2)(1 downto 0) = "00" ) then
                                  Reg4:=aluop(2);
                        else
                              if ( Iword(2)(1)='1' and carry(2)='1' ) then
                                  Reg4 := aluop(2);
                              elsif (Iword(2)(0)='1' and zero(3)='1' ) then
                                  Reg4 := aluop(2);
                              else
                                  Reg4 := regFiledata(4);
                              end if;
                       end if;

                  elsif (Iword(2)(15 downto 12) = "0001" ) then     ---------- ADI instruction
                      Reg4 := aluop(2);
                  elsif ( Iword(2)(15)='1' and Iword(2)(14)='0' and Iword(2)(13)='0')  then ----  JAL and JLR
                      Reg4 := PC_1(2);
                  elsif (Iword(2)(15 downto 12) = "0011" ) then               ---- LHI instruction
                      Reg4 := padder(2);
                  elsif (Iword(2)(15 downto 12) = "0100" ) then               ---- LW instruction
                      Reg4 := mem_out(1);
                  end if;

            else
                  Reg4 := regFiledata(4);
            end if;

    end if;
    stall(4)<=var_stall;
    RegAll(4) <= Reg4;
end process;
------------------------------------------------------------------------------------
------------------------------------- R5 PROCESS -----------------------------------------
------------------------------------------------------------------------------------
process (Iword,padder,PC_1,aluop,regDest,Lm_mem,Lm_sel,Lm_wb,mem_out,regFiledata,carry,zero)
  variable Reg5:std_logic_vector(15 downto 0):= (others=>'0');
  variable var_stall: std_logic:='0';
  begin

    ---------------- ----------------------------------------
    ------------ forwrding for R0 from execute stage----------
    var_stall:='0';
    if (Iword(0)(15 downto 12) = "0110" or Iword(0)(15 downto 12) = "0100" ) then   -- if LM of execute or LW of execute
        Reg5:=regFiledata(5);
        if (Lm_sel(0)(5)='1' or regDest(0)="101") then
          var_stall:='1';
        end if;


    elsif (Iword(0)(15 downto 12) /= "1111") then

            if(regDest(0)="101") then
                  if ( Iword(0)(15)='0' and Iword(0)(14)='0' and Iword(0)(12)='0') then ----- R type instruction
                        if (Iword(0)(1 downto 0) = "00" ) then
                                Reg5:=aluop(0);
                        else
                              if ( Iword(0)(1)='1' and carry(0)='1' ) then
                                Reg5 := aluop(0);
                              elsif (Iword(0)(0)='1' and
                              ( (zero(0)='1' and Iword(1)(15 downto 12)="0100") or
                                (zero(1)='1' and Iword(1)(15 downto 14)="00" and Iword(1)(13 downto 12)/="11" ) or
                                (zero(2)='1' and not(Iword(1)(15 downto 12)="0100") and not(Iword(1)(15 downto 14)="00" and Iword(1)(13 downto 12)/="11")))) then
                                Reg5 := aluop(0);
                              else
                                Reg5 := regFiledata(5);
                              end if;
                       end if;

                  elsif (Iword(0)(15 downto 12) = "0001" ) then     ---------- ADI instruction
                          Reg5 := aluop(0);
                  elsif ( Iword(0)(15)='1' and Iword(0)(14)='0' and Iword(0)(13)='0')  then ----  JAL and JLR
                          Reg5 := PC_1(0);
                  elsif (Iword(0)(15 downto 12) = "0011" ) then               ---- LHI instruction
                          Reg5 := padder(0);
                  end if;

            else
                  Reg5 := regFiledata(5);
            end if;

            ---------------- -------------------------------------------------------
            ------------ forwrding for R0 from memory stage------------------------

    elsif (Iword(1)(15 downto 12) = "0110") then   -- if LM of mem

            if ( Lm_sel(1)(5)='1') then
              Reg5 := Lm_mem(5);
            else
              Reg5 := regFiledata(5);
            end if;

    elsif (Iword(1)(15 downto 12) /= "1111") then

            if(regDest(1)="101") then
              if ( Iword(1)(15)='0' and Iword(1)(14)='0' and Iword(1)(12)='0') then ----- R type instruction
                    if (Iword(1)(1 downto 0) = "00" ) then
                              Reg5:=aluop(1);
                    else
                          if ( Iword(1)(1)='1' and carry(1)='1' ) then
                              Reg5 := aluop(1);
                          elsif (Iword(1)(0)='1' and zero(2)='1' ) then
                              Reg5 := aluop(1);
                          else
                              Reg5 := regFiledata(5);
                          end if;
                   end if;

              elsif (Iword(1)(15 downto 12) = "0001" ) then     ---------- ADI instruction
                      Reg5 := aluop(1);
              elsif ( Iword(1)(15)='1' and Iword(1)(14)='0' and Iword(1)(13)='0')  then ----  JAL and JLR
                      Reg5 := PC_1(1);
              elsif (Iword(1)(15 downto 12) = "0011" ) then               ---- LHI instruction
                      Reg5 := padder(1);
              elsif (Iword(1)(15 downto 12) = "0100" ) then               ---- LW instruction
                      Reg5 := mem_out(0);
              end if;

        else
              Reg5 := regFiledata(5);
            end if;
            ---------------- --------------------------------------------------
            ------------ forwrding for R0 from writeback stage---------------
    elsif (Iword(2)(15 downto 12) = "0110") then   -- if LM    of writeback

            if ( Lm_sel(2)(5)='1') then
              Reg5 := Lm_wb(5);       ---------- select R0 register
            else
              Reg5 := regFiledata(5);
            end if;

    elsif (Iword(2)(15 downto 12) /= "1111") then

            if(regDest(2)="101") then
                  if ( Iword(2)(15)='0' and Iword(2)(14)='0' and Iword(2)(12)='0') then ----- R type instruction
                        if (Iword(2)(1 downto 0) = "00" ) then
                                  Reg5:=aluop(2);
                        else
                              if ( Iword(2)(1)='1' and carry(2)='1' ) then
                                  Reg5 := aluop(2);
                              elsif (Iword(2)(0)='1' and zero(3)='1' ) then
                                  Reg5 := aluop(2);
                              else
                                  Reg5 := regFiledata(5);
                              end if;
                       end if;

                  elsif (Iword(2)(15 downto 12) = "0001" ) then     ---------- ADI instruction
                      Reg5 := aluop(2);
                  elsif ( Iword(2)(15)='1' and Iword(2)(14)='0' and Iword(2)(13)='0')  then ----  JAL and JLR
                      Reg5 := PC_1(2);
                  elsif (Iword(2)(15 downto 12) = "0011" ) then               ---- LHI instruction
                      Reg5 := padder(2);
                  elsif (Iword(2)(15 downto 12) = "0100" ) then               ---- LW instruction
                      Reg5 := mem_out(1);
                  end if;

            else
                  Reg5 := regFiledata(5);
            end if;

    end if;
    stall(5) <=  var_stall;
    RegAll(5) <= Reg5;
end process;
------------------------------------------------------------------------------------
------------------------------------- R6 PROCESS -----------------------------------------
------------------------------------------------------------------------------------
process (Iword,padder,PC_1,aluop,regDest,Lm_mem,Lm_sel,Lm_wb,mem_out,regFiledata,carry,zero)
  variable Reg6:std_logic_vector(15 downto 0):= (others=>'0');
  variable var_stall: std_logic:='0';
  begin

    ---------------- ----------------------------------------
    ------------ forwrding for R0 from execute stage----------
    var_stall:='0';
    if (Iword(0)(15 downto 12) = "0110" or Iword(0)(15 downto 12) = "0100" ) then   -- if LM of execute or LW of execute
        Reg6:=regFiledata(6);
        if (Lm_sel(0)(6)='1' or regDest(0)="110") then
          var_stall:='1';
        end if;


    elsif (Iword(0)(15 downto 12) /= "1111") then

            if(regDest(0)="110") then
                  if ( Iword(0)(15)='0' and Iword(0)(14)='0' and Iword(0)(12)='0') then ----- R type instruction
                        if (Iword(0)(1 downto 0) = "00" ) then
                                Reg6:=aluop(0);
                        else
                              if ( Iword(0)(1)='1' and carry(0)='1' ) then
                                Reg6 := aluop(0);
                              elsif (Iword(0)(0)='1' and
                              ( (zero(0)='1' and Iword(1)(15 downto 12)="0100") or
                                (zero(1)='1' and Iword(1)(15 downto 14)="00" and Iword(1)(13 downto 12)/="11" ) or
                                (zero(2)='1' and not(Iword(1)(15 downto 12)="0100") and not(Iword(1)(15 downto 14)="00" and Iword(1)(13 downto 12)/="11"))) ) then
                                Reg6 := aluop(0);
                              else
                                Reg6 := regFiledata(6);
                              end if;
                       end if;

                  elsif (Iword(0)(15 downto 12) = "0001" ) then     ---------- ADI instruction
                          Reg6 := aluop(0);
                  elsif ( Iword(0)(15)='1' and Iword(0)(14)='0' and Iword(0)(13)='0')  then ----  JAL and JLR
                          Reg6 := PC_1(0);
                  elsif (Iword(0)(15 downto 12) = "0011" ) then               ---- LHI instruction
                          Reg6 := padder(0);
                  end if;

            else
                  Reg6 := regFiledata(6);
            end if;

            ---------------- -------------------------------------------------------
            ------------ forwrding for R0 from memory stage------------------------

    elsif (Iword(1)(15 downto 12) = "0110") then   -- if LM of mem

            if ( Lm_sel(1)(6)='1') then
              Reg6 := Lm_mem(6);
            else
              Reg6 := regFiledata(6);
            end if;

    elsif (Iword(1)(15 downto 12) /= "1111") then

            if(regDest(1)="110") then
              if ( Iword(1)(15)='0' and Iword(1)(14)='0' and Iword(1)(12)='0') then ----- R type instruction
                    if (Iword(1)(1 downto 0) = "00" ) then
                              Reg6:=aluop(1);
                    else
                          if ( Iword(1)(1)='1' and carry(1)='1' ) then
                              Reg6 := aluop(1);
                          elsif (Iword(1)(0)='1' and zero(2)='1' ) then
                              Reg6 := aluop(1);
                          else
                              Reg6 := regFiledata(6);
                          end if;
                   end if;

              elsif (Iword(1)(15 downto 12) = "0001" ) then     ---------- ADI instruction
                      Reg6 := aluop(1);
              elsif ( Iword(1)(15)='1' and Iword(1)(14)='0' and Iword(1)(13)='0')  then ----  JAL and JLR
                      Reg6 := PC_1(1);
              elsif (Iword(1)(15 downto 12) = "0011" ) then               ---- LHI instruction
                      Reg6 := padder(1);
              elsif (Iword(1)(15 downto 12) = "0100" ) then               ---- LW instruction
                      Reg6 := mem_out(0);
              end if;

        else
              Reg6 := regFiledata(6);
            end if;
            ---------------- --------------------------------------------------
            ------------ forwrding for R0 from writeback stage---------------
    elsif (Iword(2)(15 downto 12) = "0110") then   -- if LM    of writeback

            if ( Lm_sel(2)(6)='1') then
              Reg6 := Lm_wb(6);       ---------- select R0 register
            else
              Reg6 := regFiledata(6);
            end if;

    elsif (Iword(2)(15 downto 12) /= "1111") then

            if(regDest(2)="110") then
                  if ( Iword(2)(15)='0' and Iword(2)(14)='0' and Iword(2)(12)='0') then ----- R type instruction
                        if (Iword(2)(1 downto 0) = "00" ) then
                                  Reg6:=aluop(2);
                        else
                              if ( Iword(2)(1)='1' and carry(2)='1' ) then
                                  Reg6 := aluop(2);
                              elsif (Iword(2)(0)='1' and zero(3)='1' ) then
                                  Reg6 := aluop(2);
                              else
                                  Reg6 := regFiledata(6);
                              end if;
                       end if;

                  elsif (Iword(2)(15 downto 12) = "0001" ) then     ---------- ADI instruction
                      Reg6 := aluop(2);
                  elsif ( Iword(2)(15)='1' and Iword(2)(14)='0' and Iword(2)(13)='0')  then ----  JAL and JLR
                      Reg6 := PC_1(2);
                  elsif (Iword(2)(15 downto 12) = "0011" ) then               ---- LHI instruction
                      Reg6 := padder(2);
                  elsif (Iword(2)(15 downto 12) = "0100" ) then               ---- LW instruction
                      Reg6 := mem_out(1);
                  end if;

            else
                  Reg6 := regFiledata(6);
            end if;

    end if;
    stall(6) <= var_stall;
    RegAll(6) <= Reg6;
end process;
------------------------------------------------------------------------------------
------------------------------------- R7 PROCESS [PC] -------------------------------------
------------------------------------------------------------------------------------
process (Iword,padder,PC_1,aluop,regDest,Lm_mem,Lm_sel,Lm_wb,mem_out,regFiledata,carry,zero)
  variable Reg7:std_logic_vector(15 downto 0):= (others=>'0');
  variable var_stall: std_logic:='0';
  begin

    ---------------- ----------------------------------------
    ------------ forwrding for R0 from execute stage----------
    var_stall:='0';
    if (Iword(0)(15 downto 12) = "0110" or Iword(0)(15 downto 12) = "0100" ) then   -- if LM of execute or LW of execute
        Reg7:=regFiledata(7);
        if (Lm_sel(0)(7)='1' or regDest(0)="111") then
          var_stall:='1';
        end if;


    elsif (Iword(0)(15 downto 12) /= "1111") then

            if(regDest(0)="111") then
                  if ( Iword(0)(15)='0' and Iword(0)(14)='0' and Iword(0)(12)='0') then ----- R type instruction
                        if (Iword(0)(1 downto 0) = "00" ) then
                                Reg7:=aluop(0);
                        else
                              if ( Iword(0)(1)='1' and carry(0)='1' ) then
                                Reg7 := aluop(0);
                              elsif (Iword(0)(0)='1' and
                              ( (zero(0)='1' and Iword(1)(15 downto 12)="0100") or
                                (zero(1)='1' and Iword(1)(15 downto 14)="00" and Iword(1)(13 downto 12)/="11" ) or
                                (zero(2)='1' and not(Iword(1)(15 downto 12)="0100") and not(Iword(1)(15 downto 14)="00" and Iword(1)(13 downto 12)/="11"))) ) then
                                Reg7 := aluop(0);
                              else
                                Reg7 := regFiledata(7);
                              end if;
                       end if;

                  elsif (Iword(0)(15 downto 12) = "0001" ) then     ---------- ADI instruction
                          Reg7 := aluop(0);
                  elsif ( Iword(0)(15)='1' and Iword(0)(14)='0' and Iword(0)(13)='0')  then ----  JAL and JLR
                          Reg7 := PC_1(0);
                  elsif (Iword(0)(15 downto 12) = "0011" ) then               ---- LHI instruction
                          Reg7 := padder(0);
                  end if;

            else
                  Reg7 := regFiledata(7);
            end if;

            ---------------- -------------------------------------------------------
            ------------ forwrding for R0 from memory stage------------------------

    elsif (Iword(1)(15 downto 12) = "0110") then   -- if LM of mem

            if ( Lm_sel(1)(7)='1') then
              Reg7 := Lm_mem(7);
            else
              Reg7 := regFiledata(7);
            end if;

    elsif (Iword(1)(15 downto 12) /= "1111") then

            if(regDest(1)="111") then
              if ( Iword(1)(15)='0' and Iword(1)(14)='0' and Iword(1)(12)='0') then ----- R type instruction
                    if (Iword(1)(1 downto 0) = "00" ) then
                              Reg7:=aluop(1);
                    else
                          if ( Iword(1)(1)='1' and carry(1)='1' ) then
                              Reg7 := aluop(1);
                          elsif (Iword(1)(0)='1' and zero(2)='1' ) then
                              Reg7 := aluop(1);
                          else
                              Reg7 := regFiledata(7);
                          end if;
                   end if;

              elsif (Iword(1)(15 downto 12) = "0001" ) then     ---------- ADI instruction
                      Reg7 := aluop(1);
              elsif ( Iword(1)(15)='1' and Iword(1)(14)='0' and Iword(1)(13)='0')  then ----  JAL and JLR
                      Reg7 := PC_1(1);
              elsif (Iword(1)(15 downto 12) = "0011" ) then               ---- LHI instruction
                      Reg7 := padder(1);
              elsif (Iword(1)(15 downto 12) = "0100" ) then               ---- LW instruction
                      Reg7 := mem_out(0);
              end if;

        else
              Reg7 := regFiledata(7);
            end if;
            ---------------- --------------------------------------------------
            ------------ forwrding for R0 from writeback stage---------------
    elsif (Iword(2)(15 downto 12) = "0110") then   -- if LM    of writeback

            if ( Lm_sel(2)(7)='1') then
              Reg7 := Lm_wb(7);       ---------- select R0 register
            else
              Reg7 := regFiledata(7);
            end if;

    elsif (Iword(2)(15 downto 12) /= "1111") then

            if(regDest(2)="111") then
                  if ( Iword(2)(15)='0' and Iword(2)(14)='0' and Iword(2)(12)='0') then ----- R type instruction
                        if (Iword(2)(1 downto 0) = "00" ) then
                                  Reg7:=aluop(2);
                        else
                              if ( Iword(2)(1)='1' and carry(2)='1' ) then
                                  Reg7 := aluop(2);
                              elsif (Iword(2)(0)='1' and zero(3)='1' ) then
                                  Reg7 := aluop(2);
                              else
                                  Reg7 := regFiledata(7);
                              end if;
                       end if;

                  elsif (Iword(2)(15 downto 12) = "0001" ) then     ---------- ADI instruction
                      Reg7 := aluop(2);
                  elsif ( Iword(2)(15)='1' and Iword(2)(14)='0' and Iword(2)(13)='0')  then ----  JAL and JLR
                      Reg7 := PC_1(2);
                  elsif (Iword(2)(15 downto 12) = "0011" ) then               ---- LHI instruction
                      Reg7 := padder(2);
                  elsif (Iword(2)(15 downto 12) = "0100" ) then               ---- LW instruction
                      Reg7 := mem_out(1);
                  end if;

            else
                  Reg7 := regFiledata(7);
            end if;

    end if;
    stall(7)<=var_stall;
    RegAll(7) <= Reg7;
end process;

regDataout<=RegAll;
stallflag<= (stall(0) or stall(1) or stall(2) or stall(3) or stall(4) or stall(5) or stall(6) or stall(7));
end comb;
