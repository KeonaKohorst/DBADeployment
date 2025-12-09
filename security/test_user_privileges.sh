#!/bin/bash

# ===========================================================
# Test User Privileges Script
# ===========================================================

su - oracle -c "sqlplus -s / as sysdba << 'EOF'

ALTER SESSION SET CONTAINER = ORCLPDB;

SET SERVEROUTPUT ON
SET DEFINE OFF
SET LINESIZE 200
SET PAGESIZE 200

PROMPT =====================================================
PROMPT  PRIVILEGE & ROLE VERIFICATION REPORT (READ-ONLY)
PROMPT =====================================================
PROMPT

DECLARE
    TYPE role_list IS TABLE OF VARCHAR2(50);

    kgag_roles  role_list := role_list('DBA','SYSDBA');
    aant_roles  role_list := role_list('DBA','SYSDBA','ADVISOR');
    cjor_roles  role_list := role_list('DBA','SYSOPER');
    eitu_roles  role_list := role_list('DBA','SYSOPER','ADVISOR');
    cdem_roles  role_list := role_list('DBA','SYSOPER');

    app_readonly_privs role_list := role_list('CREATE SESSION','SELECT');
    ml_analyst_privs   role_list := role_list(
                                'CREATE SESSION',
                                'SELECT ANY TABLE',
                                'CREATE MATERIALIZED VIEW',
                                'CREATE SYNONYM');
    ml_developer_privs role_list := role_list(
                                'CREATE SESSION',
                                'CREATE TABLE',
                                'CREATE VIEW');
    stock_user_privs   role_list := role_list(
                                'CREATE SESSION',
                                'CREATE TABLE',
                                'CREATE SEQUENCE');

    FUNCTION has_role(p_user VARCHAR2, p_role VARCHAR2) RETURN BOOLEAN IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM dba_role_privs
        WHERE grantee = UPPER(p_user)
        AND granted_role = UPPER(p_role);
        RETURN (v_count > 0);
    END;

    FUNCTION has_sys_priv(p_user VARCHAR2, p_priv VARCHAR2) RETURN BOOLEAN IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM dba_sys_privs
        WHERE grantee = UPPER(p_user)
        AND privilege = UPPER(p_priv);
        RETURN (v_count > 0);
    END;

    PROCEDURE check_roles(p_user VARCHAR2, p_roles role_list) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('--- Checking expected roles for ' || p_user);
        FOR i IN 1 .. p_roles.COUNT LOOP
            IF has_role(p_user, p_roles(i)) THEN
                DBMS_OUTPUT.PUT_LINE('PASS: ' || p_roles(i) || ' granted');
            ELSE
                DBMS_OUTPUT.PUT_LINE('FAIL: ' || p_roles(i) || ' NOT granted');
            END IF;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('');
    END;

    PROCEDURE list_roles(p_user VARCHAR2) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Roles actually granted to ' || p_user || ':');
        FOR r IN (
            SELECT granted_role
            FROM dba_role_privs
            WHERE grantee = UPPER(p_user)
            ORDER BY granted_role
        )
        LOOP
            DBMS_OUTPUT.PUT_LINE('  - ' || r.granted_role);
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('');
    END;

    PROCEDURE check_sys_privs(p_user VARCHAR2, p_privs role_list) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('--- Checking system privileges for ' || p_user);
        FOR i IN 1 .. p_privs.COUNT LOOP
            IF has_sys_priv(p_user, p_privs(i)) THEN
                DBMS_OUTPUT.PUT_LINE('PASS: ' || p_privs(i) || ' granted');
            ELSE
                DBMS_OUTPUT.PUT_LINE('FAIL: ' || p_privs(i) || ' NOT granted');
            END IF;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('');
    END;

BEGIN
    DBMS_OUTPUT.PUT_LINE('==================== DBA USERS ====================');

    list_roles('C##KGAG');
    list_roles('C##AANT');
    list_roles('C##CJOR');
    list_roles('C##EITU');
    list_roles('C##CDEM');
    DBMS_OUTPUT.PUT_LINE('');

    check_roles('C##KGAG', kgag_roles);
    check_roles('C##AANT', aant_roles);
    check_roles('C##CJOR', cjor_roles);
    check_roles('C##EITU', eitu_roles);
    check_roles('C##CDEM', cdem_roles);

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('================ APPLICATION USERS =================');

    list_roles('APP_READONLY');
    list_roles('ML_ANALYST');
    list_roles('ML_DEVELOPER');
    list_roles('STOCK_USER');
    DBMS_OUTPUT.PUT_LINE('');

    check_sys_privs('APP_READONLY', app_readonly_privs);
    check_sys_privs('ML_ANALYST', ml_analyst_privs);
    check_sys_privs('ML_DEVELOPER', ml_developer_privs);
    check_sys_privs('STOCK_USER', stock_user_privs);

END;
/
EXIT;
EOF"

