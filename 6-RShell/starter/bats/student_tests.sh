#!/usr/bin/env bats

# File: student_tests.sh
# 
# Create your unit tests suit in this file

## Server Setup for Shell P4 Tests

setup() {
  # Start the server in the background
  ./dsh -s -i 127.0.0.1 -p 1234 &
  SERVER_PID=$!
  sleep 1  # Give the server time to start
}

teardown() {
  # Kill the server after the test
  if [ "$NO_KILL_NEEDED" != "true" ]; then
    kill $SERVER_PID
  fi
}

## Shell P2 Tests (UPDATED)

@test "Local: check ls runs without errors" {
    run ./dsh <<EOF                
ls
EOF

    # Assertions
    [ "$status" -eq 0 ]
}

@test "Local: exit command works" {
    run ./dsh <<EOF
exit
EOF

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"

    [ "$status" -eq 0 ]
}

@test "Local: exit command works with unnecessary arg" {
    run ./dsh <<EOF
exit arg1
EOF

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"

    [ "$status" -eq 0 ]
}

@test "Local: cd to non-existent directory" {
    run ./dsh <<EOF
cd /does/not/exist
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="cdfailed:Nosuchfileordirectorylocalmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "Local: cd with multiple arguments" {
    run ./dsh <<EOF
cd /tmp /var
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="cd:toomanyarguments:Successlocalmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
}

@test "Local: ls command works" {
    run ./dsh <<EOF
ls
EOF

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"

    [ "$status" -eq 0 ]
}

@test "Local: ls command with arg" {
    run ./dsh <<EOF
ls bats /var
EOF

    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')
    expected_output="/var:backupscacheliblocallocklogmailoptrunspooltmpwwwbats:assignment_tests.shstudent_tests.shlocalmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
}

@test "Local: ls command with multiple args" {
    run ./dsh <<EOF
ls bats 
EOF

    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')
    expected_output="assignment_tests.shstudent_tests.shlocalmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
}

@test "Local: pwd works correctly" {
    run ./dsh <<EOF
pwd
EOF

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"

    [ "$status" -eq 0 ]
}

@test "Local: pwd works with unnecessary arg" {
    run ./dsh <<EOF
pwd arg1
EOF

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"

    [ "$status" -eq 0 ]
}

@test "Local: echo command with no arguments" {
    run ./dsh <<EOF
echo
EOF

    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')
    expected_output="localmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
}

@test "Local: echo command with unquoted and quotes arguments" {
    run ./dsh <<EOF
echo unquoted "   quoted   args   "
EOF

    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')
    expected_output="unquotedquotedargslocalmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
}

@test "Local: echo command with internal quotes" {
    run ./dsh <<EOF
echo "   'internal quotes' quoted   args   "
EOF

    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')
    expected_output="'internalquotes'quotedargslocalmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
}

@test "Local: echo command with unclosed quote" {
    run ./dsh <<EOF
echo "unclosed quote
EOF

    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')
    expected_output="unclosedquotelocalmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
}

@test "Local: which command works" {
    run ./dsh <<EOF
which ls
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"

    [ -n "$stripped_output" ] 
    [ "$status" -eq 0 ]
}

@test "Local: empty command passes" {
    run ./dsh <<EOF
EOF

    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')

    expected_output="localmodedsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
}

@test "Local: invalid command returns an error" {
    run ./dsh <<EOF
nonexistentcommand
EOF

    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')

    expected_output="execvpfailed:Nosuchfileordirectorylocalmodedsh4>localmodedsh4>dsh4>cmdloopreturned127"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
}

@test "Local: trailing/leading spaces" {
    run ./dsh <<EOF
  ls  
EOF

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"

    [ "$status" -eq 0 ]
}

## Shell P3 Tests (UPDATED)

# Pipeline test

@test "Local: single pipe" {
    run ./dsh <<EOF
echo hello | cat
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="hellolocalmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "Local: multiple pipes" {
    run ./dsh <<EOF
ls | grep .c | wc -l
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="4localmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "Local: under 8 command limit" {
    run ./dsh <<EOF
ls | grep .c | wc -l | ls | grep .c | wc -l | ls
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="batsdshdsh_cli.cdshlib.cdshlib.hmakefilereadme.mdrsh_cli.crsh_server.crshlib.hlocalmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "Local: on 8 command limit" {
    run ./dsh <<EOF
ls | grep .c | wc -l | ls | grep .c | wc -l | ls | grep .c
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="dsh_cli.cdshlib.crsh_cli.crsh_server.clocalmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "Local: over 8 command limit" {
    run ./dsh <<EOF
ls | grep .c | wc -l | ls | grep .c | wc -l | ls | grep .c | wc -l
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="localmodedsh4>error:pipinglimitedto8commandsdsh4>cmdloopreturned-2"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "Local: non existent command before pipe" {
    run ./dsh <<EOF
non_existent_cmd | ls
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="execvpfailed:Nosuchfileordirectorybatsdshdsh_cli.cdshlib.cdshlib.hmakefilereadme.mdrsh_cli.crsh_server.crshlib.hlocalmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "Local: non existent command after pipe" {
    run ./dsh <<EOF
ls | non_existent_cmd
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="execvpfailed:Nosuchfileordirectorylocalmodedsh4>localmodedsh4>dsh4>cmdloopreturned250"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "Local: pipe as first command" {
    run ./dsh <<EOF
| ls
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="localmodedsh4>dsh3:syntaxerrornearunexpectedtoken'|'dsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "Local: pipe w/ no second command" {
    run ./dsh <<EOF
ls |
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="batsdshdsh_cli.cdshlib.cdshlib.hmakefilereadme.mdrsh_cli.crsh_server.crshlib.hlocalmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "Local: two pipes w/ no second command" {
    run ./dsh <<EOF
ls | | grep .c
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="dsh3:syntaxerrornearunexpectedtoken'|'localmodedsh4>dsh4>cmdloopreturned-4"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "Local: pipe attached to first command" {
    run ./dsh <<EOF
ls| cat
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="batsdshdsh_cli.cdshlib.cdshlib.hmakefilereadme.mdrsh_cli.crsh_server.crshlib.hlocalmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "Local: pipe attached to second command" {
    run ./dsh <<EOF
ls |cat
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="batsdshdsh_cli.cdshlib.cdshlib.hmakefilereadme.mdrsh_cli.crsh_server.crshlib.hlocalmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "Local: pipe itself" {
    run ./dsh <<EOF
|
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="localmodedsh4>dsh3:syntaxerrornearunexpectedtoken'|'dsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "Local: pipe with built-in functions" {
    run ./dsh <<EOF
cd | exit
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="error:built-incommandcannotbepipelinedlocalmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "Local: pipe with external functions" {
    run ./dsh <<EOF
ls | echo hello
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="hellolocalmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "Local: pipe with built-in and external functions" {
    run ./dsh <<EOF
ls | cd
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="localmodedsh4>error:built-incommandcannotbepipelineddsh4>cmdloopreturned-4"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "Local: non-existing file or directory as first argument before a pipe" {
    run ./dsh <<EOF
ls j | echo o
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="ols:cannotaccess'j':Nosuchfileordirectorylocalmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "Local: non-existing file or directory as last argument after a pipe" {
    run ./dsh <<EOF
echo o | ls j
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="ls:cannotaccess'j':Nosuchfileordirectorylocalmodedsh4>dsh4>cmdloopreturned2"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "Local: echo with pipe in quotes" {
    run ./dsh <<EOF
echo "ls | cd "
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="ls|cdlocalmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "Local: false command: quotes with a pipe as the first command" {
    run ./dsh <<EOF
" po | "
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="execvpfailed:Nosuchfileordirectorylocalmodedsh4>localmodedsh4>dsh4>cmdloopreturned250"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

## Shell P4 Tests

# Single command tests

@test "Client: check ls runs without errors" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF                
ls
EOF

    # Assertions
    [ "$status" -eq 0 ]
}

@test "Client: exit command works" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
exit
EOF

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"

    [ "$status" -eq 0 ]
}

@test "Client: exit command works with unnecessary arg" {
    # Run the client command
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
exit arg1
EOF

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"

    [ "$status" -eq 0 ]
}

@test "Client: cd to non-existent directory" {
  # Send a test command to the server using a direct TCP connection or a simple echo to stdin
  run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
cd /does/not/exist
EOF

    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')

    expected_output="socketclientmode:addr:127.0.0.1:1234rsh>cd:/does/not/exist:Nosuchfileordirectoryrsh>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "Client: cd with multiple arguments" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
cd /tmp /var
EOF

    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')

    expected_output="socketclientmode:addr:127.0.0.1:1234rsh>rsh>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
}


@test "Client: ls command works" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
ls
EOF

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"

    [ "$status" -eq 0 ]
}

@test "Client: ls command with arg" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
ls bats /var
EOF

    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')
    expected_output="socketclientmode:addr:127.0.0.1:1234rsh>/var:backupscacheliblocallocklogmailoptrunspooltmpwwwbats:assignment_tests.shstudent_tests.shrsh>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
}

@test "Client: ls command with multiple args" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
ls bats 
EOF

    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')
    expected_output="socketclientmode:addr:127.0.0.1:1234rsh>assignment_tests.shstudent_tests.shrsh>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
}

@test "Client: pwd works correctly" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
pwd
EOF

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"

    [ "$status" -eq 0 ]
}

@test "Client: pwd works with unnecessary arg" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
pwd arg1
EOF

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"

    [ "$status" -eq 0 ]
}

@test "Client: echo command with no arguments" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
echo
EOF

    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')
    expected_output="socketclientmode:addr:127.0.0.1:1234rsh>rsh>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
}

@test "Client: echo command with unquoted and quotes arguments" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
echo unquoted "   quoted   args   "
EOF

    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')
    expected_output="socketclientmode:addr:127.0.0.1:1234rsh>unquotedquotedargsrsh>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
}

@test "Client: echo command with internal quotes" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
echo "   'internal quotes' quoted   args   "
EOF

    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')
    expected_output="socketclientmode:addr:127.0.0.1:1234rsh>'internalquotes'quotedargsrsh>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
}

@test "Client: echo command with unclosed quote" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
echo "unclosed quote
EOF

    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')
    expected_output="socketclientmode:addr:127.0.0.1:1234rsh>unclosedquotersh>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
}

@test "Client: which command works" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
which ls
EOF

stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"

    [ -n "$stripped_output" ] 
    [ "$status" -eq 0 ]
}

@test "Client: empty command passes" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
EOF

    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')

    expected_output="socketclientmode:addr:127.0.0.1:1234rsh>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
}

@test "Client: invalid command returns an error" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
nonexistentcommand
EOF

    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')

    expected_output="socketclientmode:addr:127.0.0.1:1234rsh>socketservermode:addr:127.0.0.1:1234->Single-ThreadedModeError:Commandexecutionfailedrsh>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
}

@test "Client: trailing/leading spaces" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
  ls  
EOF

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"

    [ "$status" -eq 0 ]
}

# Pipeline test

@test "Client: single pipe" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
echo hello | cat
EOF
    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')

    expected_output="socketclientmode:addr:127.0.0.1:1234rsh>hellorsh>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "Client: multiple pipes" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
ls | grep .c | wc -l
EOF
    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')

    expected_output="socketclientmode:addr:127.0.0.1:1234rsh>4rsh>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "Client: under 8 command limit" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
ls | grep .c | wc -l | ls | grep .c | wc -l | ls
EOF
    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')

    expected_output="socketclientmode:addr:127.0.0.1:1234rsh>batsdshdsh_cli.cdshlib.cdshlib.hmakefilereadme.mdrsh_cli.crsh_server.crshlib.hrsh>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "Client: on 8 command limit" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
ls | grep .c | wc -l | ls | grep .c | wc -l | ls | grep .c
EOF
    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')

    expected_output="socketclientmode:addr:127.0.0.1:1234rsh>dsh_cli.cdshlib.crsh_cli.crsh_server.crsh>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "Client: over 8 command limit" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
ls | grep .c | wc -l | ls | grep .c | wc -l | ls | grep .c | wc -l
EOF
    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')

    expected_output="socketclientmode:addr:127.0.0.1:1234rsh>error:pipinglimitedto8commandsrsh>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "Client: non existent command before pipe" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
non_existent_cmd | ls
EOF
    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')

    expected_output="socketclientmode:addr:127.0.0.1:1234rsh>batsdshdsh_cli.cdshlib.cdshlib.hmakefilereadme.mdrsh_cli.crsh_server.crshlib.hrsh>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "Client: non existent command after pipe" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
ls | non_existent_cmd
EOF
    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')

    expected_output="socketclientmode:addr:127.0.0.1:1234rsh>socketservermode:addr:127.0.0.1:1234->Single-ThreadedModePipe0createdError:Commandexecutionfailedrsh>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "Client: pipe as first command" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
| ls
EOF
    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')

    expected_output="socketclientmode:addr:127.0.0.1:1234rsh>Error:commandparsingfailedrsh>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "Client: pipe w/ no second command" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
ls |
EOF
    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')

    expected_output="socketclientmode:addr:127.0.0.1:1234rsh>batsdshdsh_cli.cdshlib.cdshlib.hmakefilereadme.mdrsh_cli.crsh_server.crshlib.hrsh>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "Client: two pipes w/ no second command" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
ls | | grep .c
EOF
    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')

    expected_output="socketclientmode:addr:127.0.0.1:1234rsh>Error:commandparsingfailedrsh>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "Client: pipe attached to first command" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
ls| cat
EOF
    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')

    expected_output="socketclientmode:addr:127.0.0.1:1234rsh>batsdshdsh_cli.cdshlib.cdshlib.hmakefilereadme.mdrsh_cli.crsh_server.crshlib.hrsh>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "Client: pipe attached to second command" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
ls |cat
EOF
    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')

    expected_output="socketclientmode:addr:127.0.0.1:1234rsh>batsdshdsh_cli.cdshlib.cdshlib.hmakefilereadme.mdrsh_cli.crsh_server.crshlib.hrsh>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "Client: pipe itself" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
|
EOF
    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')

    expected_output="socketclientmode:addr:127.0.0.1:1234rsh>Error:commandparsingfailedrsh>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "Client: pipe with built-in functions" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
cd | exit
EOF
    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')

    expected_output="socketclientmode:addr:127.0.0.1:1234rsh>rsh>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "Client: pipe with external functions" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
ls | echo hello
EOF
    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')

    expected_output="socketclientmode:addr:127.0.0.1:1234rsh>hellorsh>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "Client: pipe with built-in and external functions" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
ls | cd
EOF
    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')

    expected_output="socketclientmode:addr:127.0.0.1:1234rsh>socketservermode:addr:127.0.0.1:1234->Single-ThreadedModePipe0createdError:Commandexecutionfailedrsh>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "Client: non-existing file or directory as first argument before a pipe" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
ls j | echo o
EOF
    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')

    expected_output="socketclientmode:addr:127.0.0.1:1234rsh>orsh>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "Client: non-existing file or directory as last argument after a pipe" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
echo o | ls j
EOF
    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')

    expected_output="socketclientmode:addr:127.0.0.1:1234rsh>Error:Commandexecutionfailedrsh>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "Client: echo with pipe in quotes" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
echo "ls | cd "
EOF
    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')

    expected_output="socketclientmode:addr:127.0.0.1:1234rsh>ls|cdrsh>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "Client: Client: false command: quotes with a pipe as the first command" {
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
" po | "
EOF
    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')

    expected_output="socketclientmode:addr:127.0.0.1:1234rsh>socketservermode:addr:127.0.0.1:1234->Single-ThreadedModeError:Commandexecutionfailedrsh>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

## Exit and Stop-Server Commands

@test "Client: exit command {
    
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
exit
EOF

    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')

    expected_output="socketclientmode:addr:127.0.0.1:1234rsh>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "Client: stop-server command" {
    export NO_KILL_NEEDED="true"
    run ./dsh -c -i 127.0.0.1 -p 1234 <<EOF
stop-server
EOF

    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v' | tr -d '[:space:]' | tr -cd '\11\12\15\40-\176')

    expected_output="connect:Connectionrefusedstartclient:Invalidargumentsocketclientmode:addr:127.0.0.1:1234cmdloopreturned-52"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    if ps -p $SERVER_PID > /dev/null; then
        echo "Server process is still running, test failed."
        exit 1
    else
        echo "Server process successfully killed."
    fi

    # Check exact match
    [ $status -eq 0 ]
}