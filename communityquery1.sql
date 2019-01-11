

SELECT donationdate, EXTRACT('year' FROM donationdate) AS "Year"
FROM donation;
SELECT donationdate, EXTRACT('month' FROM donationdate) AS "Month"
FROM donation;
SELECT donationdate, EXTRACT('day' FROM donationdate) AS "Day"
FROM donation;

SELECT * FROM employeeposition;

SELECT employeekey, age(employeepositionstartdate) 
FROM employeeposition
ORDER BY age(employeepositionstartdate) DESC;

SELECT grantapplicationkey, grantapplicationdate, 
grantapplication + interval '48 hours' "read by"
FROM grantapplication;

--concatenation
SELECT personlastname || ', ' || personfirstname
AS "Name" FROM Person;

--aggregate functions
SELECT AVG(donationamount) FROM donation;
SELECT SUM(donationamount) FROM donation;
SELECT MAX(donationamount) FROM donation;
SELECT MIN(donationamount) FROM donation;
SELECT COUNT(donationamount) FROM donation;

SELECT granttypekey, SUM(grantapplicationamount) AS Total
FROM grantapplication
GROUP BY granttypekey
ORDER BY granttypekey;