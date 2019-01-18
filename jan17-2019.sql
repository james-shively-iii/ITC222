--joins
SELECT * FROM employee;
SELECT * FROM jobposition;

--cross join
SELECT * FROM employee
CROSS JOIN jobposition
ORDER BY employeekey;

SELECT * FROM employee, jobposition
ORDER BY employeekey;

--inner join
SELECT employeekey, personlastname, personfirstname
FROM person
INNER JOIN employee
ON person.personkey=employee.personkey;

SELECT employee.employeekey, employee.personkey, personlastname, personfirstname,
employeepositionstartdate, positionname
FROM person
INNER JOIN employee
ON employee.personkey=person.personkey
INNER JOIN employeeposition
ON employeeposition.employeekey=employee.employeekey
INNER JOIN jobposition
ON jobposition.positionkey=employeeposition.positionkey;

SELECT e.employeekey, e.personkey, personlastname, personfirstname,
employeepositionstartdate, positionname
FROM person p
INNER JOIN employee e
ON p.personkey=e.personkey
INNER JOIN employeeposition ep
ON ep.employeekey=e.employeekey
INNER JOIN jobposition jp
ON ep.positionkey=jp.positionkey;

--older syntax
SELECT employee.employeekey, employee.personkey, personlastname, personfirstname,
employeepositionstartdate, positionname
FROM person, employee, employeeposition, jobposition
WHERE person.personkey=employee.personkey
AND employee.personkey=employeeposition.employeekey
AND jobposition.positionkey=employeeposition.positionkey;

--accidental cross join by leaving out a relationship
SELECT employee.employeekey, employee.personkey, personlastname, personfirstname,
employeepositionstartdate, positionname
FROM person, employee, employeeposition, jobposition
WHERE person.personkey=employee.personkey
AND jobposition.positionkey=employeeposition.positionkey;

--aggregate
SELECT EXTRACT(year from grantapplicationdate) "Year",
granttypename, SUM(grantapplicationamount) "Total",
AVG(grantapplicationamount) "Average"
FROM grantapplication
INNER JOIN granttype
ON granttype.granttypekey=grantapplication.granttypekey
GROUP BY EXTRACT(year from grantapplicationdate), granttypename
ORDER BY EXTRACT(year from grantapplicationdate), granttypename;

SELECT EXTRACT(year from grantapplicationdate) "Year",
SUM(grantapplicationamount) FROM grantapplication
GROUP BY EXTRACT(year from grantapplicationdate);

--Danger!!
--total donation by city(person personaddress-donation)
SELECT personaddresscity "City", SUM(donationamount) "Total"
FROM person
INNER JOIN personaddress
ON person.personkey=personaddress.personkey
INNER JOIN donation
ON person.personkey=donation.personkey
GROUP BY personaddresscity;

SELECT SUM(donationamount) FROM donation;

SELECT personaddresscity, donationamount
FROM personaddress
INNER JOIN donation
ON personaddress.personkey=donation.personkey
WHERE donation.personkey=7;

--outer joins about not matching data
SELECT DISTINCT granttypename, grantapplication.granttypekey
FROM granttype
LEFT OUTER JOIN grantapplication
ON granttype.granttypekey=grantapplication.granttypekey;

SELECT DISTINCT granttypename, grantapplication.granttypekey
FROM granttype
LEFT OUTER JOIN grantapplication
ON granttype.granttypekey=grantapplication.granttypekey
WHERE grantapplication.granttypekey IS null;

SELECT DISTINCT granttypename, grantapplication.granttypekey
FROM grantapplication
RIGHT OUTER JOIN granttype
ON granttype.granttypekey=grantapplication.granttypekey;

--full join
SELECT DISTINCT granttypename, grantapplication.granttypekey
FROM grantapplication
FULL JOIN granttype
ON granttype.granttypekey=grantapplication.granttypekey;

--using
SELECT employeekey, employee.personkey, personlastname, personfirstname
FROM person
INNER JOIN employee
using(personkey);

SELECT employeekey, employee.personkey, personlastname, personfirstname, personaddresscity
FROM person
NATURAL JOIN employee
NATURAL JOIN personaddress;

SELECT personlastname, personfirstname, donationdate, donationamount, grantapplicationdate,
grantapplicationamount
FROM donation
JOIN person
ON person.personkey=donation.personkey
JOIN grantapplication
ON grantapplicationdate BETWEEN donationdate AND donationdate + interval '7 day'
WHERE personlastname='Baker'
ORDER BY personlastname, personfirstname;