drop database if exists prime_play;
create database prime_play;
use prime_play;

set @@cte_max_recursion_depth = 50000000;
set global max_execution_time = 3000000;
SET GLOBAL connect_timeout=100000;

-- This one is as example using recursive Common Table Expression to define factorial 
-- The way I read it is , the start iis the first 'select' that sets up two attributes 'para_val' and 'fact' 
--  these are also declares as arguments or parameters in the recursion in the with part
-- the 'union all' then unions a set of selects that are generated recursively - each producing One set with one row
-- according to the values of the paramters at the previous select. 
-- the stopping point is where param_val < z.
delimiter $$
drop procedure if exists factorial_cte$$
create definer='root'@'localhost' procedure factorial_cte(IN z BIGINT)
begin
	with recursive factorial(param_val,fact) as (
		select 0 as 'param_val', 1 AS 'fact'
		union all
		select param_val + 1, fact * (param_val + 1) 
		from factorial
		where param_val < z

	)
	select fact from factorial;
end $$
delimiter ;

call factorial_cte(3);


-- Can we find primes using recursive CTEs?
-- Wikipedia has pseudo code for Sieve of Eratosthenes here: https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes
/*
algorithm Sieve of Eratosthenes is
    input: an integer n > 1.
    output: all prime numbers from 2 through n.

    let A be an array of Boolean values, indexed by integers 2 to n,
    initially all set to true.
    
    for i = 2, 3, 4, ..., not exceeding √n do
        if A[i] is true
            for j = i2, i2+i, i2+2i, i2+3i, ..., not exceeding n do
                A[j] := false

    return all i such that A[i] is true.

*/

-- let A be an array of Boolean values, indexed by integers 2 to n,
-- initially all set to true.

drop table if exists SetA;
create table SetA(
	i INT, v bool, n INT
);
 
 
drop procedure if exists prime_up_to;

delimiter $$
create procedure prime_up_to(IN pValue INT)
begin
	 set pValue = pValue -1;
	 with recursive A(i,v,n) as(
		select 2 as 'i', true as 'v', 0 as n
		union all
		select i + 1, v , n + 1
		from A
		where 
			 i < pValue
	),
	B(n,v) as (
	select 1 as 'n', 1 as 'v'
	union all
		select n + 1 , 
		case 
		   when (select count(*) from A where (((B.n + 1) mod A.i)  = 0))  = 1 then true
		   else false
		end 
		from B 
		where 
			   n < pValue
	)
	select n, case when v = 1 then 'True' else 'False' end as Maybe_Prime from B where v = 1;
end $$
delimiter ;
call prime_up_to(1000);


-- Error Code: 3636. Recursive query aborted after 1001 iterations. Try increasing @@cte_max_recursion_depth to a larger value.

