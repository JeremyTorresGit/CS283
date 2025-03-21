#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include "dshlib.h"

/*
 *  build_cmd_list
 *    cmd_line:     the command line from the user
 *    clist *:      pointer to clist structure to be populated
 *
 *  This function builds the command_list_t structure passed by the caller
 *  It does this by first splitting the cmd_line into commands by spltting
 *  the string based on any pipe characters '|'.  It then traverses each
 *  command.  For each command (a substring of cmd_line), it then parses
 *  that command by taking the first token as the executable name, and
 *  then the remaining tokens as the arguments.
 *
 *  NOTE your implementation should be able to handle properly removing
 *  leading and trailing spaces!
 *
 *  errors returned:
 *
 *    OK:                      No Error
 *    ERR_TOO_MANY_COMMANDS:   There is a limit of CMD_MAX (see dshlib.h)
 *                             commands.
 *    ERR_CMD_OR_ARGS_TOO_BIG: One of the commands provided by the user
 *                             was larger than allowed, either the
 *                             executable name, or the arg string.
 *
 *  Standard Library Functions You Might Want To Consider Using
 *      memset(), strcmp(), strcpy(), strtok(), strlen(), strchr()
 */
int build_cmd_list(char *cmd_line, command_list_t *clist)
{
    if (!cmd_line) 
        return ERR_CMD_OR_ARGS_TOO_BIG;
    if (!clist) 
        return ERR_CMD_OR_ARGS_TOO_BIG;
    
    memset(clist, 0, sizeof(command_list_t));
    
    char *token;
    char *rest = cmd_line;
    int cmd_count = 0;
    
    while ((token = strtok_r(rest, PIPE_STRING, &rest))) {
        while (*token == SPACE_CHAR) token++;
        
        if (cmd_count >= CMD_MAX) 
            return ERR_TOO_MANY_COMMANDS;
        
        command_t *cmd = &clist->commands[cmd_count];
        
        char *arg_start = strchr(token, SPACE_CHAR);
        if (arg_start) {
            *arg_start = '\0';
            arg_start++;
            while (*arg_start == SPACE_CHAR) arg_start++;
            strncpy(cmd->args, arg_start, ARG_MAX - 1);


            // trim trailing spaces in args
            int arg_len = strlen(cmd->args);
            while (arg_len > 0 && cmd->args[arg_len - 1] == SPACE_CHAR) {
                cmd->args[arg_len - 1] = '\0';
                arg_len--;
            }
        }
        
        strncpy(cmd->exe, token, EXE_MAX - 1);
        
        if (strlen(cmd->exe) >= EXE_MAX)
            return ERR_CMD_OR_ARGS_TOO_BIG;
        if (strlen(cmd->args) >= ARG_MAX)
            return ERR_CMD_OR_ARGS_TOO_BIG;
        
        cmd_count++;
    }
    
    clist->num = cmd_count;
    if (cmd_count > 0) {
        return OK;
    } else {
        return WARN_NO_CMDS;
    }
}