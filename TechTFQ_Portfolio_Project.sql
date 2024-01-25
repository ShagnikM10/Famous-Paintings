use TechTFQ_Project
select * from artist;
select * from canvas_size;
select * from image_link;
select * from museum;
select * from museum_hours;
select * from product_size;
select * from subject;
select * from work;


--Q1. Fetch all the paintings which are not displayed on any museums

select *
from work
where museum_id is null

--Q2. Are there museuems without any paintings?

select mu.museum_id, mu.name, COUNT(wrk.work_id) as No_of_Paintings
from museum mu
join work wrk
on mu.museum_id = wrk.museum_id
group by mu.museum_id, mu.name
order by COUNT(wrk.work_id) desc

--Q3. How many paintings have an asking price of more than their regular price? 

select *
from product_size
where sale_price > regular_price
-- There aren't any paintings which come with an asking bid that is higher than its regular price

--Q4. Identify the paintings whose asking price is less than 50% of its regular price
select ps.*, sub.subject
from product_size ps
left join subject sub
on ps.work_id = sub.work_id
where ps.sale_price < 0.5*ps.regular_price
--group by work_id
--order by size_id asc

--Q5. Which canva size costs the most?

select *
from product_size
where regular_price in (select MAX(regular_price) from product_size)

-- Its not mnetioned rather given as NULL.

--Q7. Identify the museums with invalid city information in the given dataset

select *
from museum
where city not like '%[^a-zA-Z]%'

--Q8. Museum_Hours table has 1 invalid entry. Identify it and remove it.

select *
from museum_hours mh
where mh.museum_id = 73 and mh.day = 'Thusday'

delete
from museum_hours
where museum_id = 73 and day = 'Thusday'

--Q10. Identify the museums which are open on both Sunday and Monday. Display museum name, city.

with sunday as(
				select mu.museum_id, mu.name, mu.city, hr.day
				from museum mu
				inner join museum_hours hr
				on mu.museum_id = hr.museum_id
				where hr.day = 'Sunday'
),
monday as(
			select mu.museum_id, mu.name, mu.city, hr.day
			from museum mu
			inner join museum_hours hr
			on mu.museum_id = hr.museum_id
			where hr.day = 'Monday'
)

select *
from sunday sun
inner join monday mon
on sun.museum_id = mon.museum_id

--Q11. How many museums are open every single day?

select 
	  CASE WHEN day = 'Thusday' THEN 'Thursday' ELSE day
	  END as days,
	  COUNT(museum_id) as No_of_Museums_Open
from museum_hours
group by day
order by day

--Q12. Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)

select top 5 mu.museum_id, mu.name, COUNT(work_id) as No_of_Paintings
from work wrk
inner join museum mu
on mu.museum_id = wrk.museum_id
group by mu.museum_id, mu.name
order by No_of_Paintings desc

--Q13. Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)

select top 5 art.artist_id, art.full_name, COUNT(wrk.work_id) as No_of_Paintings
from work wrk
inner join artist art
on wrk.artist_id = art.artist_id
group by art.artist_id, art.full_name
order by No_of_Paintings desc

--Q14. Display the 3 least popular canva sizes

select can.size_id, can.label, COUNT(prd.work_id) as No_of_Paintings
from product_size prd
inner join canvas_size can
on prd.size_id = can.size_id
group by can.size_id, can.label
having COUNT(prd.work_id) < 2
order by No_of_Paintings desc

--Q15. Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?

-- Replace 'YourTableName' with the actual name of your table
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'museum_hours';

-- Replace 'YourTableName' and 'YourColumnName' with actual names

--Q16. Which museum has the most no of most popular painting style?

with most_popular_painting as(
select work_id, count(work_id) as count_wrk
from work
group by work_id
having count(work_id) > 1
)

select wrk.work_id, wrk.name, wrk.museum_id
from work wrk
inner join most_popular_painting mst
on wrk.work_id = mst.work_id
where mst.count_wrk = 3


--Q17. Identify the artists whose paintings are displayed in multiple countries

with everything as(
select wrk.artist_id, art.full_name, wrk.work_id, wrk.museum_id, mu.name, mu.country
from work wrk
inner join artist art
on art.artist_id = wrk.artist_id
inner join museum mu
on wrk.museum_id = mu.museum_id
)
select artist_id, full_name, count(distinct country) as No_of_countries
from everything
group by artist_id, full_name
having count(distinct country) > 1
order by artist_id

--Q18. Display the country and the city with most no of museums. Output 2 seperate columns to mention the city and 
-- country. If there are multiple value, seperate them with comma.

select city, count(museum_id) as No_of_Museums
from museum
group by city
order by No_of_Museums desc

select country, count(museum_id) as No_of_Museums
from museum
group by country
order by No_of_Museums desc

--Q19. Identify the artist and the museum where the most expensive and least expensive painting is placed. Display the artist 
-- name, sale_price, painting name, museum name, museum city and canvas label

select art.full_name as Artist_Name, wrk.name as Painting_Name, mu.name as Museum_Name, mu.city as City, pr.sale_price, can.label
from product_size pr
inner join work wrk
on wrk.work_id = pr.work_id
inner join artist art
on art.artist_id = wrk.artist_id
inner join museum mu
on mu.museum_id = wrk.museum_id
inner join canvas_size can
on can.size_id = pr.size_id
where sale_price in (select min(sale_price) from product_size)
union
select art.full_name as Artist_Name, wrk.name as Painting_Name, mu.name as Museum_Name, mu.city as City, pr.sale_price, can.label
from product_size pr
inner join work wrk
on wrk.work_id = pr.work_id
inner join artist art
on art.artist_id = wrk.artist_id
inner join museum mu
on mu.museum_id = wrk.museum_id
inner join canvas_size can
on can.size_id = pr.size_id
where sale_price in (select max(sale_price) from product_size)

--Q20. Which country has the 5th highest no of paintings?

with cte as(
select wrk.*,mu.country
from work wrk
inner join museum mu
on wrk.museum_id = mu.museum_id
)
select *
from(select country, count(work_id) as No_of_Paintings,
	 dense_rank() over(order by count(work_id) desc) as rnk
	 from cte
	 group by country) x
where x.rnk = 5

--Q21. Which are the 3 most popular and 3 least popular painting styles?

select top 3 style, count(style) as Count_of_paintings
from work
where style is not null
group by style
order by Count_of_paintings desc

select top 3 style, count(style) as Count_of_paintings
from work
where style is not null
group by style
order by Count_of_paintings 


--Q22. Which artist has the most no of Portraits paintings outside USA?. Display artist name, no of paintings and the artist 
-- nationality.

select top 1 art.full_name, art.nationality, sub.subject, count(wrk.work_id) as No_of_Paintings
from work wrk
inner join subject sub
on wrk.work_id = sub.work_id
inner join artist art
on art.artist_id = wrk.artist_id
where sub.subject = 'Portraits' and art.nationality <> 'American'
group by art.full_name, art.nationality, sub.subject
order by No_of_Paintings desc