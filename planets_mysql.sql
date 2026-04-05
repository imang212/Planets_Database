#MySQL
CREATE DATABASE IF NOT EXISTS planety DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_czech_ci; USE planety;

DROP TABLE IF EXISTS Typy_hvezd;
CREATE TABLE IF NOT EXISTS Typy_hvezd
(
    id_hve INT PRIMARY KEY AUTO_INCREMENT,
    typ char(30) NOT NULL,
    spektralni_trida char(1) NOT NULL,
    barva char(12) NOT NULL,
    `teplota_(K)` int(5) NOT NULL,
    `zastoupení_(%)` DECIMAL(7,5),
    `zivotnost_(mil._let)` int(6)
);

DROP TABLE IF EXISTS Typy_planet;
CREATE TABLE IF NOT EXISTS Typy_planet
(
    id_pla INT PRIMARY KEY AUTO_INCREMENT,
    typ char(30) NOT NULL
);

DROP TABLE IF EXISTS Typ_telesa;
CREATE TABLE IF NOT EXISTS Typ_telesa
(
    id_typ INT PRIMARY KEY AUTO_INCREMENT,
    nazev char(20) NOT NULL,
    id_hve INT,
    id_pla INT,
    CONSTRAINT fk_typ_hve FOREIGN KEY (id_hve) REFERENCES Typy_hvezd(id_hve),
    CONSTRAINT fk_typ_pla FOREIGN KEY (id_pla) REFERENCES Typy_planet(id_pla)
);

SET foreign_key_checks = 0;
DROP TABLE IF EXISTS Teleso;
SET foreign_key_checks = 1;
CREATE TABLE IF NOT EXISTS Teleso
(
    id_tel INT PRIMARY KEY AUTO_INCREMENT,
    nazev char(25) NOT NULL,
    symbol char(5),
    id_typ_tel INT NOT NULL,
    `prumer_(km)` FLOAT(3) NOT NULL,
    `hmotnost_(kg)` FLOAT(4) NOT NULL,
    `hustota_(g/cm^(3))` DECIMAL(6,4) NOT NULL,
    `gravitace_(m/s^(2))` FLOAT(3) NOT NULL,
    `min_teplota_(K)` INT(4),
    `prum_teplota_(K)` INT(4),
    `max_teplota_(K)` INT(4),
    `rychlost_rotace_(km/h)` FLOAT(3),
    `perioda_(d)` FLOAT(5) NOT NULL,
    id_mat_hve INT,
    id_pla INT,
    CONSTRAINT fk_typ_tel FOREIGN KEY (id_typ_tel) REFERENCES Typ_telesa(id_typ),
    CONSTRAINT fk_mat_hve FOREIGN KEY (id_mat_hve) REFERENCES Teleso(id_tel),
    CONSTRAINT fk_mesic FOREIGN KEY (id_pla) REFERENCES Teleso(id_tel)
);

DROP TABLE IF EXISTS Vzdalenost;
CREATE TABLE IF NOT EXISTS Vzdalenost
(
    id_vzd INT PRIMARY KEY AUTO_INCREMENT,
    `vzd_od_zeme_(AU)` FLOAT(3),
    `vzd_od_slunce_min_(AU)` FLOAT(3),
    `vzd_od_slunce_max_(AU)` FLOAT(3),
    id_tel INT NOT NULL,
    CONSTRAINT fk_tel_vzd FOREIGN KEY (id_tel) REFERENCES teleso(id_tel)
);

DROP TABLE IF EXISTS Objevitel;
CREATE TABLE IF NOT EXISTS Objevitel
(
    id_jme INT PRIMARY KEY AUTO_INCREMENT,
    jmeno char(15) NOT NULL,
    prijmeni char(15) NOT NULL,
    datum_narozeni date NOT NULL,
    zeme_narozeni char(20) NOT NULL,
    misto_narozeni char(20) NOT NULL,
    puvod char(20) NOT NULL
);

DROP TABLE IF EXISTS Objev;
CREATE TABLE IF NOT EXISTS Objev
(
    id_obj INT PRIMARY KEY,
    datum_objevu date,
    objevitel char(30) NOT NULL,
    id_pla INT NOT NULL,
    id_jme INT,
    CONSTRAINT fk_planeta FOREIGN KEY (id_pla) REFERENCES Teleso(id_tel),
    CONSTRAINT fk_jmeno FOREIGN KEY (id_jme) REFERENCES Objevitel(id_jme)
);

DROP TABLE IF EXISTS Prvky;
CREATE TABLE IF NOT EXISTS Prvky
(
    id_prv INT PRIMARY KEY,
    nazev char(20) NOT NULL,
    zkratka char(2) NOT NULL,
    protonove_cislo int(3) NOT NULL,
    relativni_atomova_hmotnost decimal(7,4) NOT NULL,
    elektronegativita decimal(5,4),
    skupina char(3) NOT NULL
);

DROP TABLE IF EXISTS Slouceniny;
CREATE TABLE IF NOT EXISTS Slouceniny
(
    id_slouc INT PRIMARY KEY,
    nazev char(25) NOT NULL,
    zkratka char(4) NOT NULL,
    id_prv1 INT NOT NULL,
    pocet_molekul_1 INT(1) NOT NULL,
    id_prv2 INT NOT NULL,
    pocet_molekul_2 INT(1) NOT NULL,
    CONSTRAINT fk_prv1 FOREIGN KEY (id_prv1) REFERENCES Prvky(id_prv),
    CONSTRAINT fk_prv2 FOREIGN KEY (id_prv2) REFERENCES Prvky(id_prv)
);

DROP TABLE IF EXISTS Slozeni;
CREATE TABLE IF NOT EXISTS Slozeni
(
    id_pla INT,
    id_prv INT,
    id_slouc INT,
    `vyskyt_(%)` FLOAT(5) NOT NULL,
    CONSTRAINT fk_pla_sloz FOREIGN KEY (id_pla) REFERENCES Teleso(id_tel),
    CONSTRAINT fk_prvek FOREIGN KEY (id_prv) REFERENCES Prvky(id_prv),
    CONSTRAINT fk_sloucenina FOREIGN KEY (id_slouc) REFERENCES Slouceniny(id_slouc)
);

INSERT INTO Typy_hvezd(id_hve,typ,spektralni_trida,barva,`teplota_(K)`,`zastoupení_(%)`,`zivotnost_(mil._let)`) VALUES
(1,'Červená hvězda','M','červená',3200,80,200000),
(2,'Oranžová hvězda','K','oranžová',4500,8,50000),
(3,'Žlutá hvězda','G','žlutá',5700,3.5,10000),
(4,'Bílá hvězda','F','žlutobílá',6500,2,3000),
(5,'Bílomodrá hvězda','A','bílomodrá',8500,0.7,1000),
(6,'Modrobílá hvězda','B','modrobílá',20000,0.1,100),
(7,'Modrý veleobr','O','modrá',40000,0.00001,10);

INSERT INTO Typy_planet(id_pla,typ) VALUES (1,'kamenná planeta'),(2,'plynný obr'),(3,'trpasličí planeta'),(4,'kamenný měsíc'),
(5,'meteorit'),(6,'kometa');

INSERT INTO Typ_telesa(id_typ,nazev,id_hve,id_pla) VALUES (1,'hvězda',1,NULL),(2,'hvězda',2,NULL),(3,'hvězda',3,NULL),(4,'hvězda',4,NULL),
(5,'hvězda',5,NULL),(6,'hvězda',6,NULL),(7,'hvězda',7,NULL),(8,'červený trpaslík',1,NULL),
(9,'planeta',NULL,1),(10,'planeta',NULL,2),(11,'planeta',NULL,3),(12,'měsíc',NULL,4),(13,'planetka',NULL,5),(14,'planetka',NULL,6);

INSERT INTO Teleso
(id_tel,nazev,symbol,id_typ_tel,
`prumer_(km)`,`hmotnost_(kg)`,`hustota_(g/cm^(3))`,`gravitace_(m/s^(2))`,`min_teplota_(K)`,`prum_teplota_(K)`,`max_teplota_(K)`,`rychlost_rotace_(km/h)`,`perioda_(d)`,id_mat_hve,id_pla) VALUES
(1 ,"Slunce", '☉', 3, 1392020, 1.9891*POWER(10,30), 1.408, 273.95, NULL, NULL,5780,7174,25.3800,NULL,NULL),
(2,'Merkur', '☿', 9, 4879.4, 3.302*POWER(10,23) , 5.427, 3.701, 90, 440, 700, 10.892, 58.6462, 1, NULL),
(3, 'Venuše', '♀', 9, 12103.7, 4.8685*POWER(10,24), 5.204, 8.87, NULL, 737, 773, 6.52, 243.0185,1,NULL),
(4, 'Země', '🜨', 9, 12756.270, 5.9736*POWER(10,24), 5.515, 9.81, 184, 287, 329, 1674.4, 1, 1, NULL),
(5, 'Měsíc', '☽', 12, 3476.2, 7.347673*POWER(10,22), 3.344, 1.622, 33,250,396, 16.657, 30, 1, 4),
(6, 'Mars', '♂', 9, 6792.4, 6.4185*POWER(10,23), 3.933, 3.69, 130, 210, 308, 868.22, 1.026, 1, NULL),
(7, 'Phobos', NULL, 12, 11.08, 1.070*POWER(10,16), 1.876, 0.0084, NULL, 233, NULL, 2.138, 0.319, 1, 6),
(8, 'Deimos', NULL, 12, 12.4, 2.244*POWER(10,15), 2.247, 0.0039, NULL, 233, NULL, 1.3513, 1.263, 1, 6),

(9, 'Jupiter', '♃', 10, 142984, 1.899*POWER(10,27), 1.326, 23.12, 112, 152, NULL,45262, 4332.59,1,NULL),
(10, 'Io',NULL,12, 3643, 8.9*POWER(10,22), 3.528, 1.79, 90, 110, 130, 271, 1.769, 1, 9),
(11, 'Europa',NULL,12, 3122, 4.8*POWER(10,22), 3.01, 1.314, 50, 103, 125, 115.67, 3.55, 1, 9),
(12, 'Ganymed',NULL,12, 5262, 14.8*POWER(10,22), 1.936, 1.428, 70, 110, 152, 271, 7.154, 1, 9),
(13, 'Callisto',NULL,12, 4821, 10.8*POWER(10,22), 1.834, 1.235, 80, 134, 165, 8.204, 16.689, 1, 9),

(14, 'Saturn', '♄',10, 120536, 5.6846*POWER(10,26), 0.6873, 8.96, 93, NULL, NULL, 35532, 10757.7, 1, NULL),
(15, 'Mimas', NULL, 12, 400,0.4*POWER(10,20), 1.1501, 0.064, NULL, 64, NULL, 14.28, 0.942,1, 14),
(16, 'Enceladus', NULL, 12, 504, 1.080*POWER(10,20), 1.6097, 0.113, 33, 75, 145,null, 1.3702, 1, 14),
(17, 'Tethys', NULL, 12, 1062, 6.1749*POWER(10,20), 0.984, 0.146, NULL, 86, NULL, 11.35, 1.8878, 1, 14),
(18, 'Dione', NULL, 12, 1123, 1.1*POWER(10,21), 1.4781, 0.232, NULL, 87, NULL, NULL, 2.7369, 1, 14),
(19, 'Rhea', NULL, 12, 1527, 2.3*POWER(10,21), 1.2372, 0.262, 53, NULL, 99, 8.48, 4.518, 1, 14),
(20, 'Titan', NULL, 12, 5149, 1.35*POWER(10,23), 1.8798, 1.352, NULL, 94, null, 5.57, 15.945, 1, 14),
(21, 'Lapetus', NULL, 12, 1470, 1.8*POWER(10,21), 1.0887, 0.223, 90,NULL,130, 3.26, 79.3215, 1, 14),

(22, 'Uran', '♅', 10,   51118, 8.6832*POWER(10,25), 1.270, 8.69, 55, 68, NULL, 9315.08, 30708.16, 1, NULL),
(23, 'Miranda', NULL, 12, 235.8, 6.293*POWER(10,19), 1.148, 0.076, null, 60, 84, 6.66, 1.413, 1, 22),
(24, 'Ariel', null, 12, 578.9, 1.2331*POWER(10,21),1.517, 0.246, null, 60, 84, 5.51, 2.520, 1, 22),
(25, 'Umbriel',null,12,584.7, 1.2885*POWER(10,21), 1.539, 0.252, null, 75, 85, 4.67, 4.144, 1, 22),
(26, 'Titania', null,12,788.4,3.4550*POWER(10,21), 1.683, 0.371, 60, 70, 89, 3.64, 8.706, 1, 22),
(27, 'Oberon', null, 12, 761.4, 3.1104*POWER(10,21), 1.682, 0.358, 70, null, 80, 3.15, 12.4632, 1, 22),

(28, 'Neptun', '♆', 10, 49528, 1.0243*POWER(10,26), 1.638, 11.15, 50,53,null, 9660, 60190, 1, null),
(29, 'Triton', null, 12, 2706.8, 2.14*POWER(10,22), 2.061, 0.0779, null, 38, null, 115.67, 5.877,1,28),

(30, 'Pluto', '♇', 11, 2370, 1.305*POWER(10,22), 1.87, 0.620, 33, 44, 55, 4.666, 90306.8, 1, null),
(31, 'Charon','⚷', 12, 1212, 1.586*POWER(10,21), 1.702, 0.288, null, 53, null, 0.21, 6.3872,1,30),
(32, 'Ceres', '⚳', 11, 952, 9.5*POWER(10,20), 2.077, 0.27, null, null, null, 17.9, 1680,1,null),
(33, 'Eris',null, 11, 2326, 1.6466*POWER(10,22), 2.43, 0.082, 30, 42, 56, 3.434, 2041999, 1, null),

(34, 'Proxima Centauri',null,8, 0.104*POWER(10,6)*2, 0.24*POWER(10,30), 56.8, 5.20, null, null, 2992, 22.204, 89.8,null,null);

INSERT INTO Vzdalenost (`vzd_od_zeme_(AU)`,`vzd_od_slunce_min_(AU)`,`vzd_od_slunce_max_(AU)`,id_tel) VALUES
(1,null,null,1),(null,0.3075,0.4667,2),(null,0.7184,0.7282,3),(0,0.9833,1.0167,4),(null,1.3813,1.665,6),(null,4.9516,5.4552,9),
(null,9.0206,10.0535,14),(null,18.286,20.096,22),(null,29.766,30.441,28),(null,29.657,49.119,30),(null,2.5447,2.9873,32),
(null,38.271,67.864,33),(268521613.32, null, null, 34);

INSERT INTO Objevitel(id_jme,jmeno,prijmeni,datum_narozeni,zeme_narozeni,misto_narozeni,puvod) VALUES
(1,'Mikuláš','Koperník','1473-02-19','Polsko','Toruň','Polsko-německý'),
(2,'Galileo','Galilej','1564-02-15','Itálie','Pisa','Italský'),
(3,'Johannes','Kepler','1571-12-27','Německo','Weil der Stadt','Německý'),
(4, 'Asaph', 'Hall', '1829-10-15','USA', 'Conecticut','Americký'),
(5, 'William','Herschel', '1738-11-15', 'Svatá říše římská', 'Hanover', 'Německý'),
(6, 'Giovanni', 'Cassini', '1625-06-08','Janovská republika', 'Paříž', 'Francie'),
(7, 'Gerard','Kuiper', '1905-12-07','Nizozemsko','Tuitjenhorn','Nizozemsko-americký'),
(8, 'William','Lassell','1799-01-18','Anglický','Bolton','Anglický'),
(9, 'Clyde','Tombaugh','1906-02-04','Illinois','Streator','Americký'),
(10, 'James','Christy','1938-09-15','Wisconsin','Milwaukee','Americký'),
(11, 'Giuseppe','Piazzi','1746-07-07','Sicílie','Neapol','Římskokatolický'),
(12,'Christian','Huygens','1629-04-14','Nizozemsko','The Hague','Nizozemský'),
(13, 'Michael','E. Brown', '1965-01-05','Alabama','Huntsville','Americký');

INSERT INTO Objev(id_obj,datum_objevu, objevitel, id_pla, id_jme) VALUES
(1,null,'lidstvo',1,null),
(2,null,'Starověké civilizace',2,null),
(3,null,'Starověké civilizace',3,null),
(4,null,'lidstvo',4,null),
(5,null,'lidstvo',5,null),
(6,null,'Starověké civilizace',6,null),
(7,'1877-08-17','člověk',7,4),
(8,'1877-08-11','člověk',8,4),
(9,null,'Starověké civilizace',9,null),
(10,'1610-01-07','člověk',10,2),
(11,'1610-01-07','člověk',11,2),
(12,'1610-01-13','člověk',12,2),
(13,'1610-01-07','člověk',13,2),
(14,null,'Starověké civilizace',14,null),
(15,'1789-09-17','člověk',15,5),
(16,'1789-08-28','člověk',16,5),
(17,'1684-03-11','člověk',17,6),
(18,'1684-03-30','člověk',18,6),
(19,'1672-12-23','člověk',19,6),
(20,'1655-03-25','člověk',20,12),
(21,'1671-10-25','člověk',21,6),
(22,null,'Starověké civilizace',22,null),
(23,'1948-02-16','člověk',23,7),
(24,'1851-10-24','člověk',24,8),
(25,'1851-10-24','člověk',25,8),
(26,'1787-01-11','člověk',26,5),
(27,'1787-01-11','člověk',27,5),
(28,null,'Starověké civilizace',28,null),
(29,'1846-10-10','člověk',29,8),
(30,'1930-02-18','člověk',30,9),
(31,'1978-06-22','člověk',31,10),
(32,'1801-01-01','člověk',32,11),
(33, '2005-01-05','člověk',33,13),
(34, null, 'Starověké civilizace',34,null);

INSERT INTO Prvky(id_prv,nazev, zkratka, protonove_cislo, relativni_atomova_hmotnost, elektronegativita, skupina) VALUES 
(1, 'Vodík', 'H', 1, 1.008, 2.20, '1.'),
(2, 'Helium', 'He', 2, 4.006, NULL, '18.'),
(3, 'Lithium', 'Li', 3, 6.97, 0.97, '1.'),
(4, 'Beryllium', 'Be', 4, 9.0122, 1.47, '2.'),
(5, 'Bor', 'B', 5, 10.81, 2.01, '13.'),
(6, 'Uhlík', 'C', 6, 12.011, 2.50, '14.'),
(7, 'Dusík','N', 7, 14.007, 3.07, '15.'),
(8, 'Kyslík', 'O', 8, 15.999, 3.50, '16.'),
(9, 'Fluor', 'F', 9, 18.998, 4.10, '17.'),
(10, 'Neon', 'Ne', 10, 20.180, NULL, '18.'),
(11, 'Sodík', 'Na', 11, 22.990, 1.01, '1.'),
(12, 'Hořčík', 'Mg', 12, 24.305, 1.23, '2.'),
(13, 'Hliník', 'Al', 13, 26.982, 1.47, '13.'),
(14, 'Křemík', 'Si', 14, 28.085, 1.74, '14.'),
(15, 'Fosfor', 'P', 15, 30.974, 2.06, '15.'),
(16, 'Síra', 'S', 16, 32.06, 2.44, '16.'),
(17, 'Chlor', 'Cl',17, 35.45, 2.83, '17.'),
(18, 'Argon', 'Ar',18,39.948, null, '18.'),
(19, 'Draslík', 'K', 19, 39.098, 0.91, '1.'),
(20, 'Vápník', 'Ca',20, 40.08, 1.04, '2.'),
(21, 'Skandium', 'Sc',21, 44.956, 1.20, '3.'),
(22, 'Titan', 'Ti',22, 47.867, 1.32, '4.'),
(24, 'Chrom', 'Cr', 24, 51.996, 1.56, '6.'),
(25, 'Mangan', 'Mn', 25, 54.938, 1.60, '7.'),
(26, 'Železo', 'Fe',26, 55.845, 1.64, '8.'),
(27, 'Kobalt', 'Co', 27, 58.933, 1.70, '9.'),
(28, 'Nikl', 'Ni', 28, 58.693, 1.75, '10.'),
(29, 'Měď', 'Cu', 29, 63.546, 1.75, '11.'),
(30, 'Zinek', 'Zn', 30, 65.38, 1.66, '12.'),
(31, 'Gallium','Ga',31,69.723,1.82,'13.'),
(32, 'Germanium', 'Ge', 32, 72.630, 2.02, '14.'),
(33,'Arsen','Ar',33, 74.922,2.20, '15.'),
(34,'Selen','Se',34, 78.97, 2.48, '16.'),
(35,'Brom','Br',35,79.904, 2.74, '17.'),
(36,'Krypton', 'Kr', 36, 83.798, null, '18.'),
(37, 'Rubidium','Rb',37, 85.468,0.89,'1.'),
(38, 'Stroncium', 'Sr', 38, 87.62, 0.99, '2.'),
(39, 'Yttrium', 'Y',39, 88.906, 1.11, '3.'),
(40, 'Zirkonium','Zr',40,91.224,1.22,'4.'),
(41, 'Niob', 'Nb', 41, 92.906, 1.23, '5.'),
(42, 'Molybden','Mo',42,95.95,1.30,'6.'),
(43,'Technecium','Tc',43,97,1.36,'7.'),
(44,'Ruthenium', 'Ru', 44,101.07, 1.42, '8.'),
(45, 'Rhodium','Rh',45,102.91,1.45,'9.'),
(46,'Palladium','Pd',46,106.42,1.35,'10.'),
(47,'Stříbro','Ag',47,107.87,1.42,'11.'),
(48,'Kadmium','Cd',48,112.41,1.46,'12.'),
(49,'Indium','In',49,114.82,1.49,'13.'),
(50,'Cín','Sn',50,118.71,1.72,'14.'),
(51,'Antimon','Sb',51, 121.76,1.82,'15.'),
(52,'Tellur','Te',52,127.60,2.01,'16.'),
(53,'Jod','I',53,126.90,2.21,'17.'),
(54,'Xenon','Xe',54,131.29,null,'18.'),
(55,'Cesium','Cs',55,132.91,0.86,'1.'),
(56,'Baryum','Ba',56,137.33,0.97,'2.'),
(57,'Lanthan','La',57,138.91,1.08,'3.'),
(72,'Hafnium','Hf',72,178.49,1.23,'4.'),
(74,'Wolfram','W',74,183.84,1.40,'6.'),
(78,'Platina','Pt',78,195.08,1.44,'10.'),
(79,'Zlato','Au',79,196.97,1.42,'11.'),
(80,'Rtuť','Hg',80,200.59,1.44,'12.'),
(81,'Thallium','Tl',81, 204.38, 1.44, '13.'),
(82,'Olovo','Pb',82, 207.2, 1.55, '14.');

INSERT INTO Slouceniny(id_slouc,nazev,zkratka, id_prv1, pocet_molekul_1,id_prv2, pocet_molekul_2) VALUES
(1, 'Oxid Uhličitý', 'CO₂',6, 1, 8, 2),
(2, 'Metan','CH₄',6, 1, 1, 4),
(3, 'Ethan','C₂H₆',6,2,1,6),
(4, 'Voda', 'H₂O', 1, 2, 8, 1),
(5, 'Oxid siřičitý','SO₂',16, 1, 8, 2),
(6, 'Oxid dusnatý', 'NO', 7, 1, 8, 1),
(7, 'Oxid uhelnatý','CO',6 ,1 ,8 ,1),
(8, 'Amoniak', 'NH3', 7, 1, 1, 3),
(9, 'Acetylen', 'C₂H₂',6 ,2 ,1, 2),
(10,'Ethen','C₂H₄',6, 2, 1, 4);

INSERT INTO Slozeni(id_pla, id_prv,id_slouc,`vyskyt_(%)`) VALUES
(1,1,null,73.46),(1,2,null,24.85),(1,8,null,0.77),(1,6,null,0.29),(1,26,null,0.16),(1,10,null,0.12),(1,7,null,0.09),(1,14,null,0.07),(1,12,null,0.5),(1,16,null,0.04),
(2,19,null,31.7),(2,11,null,24.9),(2,8,null,15.1),(2,18,null,7),(2,2,null,5.9),(2,7,null,5.2),(2,null,1,3.6),(2,null,4,3.4),(2,1,null,3.2),
(3,null,1,96.5),(3,7,null,3),(3,null,5,0.015),(3,null,7,0.007),(3,18,null,0.007),(3,2,null,0.0012),(3,10,null,0.0007),
(4,7,null,78.08),(4,8,null,20.95),(4,18,null,0.93),(4,null,1,0.038),(4,null,5,0.033),
(5,8,null,43),(5,14,null,21),(5,13,null,10),(5,20,null,9),(5,26,null,9),(5,12,null,5),(5,22,null,2),(5,28,null,0.6),(5,11,null,0.3),(5,24,null,0.2),(5,19,null,0.1),(5,25,null,0.1),(5,16,null,0.1),
(6,null,1,95.32),(6,7,null,2.7),(6,18,null,1.16),(6,8,null,0.13),(6,null,7,0.07),(6,null,6,0.01),
(9,1,null,86),(9,2,null,14),(9,null,2,0.1),(9,null,8,0.02),
(10,null,5,90),
(14,1,null,96),(14,2,null,3),(14,null,2,0.4),(14,null,8,0.01),(14,null,3,0.0007),
(16,null,4,100),
(20,7,null,98.4),(20,null,2,1.4),(20,1,null,0.2),
(22,1,null,83),(22,2,null,15),(22,null,2,1.99),(22,null,8,0.01),(22,null,3,0.00025),(22,null,9,0.00001),
(28,1,null,80),(28,2,null,19),(28,null,2,1.5),(28,null,3,0.00015),
(30,7,null,99),(30,null,2,0.25),(30,null,7,0.0515),(30,null,9,0.0003),(30,null,10,0.0001);
