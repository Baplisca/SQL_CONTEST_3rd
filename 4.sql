with 'time_judge_table' as (
    select
        s.ENTRY_ID,
        s.USER_ID,
        s.PROBLEM_ID,
        s.STATUS as sSTATUS,
        s.SUBMITTED_AT as sSUBMITTED_AT,
        a.STATUS as aSTATUS,
        a.SUBMITTED_AT as aSUBMITTED_AT
    from
        SUBMISSIONS s
        inner join (
            select
                USER_ID,
                PROBLEM_ID,
                STATUS,
                SUBMITTED_AT
            from
                SUBMISSIONS
            where
                ENTRY_ID is not null
                and CONTEST_ID = 2
                and STATUS = 'WA'
        ) a on s.USER_ID = a.USER_ID
        and s.PROBLEM_ID = a.PROBLEM_ID
    where
        s.ENTRY_ID is not null
        and s.CONTEST_ID = 2
        and s.STATUS = 'AC'
),
'mistake_table' as (
    select
        USER_ID,
        SUM(
            case
                when aSUBMITTED_AT < sSUBMITTED_AT then 1
                else 0
            end
        ) as mistake
    from
        time_judge_table
    group by
        USER_ID
)
select
    RANK() over(
        order by
            p.POINT DESC,
            p.RAW_TIME
    ) as RANK,
    p.USER_ID,
    p.POINT,
    p.RAW_TIME as EX_TIME,
    p.WRONG_ANS
from
    (
        select
            s.USER_ID,
            SUM(s.POINT) as POINT,
            STRFTIME(
                '%s',
                MAX(
                    CASE
                        WHEN s.STATUS = 'AC' then s.SUBMITTED_AT
                        else 0
                    end
                )
            ) - STRFTIME('%s', MIN(e.STARTED_AT)) + 300 * IFNULL(m.mistake, 0) as RAW_TIME,
            IFNULL(m.mistake, 0) as WRONG_ANS
        from
            SUBMISSIONS s
            inner join ENTRIES e on s.ENTRY_ID = e.ENTRY_ID
            and s.CONTEST_ID = e.CONTEST_ID
            and s.USER_ID = e.USER_ID
            left join mistake_table m on s.USER_ID = m.USER_ID
        where
            s.ENTRY_ID is not null
            and s.CONTEST_ID = 2
        group by
            s.ENTRY_ID,
            s.USER_ID
    ) p
where
    p.POINT != 0
order by
    RANK,
    p.WRONG_ANS,
    USER_ID;