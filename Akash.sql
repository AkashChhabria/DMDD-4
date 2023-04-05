SET SERVEROUTPUT ON;

CREATE TABLE department (
  dept_id NUMBER(5) NOT NULL PRIMARY KEY,
  dept_name VARCHAR2(20) UNIQUE NOT NULL,
  dept_location VARCHAR2(2) NOT NULL
);

CREATE SEQUENCE dept_id_seq START WITH 1;

INSERT INTO department (dept_id, dept_name, dept_location) VALUES (dept_id_seq.NEXTVAL, 'Marketing', 'MA');
INSERT INTO department (dept_id, dept_name, dept_location) VALUES (dept_id_seq.NEXTVAL, 'Sales', 'TX');
INSERT INTO department (dept_id, dept_name, dept_location) VALUES (dept_id_seq.NEXTVAL, 'Finance', 'IL');
INSERT INTO department (dept_id, dept_name, dept_location) VALUES (dept_id_seq.NEXTVAL, 'Engineering', 'CA');
INSERT INTO department (dept_id, dept_name, dept_location) VALUES (dept_id_seq.NEXTVAL, 'Human Resources', 'NY');
INSERT INTO department (dept_id, dept_name, dept_location) VALUES (dept_id_seq.NEXTVAL, 'IT', 'NJ');

CREATE OR REPLACE PROCEDURE MODIFY_DEPT(
    p_name IN VARCHAR2,
    p_location IN VARCHAR2
)
IS
    v_dept_name VARCHAR2(40);
    v_count NUMBER;
BEGIN
    -- Validate department name
    IF p_name IS NULL OR LENGTH(p_name) = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Department name cannot be null or empty.');
    ELSIF REGEXP_LIKE(p_name, '^[0-9]+$') THEN
        RAISE_APPLICATION_ERROR(-20002, 'Department name cannot be a number.');
    END IF;

    -- Convert department name to camel case
    v_dept_name := INITCAP(p_name);

    -- Validate department location
    IF NOT p_location IN ('MA', 'TX', 'IL', 'CA', 'NY', 'NJ', 'NH', 'RH') THEN
        RAISE_APPLICATION_ERROR(-20003, 'Department location is not valid.');
    END IF;
    
    -- Check if department name length is more than 20 chars
    IF LENGTH(p_name) > 20 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Department name cannot be more than 20 characters.');
    END IF;
    
    -- Check if department name already exists
    SELECT COUNT(*) INTO v_count FROM DEPARTMENT WHERE dept_name = v_dept_name;
    IF v_count = 0 THEN
        -- Insert new department
        INSERT INTO DEPARTMENT(dept_id, dept_name, dept_location)
        VALUES(dept_id_seq.NEXTVAL, v_dept_name, p_location);
        DBMS_OUTPUT.PUT_LINE('Department inserted successfully.');
    ELSE
        -- Update department location
        UPDATE DEPARTMENT SET dept_location = p_location WHERE dept_name = v_dept_name;
        DBMS_OUTPUT.PUT_LINE('Department updated successfully.');
    END IF;
    COMMIT;
END;
/
--TEST CASE TO INSERT A DEPARTMENT WITH A NULL NAME
BEGIN
    MODIFY_DEPT(NULL, 'NY');
END;
/
--TEST CASE TO INSERT A DEPARTMENT WITH EMPTY NAME (ZERO LENGTH)
BEGIN
    MODIFY_DEPT('', 'NY');
END;
/
--TEST CASE TO INERT A DEPARTMENT NAME WITH A NUMBER
BEGIN
    MODIFY_DEPT(123, 'NY');
END;
/
-- TEST CASE TO INSERT A DEPARTMENT WITH INVALID LOCATION
BEGIN
    MODIFY_DEPT('Marketing', 'TN');
END;
/
--TEST CASE TO INSERT A DEPARTMENT NAME WITH MORE THAN 20 CHARACTERS
BEGIN
    MODIFY_DEPT('abcdefghijklmnopqrstuvwxyz', 'NY');
END;
/
-- TEST CASE TO INSERT A DEPARTMENT IF NAME DOESN'T EXIST
BEGIN
    MODIFY_DEPT('Departmenttt', 'CA');
END;
/
--TEST CASE TO UPDATE A DEPARTMENT LOCATION IF NAME EXISTS
BEGIN
    MODIFY_DEPT('Marketing', 'NY');
END;
/
--TEST CASE TO CONVERT DEPARTMENT NAME TO CAMELCASE
BEGIN
    MODIFY_DEPT('camelcase', 'NY');
END;
/
BEGIN
    MODIFY_DEPT('CAMELCASEEE', 'CA');
END;
/
BEGIN
    MODIFY_DEPT('CH@RACTER', 'CA');
END;
/
