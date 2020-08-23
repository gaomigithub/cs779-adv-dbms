CREATE OR REPLACE FUNCTION public.trig_func_rentallimitcheck()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE
    COST 100
AS $BODY$declare
membershiptype integer;
cur_dvdcanrent integer;
cur_dvdholding integer;
num_monthlimit integer;
num_rentalleft integer;
begin
IF TG_OP = 'INSERT' THEN
	SELECT member.membershipid -- check membership type
	into membershiptype
	from membership
	inner join member on membership.membershipid = member.membershipid
	where memberid = (select new.memberid from rental where rentalid = new.rentalid);
	
	-- Counting how much holding in hands totally
	cur_dvdholding :=
	(select count(rentalid)
	 from rental
	 inner join member on rental.memberid = member.memberid
	 where rentalreturneddate is null and rental.memberid = (select new.memberid from rental where rentalid = new.rentalid));
	 
	 -- based on membership type then set the default number of DVD can rent now
	 if (membershiptype = 1) then
	 cur_dvdcanrent := 3;
	 num_monthlimit := 99;
		-- has 3 at-one-time now
		if (cur_dvdholding = 3) then -- 3 copies not returned yet
			cur_dvdcanrent := 0; -- return 0
			raise EXCEPTION 'Error, the monthly limitation is reached.';
			return old;
		end if;
	elseif (membershiptype = 2) then
	cur_dvdcanrent := 2;
	num_monthlimit := 4;
		-- has 2 at-one-time now
		if (cur_dvdholding = 2) then -- 2 copies not returned yet
			cur_dvdcanrent := 0; -- return 0
			raise EXCEPTION 'Error, the monthly limitation is reached.';
			return old;
		end if;
	end if;
	
	-- Counting how much left in this month
	num_rentalleft := (num_monthlimit - (select count(rentalid) 
						 from rental 
						 inner join member on rental.memberid = member.memberid
						 where EXTRACT(MONTH FROM rentalrequestdate) = EXTRACT(MONTH FROM current_date)
						 and EXTRACT(YEAR FROM rentalrequestdate) = EXTRACT(YEAR FROM current_date)
						 and rental.memberid = (select new.memberid from rental where rentalid = new.rentalid)));
						 
	if (num_rentalleft = 0) then -- hit the limitation totally
		cur_dvdcanrent := num_rentalleft; -- return 0
			raise EXCEPTION 'Error, the monthly limitation is reached.';
			return old;
	elseif (num_rentalleft < 3) then -- only left at most 2 changes totally in this month
		cur_dvdcanrent := num_rentalleft - cur_dvdholding; -- 2 changes reduced by current holding 0 to 2 copies
			if (cur_dvdholding > num_rentalleft) then -- But if already hold too many in hands
			cur_dvdcanrent := 0;
			raise EXCEPTION 'Error, the monthly limitation is reached.';
			return old;
			end if;
	else cur_dvdcanrent := cur_dvdcanrent - cur_dvdholding; -- basic counting
	end if;
	
	return cur_dvdcanrent;
	
	
end if;
end;$BODY$;