-- 1. What does it cost for a 5-credit course in 2018? (Use pricehistory table.)
SELECT pricepercredit * 5 AS "Class Price", pricebegindate AS "For Year"
FROM pricehistory
WHERE pricebegindate='2018/01/01';

-- 2. What does it cost for 15 credits in 2018? Remember the discount.
SELECT pricepercredit * (15-(15 * .05)) AS "Quarter Price",
pricebegindate AS "For Year"
FROM pricehistory
WHERE pricebegindate= '2018/01/01';

-- 3. Format the results of exercise 2 to show as currency.
SELECT to_char(pricepercredit, '$999.99') AS "Per Credit", to_char(pricepercredit*(15-(15 * .05)),'$9,999.99') AS "Quarter Price",
pricebegindate AS "For Year"
FROM pricehistory
WHERE pricebegindate= '2018/01/01';

-- 4. Authenticate the user JSullivan. (Use Login table, the plain password is ‘SullivanPass’.)
SELECT username, userpassword
FROM logintable
WHERE username = 'JSullivan'
AND userpassword=CRYPT('SullivanPass', userpassword);

-- 5. What are the distinct years in which people were added to the person table?
SELECT personkey AS "ID", extract(year from dateadded) AS "Year"
FROM person;

-- 6. From the table certificate return just the words “data and science” from the description of Python Programming.
SELECT substring('data and science' FOR position('data and science' IN certificatedescription))
FROM certificate;

-- 7. What is the count of people added each year to the person table? Order it by year.
SELECT COUNT(DISTINCT personkey) AS "People Added",
EXTRACT(year from dateadded) AS "Year"
FROM person
GROUP BY EXTRACT(year from dateadded)
ORDER BY EXTRACT(year from dateadded);

-- 8. What is the average final grade from roster? Round the number to two decimal places.
SELECT ROUND(AVG(finalgrade),2) "Average Grade"
FROM roster;

-- 9. What is the highest grade from roster.
SELECT MAX(finalgrade) FROM roster;

-- 10. What is the average final grade per section? Order by sectionkey and round to two decimal places.
SELECT DISTINCT sectionkey "Course Key", MAX(finalgrade) "Best Grade"
FROM roster
WHERE finalgrade IS NOT NULL
GROUP BY sectionkey
ORDER BY sectionkey;

-- 11. List all the students (studentkey) who have an average final grade higher than 3.5.
SELECT studentkey "Students",
ROUND(AVG(finalgrade),2) "Min: 3.5 GPA"
FROM roster
GROUP BY finalgrade, studentkey
HAVING AVG(finalgrade) >= 3.50
ORDER BY finalgrade DESC, studentkey ASC;