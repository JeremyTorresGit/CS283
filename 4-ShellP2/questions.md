1. Can you think of why we use `fork/execvp` instead of just calling `execvp` directly? What value do you think the `fork` provides?

    > **Answer**:  We use `fork` to create a new child process, so that the shell would not replace itself by `execvp`. During the creation, the parent shell process can continue to run and accept commands.

2. What happens if the fork() system call fails? How does your implementation handle this scenario?

    > **Answer**:  If fork() fails, it usually returns -1 due to limitations. In my implementation, it check the value of fork() then returns an error code to notify the user.

3. How does execvp() find the command to execute? What system environment variable plays a role in this process?

    > **Answer**:  execvp() searches for the command in directories in the PATH enviornment variable. It itervatively runs through each directory in PATH to locate an executable file based on the name.

4. What is the purpose of calling wait() in the parent process after forking? What would happen if we didn’t call it?

    > **Answer**:  Calling wait(), in my case waitpid(), pauses execution until the child process terminates so that it can retrieve the child's exit status. If we didn't call it, the child process will become a zombie process since the parent would not clean up exit status.

5. In the referenced demo code we used WEXITSTATUS(). What information does this provide, and why is it important?

    > **Answer**:  It extracts the exit code of the child process from the status returned by waitpid(). This allows the shell to determine whether the command was executed successfully.

6. Describe how your implementation of build_cmd_buff() handles quoted arguments. Why is this necessary?

    > **Answer**:  My implementation check for an opening quote then the following closing quote. It extracts the content between them as a single argument. 

7. What changes did you make to your parsing logic compared to the previous assignment? Were there any unexpected challenges in refactoring your old code?

    > **Answer**:  I improved checking whitespace so that leading or trailing spaces do not interfere with argument parsing. I also fixed edge cases where multiple spaces were incorrectly interpreted as arguments. The biggest challenge was modifying strtok_r() usage to handle spaces while preserving quoted arguments.

8. For this quesiton, you need to do some research on Linux signals. You can use [this google search](https://www.google.com/search?q=Linux+signals+overview+site%3Aman7.org+OR+site%3Alinux.die.net+OR+site%3Atldp.org&oq=Linux+signals+overview+site%3Aman7.org+OR+site%3Alinux.die.net+OR+site%3Atldp.org&gs_lcrp=EgZjaHJvbWUyBggAEEUYOdIBBzc2MGowajeoAgCwAgA&sourceid=chrome&ie=UTF-8) to get started.

- What is the purpose of signals in a Linux system, and how do they differ from other forms of interprocess communication (IPC)?

    > **Answer**:  In a Linux system, signals enable sending asynchronous notfications to processes. Unlike other IPC forms, signals are simple and used for process control most of the time.

- Find and describe three commonly used signals (e.g., SIGKILL, SIGTERM, SIGINT). What are their typical use cases?

    > **Answer**:  SIGKILL instantly terminates a process and cannot be caught or ignored. It is useful to force unresponsive processes to stop. SIGTERM requests a process to terminate and allows it to clean up resources. `kill` without arguments uses this as a default signal. SIGINT interrupts a process. It is used when users press Ctrl+C.

- What happens when a process receives SIGSTOP? Can it be caught or ignored like SIGINT? Why or why not?

    > **Answer**:  SIGSTOP pauses a process until it recieves SIGCONT. It cannot be caught or ignored since it is designed to be an unconditional stop signal.
