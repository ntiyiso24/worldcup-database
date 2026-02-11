#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Clear existing data
$PSQL "TRUNCATE TABLE games, teams"

# Read the CSV file and insert unique teams
cat games.csv | tail -n +2 | while IFS=',' read year round winner opponent winner_goals opponent_goals
do
  # Insert winner into teams table if not already there
  $PSQL "INSERT INTO teams(name) VALUES('$winner') ON CONFLICT DO NOTHING"
  
  # Insert opponent into teams table if not already there
  $PSQL "INSERT INTO teams(name) VALUES('$opponent') ON CONFLICT DO NOTHING"
done

# Insert games data
cat games.csv | tail -n +2 | while IFS=',' read year round winner opponent winner_goals opponent_goals
do
  # Get the team IDs
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")
  
  # Insert the game
  $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', $WINNER_ID, $OPPONENT_ID, $winner_goals, $opponent_goals)"
done
