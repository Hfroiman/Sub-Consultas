-- Actividad 2.4
-- #
-- Consulta
-- 1
-- La patente, apellidos y nombres del agente que labró la multa y monto de aquellas multas que superan el monto promedio.

SELECT avg(m.Monto) Promedio  FROM Multas m


SELECT m.Patente, a.apellidos, a.nombres FROM Agentes a INNER JOIN Multas m on a.IdAgente=m.IdAgente WHERE m.Monto>(SELECT avg(m.Monto) Promedio  FROM Multas m)

-- 2
-- Las multas que sean más costosas que la multa más costosa por 'No respetar señal de stop'.

SELECT top 1 m.monto FROM Multas m INNER JOIN TipoInfracciones ti on m.IdTipoInfraccion=ti.IdTipoInfraccion WHERE ti.Descripcion='No respetar señal de stop' ORDER BY m.Monto DESC

SELECT * FROM Multas WHERE Monto>(SELECT top 1 m.monto FROM Multas m INNER JOIN TipoInfracciones ti on m.IdTipoInfraccion=ti.IdTipoInfraccion WHERE ti.Descripcion='No respetar señal de stop' ORDER BY m.Monto DESC)

-- 3
-- Los apellidos y nombres de los agentes que no hayan labrado multas en los dos primeros meses de 2023.

SELECT distinct a.IdAgente FROM Multas m INNER JOIN Agentes a on a.IdAgente=m.IdAgente WHERE MONTH(m.FechaHora)=2 AND YEAR(m.FechaHora)=2023 or MONTH(m.FechaHora)=1 AND YEAR(m.FechaHora)=2023

SELECT a.apellidos, a.nombres FROM Agentes a WHERE a.IdAgente not in (SELECT distinct a.IdAgente FROM Multas m INNER JOIN Agentes a on a.IdAgente=m.IdAgente WHERE MONTH(m.FechaHora)=2 AND YEAR(m.FechaHora)=2023 or MONTH(m.FechaHora)=1 AND YEAR(m.FechaHora)=2023)

-- 4
-- Los apellidos y nombres de los agentes que no hayan labrado multas por 'Exceso de velocidad'.

SELECT a.idagente FROM Agentes a INNER JOIN Multas m  on a.IdAgente=m.IdAgente JOIN TipoInfracciones ti on m.IdTipoInfraccion=ti.IdTipoInfraccion WHERE ti.Descripcion='Exceso de velocidad'

SELECT a.apellidos, a.nombres FROM Agentes a WHERE a.IdAgente not in (SELECT a.idagente FROM Agentes a INNER JOIN Multas m  on a.IdAgente=m.IdAgente JOIN TipoInfracciones ti on m.IdTipoInfraccion=ti.IdTipoInfraccion WHERE ti.Descripcion='Exceso de velocidad')

-- 5
-- Los legajos, apellidos y nombre de los agentes que hayan labrado multas de todos los tipos de infracciones existentes.

SELECT COUNT(distinct Descripcion) from TipoInfracciones

SELECT a.Legajo, a.Apellidos, a.Nombres FROM Agentes a INNER JOIN Multas m on a.IdAgente=m.IdAgente GROUP BY a.Legajo, a.Apellidos, a.Nombres 
HAVING COUNT(distinct m.IdTipoInfraccion)=(SELECT COUNT(*) from TipoInfracciones)

-- 6
-- Los legajos, apellidos y nombres de los agentes que hayan labrado más cantidad de multas que la cantidad de multas generadas por un radar (multas con IDAgente con valor NULL)

SELECT count(m.idmulta) FROM Multas m WHERE m.IdAgente is NULL

SELECT a.Legajo, a.Apellidos, a.Nombres FROM Agentes a INNER JOIN Multas m on a.IdAgente=m.IdAgente GROUP BY a.Legajo, a.Apellidos, a.Nombres
HAVING COUNT(M.IdMulta)>(SELECT count(m.idmulta) FROM Multas m WHERE m.IdAgente is NULL)

-- 7
-- Por cada agente, listar legajo, apellidos, nombres, cantidad de multas realizadas durante el día y cantidad de multas realizadas durante la noche.
-- NOTA: El turno noche ocurre pasadas las 20:00 y antes de las 05:00.
-- DATEPART ( DATEPART([hour], fecha_contacto) )

SELECT COUNT(m.IdAgente) FROM Multas m WHERE DATEPART([HOUR],m.FechaHora)>20 OR DATEPART([HOUR],m.FechaHora)<05 GROUP BY m.IdAgente --Noche

SELECT COUNT(m.IdAgente) FROM Multas m WHERE DATEPART([HOUR],m.FechaHora)<20 AND DATEPART([HOUR],m.FechaHora)>05 -- DIA

SELECT a.legajo, a.apellidos, a.nombres,
(SELECT COUNT(m.IdAgente) FROM Multas m WHERE DATEPART([HOUR],m.FechaHora)>20 AND m.IdAgente=a.IdAgente OR DATEPART([HOUR],m.FechaHora)<05 AND m.IdAgente=a.IdAgente GROUP BY m.IdAgente) PorNoche,
(SELECT COUNT(m.IdAgente) FROM Multas m WHERE DATEPART([HOUR],m.FechaHora)<20 AND DATEPART([HOUR],m.FechaHora)>05 AND m.IdAgente=a.IdAgente) Xdia
FROM Agentes a 
 
 

-- 8
-- Por cada patente, el total acumulado de pagos realizados con medios de pago no electrónicos y el total acumulado de pagos realizados con algún medio de pago electrónicos.

SELECT sum(p.Importe) FROM Pagos p INNER JOIN MediosPago mp on p.IDMedioPago=mp.IDMedioPago WHERE mp.MedioPagoElectronico=0 AND p.IDMulta=m.idmulta


SELECT sb.Patente, SUM(sb.pagonoelectro) Efectivo, SUM(sb.en)Electronico from (SELECT m.Patente,(SELECT sum(p.Importe) FROM Pagos p INNER JOIN MediosPago mp on p.IDMedioPago=mp.IDMedioPago WHERE mp.MedioPagoElectronico=0 AND p.IDMulta=m.idmulta) pagonoelectro, (SELECT sum(p.Importe) FROM Pagos p INNER JOIN MediosPago mp on p.IDMedioPago=mp.IDMedioPago WHERE mp.MedioPagoElectronico=1 AND p.IDMulta=m.idmulta)en FROM Multas m) sb GROUP BY sb.Patente ORDER BY sb.Patente ASC


-- 9
-- La cantidad de agentes que hicieron igual cantidad de multas por la noche que durante el día.

SELECT COUNT(p.Legajo) FROM 
            (SELECT a.legajo, a.apellidos, a.nombres,
            (SELECT COUNT(m.IdAgente) FROM Multas m WHERE DATEPART([HOUR],m.FechaHora)>20 AND m.IdAgente=a.IdAgente OR DATEPART([HOUR],m.FechaHora)<05 AND m.IdAgente=a.IdAgente GROUP BY m.IdAgente) PorNoche,
            (SELECT COUNT(m.IdAgente) FROM Multas m WHERE DATEPART([HOUR],m.FechaHora)<20 AND DATEPART([HOUR],m.FechaHora)>05 AND m.IdAgente=a.IdAgente) Xdia
            FROM Agentes a ) p WHERE p.PorNoche= p.Xdia


-- 10
-- Las patentes que, en total, hayan abonado más en concepto de pagos con medios NO electrónicos que pagos con medios electrónicos. Pero debe haber abonado tanto con medios de pago electrónicos como con medios de pago no electrónicos.

SELECT sum(p.Importe) FROM Pagos p WHERE P.IDMedioPago = 5
SELECT sum(p.Importe) FROM Pagos p WHERE P.IDMedioPago IN (1,2,3,4)

SELECT * FROM MediosPago

SELECT m.patente,
(SELECT sum(p.Importe) FROM Pagos p WHERE P.IDMedioPago = 5 AND p.IDMulta=m.IdMulta) PagoEfectivo,
(SELECT sum(p.Importe) FROM Pagos p WHERE P.IDMedioPago IN (1,2,3,4)AND p.IDMulta=m.IdMulta) Electronico
FROM Multas m


SELECT e.Patente from 
            (SELECT m.patente,
            (SELECT sum(p.Importe) FROM Pagos p WHERE P.IDMedioPago = 5 AND p.IDMulta=m.IdMulta) PagoEfectivo,
            (SELECT sum(p.Importe) FROM Pagos p WHERE P.IDMedioPago IN (1,2,3,4)AND p.IDMulta=m.IdMulta) Electronico
            FROM Multas m) e 
            GROUP BY e.Patente HAVING sum(E.PagoEfectivo) > sum(E.Electronico) and sum(E.PagoEfectivo)>0 and sum(E.Electronico)>0 ORDER BY e.Patente asc



-- 11
-- Los legajos, apellidos y nombres de agentes que hicieron más de dos multas durante el día y ninguna multa durante la noche.

SELECT COUNT(m.IdMulta) FROM Multas m WHERE DATEPART([HOUR],m.FechaHora)>20 or DATEPART([HOUR],m.FechaHora)<05

SELECT COUNT(m.IdMulta) FROM Multas m WHERE DATEPART([HOUR],m.FechaHora)<20 and DATEPART([HOUR],m.FechaHora)>05 


SELECT a.Legajo, a.Apellidos, a.Nombres,
(SELECT COUNT(m.IdMulta) FROM Multas m WHERE DATEPART([HOUR],m.FechaHora)>20 AND m.IdAgente=a.IdAgente or DATEPART([HOUR],m.FechaHora)<05 AND m.IdAgente=a.IdAgente)Noche,
(SELECT COUNT(m.IdMulta) FROM Multas m WHERE DATEPART([HOUR],m.FechaHora)<20 and DATEPART([HOUR],m.FechaHora)>05 AND m.IdAgente=a.IdAgente) Dia
FROM Agentes a


SELECT a.Legajo, a.Apellidos, a.Nombres from 
            (SELECT a.Legajo, a.Apellidos, a.Nombres,
            (SELECT COUNT(m.IdMulta) FROM Multas m WHERE DATEPART([HOUR],m.FechaHora)>20 AND m.IdAgente=a.IdAgente or DATEPART([HOUR],m.FechaHora)<05 AND m.IdAgente=a.IdAgente)Noche,
            (SELECT COUNT(m.IdMulta) FROM Multas m WHERE DATEPART([HOUR],m.FechaHora)<20 and DATEPART([HOUR],m.FechaHora)>05 AND m.IdAgente=a.IdAgente) Dia
            FROM Agentes a) a WHERE a.Dia>2 AND a.Noche=0


-- 12
-- La cantidad de agentes que hayan registrado más multas que la cantidad de multas generadas por un radar (multas con IDAgente con valor NULL)

SELECT COUNT(m.IdMulta) from Multas m WHERE m.IdAgente is null


SELECT m.IdAgente, COUNT(m.IdMulta) FROM Multas m GROUP BY m.IdAgente HAVING count(m.IdMulta)>(SELECT COUNT(m.IdMulta) from Multas m WHERE m.IdAgente is null)

SELECT COUNT(ab.IdAgente) FROM (SELECT m.IdAgente FROM Multas m GROUP BY m.IdAgente HAVING count(m.IdMulta)>(SELECT COUNT(m.IdMulta) from Multas m WHERE m.IdAgente is null)) ab 