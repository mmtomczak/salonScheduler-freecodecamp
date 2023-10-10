#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?"

MAIN_MENU(){
  # if message is passed
  if [[ $1 ]]
  then
    # print message
    echo -e '\n'$1
  fi
  # get available services
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  # list available services
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo -e "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  # get selected service name
  SELECTED_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  # if service name not found
  if [[ -z $SELECTED_SERVICE_NAME ]]
  then
    # return to main menu
    MAIN_MENU "\nI could not find that service. What would you like today?"
  else
    # ask for customer's phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    # get customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    # if customer not present in the database
    if [[ -z $CUSTOMER_ID ]]
    then
      # ask for customer name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      CUSTOMER_INSERT_RESUL=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      # get customer id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    fi
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
    # ask for service time
    echo -e "\nWhat time would you like your $SELECTED_SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME
    # add appointment and inform the customer
    APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $(echo $SELECTED_SERVICE_NAME | sed 's/ *^//') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/ *^//')."
  fi
}
MAIN_MENU

