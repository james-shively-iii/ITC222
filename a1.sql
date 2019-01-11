/* 1. Return everything from the certificate table */
SELECT * FROM certificate;

/* 2. Return the first name, last name, and email from everyone in person.
	  Alias the first name and last name columns as "First" and "Last"  */
SELECT firstname AS "First", lastname AS "Last", email
FROM person;

/* 3. Return the same as for 2 but sort it by lastname in a descending order*/
SELECT firstname AS "First", lastname AS "Last", email
FROM person
ORDER BY "Last" DESC;

/* 4. Return the last name, first name, email, and city for everyone
	  who lives in Seattle */
SELECT lastname, firstname, email, city
FROM person
WHERE city = 'Seattle';

/* 5. Return the same as for 4, but only for those added in February 2017 */
SELECT lastname, firstname, email, city
FROM person
WHERE city = 'Seattle'
AND dateadded BETWEEN '2017/02/01' AND '2017/02/28';

/* 6. Who are the people in the database who live in Washington(WA),
	  Oregon(OR), or California(CA) */
SELECT lastname, firstname, state
FROM person
WHERE state = 'WA'
OR state = 'OR'
OR state = 'CA';

/* 7. Which instructional areas don't have a description? */
SELECT * 
FROM instructionalarea
WHERE description IS NULL;

/* 8. Which instructional areas do have a description? */
SELECT *
FROM instructionalarea
WHERE description IS NOT NULL;

/* 9. List all the people whose last name has a double "nn" somewhere in the lastname */
SELECT *
FROM person
WHERE lastname LIKE '%nn%';

/* 10. Which courses have "Python" in the course description? */
SELECT * 
FROM course
WHERE coursedescription LIKE '%Python%';

/* 11. List only unduplicated students for Fall quarter 2018. */
SELECT DISTINCT *
FROM student
WHERE studentstartdate BETWEEN '2018-09-01'
AND '2018-12-31'
ORDER BY studentkey ASC;