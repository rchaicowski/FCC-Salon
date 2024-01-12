PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  LIST_SERVICES=$($PSQL "SELECT * FROM services")
  echo "$LIST_SERVICES" | while read SERVICE_ID _ SERVICE
  do
    ID=$(echo "$SERVICE_ID" | sed 's/ //g')
    NAME=$(echo "$SERVICE" | sed 's/ //g')
    echo "$ID) $SERVICE"
  done
  echo
  read -p "Enter the service ID: " SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in
  [1-3]) NEXT ;;
    *)
      echo "I couldn't find that service. Please choose a valid service."
      MAIN_MENU
      ;;
  esac
}

NEXT() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  
  CUSTOMER_NAME=$( $PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'" | sed 's/ //g')
  if [[ -z $CUSTOMER_NAME ]]; then
    echo -e "\nI don't have a record for that phone number. What's your name?"
    read CUSTOMER_NAME
    $PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')"
  fi
  
  GET_SERVICE_NAME=$( $PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED" | sed 's/ //g')
  CUSTOMER_ID=$( $PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  
  
  while true; do
  echo -e "\nWhat time would you like your $GET_SERVICE_NAME, $CUSTOMER_NAME? (HH:MM)"
  read SERVICE_TIME

  
  if [[ $SERVICE_TIME =~ ^([0][9]|1[0-7]):[0-5][0-9]$ ]]; then
    break  
  else
    echo "Invalid time. Please enter a time between 09:00 and 18:00."
  fi
done

  SAVED_TO_TABLE_APPOINTMENTS=$( $PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  if [[ $SAVED_TO_TABLE_APPOINTMENTS == "INSERT 0 1" ]]; then
    echo -e "\nI have scheduled a $GET_SERVICE_NAME for you at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU
