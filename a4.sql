--1. What are the course names for the courses in Certificate 3?
SELECT coursename
FROM course co
INNER JOIN certificatecourse ce
ON co.coursekey=ce.coursekey
WHERE ce.certificatekey=3;

--2. Who were the people added first to the person table? (You could sort, but use a subquery. The MIN () function will return the earliest date)
SELECT lastname || ', '  || firstname AS "Name", dateadded AS "Date"
FROM person
WHERE dateadded=
	(SELECT MIN(dateadded) FROM person);

--3. Return all the students (just their key for now) who are not in any roster.
SELECT studentkey FROM student
WHERE studentkey NOT IN
	(SELECT studentkey FROM roster);

--4-5. Create a query using the roster table that returns these results. (I am only showing the top 6 results-there are actually 67 rows returned. 
The field averaged is finalgrade. I rounded the results to two decimal points. I also removed all nulls with HAVING AVG(finalgrade) IS NOT NULL. 
The difference is the grouped average subtracted from the total table average. A negative result means that the section grades were higher than 
average, a positive result that they were below the school average.)
SELECT r.sectionkey, coursename, ROUND(AVG(finalgrade),2) AS "Section Average",
	(SELECT ROUND(AVG(finalgrade),2) FROM roster) AS "Overall Average",
	(SELECT ROUND(AVG(finalgrade),2) FROM roster) - ROUND(AVG(finalgrade),2) AS "Difference"
FROM roster r
INNER JOIN coursesection cs
ON r.sectionkey=cs.sectionkey
INNER JOIN course c
ON cs.coursekey=c.coursekey
GROUP BY r.sectionkey, coursename
HAVING AVG(finalgrade) IS NOT NULL
ORDER BY r.sectionkey ASC; 

--6. Use a table expression to get the student key, last name, first name and email from all the   students in section 30.
SELECT "last", "first", "email", "sk"
FROM (SELECT lastname AS "last",
	  	firstname AS "first",
		email AS "email",
		coursesection.sectionkey AS "sk"
		FROM person
		INNER JOIN student
		ON person.personkey=student.personkey
		INNER JOIN roster
		ON roster.studentkey=student.studentkey
		INNER JOIN coursesection
		ON coursesection.sectionkey=roster.sectionkey
		GROUP BY "last", "first", "email", "sk"
) AS section30
WHERE "sk" = 30;

--7. Redo number 6 as a Common table expression.
WITH "Section 30" AS 
(
	SELECT
		lastname || ', ' || firstname AS "Name",
		email AS "Email",
		coursesection.sectionkey AS "SK"
		FROM person
		INNER JOIN student
		ON person.personkey=student.personkey
		INNER JOIN roster
		ON roster.studentkey=student.studentkey
		INNER JOIN coursesection
		ON coursesection.sectionkey=roster.sectionkey
		GROUP BY "Name", "Email", "SK"
)
SELECT "Name", "Email", "SK"
FROM "Section 30"
WHERE "SK" = 30;

--8. Create a Common table expression that shows each instructors name and specialty area.
WITH instructorspecialty AS
(
	SELECT 
		lastname || ', ' || firstname AS "Name",
		areaname AS "Specialty"
	FROM person p
	INNER JOIN instructor i
	ON p.personkey=i.personkey
	INNER JOIN instructorarea ia
	ON i.instructorkey=ia.instructorkey
	INNER JOIN instructionalarea ina
	ON ina.instructionalareakey=ia.instructionalareakey
	ORDER BY "Name", "Specialty"
)
SELECT "Name", "Specialty"
FROM instructorspecialty
GROUP BY "Name", "Specialty";

--9-10. Create a correlated subquery that shows which students had grades less than the average grades for each section.
SELECT ROUND(AVG(finalgrade),2) AS "Final Grade", 
studentkey AS "Student ID",
sectionkey AS "Section ID"
FROM roster r
WHERE finalgrade < (SELECT AVG(finalgrade) FROM roster)
GROUP BY r.studentkey, r.sectionkey, r.finalgrade
ORDER BY finalgrade DESC;