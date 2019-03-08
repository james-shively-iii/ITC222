--system queries
SELECT * FROM information_schema.tables
WHERE table_schema='public';

SELECT table_schema, table_name, is_updatable
FROM information_schema.

SELECT table_catalog, table_schema, table_name, table_type
FROM INFORMATION_SCHEMA.TABLES
WHERE NOT table_schema='pg_catalog'
AND NOT table_schema='information_schema';

SELECT column_name, data_type, constraint_name, constraint_type
FROM information_schema.columns
JOIN information_schema.table_constraints
ON information_schema.columns.table_name=information_schema.constraints.table_name
WHERE information_schema.columns.table_name='grantapplication'
ORDER BY column_name;

--index
CREATE INDEX ON person(personlastname);

ALTER INDEX person_personlastname_idx
rename to idx_lastname;

SELECT grantapplicationkey, grantapplicationdate, personlastname, grantapplicationamount
FROM grantapplication
JOIN person
USING (personkey)
WHERE personlastname='Blake';

CREATE UNIQUE INDEX ON person(personprimaryphone);

CREATE INDEX ON grantapplication(granttypekey,personkey);

CREATE ROLE employeerole;

GRANT CONNECT ON database communityassistpg TO employeerole;
GRANT USAGE ON SCHEMA public TO employeerole;
GRANT SELECT ON TABLES IN SCHEMA PUBLIC TO employeerole;
GRANT USAGE ON SCHEMA employeeschema TO employeerole;
GRANT SELECT ON TABLES IN SCHEMA employeeschema TO employeerole;


CREATE ROLE janderson WITH PASSWORD 'P@ssw0rd1' LOGIN INHERIT;
GRANT employeerole to janderson;