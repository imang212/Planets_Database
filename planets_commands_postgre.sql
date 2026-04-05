--- 4x select
-- calculate the average number of records per table
SELECT ROUND(AVG(pocet_zaznamu),0) AS "Average number of records per table"
FROM (
    SELECT COUNT(*) AS pocet_zaznamu FROM public."Objev"
    UNION ALL
    SELECT COUNT(*) AS pocet_zaznamu FROM public."Objevitel"
    UNION ALL
    SELECT COUNT(*) AS pocet_zaznamu FROM public."Prvky"
    UNION ALL
    SELECT COUNT(*) AS pocet_zaznamu FROM public."Slouceniny"
    UNION ALL
    SELECT COUNT(*) AS pocet_zaznamu FROM public."Slozeni"
    UNION ALL
    SELECT COUNT(*) AS pocet_zaznamu FROM public."Teleso"
    UNION ALL
    SELECT COUNT(*) AS pocet_zaznamu FROM public."Typ_telesa"
    UNION ALL
    SELECT COUNT(*) AS pocet_zaznamu FROM public."Typy_hvezd"
    UNION ALL
    SELECT COUNT(*) AS pocet_zaznamu FROM public."Typy_planet"
    UNION ALL
    SELECT COUNT(*) AS pocet_zaznamu FROM public."Vzdalenost"
) 

-- select with a nested subquery
select nazev as "Body Name", 1 + (select count(*) from "Teleso" where "hmotnost_(kg)" > t."hmotnost_(kg)") as "Mass Ranking" 
from "Teleso" t
order by "Mass Ranking";

-- select with an analytical function
select t3.typ AS "Body Type", CONCAT(ROUND(AVG(t1."prumer_(km)")::numeric,0),' ','km') AS "Average Diameter"
FROM ("Teleso" t1 JOIN "Typ_telesa" t2 ON t1.id_typ_tel = t2.id_typ) 
LEFT JOIN "Typy_planet" t3 ON t2.id_pla = t3.id_pla
WHERE t2.id_pla IS NOT NULL
group by t3.typ 
order by AVG(t1."prumer_(km)") desc
limit 4

-- select with hierarchy (SELF_join)
-- Note: should be adjusted to be within the same table
with recursive dedicnost_planet as(
  select t.id_pla, (SELECT nazev FROM "Teleso" s WHERE s.id_tel = t.id_pla) AS "planet name", t.id_tel, t.nazev 
  from "Teleso" t 
  where t.id_pla is not null
  union 
  select t.id_pla, (SELECT nazev FROM "Teleso" s WHERE s.id_tel = t.id_pla) AS "planet name", t.id_tel, t.nazev as "moon name" 
  from "Teleso" t 
  inner join dedicnost_planet d on d.id_pla = t.id_tel
)
select * from dedicnost_planet order by id_pla ASC;

with recursive dedicnost_hvezd as(
  select t.id_mat_hve, (SELECT nazev FROM "Teleso" s WHERE s.id_tel = t.id_mat_hve) AS "star name", t.id_tel, t.nazev 
  from "Teleso" t 
  where id_mat_hve is not null
  union 
  select t.id_mat_hve, (SELECT nazev FROM "Teleso" s WHERE s.id_tel = t.id_mat_hve) AS "star name", t.id_tel, t.nazev 
  from "Teleso" t 
  inner join dedicnost_hvezd d on d.id_mat_hve = t.id_tel
)
select * from dedicnost_hvezd order by id_tel ASC;

-- view
CREATE OR REPLACE VIEW Telesa_view AS
SELECT t1.nazev AS "body name", t1.symbol AS "body symbol", 
CONCAT(t1."hmotnost_(kg)",' kg') AS "body mass", 
CONCAT(ROUND(t1."prumer_(km)"::numeric,0),' km') AS "body diameter",  
t2.objevitel AS "Discovered by", t3.nazev AS "body type", 
CONCAT_WS(' ',t5.typ,t4.typ) AS "category" 
FROM ("Teleso" t1 JOIN "Objev" t2 ON t1.id_tel = t2.id_pla JOIN "Typ_telesa" t3 ON t1.id_typ_tel = t3.id_typ) 
LEFT JOIN "Typy_planet" t4 ON t3.id_pla = t4.id_pla
LEFT JOIN "Typy_hvezd" t5 ON t3.id_hve = t5.id_hve
ORDER BY id_tel;

--- index
explain analyse SELECT t3.typ AS "planet type",
t3.id_pla as "planet type ID",
t1.nazev AS "name", 
t1.id_tel as "planet ID"
FROM ("Teleso" t1 JOIN "Typ_telesa" t2 ON t1.id_typ_tel = t2.id_typ) 
LEFT JOIN "Typy_planet" t3 ON t2.id_pla = t3.id_pla
WHERE t3.id_pla IS NOT NULL
ORDER BY t3.id_pla asc

-- index1
CREATE index index1 ON "Teleso"("id_typ_tel");

explain analyse SELECT t3.typ AS "planet type",
t3.id_pla as "planet type ID",
t1.nazev AS "name", 
t1.id_tel as "planet ID"
FROM ("Teleso" t1 JOIN "Typ_telesa" t2 ON t1.id_typ_tel = t2.id_typ) 
LEFT JOIN "Typy_planet" t3 ON t2.id_pla = t3.id_pla
WHERE t3.id_pla IS NOT NULL
ORDER BY t3.id_pla asc

-- creating another index (index2)
create index index2 ON "Typ_telesa"("id_typ","id_pla");

explain analyse SELECT t3.typ AS "planet type",
t3.id_pla as "planet type ID",
t1.nazev AS "name", 
t1.id_tel as "planet ID"
FROM ("Teleso" t1 JOIN "Typ_telesa" t2 ON t1.id_typ_tel = t2.id_typ) 
LEFT JOIN "Typy_planet" t3 ON t2.id_pla = t3.id_pla
WHERE t3.id_pla IS NOT NULL
ORDER BY t3.id_pla asc

-- additional index
CREATE index index1 ON "Teleso"("id_typ_tel");

explain SELECT t1.nazev, to_char(t2."datum_objevu"::date ,'dd.mm.YYYY') AS "discovery date", 
concat(t3."jmeno",t3."prijmeni") AS "Discoverer name", 
t3.puvod as "Discoverer origin"
FROM ("Teleso" t1 JOIN "Objev" t2 ON t1.id_tel = t2.id_pla) 
JOIN "Objevitel" t3 ON t2.id_jme = t3.id_jme
WHERE t1.id_typ_tel = 12
ORDER BY t2.datum_objevu ASC;

CREATE INDEX index2 ON "Objev"("id_pla","id_jme")

explain SELECT t1.nazev, to_char(t2."datum_objevu"::date ,'dd.mm.YYYY') AS "discovery date", 
concat(t3."jmeno",t3."prijmeni") AS "Discoverer name", 
t3.puvod as "Discoverer origin"
FROM ("Teleso" t1 JOIN "Objev" t2 ON t1.id_tel = t2.id_pla) 
JOIN "Objevitel" t3 ON t2.id_jme = t3.id_jme
WHERE t1.id_typ_tel = 12
ORDER BY t2.datum_objevu ASC;

-- function, returns body mass
create or replace function Vrat_prumernou_hmotnost(druh_telesa text)
  returns Table(hmotnost text) AS $$
    select concat(AVG(t1."hmotnost_(kg)"::real),' kg') as "Average Mass" 
    from "Teleso" t1 join "Typ_telesa" t2 ON t1.id_typ_tel = t2.id_typ 
    where t2.nazev = druh_telesa
$$ language sql;

select Vrat_prumernou_hmotnost('měsíc'); -- moon
select Vrat_prumernou_hmotnost('planeta'); -- planet

--- procedure
-- procedure that returns a table with gravity of individual bodies
create or replace procedure Vrat_gravitaci(min_gravitace numeric, max_gravitace numeric) 
AS $$
DECLARE
  p_cursor CURSOR FOR SELECT t2.nazev AS typ_planety, t1.nazev, t1."gravitace_(m/s^(2))" AS gravitace 
      FROM "Teleso" t1 LEFT join "Typ_telesa" t2 ON t1.id_typ_tel = t2.id_typ 
      WHERE t1."gravitace_(m/s^(2))" IS NOT NULL
      ORDER BY t1."gravitace_(m/s^(2))" DESC; 
  p_record RECORD;
BEGIN
  DROP TABLE IF EXISTS "gravitace_planet";
    CREATE TABLE IF NOT EXISTS "gravitace_planet" (
    nazev TEXT,        
    typ_planety TEXT,
        gravitace TEXT
    );

  OPEN p_cursor;
  LOOP
    FETCH p_cursor INTO p_record;
    EXIT WHEN NOT FOUND;
    BEGIN
    IF p_record.gravitace >= min_gravitace AND p_record.gravitace <= max_gravitace THEN
          INSERT INTO gravitace_planet(nazev, typ_planety, gravitace)
          VALUES (p_record.nazev, p_record.typ_planety, concat(p_record.gravitace, ' m/s'));
  ELSE
    END IF;
    EXCEPTION WHEN OTHERS THEN
      RAISE WARNING 'Error: %: %',p_record.nazev, SQLERRM;
    END;
  END LOOP;
  CLOSE p_cursor;
  RAISE NOTICE 'Procedure completed successfully.';
END;
$$ language plpgsql;

BEGIN;
-- first, bodies with gravity between 0 and 2 m/s
CALL Vrat_gravitaci(0,2); 
ROLLBACK; -- call rollback in case of error
COMMIT;

BEGIN;
-- then bodies with gravity higher than 20 m/s
CALL Vrat_gravitaci(20,1000); 
ROLLBACK; -- call rollback in case of error
COMMIT;

--- trigger
-- create a table for logging trigger actions
DROP TABLE IF EXISTS teleso_action;
CREATE TABLE teleso_action(
    id SERIAL NOT NULL,
    id_tel INT, 
    nazev CHAR(50),
    datum  TIMESTAMP,
    akce CHAR(6),
    user_ VARCHAR(30),
    CONSTRAINT "Teleso_action_pkey" PRIMARY KEY (id)
);

-- function to be used by the trigger for insertion
CREATE OR REPLACE FUNCTION teleso_insert()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO Teleso_action(id_tel,nazev,datum,akce,user_) VALUES (NEW.id_tel,NEW.nazev,CURRENT_TIMESTAMP,'INSERT',SESSION_USER);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- final insert trigger: logs when a new planet is added to the DB using the above function
CREATE TRIGGER teleso_insert_after
AFTER INSERT ON "Teleso"
FOR EACH ROW
EXECUTE FUNCTION teleso_insert()

-- testing by adding a new body
INSERT INTO "Teleso" VALUES (36,'Alpha Centauri A',Null, 3, 1.2175*695700, 1.078*2*POWER(10,30), 1.51 , 42.17, NULL,5.804,NULL,9720, 28.3,NULL,NULL);
DELETE FROM "Teleso" WHERE id_tel = 36;

--- transaction
CREATE OR REPLACE PROCEDURE zmen_prumer_planety(nazev1 VARCHAR, nazev2 VARCHAR, o_kolik NUMERIC)
AS $$
DECLARE
  aktualni_prumer NUMERIC; -- store body diameter in a variable
BEGIN -- start transaction
  -- get the diameter of the source body
    SELECT "prumer_(km)" INTO aktualni_prumer 
  FROM "Teleso" 
  WHERE nazev = nazev1;
  -- raise exception if the body diameter is smaller than the subtracted value
  IF aktualni_prumer < o_kolik THEN 
    RAISE EXCEPTION 'Body % has a diameter too small.', nazev1;
  ELSE
    END IF;
    -- subtract diameter
    UPDATE "Teleso"
    SET "prumer_(km)" = "prumer_(km)" - o_kolik
    WHERE nazev = nazev1;
    -- add diameter
    UPDATE "Teleso"
    SET "prumer_(km)" = "prumer_(km)" + o_kolik
    WHERE nazev = nazev2;

  -- notice that transaction was completed
  RAISE NOTICE 'Diameter transfer completed.';
-- handle errors by raising an exception and rolling back
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Transaction failed: %', SQLERRM;
  RAISE;
END;
$$ LANGUAGE plpgsql;

SELECT id_tel, nazev, concat(ROUND("prumer_(km)"::numeric,0),' km') FROM "Teleso" WHERE nazev IN ('Jupiter','Merkur');

BEGIN;
CALL zmen_prumer_planety('Jupiter','Merkur',100000);
ROLLBACK; -- rollback in case of error
COMMIT; 

SELECT id_tel, nazev, concat(ROUND("prumer_(km)"::numeric,0),' km') FROM "Teleso" WHERE nazev IN ('Jupiter','Merkur');

BEGIN;
CALL zmen_prumer_planety('Merkur','Jupiter',100000);
ROLLBACK;
COMMIT;

SELECT id_tel, nazev, concat(ROUND("prumer_(km)"::numeric,0),' km') FROM "Teleso" WHERE nazev IN ('Jupiter','Merkur');

--- user
CREATE USER patricek WITH PASSWORD 'patrik123456';
GRANT CONNECT ON DATABASE postgres TO patricek;

CREATE ROLE selecting_role WITH LOGIN PASSWORD 'heslo';

GRANT USAGE, CREATE ON SCHEMA public TO selecting_role;

-- GRANT SELECT ON TABLE "Planety" TO Patricek;
GRANT SELECT ON TABLE "Teleso" TO selecting_role;

GRANT selecting_role TO patricek;
-- select * from "Teleso"; DELETE FROM "Teleso" WHERE id_tel = 36; INSERT INTO "Teleso" VALUES (36,'Alpha Centauri A',Null, 3, 1.2175*695.700, 1.078*2*POWER(10,30), 1.51 , 42.17, NULL,5.804,NULL,9720, 28.3,NULL,NULL);
-- psql -U patricek -d postgres

GRANT select, insert, UPDATE ON TABLE "Teleso","teleso_action" TO selecting_role;
GRANT USAGE, SELECT ON SEQUENCE teleso_action_id_seq TO selecting_role;

REVOKE ALL PRIVILEGES ON TABLE "Teleso","teleso_action" FROM selecting_role;
REVOKE USAGE, CREATE ON SCHEMA public FROM selecting_role;
REVOKE USAGE, SELECT ON SEQUENCE teleso_action_id_seq FROM selecting_role;
REVOKE ALL PRIVILEGES ON DATABASE postgres FROM patricek;

DROP user patricek;
DROP ROLE selecting_role;

-- lock
BEGIN WORK;
LOCK TABLE "Teleso" IN SHARE MODE; -- lock table before specific operation
SELECT * FROM "Teleso" WHERE id_tel = 1 FOR SHARE;
SELECT * FROM "Teleso" WHERE id_tel = 1 for update;
ROLLBACK;
COMMIT WORK;
UPDATE "Teleso" SET "prumer_(km)" = "prumer_(km)" - 100000 WHERE id_tel = 1;

BEGIN WORK;
LOCK TABLE "Teleso" in ACCESS EXCLUSIVE MODE;
SELECT * FROM "Teleso" WHERE id_tel = 1 FOR SHARE;
SELECT * FROM "Teleso" WHERE id_tel = 1 for update;
UPDATE "Teleso" SET "prumer_(km)" = "prumer_(km)" + 100000 WHERE id_tel = 1;
ROLLBACK;
COMMIT WORK;

REVOKE CONNECT ON DATABASE postgres FROM PUBLIC;

GRANT CONNECT ON DATABASE postgres TO PUBLIC;