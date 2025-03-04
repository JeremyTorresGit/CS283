#!/usr/bin/env bats

# File: student_tests.sh
# 
# Create your unit tests suit in this file

## Shell P3 Tests

# Pipeline test

@test "single pipe" {
    run ./dsh <<EOF
echo hello | cat
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="hellodsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "multiple pipes" {
    run ./dsh <<EOF
ls | grep .c | wc -l
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="2dsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "under 8 command limit" {
    run ./dsh <<EOF
ls | grep .c | wc -l | ls | grep .c | wc -l | ls
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="batsdshdsh_cli.cdshlib.cdshlib.hmakefiledsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "on 8 command limit" {
    run ./dsh <<EOF
ls | grep .c | wc -l | ls | grep .c | wc -l | ls | grep .c
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="dsh_cli.cdshlib.cdsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "over 8 command limit" {
    run ./dsh <<EOF
ls | grep .c | wc -l | ls | grep .c | wc -l | ls | grep .c | wc -l
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="dsh3>error:pipinglimitedto8commandsdsh3>cmdloopreturned-2"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "non existent command before pipe" {
    run ./dsh <<EOF
non_existent_cmd | ls
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="execvpfailed:Nosuchfileordirectorybatsdshdsh_cli.cdshlib.cdshlib.hmakefiledsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "non existent command after pipe" {
    run ./dsh <<EOF
ls | non_existent_cmd
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="execvpfailed:Nosuchfileordirectorydsh3>dsh3>dsh3>cmdloopreturned250"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "pipe as first command" {
    run ./dsh <<EOF
| ls
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="dsh3>dsh3:syntaxerrornearunexpectedtoken'|'dsh3>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "pipe w/ no second command" {
    run ./dsh <<EOF
ls |
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="batsdshdsh_cli.cdshlib.cdshlib.hmakefiledsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "two pipes w/ no second command" {
    run ./dsh <<EOF
ls | | grep .c
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="dsh3:syntaxerrornearunexpectedtoken'|'dsh3>dsh3>cmdloopreturned-4"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "pipe attached to first command" {
    run ./dsh <<EOF
ls| cat
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="batsdshdsh_cli.cdshlib.cdshlib.hmakefiledsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "pipe attached to second command" {
    run ./dsh <<EOF
ls |cat
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="batsdshdsh_cli.cdshlib.cdshlib.hmakefiledsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "pipe itself" {
    run ./dsh <<EOF
|
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="dsh3>dsh3:syntaxerrornearunexpectedtoken'|'dsh3>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "pipe with built-in functions" {
    run ./dsh <<EOF
cd | exit
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="error:built-incommandcannotbepipelineddsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "pipe with external functions" {
    run ./dsh <<EOF
ls | echo hello
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="hellodsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "pipe with built-in and external functions" {
    run ./dsh <<EOF
ls | cd
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="dsh3>error:built-incommandcannotbepipelineddsh3>cmdloopreturned-4"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "non-existing file or directory as first argument before a pipe" {
    run ./dsh <<EOF
ls j | echo o
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="ols:cannotaccess'j':Nosuchfileordirectorydsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "non-existing file or directory as last argument after a pipe" {
    run ./dsh <<EOF
echo o | ls j
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="ls:cannotaccess'j':Nosuchfileordirectorydsh3>dsh3>cmdloopreturned2"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "echo with pipe in quotes" {
    run ./dsh <<EOF
echo "ls | cd "
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="ls|cddsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "false command: quotes with a pipe as the first command" {
    run ./dsh <<EOF
" po | "
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="execvpfailed:Nosuchfileordirectorydsh3>dsh3>dsh3>cmdloopreturned250"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}



## Shell P2 Tests

<<COMMENT

@test "Example: check ls runs without errors" {
    run ./dsh <<EOF                
ls
EOF

    # Assertions
    [ "$status" -eq 0 ]
}

@test "exit command works" {
    run ./dsh <<EOF
exit
EOF

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"

    [ "$status" -eq 0 ]
}

@test "exit command works with unnecessary arg" {
    run ./dsh <<EOF
exit arg1
EOF

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"

    [ "$status" -eq 0 ]
}

@test "cd to non-existent directory" {
    run ./dsh <<EOF
cd /does/not/exist
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="cdfailed:Nosuchfileordirectorydsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "cd with multiple arguments" {
    run ./dsh <<EOF
cd /tmp /var
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="cd:toomanyarguments:Successdsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
}

@test "ls command works" {
    run ./dsh <<EOF
ls
EOF

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"

    [ "$status" -eq 0 ]
}

@test "ls command with arg" {
    run ./dsh <<EOF
ls bats /var
EOF

    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v')
    expected_output="/var:backupscacheliblocallocklogmailoptrunspooltmpwwwbats:assignment_tests.shstudent_tests.shdsh3> dsh3> cmd loop returned 0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
}

@test "ls command with multiple args" {
    run ./dsh <<EOF
ls bats 
EOF

    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v')
    expected_output="assignment_tests.shstudent_tests.shdsh3> dsh3> cmd loop returned 0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
}

@test "pwd works correctly" {
    run ./dsh <<EOF
pwd
EOF

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"

    [ "$status" -eq 0 ]
}

@test "pwd works with unnecessary arg" {
    run ./dsh <<EOF
pwd arg1
EOF

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"

    [ "$status" -eq 0 ]
}

@test "echo command with no arguments" {
    run ./dsh <<EOF
echo
EOF

    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v')
    expected_output="dsh3> dsh3> cmd loop returned 0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
}

@test "echo command with unquoted and quotes arguments" {
    run ./dsh <<EOF
echo unquoted "   quoted   args   "
EOF

    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v')
    expected_output="unquoted    quoted   args   dsh3> dsh3> cmd loop returned 0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
}

@test "echo command with internal quotes" {
    run ./dsh <<EOF
echo "   'internal quotes' quoted   args   "
EOF

    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v')
    expected_output="   'internal quotes' quoted   args   dsh3> dsh3> cmd loop returned 0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
}

@test "echo command with unclosed quote" {
    run ./dsh <<EOF
echo "unclosed quote
EOF

    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v')
    expected_output="unclosed quotedsh3> dsh3> cmd loop returned 0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
}

@test "which command works" {
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

@test "empty command passes" {
    run ./dsh <<EOF
EOF

    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v')

    expected_output="dsh3> cmd loop returned 0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
}

@test "invalid command returns an error" {
    run ./dsh <<EOF
nonexistentcommand
EOF

    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v')

    expected_output="execvp failed: No such file or directorydsh3> dsh3> dsh3> cmd loop returned 127"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
}

@test "trailing/leading spaces" {
    run ./dsh <<EOF
  ls  
EOF

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"

    [ "$status" -eq 0 ]
}
COMMENT