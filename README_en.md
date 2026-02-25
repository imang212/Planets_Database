# Cosmic Database

## Database Model

![postgres -
public](https://github.com/user-attachments/assets/c59531e7-c6d6-439e-b75b-8f1fd7d49c5b)

The database model was created using DBeaver.

## Loading the Database

You can load the database using the uploaded file
**"planety_postgre.sql"**.\
Simply copy the code into a PostgreSQL database, run it as a whole, and
the database should appear in your system.\
This script works only for PostgreSQL databases.

## SQL Commands

Below are the SQL commands created as part of a seminar project for the
course RDBS (Relational Database Systems).\
They are stored in the file **"planety_prikazy_postgre.sql"**.

### SELECT to Calculate the Average Number of Records per Table

``` sql
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
);
```

### SELECT with Nested Query

``` sql
SELECT nazev AS "Object name",
1 + (SELECT count(*) FROM "Teleso" WHERE "hmotnost_(kg)" > t."hmotnost_(kg)") AS "Mass ranking" 
FROM "Teleso" t
ORDER BY "Mass ranking";
```

### SELECT with Analytical Function

``` sql
SELECT t3.typ AS "Object type", 
CONCAT(ROUND(AVG(t1."prumer_(km)")::NUMERIC,0),' ','km') AS "Average diameter"
FROM ("Teleso" t1 JOIN "Typ_telesa" t2 ON t1.id_typ_tel = t2.id_typ) 
LEFT JOIN "Typy_planet" t3 ON t2.id_pla = t3.id_pla
WHERE t2.id_pla IS NOT NULL
GROUP BY t3.typ 
ORDER BY AVG(t1."prumer_(km)") DESC
LIMIT 4;
```

### Recursive SELECT -- Planet and Its Moons

``` sql
WITH RECURSIVE dedicnost_planet AS(
  SELECT t.id_pla, (SELECT nazev FROM "Teleso" s WHERE s.id_tel = t.id_pla) AS "Planet name",
  t.id_tel, t.nazev as "Moon name"
  FROM "Teleso" t 
  WHERE t.id_pla IS NOT NULL
  UNION 
  SELECT t.id_pla, (SELECT nazev FROM "Teleso" s WHERE s.id_tel = t.id_pla) AS "Planet name",
  t.id_tel, t.nazev as "Moon name" 
  FROM "Teleso" t 
  INNER JOIN dedicnost_planet d ON d.id_pla = t.id_tel
)
SELECT * FROM dedicnost_planet ORDER BY id_pla ASC;
```

## View

``` sql
CREATE OR REPLACE VIEW Telesa_view AS
SELECT t1.nazev AS "Object name", t1.symbol AS "Symbol", 
CONCAT(t1."hmotnost_(kg)",' kg') AS "Mass", 
CONCAT(ROUND(t1."prumer_(km)"::numeric,0),' km') AS "Diameter",  
t2.objevitel AS "Discoverer", t3.nazev AS "Object type", 
CONCAT_WS(' ',t5.typ,t4.typ) AS "Subtype" 
FROM ("Teleso" t1 
JOIN "Objev" t2 ON t1.id_tel = t2.id_pla 
JOIN "Typ_telesa" t3 ON t1.id_typ_tel = t3.id_typ) 
LEFT JOIN "Typy_planet" t4 ON t3.id_pla = t4.id_pla
LEFT JOIN "Typy_hvezd" t5 ON t3.id_hve = t5.id_hve
ORDER BY id_tel;
```

## Function -- Average Mass by Object Type

``` sql
CREATE OR REPLACE FUNCTION Vrat_prumernou_hmotnost(druh_telesa text)
returns Table(hmotnost text) AS $$
    select concat(AVG(t1."hmotnost_(kg)"::real),' kg') as "Average mass" 
    from "Teleso" t1 
    join "Typ_telesa" t2 ON t1.id_typ_tel = t2.id_typ 
    where t2.nazev = druh_telesa
$$ language sql;
```

## Procedure -- Gravity Range

``` sql
CREATE OR REPLACE PROCEDURE Vrat_gravitaci(min_gravitace numeric, max_gravitace numeric)
...
```

## Trigger

Trigger for logging inserts into the `teleso_action` table.

## Transactions

Example transaction that subtracts diameter from one planet and adds it
to another.

## Users and Roles

Examples of creating users, assigning roles, granting and revoking
privileges.

## Locking

Examples of table locking modes (SHARE MODE, ACCESS EXCLUSIVE MODE).

## ORM (Object Relational Mapping)

ORM implementation using **SQLAlchemy** and **psycopg2** is available in
the file **"orm.py"**.

The Python code defines:

-   `Teleso` model
-   `Teleso_action` model
-   Database connection
-   Insert operations
-   Transaction operations
-   Logging system
