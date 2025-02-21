#!/usr/bin/env bats

# File: student_tests.sh
# 
# Create your unit tests suit in this file


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

    expected_output="cdfailed:Nosuchfileordirectorydsh2>dsh2>cmdloopreturned0"

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

    expected_output="cd:toomanyarguments:Successdsh2>dsh2>cmdloopreturned0"

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
    expected_output="/var:backupscacheliblocallocklogmailoptrunspooltmpwwwbats:assignment_tests.shstudent_tests.shdsh2> dsh2> cmd loop returned 0"

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
    expected_output="assignment_tests.shstudent_tests.shdsh2> dsh2> cmd loop returned 0"

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
    expected_output="dsh2> dsh2> cmd loop returned 0"

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
    expected_output="unquoted    quoted   args   dsh2> dsh2> cmd loop returned 0"

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
    expected_output="   'internal quotes' quoted   args   dsh2> dsh2> cmd loop returned 0"

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
    expected_output="dsh2> dsh2> cmd loop returned 0"

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

    expected_output="dsh2> cmd loop returned 0"

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

    expected_output="execvp failed: No such file or directorydsh2> dsh2> dsh2> cmd loop returned 127"

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