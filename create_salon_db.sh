#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=postgres -t -c"

DATABASE=$($PSQL "SELECT 1 FROM pg_database WHERE datname = 'salon'")

# if there isn't a database
if [[ -z $DATABASE ]]
then
  # create database
  RESULTS=$($PSQL "CREATE DATABASE salon")
  echo $RESULTS
  echo "created database"

  # create tables
  SQL="psql -X --username=freecodecamp --dbname=salon -t -c"
  CUSTOMERS=$($SQL "CREATE TABLE customers(customer_id SERIAL PRIMARY KEY, phone VARCHAR(12) UNIQUE, name VARCHAR(30))")
  SERVICES=$($SQL "CREATE TABLE services(service_id SERIAL PRIMARY KEY, name VARCHAR(30))")
  APPOINTMENTS=$($SQL "CREATE TABLE appointments(appointment_id SERIAL PRIMARY KEY, customer_id INT, service_id INT, time VARCHAR(10), CONSTRAINT customer_id_fkey FOREIGN KEY (customer_id) REFERENCES customers(customer_id), CONSTRAINT service_id_fkey FOREIGN KEY (service_id) REFERENCES services(service_id))")

  echo "Inserted $CUSTOMERS, $SERVICES, $APPOINTMENTS"

  # add different services
  SERVICES_ROWS=$($SQL "INSERT INTO services(name) VALUES('cut'), ('dye'), ('style'), ('wash'), ('massage')")

# if there is a database
  else
    echo -e "\nThere already is a salon db, would you like to delete it?"
    echo -e "\nyes\nno\n--------"
    read CHOICE

    if [[ $CHOICE = "yes" ]]
    then
      RESULT=$($PSQL "DROP DATABASE salon")
      if [[ $RESULT = 'DROP DATABASE' ]]
      then
        echo -e "\nDeleted salon"
      else
        echo -e "\n\033[31m$RESULT"
      fi
    else
      echo "Did not delete salon"
    fi
fi
echo -e "\n~~~ Complete ~~~\n"
