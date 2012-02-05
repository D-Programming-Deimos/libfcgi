module deimos.fastcgi.fcgi_stdio;

import std.c.stdarg;

import fastcgi.c.fcgiapp;


extern (System) {
/*
 * fcgi_stdio.h --
 *
 *      FastCGI-stdio compatibility package
 *
 *
 * Copyright (c) 1996 Open Market, Inc.
 *
 * See the file "LICENSE.TERMS" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 * $Id: fcgi_stdio.h,v 1.5 2001/06/22 13:21:15 robs Exp $
 */

/*
 * Wrapper type for FILE
 */

struct FCGI_FILE{
    FILE*           stdio_stream;
    FCGX_Stream*    fcgx_stream;
}

/*
 * The four new functions and two new macros
 */
int     FCGI_Accept();
void    FCGI_Finish();
int     FCGI_StartFilterData();
void    FCGI_SetExitStatus( int status );


// BUILD FAIL !
//~ template FCGI_ToFILE( FCGI_FILE fcgi_file ){
    //~ const(FILE)* FCGI_ToFILE = fcgi_file.stdio_stream;
//~ }
//~
//~ template FCGI_ToFcgiStream( FCGI_FILE fcgi_file ){
    //~ const(FCGX_Stream)* FCGI_ToFcgiStream = fcgi_file.fcgx_stream;
//~ }

/*
 * Wrapper stdin, stdout, and stderr variables, set up by FCGI_Accept()
 */

extern   FCGI_FILE*[]   _fcgi_sF;
template FCGI_stdin(  ){
    const(FILE)* FCGI_stdin  = &_fcgi_sF[0];
}
template FCGI_stdout(  ){
    const(FILE)* FCGI_stdout = &_fcgi_sF[1];
}
template FCGI_stderr(  ){
    const(FILE)* FCGI_stderr = &_fcgi_sF[2];
}

/*
 * Wrapper function prototypes, grouped according to sections
 * of Harbison & Steele, "C: A Reference Manual," fourth edition,
 * Prentice-Hall, 1995.
 */

void FCGI_perror(const char* str);

FCGI_FILE* FCGI_fopen(const char* path, const char* mode);
int        FCGI_fclose(FCGI_FILE* fp);
int        FCGI_fflush(FCGI_FILE* fp);
FCGI_FILE* FCGI_freopen(const char* path, const char* mode, FCGI_FILE* fp);

int        FCGI_setvbuf(FCGI_FILE* fp, char* buf, int bufmode, size_t size);
void       FCGI_setbuf(FCGI_FILE* fp, char* buf);

int        FCGI_fseek(FCGI_FILE* fp, long offset, int whence);
int        FCGI_ftell(FCGI_FILE* fp);
void       FCGI_rewind(FCGI_FILE* fp);
//~ int        FCGI_fgetpos(FCGI_FILE* fp, fpos_t* pos);
//~ int        FCGI_fsetpos(FCGI_FILE* fp, const fpos_t* pos);
int        FCGI_fgetc(FCGI_FILE* fp);
int        FCGI_getchar();
int        FCGI_ungetc(int c, FCGI_FILE* fp);

char*      FCGI_fgets(char* str, int size, FCGI_FILE* fp);
char*      FCGI_gets(char* str);

/*
 * Not yet implemented
 *
 * int        FCGI_fscanf(FCGI_FILE* fp, const char* format, ...);
 * int        FCGI_scanf(const char* format, ...);
 *
 */

int        FCGI_fputc(int c, FCGI_FILE* fp);
int        FCGI_putchar(int c);

int        FCGI_fputs(const char* str, FCGI_FILE* fp);
int        FCGI_puts(const char* str);

int        FCGI_fprintf(FCGI_FILE* fp, const char* format, ...);
int        FCGI_printf(const char* format, ...);

int        FCGI_vfprintf(FCGI_FILE* fp, const char* format, va_list ap);
int        FCGI_vprintf(const char* format, va_list ap);

size_t     FCGI_fread(void* ptr, size_t size, size_t nmemb, FCGI_FILE* fp);
size_t     FCGI_fwrite(void* ptr, size_t size, size_t nmemb, FCGI_FILE* fp);

int        FCGI_feof(FCGI_FILE* fp);
int        FCGI_ferror(FCGI_FILE* fp);
void       FCGI_clearerr(FCGI_FILE* fp);

FCGI_FILE* FCGI_tmpfile();

int        FCGI_fileno(FCGI_FILE* fp);
FCGI_FILE* FCGI_fdopen(int fd, const char* mode);
FCGI_FILE* FCGI_popen(const char* cmd, const char* type);
int        FCGI_pclose(FCGI_FILE *);


/*
 * Replace standard types, variables, and functions with FastCGI wrappers.
 * Use undef in case a macro is already defined.
 */
alias FCGI_FILE     FILE;
alias FCGI_stdin    stdin;
alias FCGI_stdout   stdout;
alias FCGI_stderr   stderr;

alias FCGI_perror   perror;

alias FCGI_fopen    fopen;
alias FCGI_fclose   fclose;
alias FCGI_fflush   fflush;
alias FCGI_freopen  freopen;

alias FCGI_setvbuf  setvbuf;
alias FCGI_setbuf   setbuf;

alias FCGI_fseek    fseek;
alias FCGI_ftell    ftell;
alias FCGI_rewind   rewind;
//~ alias FCGI_fgetpos  fgetpos;
//~ alias FCGI_fsetpos  fsetpos;

alias FCGI_fgetc    fgetc;
alias FCGI_fgetc    getc;
alias FCGI_getchar  getchar;
alias FCGI_ungetc   ungetc;

alias FCGI_fgets    fgets;
alias FCGI_gets     gets;

alias FCGI_fputc    fputc;
alias FCGI_fputc    putc;
alias FCGI_putchar  putchar;

alias FCGI_fputs    fputs;
alias FCGI_puts     puts;

alias FCGI_fprintf  fprintf;
alias FCGI_printf   printf;

alias FCGI_vfprintf vfprintf;
alias FCGI_vprintf  vprintf;

alias FCGI_fread    fread;
alias FCGI_fwrite   fwrite;

alias FCGI_feof     feof;
alias FCGI_ferror   ferror;
alias FCGI_clearerr clearerr;

alias FCGI_tmpfile  tmpfile;

alias FCGI_fileno   fileno;
alias FCGI_fdopen   fdopen;
alias FCGI_popen    popen;
alias FCGI_pclose   pclose;


}
