-- 데이터 분석을 위한 쿼리 작성 
-- 데이터를 테이블로 받은 뒤, as절로 명시하여 다양한 데이터를 조합한 테이블로 분석한다 
with pair as (select distinct buyer_id, gender, product 
	from orders order by buyer_id,product),
	
cr as (select a.buyer_id, a.product product1, b.product product2 
    from pair a join pair b
	on a.buyer_id = b.buyer_id
	and a.product != b.product),
    
cr_cnt as (select product1, product2,count(*) as cross_cnt
	from cr group by product1, product2),

tot_cnt as (select product,count(distinct buyer_id) as tot_cnt
	from orders group by product)

select t.product,t.tot_cnt,c.product2,c.cross_cnt,c.cross_cnt/t.tot_cnt * 100 as ratio
from tot_cnt t left join cr_cnt c on t.product=c.product1
order by ratio;

select t.product,t.tot_cnt,c.product2,c.cross_cnt 
from tot_cnt t left join cr_cnt c on t.product=c.product1;

-- 2. 인사이트 뽑기
-- 성별 연령대에 대한 교차 구매 분석
with distinct_pairs as (select distinct buyer_id, product, gender, age_group 
			from orders),
    
    cross_combinations as (select a.buyer_id,a.gender,a.age_group,
			a.product as product_1, b.product as product_2 from distinct_pairs a 
            join distinct_pairs b on a.buyer_id = b.buyer_id 
            where a.product != b.product),
     buyer as (select gender, age_group, count(*) as buyer_cnt
			from orders group by gender,age_group)
select c.gender, c.age_group, product_1, product_2, count(*) as total_count,
		b.buyer_cnt, count(*)/b.buyer_cnt * 100 as ratio
        from cross_combinations c left join buyer b 
        on c.gender = b.gender and c.age_group = b.age_group 
        group by gender,age_group,product_1,product_2,b.buyer_cnt
        order by ratio;
