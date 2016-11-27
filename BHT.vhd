LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity BHt is
port(
next_instrn_num: out std_logic_vector(15 downto 0);--IF
screwed_bit: out std_logic;--EX
update_branched_instrn: in std_logic_vector(15 downto 0);--EX
update_history: in std_logic;--EX
up_read_instrn_num: in std_logic_vector(15 downto 0);--EX
rd_read_instrn_num: in std_logic_vector(15 downto 0);--IF
rd_match:out std_logic--IF
);
end BHt;

architecture  BHT_impl of  BHt is
type BH_record is
  RECORD
  instrn_num: std_logic_vector(15 downto 0);
  branched_instrn: std_logic_vector(15 downto 0);
  history: std_logic;
  END RECORD;

type BHT_dbase is array(0 to 20) of BH_record;
signal BHT_db:BHT_dbase;
signal up_is_hit:std_logic:='0';
signal rd_is_hit:std_logic:='0';
signal end_ptr:integer:=0;
begin
Search_F_ass: Process(up_read_instrn_num,rd_read_instrn_num)
  begin
  for i in 0 to 20 loop
    if(BHT_db(i).instrn_num=up_read_instrn_num) then
      if(BHT_db(i).history /= update_history ) then
        BHT_db(i).instrn_num<=update_branched_instrn;
        BHT_db(i).instrn_num<=up_read_instrn_num;
        BHT_db(i).history<=update_history;
        screwed_bit<='1';
        up_is_hit<='1';
      else
      up_is_hit<='1';
      screwed_bit<='0';
      end if;
    end if;
    if(BHT_db(i).instrn_num=rd_read_instrn_num) then
      rd_is_hit<='1';
      next_instrn_num<=BHT_db(i).branched_instrn;
    end if;
  end loop;

if(up_is_hit = '0') then
    if(up_read_instrn_num/="1111111111111111") then
    BHT_db(end_ptr).instrn_num<=update_branched_instrn;
    BHT_db(end_ptr).instrn_num<=up_read_instrn_num;
    BHT_db(end_ptr).history<=update_history;
    end_ptr<=end_ptr+1;
    if(end_ptr=20) then end_ptr<=0; end if;
    end if;
    screwed_bit<='0';
end if;

if(rd_is_hit='0')   then
next_instrn_num<="1111111111111111";
rd_match<='0';
else
rd_match<='1';
end if;

end process Search_F_ass;


end architecture;
