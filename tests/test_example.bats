#!/usr/bin/env bats

function setup() {
  # run the example server each time
  ./example.native &
  pid=$!
}

function teardown() {
  kill "$pid"
}

function rset() {
  curl -X POST 'localhost:4000/set' -d "$1" | jq "$2" -c
}

function rget() {
  curl -X POST 'localhost:4000/get' -d "$1" | jq "$2" -c
}

@test "test set and get keys" {
  run rset '{"you are": "cool"}' .response
  echo "${lines[3]}"
  [ "${lines[3]}" = '"ok"' ]
  [ "$status" -eq 0 ]

  run rget '"you are"' .response
  echo "${lines[3]}"
  [ "${lines[3]}" = '"cool"' ]
  [ "$status" -eq 0 ]

  run rset '{"they are": "cool", "you are": "strange"}' .response
  echo "${lines[3]}"
  [ "${lines[3]}" = '"ok"' ]
  [ "$status" -eq 0 ]

  run rget '"you are"' .response
  echo "${lines[3]}"
  [ "${lines[3]}" = '"strange"' ]
  [ "$status" -eq 0 ]

  run rget '"they are"' .response
  echo "${lines[3]}"
  [ "${lines[3]}" = '"cool"' ]
  [ "$status" -eq 0 ]
}

@test "test get key malformed input" {
  run rget '23' .
  echo "${lines[3]}"
  [ "${lines[3]}" = '{"error":"incorrect type : string","error_data":23}' ]
  [ "$status" -eq 0 ]
}

@test "test set key malformed input" {
  run rset '23' .
  echo "${lines[3]}"
  [ "${lines[3]}" = '{"error":"incorrect type : should be a dictionary of strings","error_data":23}' ]
  [ "$status" -eq 0 ]
}
