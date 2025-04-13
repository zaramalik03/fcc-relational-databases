#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"


echo "Enter your username:"
read USERNAME

# get user id
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ -z $USER_ID ]]
then
  # add player to database
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"
  INSERT_USERNAME=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME')")
else
  # get username/best game data & remove unecessary spaces
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games INNER JOIN users USING(user_id) WHERE username ='$USERNAME'")
  GAMES_PLAYED_FORMATTED=$(echo $GAMES_PLAYED | sed 's/^ *//;s/ *$//')

  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games INNER JOIN users USING(user_id) WHERE username ='$USERNAME'")
  BEST_GAME_FORMATTED=$(echo $BEST_GAME | sed 's/^ *//;s/ *$//')
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED_FORMATTED games, and your best game took $BEST_GAME_FORMATTED guesses.\n"

fi

# generate random number between 1 and 1000
SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))

# variable to store number of guesses/tries
TRIES=0
NUMBER_GUESSED=0

# prompt guess
echo "Guess the secret number between 1 and 1000:"

# loop to prompt user to guess until correct
while [[ $NUMBER_GUESSED -ne $SECRET_NUMBER ]]
do
  read NUMBER_GUESSED
  # check if guess is valid/an integer
  if [[ ! $NUMBER_GUESSED =~ ^[0-9]+$ ]]
  then
    TRIES=$(($TRIES + 1))
    echo "That is not an integer, guess again:"
  elif [[ $NUMBER_GUESSED -lt $SECRET_NUMBER ]]
  then
    TRIES=$(($TRIES + 1))
    echo "It's higher than that, guess again:"
  elif [[ $NUMBER_GUESSED -gt $SECRET_NUMBER ]]
  then
    TRIES=$(($TRIES + 1))
    echo "It's lower than that, guess again:"
  else 
    TRIES=$(($TRIES + 1))
    echo "You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"
    # Insert data from game
    USER_ID_RESULT=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
    INSERTED_GAME=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID_RESULT, $TRIES)")
    break
  fi
done
