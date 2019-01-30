--1. What is every possible combination of quarter and course?
SELECT * FROM course
CROSS JOIN quarter;

--2. What are the names and emails and start dates of all the students who started sometime in 2017?
SELECT studentkey,
person.lastname || ', ' || person.firstname AS "Name",
email, studentstartdate
FROM person
LEFT OUTER JOIN student
ON person.personkey=student.studentkey
WHERE studentstartdate >= '2017-01-01'
AND studentstartdate <= '2017-12-31'
GROUP BY studentkey, "Name", person.email, studentstartdate
ORDER BY studentstartdate ASC;

--3. What are the studentkey, student names, the course name and the instructor name for sectionkey 17?
SELECT Student.Studentkey, p1.lastname, p1.firstname, Coursename, p2.lastname AS Instructor
FROM Person p1
INNER JOIN Student
ON p1.personkey = student.personkey
INNER JOIN Roster
ON student.studentkey = roster.studentkey
INNER JOIN coursesection
ON coursesection.sectionkey=roster.sectionkey
INNER JOIN course
ON course.coursekey=coursesection.coursekey
INNER JOIN instructor
ON instructor.instructorkey=coursesection.instructorkey
INNER JOIN person p2
ON p2.personkey=instructor.personkey
WHERE coursesection.sectionkey=17

--4. What is the total enrollment of students in each course by Quarter? Include the course names and quarter.
SELECT COUNT(statuskey) AS "Enrollment #", coursename, quarterkey
FROM roster r
INNER JOIN coursesection cs
ON r.sectionkey=cs.sectionkey
INNER JOIN course c
ON cs.coursekey=c.coursekey
INNER JOIN student s
ON r.studentkey=s.studentkey
WHERE statuskey = 1
GROUP BY quarterkey, c.coursekey
ORDER BY quarterkey ASC;

--5. What is the average grade for each course? Include course names.
SELECT coursename, ROUND(AVG(finalgrade),2) AS "Average GPA"
FROM course c
INNER JOIN coursesection cs
ON c.coursekey=cs.coursekey
INNER JOIN roster r
ON cs.sectionkey=r.sectionkey
WHERE finalgrade IS NOT NULL
GROUP BY c.coursename
ORDER BY c.coursename ASC;

--6. What is the average grade for the student with the studentkey 21? Include lastname and the average. (We won’t worry about GPA for now. Just use a straight average.)
SELECT r.studentkey, lastname, firstname, ROUND(AVG(finalgrade),2) AS "GPA Average"
FROM roster r
INNER JOIN student s
ON r.studentkey=s.studentkey
INNER JOIN person p
ON s.personkey=p.personkey
WHERE r.studentkey = 21
GROUP BY r.studentkey, lastname, firstname;

--7. Which instructors listed have never taught a class? Return their names.
SELECT instructorkey, lastname, firstname, hiredate
FROM instructor
NATURAL JOIN person
WHERE DATE(hiredate) >= '2019-01-01'
ORDER BY lastname ASC;

--8. What are the names of the courses that have never been offered yet?
SELECT c.coursekey, coursename, sectionyear
FROM course c
LEFT OUTER JOIN coursesection cs
ON c.coursekey=cs.coursekey
WHERE sectionyear IS NULL;

--9. Use a FULL JOIN to return the same values as in 8.
SELECT c.coursekey, coursename, sectionyear
FROM course c
FULL JOIN coursesection cs
ON c.coursekey=cs.coursekey
WHERE sectionyear IS NULL;

--10. Use a NATURAL JOIN to show the name of each certificate and the names of the courses each contains.
SELECT certificatekey, coursename, certificatename
FROM course
NATURAL JOIN certificate
ORDER BY certificatename ASC;