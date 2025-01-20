#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>


#define BUFFER_SZ 50

//prototypes
void usage(char *);
void print_buff(char *, int);
int  setup_buff(char *, char *, int);

//prototypes for functions to handle required functionality
int  count_words(char *, int, int);
//add additional prototypes here
void reverse_string(char *, int);
void print_words(char *, int);
int replace_string(char *, int , const char *, const char *);


// Prepares the buffer by copying the user's string to it
int setup_buff(char *buff, char *user_str, int len) {
    //TODO: #4:  Implement the setup buff as per the directions
    char *dest = buff;
    char *start = user_str;
    char *end;
    int space_seen = 1;
    int count = 0;

    while (isspace(*start)) {
        start++;
    }

    end = start;

    while (*end) {
        end++;
    }

    while (end > start && isspace(*(end - 1))) {
        end--;
    }

    user_str = start;

    // copy characters to buffer
    // collapse multiple spaces
    while (user_str < end && count < len) {
        if (isspace(*user_str)) {
            if (!space_seen) {
                *dest++ = ' ';
                count++;
                space_seen = 1;
            }
        } else {
            *dest++ = *user_str;
            count++;
            space_seen = 0;
        }
        user_str++;
    }

    if (user_str < end) return -2;

    while (count < len) {
        *dest++ = '.';
        count++;
    }

    return dest - buff;
}

// Prints contents of the buffer
void print_buff(char *buff, int len){
    printf("Buffer:  [");
    for (int i=0; i<len; i++){
        putchar(*(buff+i));
    }
    printf("]\n");
}

// Prints usage message
void usage(char *exename){
    printf("usage: %s [-h|c|r|w|x] \"string\" [other args]\n", exename);

}

// Counts the number of words in buffer
int count_words(char *buff, int len, int str_len){
    if (str_len > len) {
        printf("Error: provided input string is too long\n");
        exit(3);
    }

    int word_count = 0;
    int in_word = 0;

    for (int i = 0; i < str_len; i++) {
        if (buff[i] != ' ') {
            if (!in_word) {
                word_count++;
                in_word = 1;
            }
        } else {
            in_word = 0;
        }
    }
    return word_count;
}

// Reverses the content of the buffer
void reverse_string(char *buff, int len) {
    int start = 0;
    int end = len - 1;

    while (buff[start] == ' ' || buff[start] == '.') {
        start++;
    }

    while (buff[end] == ' ' || buff[end] == '.') {
        end--;
    }

    while (start < end) {
        char temp = buff[start];
        buff[start] = buff[end];
        buff[end] = temp;

        start++;
        end--;
    }
}

// Print each word in the buffer and their length
void print_words(char *buff, int str_len) {
    int word_count = 0;
    int in_word = 0;
    int word_start = 0;

    printf("Word Print\n");
    printf("----------\n");

    for (int i = 0; i < str_len; i++) {
        if (buff[i] != ' ' && buff[i] != '.') {
            if (!in_word) {
                word_start = i;
                in_word = 1;
            }
        } else {
            if (in_word) {
                int word_length = i - word_start;
                printf("%d. ", ++word_count);
                for (int j = word_start; j < i; j++) {
                    printf("%c", buff[j]);
                }
                printf("(%d)\n", word_length);
                in_word = 0;
            }
        }
    }

    if (in_word) {
        int word_length = str_len - word_start;
        printf("%d. ", ++word_count);
        for (int i = word_start; i < str_len; i++) {
            printf("%c", buff[i]);
        }
        printf("(%d)\n", word_length);
    }

    printf("\nNumber of words returned: %d\n", word_count);
}

// Replaces occurrences of old_str with new_str in the buffer
int replace_string(char *buff, int buff_len, const char *old_str, const char *new_str) {
    int replaced = 0;
    char *temp_buff = malloc(buff_len);

    if (!temp_buff) return 2;

    char *temp_ptr = temp_buff;
    char *buff_ptr = buff;

    int old_len = 0;
    const char *old_ptr = old_str;
    while (*old_ptr++) {
        old_len++;
    }

    int new_len = 0;
    const char *new_ptr = new_str;
    while (*new_ptr++) {
        new_len++;
    }

    // traverses the buffer
    while (buff_ptr < buff + buff_len) {
        char *match_ptr = buff_ptr;
        const char *old_match_ptr = old_str;

        // checks if old_str matches at the current position
        while (match_ptr < buff + buff_len && *match_ptr == *old_match_ptr && *old_match_ptr) {
            match_ptr++;
            old_match_ptr++;
        }

        // if a match is found, replaces it with new_str
        if (old_match_ptr - old_str == old_len) {
            if (temp_ptr + new_len <= temp_buff + buff_len) {
                const char *new_copy_ptr = new_str;
                while (new_copy_ptr < new_str + new_len) {
                    *temp_ptr++ = *new_copy_ptr++;
                }
                buff_ptr += old_len;
                replaced = 1;
            } else {
                break;
            }
        } else {
            *temp_ptr++ = *buff_ptr++;
        }
    }

    while (temp_ptr < temp_buff + buff_len) {
        *temp_ptr++ = '.';
    }

    if (!replaced) {
        free(temp_buff);
        return 3;
    }

    // copies modified content back to the original buffer
    temp_ptr = temp_buff;
    buff_ptr = buff;
    while (temp_ptr < temp_buff + buff_len) {
        *buff_ptr++ = *temp_ptr++;
    }

    free(temp_buff);
    return 0;
}

int main(int argc, char *argv[]){

    char *buff;             //placehoder for the internal buffer
    char *input_string;     //holds the string provided by the user on cmd line
    char opt;               //used to capture user option from cmd line
    int  rc;                //used for return codes
    int  user_str_len;      //length of user supplied string

    //TODO:  #1. WHY IS THIS SAFE, aka what if arv[1] does not exist?
    // The first condition ensures that the argv[1] exists before trying to dereference argv[1].
    // Without checking this, the attempt to access argv[1] when argc is less than 2 would cause undefined behavior, as argv[1] would be out of bounds.
    // If either condition is true, it signals a command line problem and exits the program. This promotes proper user input.
    if ((argc < 2) || (*argv[1] != '-')){
        usage(argv[0]);
        exit(1);
    }

    opt = (char)*(argv[1]+1);   //get the option flag

    //handle the help flag and then exit normally
    if (opt == 'h'){
        usage(argv[0]);
        exit(0);
    }

    //WE NOW WILL HANDLE THE REQUIRED OPERATIONS

    //TODO:  #2 Document the purpose of the if statement below
    // It ensures the user enters enough arguments of at least three.
    // Each operation besides 'h' requires at least 3 arguments.
    // If not, it signals a command line problem and exits the program.
    if (argc < 3){
        usage(argv[0]);
        exit(1);
    }

    input_string = argv[2]; //capture the user input string

    //TODO:  #3 Allocate space for the buffer using malloc and
    //          handle error if malloc fails by exiting with a 
    //          return code of 99
    buff = (char *)malloc(BUFFER_SZ);
    if (!buff) {
        printf("Memory allocation error\n");
        exit(2);
    }


    user_str_len = setup_buff(buff, input_string, BUFFER_SZ);     //see todos
    if (user_str_len < 0){
        printf("Error setting up buffer, error = %d", user_str_len);
        exit(2);
    }

    switch (opt){
        case 'c':
            rc = count_words(buff, BUFFER_SZ, user_str_len);  //you need to implement
            if (rc < 0){
                printf("Error counting words, rc = %d", rc);
                exit(2);
            }
            printf("Word Count: %d\n", rc);
            break;

        //TODO:  #5 Implement the other cases for 'r' and 'w' by extending
        //       the case statement options
        case 'r':
            reverse_string(buff, BUFFER_SZ);
            break;
        case 'w':
            print_words(buff, user_str_len);
            break;
        case 'x':
            if (argc < 5) {
                printf("Error: Missing arguments for -x\n");
                exit(1);
            }

            const char *old_str = argv[3];
            const char *new_str = argv[4];

            rc = replace_string(buff, BUFFER_SZ, old_str, new_str);
            if (rc == 2) {
                printf("Memory allocation error\n");
                exit(2);
            } else if (rc == 3) {
                printf("Replacement not found\n");
                exit(3);
            }
            break;
        default:
            usage(argv[0]);
            exit(1);
    }

    //TODO:  #6 Dont forget to free your buffer before exiting
    print_buff(buff,BUFFER_SZ);
    free(buff);
    exit(0);
}

//TODO:  #7  Notice all of the helper functions provided in the 
//          starter take both the buffer as well as the length.  Why
//          do you think providing both the pointer and the length
//          is a good practice, after all we know from main() that 
//          the buff variable will have exactly 50 bytes?
//  
// Providing both the pointer and the length is a good practice as it prevents buffer overflows and other potential memory conflicts.
// This is because both ensure that functions will operate within the allocated buffer size. It also allows the same buffer and length
// to be used in different functions without assuming a fixed size.