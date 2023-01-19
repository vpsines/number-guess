#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USER_RESULT=$($PSQL "SELECT * FROM users WHERE username='$USERNAME';")

#check for user
if [[ -z $USER_RESULT ]]
  then
  # add user
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username,games_played,best_game) VALUES('$USERNAME',0,0);")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  echo "$USER_RESULT" | while IFS="|" read USER USER_ID GAMES_PLAYED BEST_GAME   
  do
    echo "Welcome back, $USER! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

NUMBER=$((1 + $RANDOM % 1000))
NO_OF_GUESSES=0

echo "Guess the secret number between 1 and 1000:"

while true
do
  read GUESS

  # check if input is a number
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    # increment guess count
    NO_OF_GUESSES=$((NO_OF_GUESSES + 1))
    if [[ $GUESS < $NUMBER ]]
      then
      echo "It's higher than that, guess again:"  
    elif [[ $GUESS > $NUMBER ]]
      then
      echo "It's lower than that, guess again:"
    else
      echo "You guessed it in $NO_OF_GUESSES tries. The secret number was $NUMBER. Nice job!"
      break
    fi
  else
      # alert user input is not a number
      echo "That is not an integer, guess again:"
  fi
done

# get user details
USER_RESULT=$($PSQL "SELECT * FROM users WHERE username='$USERNAME';")
echo "$USER_RESULT" | while IFS="|" read USER USER_ID GAMES_PLAYED BEST_GAME   
do
  # check if best game
  if [[ $GAMES_PLAYED == 0 ]] || [[ $NO_OF_GUESSES < $BEST_GAME ]]
    then
      # update best game
      UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game=$NO_OF_GUESSES WHERE user_id=$USER_ID;")
  fi

  # increment games played
  GAMES_PLAYED=$((GAMES_PLAYED + 1))
  # update games played
  UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE user_id=$USER_ID;")
done
