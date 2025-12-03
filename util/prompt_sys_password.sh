#!/bin/bash
# -----------------------------------------------------------------------------
# prompt_sys_password.sh
# -----------------------------------------------------------------------------
# Prompts the user for the sys password and validates it using a connection test.
#
# Assumes:
# - The 'test_db_connection' function is already defined (sourced from another utility).
# - Global variables DB_USER and DB_PDB_SERVICE_NAME are set in the calling script.
#
# Output:
# - Returns the valid password to the calling script via 'echo'.
# - Exits the entire shell environment with a status of 1 on maximum attempts failure.
# -----------------------------------------------------------------------------

# Function to prompt for and validate the SYS password
function prompt_sys_password() {
    # Ensure necessary global variables are available for use in this function
    local DB_USER=$1
    local DB_PDB_SERVICE_NAME=$2
    
    local DB_PASS=""
    local MAX_ATTEMPTS=3
    local ATTEMPTS=0

    while [ "$ATTEMPTS" -lt "$MAX_ATTEMPTS" ]; do
        echo -n "Enter the DB_PASS for user '$DB_USER' for connection to '$DB_PDB_SERVICE_NAME': " > /dev/tty
        read -r -s DB_PASS </dev/tty
        echo "" > /dev/tty

        # Test the connection using the function from test_db_connection.sh
        echo "--- Testing Database Connection ($((ATTEMPTS + 1))/$MAX_ATTEMPTS) ---"
        # The test_db_connection function prints its own success/failure message
        test_db_connection "$DB_USER" "$DB_PASS" "$DB_PDB_SERVICE_NAME" 

        if [ $? -eq 0 ]; then
            # Validation successful
            echo "--- Connection validated. ---"
            echo "$DB_PASS" # RETURN the valid password via echo
            return 0
        else
            ATTEMPTS=$((ATTEMPTS + 1))
            echo "--- Invalid password or connection error. Please try again. ---"
        fi
    done

    # If the loop completes without success
    echo ""
    echo "!!! CRITICAL FAILURE: Maximum login attempts reached. Aborting deployment verification. !!!"
    # Note: Using 'exit' here will exit the main script since this function is sourced.
    exit 1
}
