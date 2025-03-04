1. Your shell forks multiple child processes when executing piped commands. How does your implementation ensure that all child processes complete before the shell continues accepting user input? What would happen if you forgot to call waitpid() on all child processes?

In my implementation, all child processes must complete before the shell resumes accepting input from the user: for each restarted one, waitpid() is called in a loop. This should ensure that the shell goes back to the prompt only after all commands in the pipeline have been executed. If you forgot to call waitpid(), the child processes would become zombie processes after termination.

2. The dup2() function is used to redirect input and output file descriptors. Explain why it is necessary to close unused pipe ends after calling dup2(). What could go wrong if you leave pipes open?

After calling dup2(), it is necessary to close unused pipe ends to avoid resource leaks and unintended blocking behavior. If a process doesn't close its write end of a pipe, the reading process may hang while waiting for an EOF signal that will never arrive. If read ends remain open unnecessarily, writes to the pipe may lead to unexpected behavior. Pipes left open can also lead to recource leaks.

3. Your shell recognizes built-in commands (cd, exit, dragon). Unlike external commands, built-in commands do not require execvp(). Why is cd implemented as a built-in rather than an external command? What challenges would arise if cd were implemented as an external process?

Since changing the working directory requires modifying the working directory for the current shell process (which an external process cannot do), the current design implements cd as a built-in. If cd were implemented as an external process, the change in directory would occur only in the child process and not persist after the command exits. The shell itself would remain in the same directory.

4. Currently, your shell supports a fixed number of piped commands (CMD_MAX). How would you modify your implementation to allow an arbitrary number of piped commands while still handling memory allocation efficiently? What trade-offs would you need to consider?

To support an arbitrary number of piped commands, I would replace the fixed-size pipes `[CMD_MAX - 1][2]` array with dynamic memory allocation to store the pipe file descriptors as necessary. This would allow the shell to handle an arbitrary number of commands while using memory effectively. The trade-offs I would need to consider include increased complexity in memory management and the need to handle allocation failures smoothly.
