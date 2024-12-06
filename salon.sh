#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon -t -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  # echo argument passed to MAIN_MENU
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  # greet customer
  echo -e "Welcome to My Salon, how can I help you?\n"
  # display service selection
  SERVICES=$($PSQL "SELECT * FROM SERVICES")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  # if chosen selection doesn't exist
  if [[ $SERVICE_ID_SELECTED -gt 5 || $SERVICE_ID_SELECTED -lt 1 ]]
  then
    # send back to MAIN_MENU
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # otherwise, ask for phone
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    # if not already a customer
    OLDCUSTOMER=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    if [[ -z $OLDCUSTOMER ]]
    then
      # ask for name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      # add customer
      ADDCUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi
    # format | get variables
    UNFORMATTED_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    SERVICE=$(echo $UNFORMATTED_SERVICE | sed 's/ //g' )
    UNFORMATTED_CUSTOMER=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    CUSTOMER=$(echo $UNFORMATTED_CUSTOMER | sed 's/ //g')
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    # ask for a time
    echo -e "\nWhat time would you like your $SERVICE, $CUSTOMER?"
    read SERVICE_TIME
    # schedule an appointment
    ADDTIME=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    # confirm with customer
    echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER."
  fi
}
MAIN_MENU
