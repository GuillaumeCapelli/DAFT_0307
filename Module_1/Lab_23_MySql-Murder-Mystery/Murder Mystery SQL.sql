SELECT * FROM crime_scene_report;            

SELECT description FROM crime_scene_report
WHERE date = '20180115' AND type = 'murder' AND city = 'SQL City';

SELECT * FROM person; 

SELECT id FROM person
WHERE address_street_name = 'Northwestern Dr'
ORDER BY address_number DESC LIMIT 1;

SELECT id FROM person
WHERE INSTR(name, 'Annabel') > 0 AND address_street_name = 'Franklin Ave';

SELECT * FROM interview;            

SELECT transcript from interview
WHERE person_id = "14887";

SELECT transcript from interview
WHERE person_id = "16371";

WITH gym_checkins AS (
    --SELECT person_id, name
    --FROM get_fit_now_member
    --LEFT JOIN get_fit_now_check_in ON get_fit_now_member.id = get_fit_now_check_in.membership_id
    --WHERE membership_status = 'gold'
    --AND check_in_date = '20180109'
--), suspects AS (
    --SELECT gym_checkins.person_id, gym_checkins.name, plate_number, gender
    --FROM gym_checkins
    --LEFT JOIN person ON gym_checkins.person_id = person.id
    --LEFT JOIN drivers_license ON person.license_id = drivers_license.id
--)
--SELECT * FROM suspects
--WHERE INSTR(plate_number, 'H42W') AND gender = 'male'

-- JEREMY BOWERS !!!!

-- I was hired by a woman with a lot of money. 
-- I don't know her name but I know she's around 5'5" (65") or 5'7" (67"). 
-- She has red hair and she drives a Tesla Model S. 
-- I know that she attended the SQL Symphony Concert 3 times in December 2017. 

-- ah....not really finish...




SELECT transcript FROM interview WHERE person_id = 67318;

WITH red_haired_tesla_drivers AS (
    SELECT id AS license_id
    FROM drivers_license
    WHERE gender = 'female' AND hair_color = 'red' -- She has red hair
      AND car_make = 'Tesla' AND car_model = 'Model S' -- and she drives a Tesla Model S
      AND height >= 64 AND height <= 68 -- she's around 5'5" (65") or 5'7" (67")
), rich_suspects AS (
    SELECT person.id AS person_id, name, annual_income
    FROM red_haired_tesla_drivers AS rhtd
    LEFT JOIN person ON rhtd.license_id = person.license_id
    LEFT JOIN income ON person.ssn = income.ssn
), symphony_attenders AS (
    SELECT person_id, COUNT(1) AS n_checkins
    FROM facebook_event_checkin
    WHERE event_name = 'SQL Symphony Concert' -- she attended the SQL Symphony Concert
    GROUP BY person_id
    HAVING n_checkins = 3 -- 3 times
)
SELECT name, annual_income
FROM rich_suspects
INNER JOIN symphony_attenders ON rich_suspects.person_id = symphony_attenders.person_id

-- Miranda Priestly !!!

-- Congrats, you found the brains behind the murder! 
-- Everyone in SQL City hails you as the greatest SQL detective of all time. 
-- Time to break out the champagne!