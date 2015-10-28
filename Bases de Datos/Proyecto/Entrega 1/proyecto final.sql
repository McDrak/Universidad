/* 
PROYECTO DE BASES DE DATOS
2015 30
PRIMERA ENTREGA

Marta Jimena Vargas
Alejandro Guayara
Carlos E Quimbay
*/

DROP TABLE HOTEL;
DROP TABLE PAIS;
DROP TABLE CONTINENTE;

CREATE TABLE CONTINENTE(
  COD_CONTINENTE NUMBER (1,0) PRIMARY KEY,
  DESCRIPCION VARCHAR2 (15) NOT NULL
);

CREATE TABLE PAIS(
  COD_PAIS NUMBER (3,0),
  NOMBRE VARCHAR2 (15) NOT NULL,
  COD_CONTINENTE NUMBER (1,0),
  PRIMARY KEY (COD_PAIS, COD_CONTINENTE),
  FOREIGN KEY (COD_CONTINENTE) REFERENCES CONTINENTE)
;

CREATE TABLE HOTEL
(
   COD_CONTINENTE NUMBER (1,0),
   COD_PAIS NUMBER (3,0),
   COD_HOTEL NUMBER (3,0) PRIMARY KEY,
   NOMBRE VARCHAR2 (15),
   VALOR_NOCHE NUMBER (8,2),CHECK (VALOR_NOCHE > 0),
   PATRIMONIO_HUMANIDAD CHAR,CHECK (PATRIMONIO_HUMANIDAD IN ('S','N')),
  FOREIGN KEY (COD_CONTINENTE) REFERENCES CONTINENTE,
  FOREIGN KEY (COD_PAIS,COD_CONTINENTE) REFERENCES PAIS
);

INSERT INTO CONTINENTE VALUES (1,'AFRICA');
INSERT INTO CONTINENTE VALUES (2,'AMERICA');
INSERT INTO CONTINENTE VALUES (3,'ASIA');
INSERT INTO CONTINENTE VALUES (4,'EUROPA');
INSERT INTO CONTINENTE VALUES (5,'OCEANIA');

INSERT INTO PAIS VALUES (001,'Angola',1);
INSERT INTO PAIS VALUES (002,'Egipto',1);
INSERT INTO PAIS VALUES (003,'Marruecos',1);
INSERT INTO PAIS VALUES (004,'Argentina',2);
INSERT INTO PAIS VALUES (005,'Mexico',2);
INSERT INTO PAIS VALUES (006,'Brasil',2);
INSERT INTO PAIS VALUES (007,'China',3);
INSERT INTO PAIS VALUES (008,'India',3);
INSERT INTO PAIS VALUES (009,'Japon',3);
INSERT INTO PAIS VALUES (010,'Inglaterra',4);
INSERT INTO PAIS VALUES (011,'Francia',4);
INSERT INTO PAIS VALUES (012,'Espania',4);
INSERT INTO PAIS VALUES (013,'Australia',5);
INSERT INTO PAIS VALUES (014,'Nueva Zelanda',5);
INSERT INTO PAIS VALUES (015,'Papua',5);
INSERT INTO PAIS VALUES (016,'Radio',5);

INSERT INTO HOTEL VALUES (1,002,100,'HOLIDAY',180000,'S');
INSERT INTO HOTEL VALUES (2,005,101,'HILTON',160000,'S');
INSERT INTO HOTEL VALUES (3,008,102,'MARRIOT',130000,'N');
INSERT INTO HOTEL VALUES (4,012,103,'INTER',190000,'N');
INSERT INTO HOTEL VALUES (5,015,104,'WESTERN',110000,'S');
INSERT INTO HOTEL VALUES (5,014,105,'RICHIE',110000,'S');
INSERT INTO HOTEL VALUES (5,016,106,'LAU',110000,'S');
INSERT INTO HOTEL VALUES (5,013,107,'JEFF',110000,'N');
INSERT INTO HOTEL VALUES (5,013,108,'CAR',90000,'S');
INSERT INTO HOTEL VALUES (1,002,110,'BASES',100000,'N');
INSERT INTO HOTEL VALUES (5,001,112,'JOSE',190000,'S');
INSERT INTO HOTEL VALUES (1,003,113,'JUAN',200000,'N');
INSERT INTO HOTEL VALUES (2,004,114,'JAURI',170000,'S');
INSERT INTO HOTEL VALUES (2,004,115,'OPERATIVOS',300000,'N');

--PUNTO 1

WITH PRECIO_N_HOTEL AS (
  SELECT CONTINENTE.DESCRIPCION AS CONTINENTE, PAIS.NOMBRE AS PAIS, HOTEL.NOMBRE AS HOTEL, HOTEL.VALOR_NOCHE AS "VALORENUSD"
      FROM CONTINENTE, PAIS, HOTEL
      WHERE CONTINENTE.COD_CONTINENTE = PAIS.COD_CONTINENTE
      AND 
      HOTEL.COD_CONTINENTE = CONTINENTE.COD_CONTINENTE
      AND 
      HOTEL.COD_PAIS = PAIS.COD_PAIS)
      ,
  SUMA AS (
  SELECT 'TOTAL' CONTINENTE, ' ' PAIS, ' ' HOTEL,  SUM(PRECIO_N_HOTEL.VALORENUSD)
  FROM PRECIO_N_HOTEL  
  )
  SELECT *
  FROM PRECIO_N_HOTEL 
  UNION 
  SELECT * FROM SUMA;

--PUNTO 2

WITH CXP AS
  (SELECT CONTINENTE.DESCRIPCION AS CONTINENTE, NOMBRE AS PAIS, COD_PAIS AS CP
    FROM CONTINENTE NATURAL JOIN PAIS),
     HXCP AS
  (SELECT CONTINENTE, PAIS, HOTEL.NOMBRE AS HOTEL, HOTEL.VALOR_NOCHE AS "VALOR (EN USD)"
    FROM CXP, HOTEL 
    WHERE CXP.CP = HOTEL.COD_PAIS),
    AVG_CON AS
  (SELECT CONTINENTE AS N_C, AVG("VALOR (EN USD)") AS PROM
    FROM HXCP,CONTINENTE
    WHERE CONTINENTE = CONTINENTE.DESCRIPCION
    GROUP BY CONTINENTE)
SELECT  DISTINCT CONTINENTE, PAIS,HOTEL, "VALOR (EN USD)", PROM
  FROM HXCP, AVG_CON
  WHERE  HXCP.CONTINENTE = AVG_CON.N_C and HXCP."VALOR (EN USD)">AVG_CON.PROM;

/*PUNTO 3*/

WITH TA AS (
SELECT SUM (COD_HOTEL) SP, COD_PAIS
FROM HOTEL
GROUP BY COD_PAIS
),
TU AS (
SELECT SUM (COD_HOTEL) SC, COD_CONTINENTE
FROM HOTEL
GROUP BY COD_CONTINENTE )
SELECT  (SP/SC)*100  PORCENTAJE, CONTINENTE.DESCRIPCION CONTINENTE, PAIS.NOMBRE PAIS 
FROM TU, TA, CONTINENTE, PAIS
WHERE PAIS.COD_PAIS =TA.COD_PAIS AND 
TU.COD_CONTINENTE=CONTINENTE.COD_CONTINENTE AND 
PAIS.COD_CONTINENTE = CONTINENTE.COD_CONTINENTE;


--PUNTO 4

WITH C1 AS (
SELECT SUM (1) SUMA, PAIS.COD_CONTINENTE
FROM PAIS
GROUP BY COD_CONTINENTE
),
C2 AS (
SELECT DISTINCT HOTEL.COD_PAIS, 1 SUMA
FROM HOTEL
), C3 AS (
SELECT C2.SUMA, PAIS.COD_CONTINENTE
FROM C2, PAIS
WHERE C2.COD_PAIS = PAIS.COD_PAIS
), C4 AS (
SELECT SUM (C3.SUMA) AS SUMA, C3.COD_CONTINENTE
FROM C3
GROUP BY C3.COD_CONTINENTE
)
SELECT CONTINENTE.DESCRIPCION
FROM C4,C1, CONTINENTE
WHERE C1.SUMA=C4.SUMA AND 
CONTINENTE.COD_CONTINENTE = C1.COD_CONTINENTE AND
CONTINENTE.COD_CONTINENTE = C4.COD_CONTINENTE;


/*PUNTO 5*/

WITH PATRI AS (
  SELECT CONTINENTE.DESCRIPCION AS CONTINENTE, COUNT (CASE WHEN HOTEL.PATRIMONIO_HUMANIDAD = 'S' THEN 1 END) AS EP,
  COUNT (CASE WHEN HOTEL.PATRIMONIO_HUMANIDAD = 'N' THEN 1 END) AS NEP
  FROM HOTEL,CONTINENTE
  WHERE HOTEL.COD_CONTINENTE = CONTINENTE.COD_CONTINENTE
  GROUP BY CONTINENTE.DESCRIPCION)
SELECT DISTINCT PATRI.CONTINENTE, PATRI.EP AS"TOT HOTELES SON PATRIMONIO",PATRI.NEP AS "TOT HOTELES NO SON PATRIMONIO", (PATRI.EP+PATRI.NEP) AS TOTAL
FROM PATRI
;
