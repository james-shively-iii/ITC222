SELECT employeekey, positionname
FROM employee
CROSS JOIN jobposition;

SELECT * FROM person
INNER JOIN employee
On person.personkey=employee.employeekey;

SELECT * FROM person
INNER JOIN employee
USING (personkey);

SELECT employeekey, personfirstname, personlastname
FROM person
INNER JOIN employee
ON person.personkey=employee.personkey
ORDER BY employeekey ASC;

SELECT e.employeekey, personfirstname, personlastname, positionkey, employeepositionstartdate
FROM person p
INNER JOIN employee e
ON p.personkey=e.personkey
INNER JOIN employeeposition
ON e.employeekey=employeeposition.employeekey
ORDER BY employeekey ASC;

SELECT e.employeekey, personfirstname, personlastname, positionname, employeepositionstartdate
FROM person p
INNER JOIN employee e
ON p.personkey=e.personkey
INNER JOIN employeeposition ep
ON e.employeekey=ep.employeekey
INNER JOIN jobposition jp
ON ep.positionkey=jp.positionkey
ORDER BY e.employeekey ASC;

SELECT date_part('Year', grantapplicationdate) "Year",
SUM(grantapplicationamount) "Requested",
SUM(grantstatusfinalallocation) "Allocated",
SUM(grantapplicationamount) - SUM(grantstatusfinalallocation) "Difference"
FROM grantapplication ga
INNER JOIN grantstatus gs
ON ga.grantapplicationkey=gs.grantapplicationkey
GROUP BY date_part('Year', grantapplicationdate)
ORDER BY date_part('Year', grantapplicationdate);

SELECT personaddresscity, SUM(donationamount) "Donations"
FROM personaddress pa
INNER JOIN donation d
ON pa.personkey=d.personkey
GROUP BY personaddresscity;

SELECT personaddresscity, SUM(donationamount) "Donations"
FROM personaddress pa
INNER JOIN donation d
ON pa.personkey=d.personkey
WHERE pa.personkey=7
GROUP BY personaddresscity;

SELECT personaddresscity, SUM(donationamount) "Donations"
FROM person p
INNER JOIN donation d
ON p.personkey=d.personkey
INNER JOIN personaddress pa
ON pa.personkey=p.personkey
WHERE pa.personkey=7
GROUP BY personaddresscity;

SELECT DISTINCT granttypename, ga.granttypekey
FROM granttype gt
LEFT OUTER JOIN grantapplication ga
ON gt.granttypekey=ga.granttypekey;

SELECT DISTINCT granttypename, ga.granttypekey
FROM granttype gt
LEFT OUTER JOIN grantapplication ga
ON gt.granttypekey=ga.granttypekey
WHERE ga.granttypekey IS NULL;