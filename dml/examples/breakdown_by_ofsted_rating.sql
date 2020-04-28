select
  ofsted_rating as "Ofsted rating",
  gender,
  count(*)
from
  open_schools
group by
  ofsted_rating,
  gender
order by
  ofsted_rating,
  gender
\crosstabview
