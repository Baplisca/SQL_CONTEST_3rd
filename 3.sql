select
    CLASS_NAME as CLASS,
    PERSON_NAME as PERSON,
    AMT as HOUSEHOLDS
from
    HOUSEHOLD
where
    PERSON_CODE != '1'
    and CLASS_CODE != '01'
group by
    CLASS_CODE
HAVING
    AMT = MAX(AMT)
order by
    CLASS_CODE;