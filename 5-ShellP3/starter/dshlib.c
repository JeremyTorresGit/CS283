#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/wait.h>

#include "dshlib.h"

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
int exec_local_cmd_loop() {
    char cmd_buff[SH_CMD_MAX];
    int rc = 0;
    cmd_buff_t cmd;
    command_list_t clist;

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

        if (cmd_buff[0] == PIPE_CHAR) {
            printf("dsh3: syntax error near unexpected token '|'\n");
            continue;
        }

        memset(&cmd, 0, sizeof(cmd_buff_t));
        rc = build_cmd_buff(cmd_buff, &cmd);
        if (rc == WARN_NO_CMDS) {
            printf(CMD_WARN_NO_CMD);
            continue;
        }

        Built_In_Cmds cmd_type = match_command(cmd.argv[0]);
        if (cmd_type != BI_NOT_BI) {
            exec_built_in_cmd(&cmd);
            continue;
        }

        if (strchr(cmd_buff, PIPE_CHAR)) {
            rc = build_cmd_list(cmd_buff, &clist);
            if (rc == ERR_TOO_MANY_COMMANDS || rc == ERR_CMD_ARGS_BAD) {
                continue;
            }
            rc = execute_pipeline(&clist);
        } else {
            rc = exec_cmd(&cmd);
        }
    }
    return rc;
}

int execute_pipeline(command_list_t *clist) {
    int num_cmds = clist->num;
    int pipes[CMD_MAX - 1][2];
    pid_t pids[CMD_MAX];

    for (int i = 0; i < num_cmds - 1; i++) {
        if (pipe(pipes[i]) == -1) {
            perror("pipe failed");
            return ERR_MEMORY;
        }
    }

    // loop to fork/execute each command
    for (int i = 0; i < num_cmds; i++) {
        if (match_command(clist->commands[i].argv[0]) != BI_NOT_BI) {
            printf("error: built-in command cannot be pipelined\n");
            return ERR_CMD_ARGS_BAD;
        }

        pids[i] = fork();
        if (pids[i] == 0) {
            if (i > 0) 
                dup2(pipes[i - 1][0], STDIN_FILENO);
            if (i < num_cmds - 1) 
                dup2(pipes[i][1], STDOUT_FILENO);
            for (int j = 0; j < num_cmds - 1; j++) {
                close(pipes[j][0]);
                close(pipes[j][1]);
            }
            execvp(clist->commands[i].argv[0], clist->commands[i].argv);
            perror("execvp failed");
            exit(ERR_EXEC_CMD);
        } else if (pids[i] < 0) {
            perror("fork failed");
            return ERR_MEMORY;
        }
    }

    for (int i = 0; i < num_cmds - 1; i++) {
        close(pipes[i][0]);
        close(pipes[i][1]);
    }

    int status;
    for (int i = 0; i < num_cmds; i++) { // wait for all child processes
        waitpid(pids[i], &status, 0);
    }
    return WEXITSTATUS(status);
}

int free_cmd_list(command_list_t *cmd_lst) {
    for (int i = 0; i < cmd_lst->num; i++) {
        free(cmd_lst->commands[i]._cmd_buffer);
    }
    return OK;
}

int build_cmd_buff(char *cmd_line, cmd_buff_t *cmd_buff) {
    if (!cmd_line || !cmd_buff)
        return ERR_CMD_OR_ARGS_TOO_BIG;

    memset(cmd_buff, 0, sizeof(cmd_buff_t));

    cmd_buff->_cmd_buffer = strdup(cmd_line);
    if (!cmd_buff->_cmd_buffer)
        return ERR_MEMORY;

    char *start = cmd_buff->_cmd_buffer;
    int arg_count = 0;
    bool quoted = false;

    while (*start) {
        while (*start == ' ' || *start == '\t') 
            start++;

        if (*start == '\0')
            break;

        if (*start == '"') {
            quoted = true;
            start++;
        }

        char *arg_start = start;
        
        while (*start && (quoted || (*start != ' ' && *start != '\t'))) {
            if (*start == '"' && quoted) {
                *start = '\0';
                quoted = false;
                break;
            }
            start++;
        }

        if (*start) {
            *start = '\0';
            start++;
        }

        if (arg_count >= CMD_ARGV_MAX - 1) {
            free(cmd_buff->_cmd_buffer);
            return ERR_CMD_OR_ARGS_TOO_BIG;
        }

        cmd_buff->argv[arg_count++] = arg_start;
    }

    cmd_buff->argc = arg_count;
    cmd_buff->argv[arg_count] = NULL;

    return OK;
}

Built_In_Cmds match_command(const char *input) {
    if (strcmp(input, EXIT_CMD) == 0) {
        return BI_CMD_EXIT;
    } else if (strcmp(input, "cd") == 0) {
        return BI_CMD_CD;
    } else {
        return BI_NOT_BI;
    }

}

Built_In_Cmds exec_built_in_cmd(cmd_buff_t *cmd) {
    for (int i = 0; i < cmd->argc; i++) {
        if (strcmp(cmd->argv[i], PIPE_STRING) == 0) {
            fprintf(stderr, "error: built-in command cannot be pipelined\n");
            return BI_NOT_BI;
        }
    }
    
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

        default:
            return BI_NOT_BI;
    }

    return BI_EXECUTED;
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

int build_cmd_list(char *cmd_line, command_list_t *clist) {
    if (!cmd_line || !clist) 
        return ERR_CMD_ARGS_BAD;

    int cmd_count = 0;
    clist->num = 0;
    bool quoted = false;
    char *start = cmd_line;
    char *token = start;

    while (*start) {
        if (*start == '"') {
            quoted = !quoted;
        } else if (*start == '|' && !quoted) {
            cmd_count++;
            *start = '\0';
            
            while (*token == ' ') 
                token++;

            if (*token == '\0') {
                fprintf(stderr, "dsh3: syntax error near unexpected token '|'\n");
                return ERR_CMD_ARGS_BAD;
            }

            if (cmd_count >= CMD_MAX) {
                printf(CMD_ERR_PIPE_LIMIT, CMD_MAX);
                return ERR_TOO_MANY_COMMANDS;
            }

            build_cmd_buff(token, &clist->commands[clist->num]);
            clist->num++;

            token = start + 1;
        }
        start++;
    }

    while (*token == ' ') 
        token++;
    if (*token) {
        build_cmd_buff(token, &clist->commands[clist->num]);
        clist->num++;
    }

    return OK;
}