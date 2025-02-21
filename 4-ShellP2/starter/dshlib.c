#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/wait.h>
#include "dshlib.h"

#include <errno.h>

/*
 * Implement your exec_local_cmd_loop function by building a loop that prompts the 
 * user for input.  Use the SH_PROMPT constant from dshlib.h and then
 * use fgets to accept user input.
 * 
 *      while(1){
 *        printf("%s", SH_PROMPT);
 *        if (fgets(cmd_buff, ARG_MAX, stdin) == NULL){
 *           printf("\n");
 *           break;
 *        }
 *        //remove the trailing \n from cmd_buff
 *        cmd_buff[strcspn(cmd_buff,"\n")] = '\0';
 * 
 *        //IMPLEMENT THE REST OF THE REQUIREMENTS
 *      }
 * 
 *   Also, use the constants in the dshlib.h in this code.  
 *      SH_CMD_MAX              maximum buffer size for user input
 *      EXIT_CMD                constant that terminates the dsh program
 *      SH_PROMPT               the shell prompt
 *      OK                      the command was parsed properly
 *      WARN_NO_CMDS            the user command was empty
 *      ERR_TOO_MANY_COMMANDS   too many pipes used
 *      ERR_MEMORY              dynamic memory management failure
 * 
 *   errors returned
 *      OK                     No error
 *      ERR_MEMORY             Dynamic memory management failure
 *      WARN_NO_CMDS           No commands parsed
 *      ERR_TOO_MANY_COMMANDS  too many pipes used
 *   
 *   console messages
 *      CMD_WARN_NO_CMD        print on WARN_NO_CMDS
 *      CMD_ERR_PIPE_LIMIT     print on ERR_TOO_MANY_COMMANDS
 *      CMD_ERR_EXECUTE        print on execution failure of external command
 * 
 *  Standard Library Functions You Might Want To Consider Using (assignment 1+)
 *      malloc(), free(), strlen(), fgets(), strcspn(), printf()
 * 
 *  Standard Library Functions You Might Want To Consider Using (assignment 2+)
 *      fork(), execvp(), exit(), chdir()
 */
int build_cmd_buff(char *cmd_line, cmd_buff_t *cmd_buff) {
    if (!cmd_line || !cmd_buff)
        return ERR_CMD_OR_ARGS_TOO_BIG;
    
    memset(cmd_buff, 0, sizeof(cmd_buff_t));

    char *start = cmd_line;
    int arg_count = 0;

    while (*start) {
        while (*start == ' ' || *start == '\t') start++;

        if (*start == '\0') 
            break;

        // handle quoted string arguments
        if (*start == '"') {
            start++; // skip opening quote
            char *end = strchr(start, '"');
            if (end) {
                *end = '\0';
                if (arg_count < CMD_ARGV_MAX) {
                    cmd_buff->argv[arg_count++] = start;
                }
                start = end + 1; // move pointer past closing quote
            } else {
                return ERR_CMD_ARGS_BAD;
            }
        } else {
            // finds next space or end of string
            char *space = strchr(start, ' ');
            if (!space) {
                if (arg_count < CMD_ARGV_MAX) {
                    cmd_buff->argv[arg_count++] = start;
                }
                break;
            } else {
                *space = '\0';
                if (arg_count < CMD_ARGV_MAX) {
                    cmd_buff->argv[arg_count++] = start;
                }
                start = space + 1; // move past the space
            }
        }

        if (arg_count >= CMD_ARGV_MAX) {
            return ERR_CMD_OR_ARGS_TOO_BIG;
        }
    }

    cmd_buff->argc = arg_count;
    return OK;
}

Built_In_Cmds match_command(const char *input) {

    if (strcmp(input, EXIT_CMD) == 0) {
        return BI_CMD_EXIT;
    } else if (strcmp(input, "cd") == 0) {
        return BI_CMD_CD;
    } else if (strcmp(input, "rc") == 0) {
        return BI_RC;
    } else {
        return BI_NOT_BI;
    }

}

Built_In_Cmds exec_built_in_cmd(cmd_buff_t *cmd) {
    switch (match_command(cmd->argv[0])) {
        case BI_CMD_EXIT:
            exit(0);
            break;

        case BI_CMD_CD:
            if (cmd->argc > 2) {
                perror("cd: too many arguments");
            } else if (cmd->argc == 1) {
                return BI_EXECUTED;
            } else {
                if (chdir(cmd->argv[1]) == -1) {
                    perror("cd failed");
                }
            }
            break;

        case BI_RC:
            // no extra credit implementation
            break;

        default:
            return BI_NOT_BI;
    }

    return BI_EXECUTED;
}

int exec_local_cmd_loop() {
    char cmd_buff[SH_CMD_MAX];
    int rc = 0;
    cmd_buff_t cmd;

    while (1) {
        printf("%s", SH_PROMPT);
        
        if (fgets(cmd_buff, SH_CMD_MAX, stdin) == NULL) {
            printf("\n");
            break;
        }

        cmd_buff[strcspn(cmd_buff, "\n")] = '\0';

        if (cmd_buff[0] == '\0') {
            continue;
        }

        rc = build_cmd_buff(cmd_buff, &cmd);
        if (rc == WARN_NO_CMDS) {
            printf(CMD_WARN_NO_CMD);
            continue;
        }

        if (match_command(cmd.argv[0]) != BI_NOT_BI) {
            exec_built_in_cmd(&cmd);
            continue;
        }

        pid_t pid = fork();
        if (pid == 0) {
            // child process
            execvp(cmd.argv[0], cmd.argv);
            perror("execvp failed");
            exit(127);
        } else if (pid > 0) {
            // parent process
            int status;
            waitpid(pid, &status, 0);
            rc = WEXITSTATUS(status);
        } else {
            perror("fork failed");
        }
    }

    return rc;
}

int exec_cmd(cmd_buff_t *cmd_buff) {
    Built_In_Cmds cmd_type = match_command(cmd_buff->argv[0]);
    if (cmd_type != BI_NOT_BI) {
        return exec_built_in_cmd(cmd_buff);
    }
    
    // fork/exec run external command
    pid_t pid = fork();
    if (pid == 0) {
        // child process
        if (execvp(cmd_buff->argv[0], cmd_buff->argv) == -1) {
            perror("execvp failed");
            exit(127);
        }
    } else if (pid > 0) {
        // parent process (wait for child to finish)
        int status;
        waitpid(pid, &status, 0);
        return WEXITSTATUS(status);
    } else {
        perror("fork failed");
        return -1;
    }
    return 0;
}