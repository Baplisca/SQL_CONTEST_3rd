select
    PF_CODE as CODE,
    TOTAL_VALUE as SALES_AMT
from
    CONVENIENCE
where
    SURVEY_YEAR = '2019'
    and KIND_CODE = '100'
order by
    SALES_AMT desc,
    CODE;