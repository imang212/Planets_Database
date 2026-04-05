CREATE OR REPLACE VIEW Průměry_těles AS
SELECT teleso.nazev,CONCAT(ROUND(teleso.`prumer_(km)`,0),' ','km') AS 'průměr planety', typy_planet.typ AS 'typ planety' 
FROM (teleso JOIN typ_telesa ON teleso.id_typ_tel = typ_telesa.id_typ) 
LEFT JOIN typy_planet ON typ_telesa.id_pla = typy_planet.id_pla
WHERE typ_telesa.id_pla IS NOT NULL
ORDER BY teleso.`prumer_(km)` DESC;

CREATE OR REPLACE VIEW Objevy AS
SELECT teleso.nazev, DATE_FORMAT(objev.datum_objevu,'%d.%m.%Y') AS 'datum objevu', CONCAT(objevitel.jmeno,' ',objevitel.prijmeni) AS 'Jméno objevitele', objevitel.puvod FROM (teleso JOIN objev ON teleso.id_tel = objev.id_pla) JOIN objevitel ON objev.id_jme = objevitel.id_jme
WHERE teleso.id_typ_tel = 12
ORDER BY objev.datum_objevu ASC;

CREATE OR REPLACE VIEW Telesa_view AS
SELECT teleso.nazev AS 'název tělesa', teleso.symbol AS 'symbol tělesa', CONCAT(teleso.`hmotnost_(kg)`,' kg') AS 'hmotnost tělesa', CONCAT(ROUND(teleso.`prumer_(km)`,0),' km') AS 'průměr tělesa',  objev.objevitel AS 'Kdo objevil', typ_telesa.nazev AS 'typ tělesa', CONCAT_WS(' ',typy_hvezd.typ,typy_planet.typ) AS 'druh' 
FROM (teleso JOIN objev ON teleso.id_tel = objev.id_pla JOIN typ_telesa ON teleso.id_typ_tel = typ_telesa.id_typ) 
LEFT JOIN typy_planet ON typ_telesa.id_pla = typy_planet.id_pla
LEFT JOIN typy_hvezd ON typ_telesa.id_hve = typy_hvezd.id_hve
ORDER BY id_tel;

CREATE OR REPLACE VIEW Slozeni_mesice AS
SELECT CONCAT(slozeni.`vyskyt_(%)`,' %') AS 'Výskyt', CONCAT_WS('',prvky.nazev,slouceniny.nazev) AS 'Název látky'
FROM teleso 
JOIN slozeni ON teleso.id_tel = slozeni.id_pla
LEFT JOIN slouceniny ON slozeni.id_slouc = slouceniny.id_slouc
LEFT JOIN prvky ON slozeni.id_prv = prvky.id_prv
WHERE teleso.nazev = 'Měsíc';

CREATE OR REPLACE VIEW Nejvyssi_obsah_dusiku AS
SELECT CONCAT(slozeni.`vyskyt_(%)`,' %') AS 'Výskyt', CONCAT_WS('',prvky.nazev,slouceniny.nazev) AS 'Náze látky', teleso.nazev AS 'Název planety'
FROM teleso 
JOIN slozeni ON teleso.id_tel = slozeni.id_pla
LEFT JOIN slouceniny ON slozeni.id_slouc = slouceniny.id_slouc
LEFT JOIN prvky ON slozeni.id_prv = prvky.id_prv
WHERE prvky.id_prv = 7
ORDER BY slozeni.`vyskyt_(%)` DESC;

CREATE OR REPLACE VIEW Planety_podle_vzdalenosti AS
SELECT teleso.nazev,CONCAT(vzdalenost.`vzd_od_slunce_max_(AU)`,' AU') AS 'vzdálenost od slunce', typy_planet.typ AS 'Druh tělesa'
FROM (teleso JOIN vzdalenost ON teleso.id_tel = vzdalenost.id_tel JOIN typ_telesa ON teleso.id_typ_tel = typ_telesa.id_typ)
LEFT JOIN typy_planet ON typ_telesa.id_pla = typy_planet.id_pla
WHERE typ_telesa.nazev = 'planeta'
ORDER BY vzdalenost.`vzd_od_slunce_max_(AU)` DESC;

CREATE OR REPLACE VIEW Nejvyšší_teploty_těles AS
SELECT teleso.nazev,CONCAT(ROUND(teleso.`max_teplota_(K)`-273.15,0),' °C') AS 'Teplota tělesa', CONCAT_WS('',typy_planet.typ,typy_hvezd.typ) AS 'tělesa' 
FROM (teleso JOIN typ_telesa ON teleso.id_typ_tel = typ_telesa.id_typ) 
LEFT JOIN typy_planet ON typ_telesa.id_pla = typy_planet.id_pla
LEFT JOIN typy_hvezd ON typ_telesa.id_hve = typy_hvezd.id_hve
WHERE teleso.`max_teplota_(K)` IS NOT NULL
ORDER BY teleso.`max_teplota_(K)` DESC;

CREATE OR REPLACE VIEW Tělesa_podle_gravitace AS
SELECT teleso.nazev,CONCAT(ROUND(teleso.`gravitace_(m/s^(2))`,2),' m/s^2') AS 'Gravitace tělesa', CONCAT_WS('',typy_planet.typ,typy_hvezd.typ) AS 'tělesa' 
FROM (teleso JOIN typ_telesa ON teleso.id_typ_tel = typ_telesa.id_typ) 
LEFT JOIN typy_planet ON typ_telesa.id_pla = typy_planet.id_pla
LEFT JOIN typy_hvezd ON typ_telesa.id_hve = typy_hvezd.id_hve
WHERE typ_telesa.id_typ IS NOT NULL
ORDER BY teleso.`gravitace_(m/s^(2))` DESC;

