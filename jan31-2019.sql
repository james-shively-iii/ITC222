--INSERTS, UPDATES, and DELETES

--      **INSERTS**     --
INSERT INTO person(personlastname, personfirstname, 
personemail, personprimaryphone, persondateadded)
VALUES('Mouse', 'Mickey', 'mm@disney.com', 
'2065551470', current_timestamp);

INSERT INTO personaddress(personkey, personaddressstreet,
personaddresszipcode)
--using CURRVAL('table_column_seq') meaning current value in sequence
VALUES(CURRVAL('person_personkey_seq'),'100 South Enchanted', '98001');

INSERT INTO logintable(personkey, personusername, personpassword)
SELECT CURRVAL('person_personkey_seq'),
LOWER(SUBSTRING(personfirstname, 1,1)|| personlastname),
createpassword(personlastname || 'Pass')
FROM person WHERE personkey=CURRVAL('person_personkey_seq');

SELECT * FROM person;
SELECT * FROM personaddress WHERE personkey > 130;
SELECT * FROM logintable WHERE personkey>130;

INSERT INTO jobposition(positionname)
VALUES('vice president'),
('cook and bottle washer'),
('garbage dumper');

--      **UPDATES**     --
UPDATE person
SET personlastname='Hamilton',
personemail='lindahamilton@gmail.com'
WHERE personkey=2;

SELECT personlastname, personfirstname, personemail 
INTO emaillist FROM person;

UPDATE emaillist
SET personlastname='Smith';

UPDATE granttype
SET granttypeonetimemax=granttypeonetimemax * 1.05,
granttypelifetimemax=granttypelifetimemax * 1.05;

--      **DELETE**      --
DELETE FROM personaddress WHERE personkey=134;
DELETE FROM logintable WHERE personkey=134;
DELETE FROM person WHERE personkey=134;
DELETE FROM jobposition WHERE positionkey>11;


--      **CREATING TRANSACTION INSTANCE**       --
--Begins a transaction to help work on a specific instance
BEGIN TRANSACTION;
--Rollbacks all changes to the instance you created
ROLLBACK TRANSACTION;
--Commits all changes to the instance you created
COMMIT TRANSACTION;
