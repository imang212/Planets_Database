<p align="left">
  <img src="https://img.shields.io/badge/Database-PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white" />
  <img src="https://img.shields.io/badge/Language-SQL-orange?style=for-the-badge" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Education-freeCodeCamp-blue?style=for-the-badge&logo=freecodecamp" />
</p>

# 🌌 Kosmická databáze
>Tento projekt je komplexní systém pro správu relačních databází (RDBS) navržený pro ukládání a analýzu astronomických dat. Obsahuje robustní schéma pro nebeská tělesa (planety, hvězdy, měsíce) včetně jejich fyzikálních vlastností, chemického složení a historie objevů.

**Diagram databáze:**
```mermaid
erDiagram
    Teleso ||--o{ Vzdalenost : "id_tel"
    Teleso ||--o{ Slozeni : "id_tel"
    Teleso ||--o{ Objev : "id_tel"
    Teleso ||--o{ Typ_telesa : "je typu"
    Prvky ||--o{ Slozeni : "id_prv"
    Slouceniny ||--o{ Slozeni : "id_slouc"
    Prvky ||--o{ Slouceniny : "tvori"
    Objevitel ||--o{ Objev : "id_jme"
    Typ_telesa ||--o{ Typy_hvezd : "specifikuje"
    Typ_telesa ||--o{ Typy_planet : "specifikuje"
    Teleso {
        int id_tel PK
        string nazev
        string symbol
        int id_typ_tel FK
        int prumer_km
        int hmotnost_kg
        float hustota_gcm3
        float gravitace_ms2
        int min_teplota_K
        int prum_teplota_K
        int max_teplota_K
        int rychlost_rotace_kmh
        int perioda_d
        int id_mat_hve FK
        int id_pla FK
    }
    Vzdalenost {
        int id_vzd PK
        float vzd_od_zeme_AU
        float vzd_od_slunce_min_AU
        float vzd_od_slunce_max_AU
        int id_tel FK
    }
    Slozeni {
        int id_pla PK
        int id_prv FK
        int id_slouc FK
        float vyskyt_pct
    }
    Prvky {
        int id_prv PK
        string nazev
        string zkratka
        int protonove_cislo
        float relativni_atomova_hmotnost
        float elektronegativita
        string skupina
    }
    Slouceniny {
        int id_slouc PK
        string nazev
        string zkratka
        int id_prv1 FK
        int pocet_molekul_1
        int id_prv2 FK
        int pocet_molekul_2
    }
    Objev {
        int id_obj PK
        string objevitel
        int id_pla FK
        date datum_objevu
        int id_jme FK
    }
    Objevitel {
        int id_jme PK
        string jmeno
        string prijmeni
        date datum_narozeni
        string zeme_narozeni
        string misto_narozeni
        string puvod
    }
    Typ_telesa {
        int id_typ PK
        string nazev
        int id_hve FK
        int id_pla FK
    }
    Typy_hvezd {
        int id_hve PK
        string typ
        string spektralni_trida
        string barva
        int teplota_K
        float zastoupeni_pct
        int zivotnost_mil_let
    }
    Typy_planet {
        int id_pla PK
        string typ
    }
```

Model databáze vytvoření pomocí DBeaver.

### Instalace
Ujistěte se, že máte v systému nainstalovaný Python 3.11+ a PostreSQL (server)

Nejprve naklonujte repozitář a nainstalujte potřebné knihovny:
```bash
git clone https://github.com/imang212/Planets_Database.git
cd Planets_Database

pip install sqlalchemy psycopg2
```
>Poznámka: psycopg2 slouží jako adaptér pro propojení Pythonu s PostgreSQL.

### __Načtení databáze__

Databázi můžete načíst pomocí přiloženého souboru "planets_postgre_initialize.sql" v programech **pgAdmin** nebo **DBeaver**. Jednoduše zkopírujte kód do své PostgreSQL databáze a spusťte jej jako skript.
>**Poznámka:** Tento skript je kompatibilní pouze s PostgreSQL.

Případně můžete spustit inicializační skript databáze přímo v terminálu (bash):
```bash
sql -U postgres < planets_postgre_initialize.sql
```

### Příkazy
A teď se pojďme podívat na příkazy, které jsem udělal v rámci seminární práce na předmět RDBS(Relační databázové systémy). Jsou uloženy v souboru **"planets_commands_postgre.sql**"

__SELECT pro výpočet průměrné počtu záznamů na tabulku__
```sql
SELECT ROUND(AVG(pocet_zaznamu),0) AS "Průměrný počet záznamů na jednu tabulku"
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
) --vyšlo mi 28
```
__SELECT s vnořeným selectem__
```sql
SELECT nazev AS "Název tělesa",
1 + (SELECT count(*) FROM "Teleso" WHERE "hmotnost_(kg)" > t."hmotnost_(kg)") AS "Pořadí největší hmotnosti" 
FROM "Teleso" t
ORDER BY "Pořadí největší hmotnosti";
```
__SELECT s analytickou funkcí__
```sql
SELECT t3.typ AS "Druh tělesa", CONCAT(ROUND(AVG(t1."prumer_(km)")::NUMERIC,0),' ','km') AS "Průměrný průměr těles"
FROM ("Teleso" t1 JOIN "Typ_telesa" t2 ON t1.id_typ_tel = t2.id_typ) 
LEFT JOIN "Typy_planet" t3 ON t2.id_pla = t3.id_pla
WHERE t2.id_pla IS NOT NULL
GROUP BY t3.typ 
ORDER BY AVG(t1."prumer_(km)") DESC
LIMIT 4
```
__SELECT s hiearchií SELF_JOIN__

Zde jsem udělal rekurzivní SELECT, kde každá planeta má přizazený svůj měsíc nebo měsíce.
```sql
with recursive dedicnost_planet AS(
  SELECT t.id_pla, (SELECT nazev FROM "Teleso" s WHERE s.id_tel = t.id_pla) AS "název planety",
  t.id_tel, t.nazev as "název měsíce"
  FROM "Teleso" t 
  WHERE t.id_pla IS NOT NULL
  UNION 
  SELECT t.id_pla, (SELECT nazev FROM "Teleso" s WHERE s.id_tel = t.id_pla) AS "název planety",
  t.id_tel, t.nazev as "název měsíce" 
  FROM "Teleso" t 
  INNER JOIN dedicnost_planet d ON d.id_pla = t.id_tel
)
SELECT * FROM dedicnost_planet ORDER BY id_pla ASC;
```
Rekurzivní SELECT, kde každá hvězda má svoje těleso.
```sql
with recursive dedicnost_hvezd AS(
  SELECT t.id_mat_hve, (SELECT nazev FROM "Teleso" s WHERE s.id_tel = t.id_mat_hve) AS "název hvězdy",
  t.id_tel, t.nazev 
  FROM "Teleso" t 
  WHERE id_mat_hve IS NOT NULL
  UNION 
  select t.id_mat_hve, (SELECT nazev FROM "Teleso" s WHERE s.id_tel = t.id_mat_hve) AS "název hvězdy",
  t.id_tel, t.nazev 
  FROM "Teleso" t 
  INNER JOIN dedicnost_hvezd d ON d.id_mat_hve = t.id_tel
)
SELECT * FROM dedicnost_hvezd ORDER BY id_tel ASC;

```

__View__

Přehled o tělesech v databázi.
```sql
CREATE OR REPLACE VIEW Telesa_view AS
SELECT t1.nazev AS "název tělesa", t1.symbol AS "symbol tělesa", 
CONCAT(t1."hmotnost_(kg)",' kg') AS "hmotnost tělesa", 
CONCAT(ROUND(t1."prumer_(km)"::numeric,0),' km') AS "průměr tělesa",  
t2.objevitel AS "Kdo objevil", t3.nazev AS "typ tělesa", 
CONCAT_WS(' ',t5.typ,t4.typ) AS "druh" 
FROM ("Teleso" t1 JOIN "Objev" t2 ON t1.id_tel = t2.id_pla JOIN "Typ_telesa" t3 ON t1.id_typ_tel = t3.id_typ) 
LEFT JOIN "Typy_planet" t4 ON t3.id_pla = t4.id_pla
LEFT JOIN "Typy_hvezd" t5 ON t3.id_hve = t5.id_hve
ORDER BY id_tel;
```
__INDEX__

Nejdříve změřím normální čas potřebný pro daný select pomocí příkazu explain analyse.
```sql
explain analyse SELECT t3.typ AS "typ planety",
t3.id_pla AS "ID typu planety",
t1.nazev AS "název", 
t1.id_tel AS "ID planety"
FROM ("Teleso" t1 JOIN "Typ_telesa" t2 ON t1.id_typ_tel = t2.id_typ) 
LEFT JOIN "Typy_planet" t3 ON t2.id_pla = t3.id_pla
WHERE t3.id_pla IS NOT NULL
ORDER BY t3.id_pla ASC
```
Vytvořím si první index na id typu tělesa v tabulce Teleso, aby se mezi nimi dalo ryhleji prohledávat.
```sql
CREATE INDEX index1 ON "Teleso"("id_typ_tel");
```
Potom zase zkontroluji čas příkazu a můžu vidět, že příkaz se provedl rychleji.
```sql
explain analyse SELECT t3.typ AS "typ planety",
t3.id_pla AS "ID typu planety",
t1.nazev AS "název", 
t1.id_tel AS "ID planety"
FROM ("Teleso" t1 JOIN "Typ_telesa" t2 ON t1.id_typ_tel = t2.id_typ) 
LEFT JOIN "Typy_planet" t3 ON t2.id_pla = t3.id_pla
WHERE t3.id_pla IS NOT NULL
ORDER BY t3.id_pla asc
```
Dalá si udělám index na dva sloupce u tabulky Typ_telesa
```sql
CREATE INDEX index2 ON "Typ_telesa"("id_typ","id_pla");
```
A zase se nám příkaz o něco zrychlil.

__Funkce vracející průměrnou hmotnost těles podle jejich druhu(skupiny)__
```sql
CREATE OR REPLACE FUNCTION Vrat_prumernou_hmotnost(druh_telesa text)
  returns Table(hmotnost text) AS $$
    select concat(AVG(t1."hmotnost_(kg)"::real),' kg') as "Průměrná hmotnost" 
    from "Teleso" t1 join "Typ_telesa" t2 ON t1.id_typ_tel = t2.id_typ 
    where t2.nazev = druh_telesa
$$ language sql;
```
Nyní si funkci vyzkouším měsíce
```sql
SELECT Vrat_prumernou_hmotnost('měsíc');
```
A ještě na normální planety
```sql
SELECT Vrat_prumernou_hmotnost('planeta');
```

__Procedura__

Zde mám proceduru, která nám vrátí tabulku s typy, názvy a gravitací jednotlivých těles.
```sql
CREATE OR REPLACE PROCEDURE Vrat_gravitaci(min_gravitace numeric, max_gravitace numeric) 
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
```
```sql
BEGIN;
CALL Vrat_gravitaci(0,2); --nejdřív tělesa, která mají gravitaci od 0 do 2 m/S
ROLLBACK; -- při chybě zavolám rollback
COMMIT;
```
```sql
BEGIN;
CALL Vrat_gravitaci(20,1000); -- potom tělesa, která mají vyšší gravitaci než 20 m/s
ROLLBACK; -- při chybě zavolám rollback
COMMIT;
```
__Trigger__

Abych mohl udělat trigger, tak nejdříve musím mít tabulku pro ukládání záznamů.
```sql
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
```
Teďka si nadefinuji funkci, kterou bude používat trigger.
```sql
-- funkce kterou použije trigger pro vložení
CREATE OR REPLACE FUNCTION teleso_insert()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO Teleso_action(id_tel,nazev,datum,akce,user_)
  VALUES (NEW.id_tel,NEW.nazev,CURRENT_TIMESTAMP,'INSERT',SESSION_USER);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```
Nakonec si vytvořím trigger, který použije funkci teleso_insert().
```sql
CREATE TRIGGER teleso_insert_after
AFTER INSERT ON "Teleso"
FOR EACH ROW
EXECUTE FUNCTION teleso_insert()
```
Vyzkouším, jestli to funguje.
```sql
INSERT INTO "Teleso" VALUES (36,'Alpha Centauri A',Null, 3, 1.2175*695700, 1.078*2*POWER(10,30), 1.51 , 42.17, NULL,5.804,NULL,9720, 28.3,NULL,NULL);
```
```sql
DELETE FROM "Teleso" WHERE id_tel = 36;
```
__Transakce__

Transakce, která změní odečte průměr z jedné planety a přičte ho ke druhé.
```sql
CREATE OR REPLACE PROCEDURE zmen_prumer_planety(nazev1 VARCHAR, nazev2 VARCHAR, o_kolik NUMERIC)
AS $$
DECLARE
  aktualni_prumer NUMERIC; --uložím si průměr tělesa do proměnné
BEGIN -- začnu transakci
  -- vezmu si průměr tělesa  z kterýho ho budu brát
  SELECT "prumer_(km)" INTO aktualni_prumer 
  FROM "Teleso" 
  WHERE nazev = nazev1;
    
  -- vyvolám výjimku, když těleso bude mít menší průměr než hodnota, kterou odečítám
  IF aktualni_prumer < o_kolik THEN 
    RAISE EXCEPTION 'Těleso % má malý průměr.', nazev1;
  ELSE
    END IF;
  
  --odečteme prumer
  UPDATE "Teleso"
  SET "prumer_(km)" = "prumer_(km)" - o_kolik
  WHERE nazev = nazev1;
  
  --přičteme prumer
  UPDATE "Teleso"
  SET "prumer_(km)" = "prumer_(km)" + o_kolik
  WHERE nazev = nazev2;
  

  -- vypíšu poznámku, že převod proběhl v pořádku
  RAISE NOTICE 'Převod průměru byl dokončen.';
-- když nastane nějaká chyba vyvolám výjimku a transakci vrátím nazpátek
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Transakce selhala: %', SQLERRM;
  RAISE;
END;
$$ LANGUAGE plpgsql;
```
Teď to vyzkouším.
```sql
SELECT id_tel, nazev, concat(ROUND("prumer_(km)"::numeric,0),' km') FROM "Teleso" WHERE nazev IN ('Jupiter','Merkur');
```
Následující transakce si spouštím pouze po řádcích.

Začnu transakci pomocí BEGIN
```sql
BEGIN;
```
Zavolám transakci nebo víc transakcí pomocí CALL
```sql
CALL zmen_prumer_planety('Jupiter','Merkur',100000);
```
Když si to rozmslím, tak transakci mohu vrátit nazpátek pomocí ROLLBACK.
```sql
ROLLBACK; -- při chybě zavolám rollback
```
Pomocí COMMIT transakci dokončím.
```sql
COMMIT;
```
Teď si tu transakci ověřím, tak že si vypíšu průměr převáděných těles.
```sql
SELECT id_tel, nazev, concat(ROUND("prumer_(km)"::numeric,0),' km') FROM "Teleso" WHERE nazev IN ('Jupiter','Merkur');
```
Obrácená transakce.
```sql
BEGIN;
CALL zmen_prumer_planety('Merkur','Jupiter',100000);
ROLLBACK;
COMMIT;
```
SELECT id_tel, nazev, concat(ROUND("prumer_(km)"::numeric,0),' km') FROM "Teleso" WHERE nazev IN ('Jupiter','Merkur');
```
__User__

Zde mám píklad vytvoření uživatele.
```sql
CREATE USER patrik WITH PASSWORD 'patrik123456';
```
Přidělení práva uživateli, aby se mohl připojit.
```sql
GRANT CONNECT ON DATABASE postgres TO patrik;
```
Vytvoření role.
```sql
CREATE ROLE selecting_role WITH LOGIN PASSWORD 'heslo';

GRANT USAGE, CREATE ON SCHEMA public TO selecting_role;
--GRANT SELECT ON TABLE "Planety" TO patrik;
GRANT SELECT ON TABLE "Teleso" TO selecting_role;
```
Přidělení role uživateli.
```sql
GRANT selecting_role TO patrik;
```
Přidělování práv.
```sql
GRANT SELECT, INSERT, UPDATE ON TABLE "Teleso","teleso_action" TO selecting_role;
GRANT USAGE, SELECT ON SEQUENCE teleso_action_id_seq TO selecting_role;
```
Odebírání práv.
```sql
REVOKE ALL PRIVILEGES ON TABLE "Teleso","teleso_action" FROM selecting_role;
REVOKE USAGE, CREATE ON SCHEMA public FROM selecting_role;
REVOKE USAGE, SELECT ON SEQUENCE teleso_action_id_seq FROM selecting_role;
REVOKE ALL PRIVILEGES ON DATABASE postgres FROM patrik;
```
Smazání uživatele a role.
```sql
DROP USER patrik;
DROP ROLE selecting_role;
```
__Lock__

Zamknu si tabulku do nějakého módu třeba při nějaké práci, abych mohl vrátit všechny operace s tabulkou, které proběhly v daném úseku nazpátek.
```sql
BEGIN WORK;
LOCK TABLE "Teleso" IN SHARE MODE; --zamknu tabulku, když jdu dělat konkrétní operaci
SELECT * FROM "Teleso" WHERE id_tel = 1;
ROLLBACK;
COMMIT WORK;
UPDATE "Teleso" SET "prumer_(km)" = "prumer_(km)" - 100000 WHERE id_tel = 1;
```
Zamknu tabulku do exclusive access modu
```sql
BEGIN WORK;
LOCK TABLE "Teleso" in ACCESS EXCLUSIVE MODE;
SELECT * FROM "Teleso" WHERE id_tel = 1;
UPDATE "Teleso" SET "prumer_(km)" = "prumer_(km)" + 100000 WHERE id_tel = 1;
ROLLBACK;
COMMIT WORK;
```
Odebrání připojení k databázi z veřejného serveru.
```sql
-- odeberu
REVOKE CONNECT ON DATABASE postgres FROM PUBLIC;
-- znovu přidělím
GRANT CONNECT ON DATABASE postgres TO PUBLIC;
```
__ORM(Object relation mapping)__
Tento skript používá SQLAlchemy a Psycopg2 v Pythonu.
Kód se nachází v souboru "orm_script.py".

**Aktualizujte připojovací řetězec ve skriptu tak, aby byl identický s údaji ve vaší databázi.**:
```bash
# Formát: postgresql://username:<password>@localhost:5432/<database_name>
DATABASE_URL = "postgresql://<username>:<your_password>@localhost:5432/<database_name>"
```

**Spuštění skriptu.:**
```bash
python orm_script.py
```

**Vlastnosti:**
- Modely databázových tabulek založené na třídách.
- Správa relací.
- Funkce pro vkládání objektů, změnu hodnot pomocí transakcí a zobrazení dat.

```python
from sqlalchemy import create_engine, Column, Integer, String, Numeric, DateTime, func
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from datetime import datetime

Base = declarative_base()

#nejdřív si uděláme modely
class Teleso(Base):
    __tablename__ = 'Teleso'
    __table_args__ = {"schema": "public"}

    id = Column(Integer, primary_key=True, name="id_tel")
    name = Column(String(25), nullable=False, unique=True, name="nazev")
    symbol = Column(String(5), nullable=True)
    id_type_obj = Column(Integer, nullable=False, name="id_typ_tel")
    mean = Column(Numeric, nullable=False, name="prumer_(km)")
    mass = Column(Numeric, nullable=False, name="hmotnost_(kg)")
    density = Column(Numeric, nullable=True, name="hustota_(g/cm^(3))")
    gravity = Column(Numeric, nullable=False, name="gravitace_(m/s^(2))")
    min_t = Column(Numeric, nullable=True, name="min_teplota_(K)")
    mean_t = Column(Numeric, nullable=True, name="prum_teplota_(K)")
    max_t = Column(Numeric, nullable=True, name="max_teplota_(K)")
    rotation = Column(Numeric, nullable=True, name="rychlost_rotace_(km/h)")
    period = Column(Numeric, nullable=False, name="perioda_(d)")
    id_mother_star = Column(Integer, nullable=False, name="id_mat_hve")
    id_mother_planet = Column(Integer, nullable=False, name="id_pla")
    
class Teleso_action(Base):
    __tablename__ = 'teleso_action'
    __table_args__ = {"schema": "public"}

    id = Column(Integer, primary_key=True, autoincrement=True)
    id_obj = Column(Integer, nullable=False,name="id_tel")
    name = Column(String(25), nullable=False, name="nazev")
    date = Column(DateTime, default=func.now(), name="datum")
    action = Column(String(6), nullable=False, name="akce")
    user_ = Column(String(30), nullable=False)

#připojení k databázi
def Connection(username, password):
    global engine
    engine = create_engine(f'postgresql://{username}:{password}@localhost:5432/postgres')
    print('connected')

# Vytvoření tabulek
def create_tables(engine):
    Base.metadata.create_all(engine)
    print('Tables created')

#vytvoření session
def create_session(engine):
    global session
    Session = sessionmaker(bind=engine)
    session = Session()

def Count_objects():
    try:
        objects = session.query(Teleso).all()
    finally:
        session.close()
        return len(objects)
    
def Insert_object(name, symbol, id_type_obj, mean, mass, density, gravity, min_t, mean_t, max_t, rotation, period, id_mother_star, id_mother_planet, user):
    try:
        teleso = Teleso(id=Count_objects()+1, name=name, symbol=symbol, id_type_obj=id_type_obj, mean=mean, mass=mass, density=density, 
                        gravity=gravity, min_t=min_t, mean_t=mean_t, max_t=max_t, rotation=rotation, period=period, id_mother_star=id_mother_star, id_mother_planet=id_mother_planet)
        session.add(teleso)
        session.commit()

        teleso_action = Teleso_action(id_obj=teleso.id, name=teleso.name, date = datetime.now(), action='INSERT',user_=user)
        
        session.add(teleso_action)
        session.commit()
        print("New object added to table")
    except Exception as e:
        session.rollback()
        print(f"Error: {e}")
    finally:
        session.close()

def Show_objects():
    try:
        objects = session.query(Teleso).all()
        for object in objects:
            print(f"Object: {object.name}, Mean: {round(object.mean,0)} km")
    finally:
        session.close()

def Mean_change(name1, name2, count, user):
    try:
        obj1 = session.query(Teleso).filter(Teleso.name == name1).first()
        obj2 = session.query(Teleso).filter(Teleso.name == name2).first()

        if not obj1 or not obj2: raise ValueError("Object doesn't exists")
        if obj1.mean < count: raise ValueError(f"Object {obj1} have small mean.")

        obj1.mean -= count
        obj2.mean += count

        action1 = Teleso_action(id_obj=obj1.id, name=obj2.name, date = datetime.now(), action='UPDATE', user_=user)
        action2 = Teleso_action(id_obj=obj2.id, name=obj2.name, date = datetime.now(), action='UPDATE', user_=user)

        session.add(action1)
        session.add(action2)
        session.commit()
        print("Mean transaction has been completed.")

    except Exception as e:
        session.rollback()
        print(f"Chyba: {e}")
    finally:
        session.close()

# Příklad použití
Connection('postgres','patrik123')
create_tables(engine)
create_session(engine)

#výpis těles a jejich průměrů
print(Show_objects())
#vložení objektu do databáze
#Insert_object(name='Mars2', symbol=None, id_type_obj=9, mean=6792.4, mass=6.4185*pow(10,23), density=3.933, gravity=3.69, min_t=130, mean_t=210, max_t=308, rotation=868.22, period=1.026, id_mother_star=1, id_mother_planet=None, user='patricek')
#print(Show_objects())
#převod průměru
#Mean_change('Jupiter', 'Merkur', 100000, 'patricek')
#print(Show_objects())
#Mean_change('Merkur', 'Jupiter', 100000, 'patricek')
#print(Show_objects())
```
