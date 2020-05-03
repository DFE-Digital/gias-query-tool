select
	os.ofsted_rating as "Ofsted rating",
	os.gender,
	count(*)
from
	open_schools os
group by
	os.ofsted_rating,
	os.gender
order by
	os.ofsted_rating,
	os.gender
\crosstabview
