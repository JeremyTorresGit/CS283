1. In this assignment I suggested you use `fgets()` to get user input in the main while loop. Why is `fgets()` a good choice for this application?

    > **Answer**:  By being "lines of input" based, 'fgets()' prevents buffer overflow, handles spaces and characters, and detects EOF which makes it a good choice for reading user input in our shell. The main thing is that reading stops after an EOF or a newline, making it a "line by line" processor.

2. You needed to use `malloc()` to allocte memory for `cmd_buff` in `dsh_cli.c`. Can you explain why you needed to do that, instead of allocating a fixed-size array?

    > **Answer**:  For a more dynamic approach, 'malloc()' ensures buffers can be resized and allocate only what is necessary.


3. In `dshlib.c`, the function `build_cmd_list(`)` must trim leading and trailing spaces from each command before storing it. Why is this necessary? If we didn't trim spaces, what kind of issues might arise when executing commands in our shell?

    > **Answer**:  Trimming spaces are necessary to ensure commands are correctly identified. If we didn't trim spaces, commands may be stored incorrectly or misinterpreted. Extra spaces can also interfere with argument parsing.

4. For this question you need to do some research on STDIN, STDOUT, and STDERR in Linux. We've learned this week that shells are "robust brokers of input and output". Google _"linux shell stdin stdout stderr explained"_ to get started.

- One topic you should have found information on is "redirection". Please provide at least 3 redirection examples that we should implement in our custom shell, and explain what challenges we might have implementing them.

    > **Answer**:  For output redirection, we can write ls output to a file with the syntax "command > file". A challenge for this is redirecting stdout to the file. For input redirection, we can read input from input.txt rather than stdin with the syntax "command < file". A challenge for this is handling errors if the file doesn't exist. For stderr redirection, we can redirect error messages to a file, using syntax "command 2> file". One challenge for this is ensuring stderr is seperated from stdout.

- You should have also learned about "pipes". Redirection and piping both involve controlling input and output in the shell, but they serve different purposes. Explain the key differences between redirection and piping.

    > **Answer**:  While redirection modifies where input/output is stored, piping connects multiple commands dynamically. While redirection affects one command, piping affects multiple commands in a sequence.

- STDERR is often used for error messages, while STDOUT is for regular output. Why is it important to keep these separate in a shell?

    > **Answer**:  It is important since we want to easily differentiate error messages and valid command output. Seperating stderr and stdout supports debugging and logging outputs and errors to different locations.

- How should our custom shell handle errors from commands that fail? Consider cases where a command outputs both STDOUT and STDERR. Should we provide a way to merge them, and if so, how?

    > **Answer**:  Our custom shell can handle these errors by checking return codes and printing error messages. We should merge STDOUT and STDERR to allow users to combine them when needed, which handling requires redirection in both file descriptors properly.