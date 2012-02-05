/**
  Bindings for libfcgi/fcgiapp.h

  The types are mostly the same. I have used extra D features
  (private etc) to enforce conditions stated in the documentation
  where appropriate.

  Date: February 04, 2012

  Authors: James Miller, james@aatch.net
**/
module deimos.fcgi.fcgiapp;

import std.c.stdarg : va_list;

enum FastCGIError {
    UnsupportedVersion = -2,
    ProtocolError = -3,
    ParamsError = -4,
    CallSeqError = -5
}

enum EOF = -1;

extern (C) {

    /++
        This structure defines the state of a FastCGI stream.
        It is an opaque structure and should only be used with
        the functions below
    ++/
    struct FCGX_Stream {
        private:
            ubyte* rdNext;
            ubyte* wrNext;
            ubyte* stop;
            ubyte* stopUnget;

            int isReader;
            int isClosed;
            int wasFCloseCalled;
            int FCGI_errno;

            // I can't seem to declare these functions properly. However,
            // FCGX_Stream is opaque anyway.
            void* fn1; // void (*fillBuffProc) (struct FCGX_Stream *stream);
            void* fn2; // void (*emptyBuffProc) (struct FCGX_Stream *stream, int doClose);
            void* data;
    }

    /++
        An environment (as defined by environ(7)): A NULL-terminated array
        of strings, each string having the form name=value.
    ++/
    alias char** FCGX_ParamArray;

    private {
        // This is actually defined in fcgiapp.c, but I need it so dmd can work out the right sizes.
        struct Params {
            FCGX_ParamArray vec;
            int length;
            char** cur;
        }
    }

    /++
        FCGX_Request -- State associated with a request.
    ++/
    struct FCGX_Request {
        /*
           Author's note: The comments for this struct are ambiguous, but seem
           to suggest the semantics below.
        */
        public:
            int requestId;
            int role;

            FCGX_Stream* _in;
            FCGX_Stream* _out;
            FCGX_Stream* _err;
            char** envp;

        private:
            Params* paramsPtr;
            int ipcFd;
            int isBeginProcessed;
            int keepConnection;
            int appStatus;
            int nWriters;
            int flags;
            int listen_sock;
    }

    /*
       =======
       Control
       =======
    */

    /++
        Returns TRUE iff this process appears to be a CGI process
        rather than a FastCGI process.
    ++/
    int FCGX_IsCGI();

    /++
        Initialize the FCGX library. Call in multi-threaded apps before
        calling FCGX_Accept_r().

        Returns 0 upon success.
    ++/
    int FCGX_Init();

    /++
        Create a FastCGI listen socket.

        Params:
            path =      The Unix domain socket (named pipe for WinNT), or a colon
                        followed by a port number. e.g. "/tmp/fastcgi/mysocket", ":5000"
            backlog =   The listen queue depth in the listen() call.

        Returns: the socket's file descriptor or -1 on error
    ++/
    int FCGX_OpenSocket(const char* path, int backlog);

    /++
        Initialize a FCGX_Request for use with FCGX_Accept_r().

        Params:
            request =   A pointer to a FCGX_Request
            sock =      A file descriptor returned by FCGX_OpenSocket()
                        or 0 (default)
            flags =     Flags
        Returns: 0 upon success
    ++/
    /* The flags are not well documented, there is a defined
       FCGI_FAIL_ACCEPT_ON_INTR, but the documentation for this function
       mentions FCGI_FAIL_ON_INTR, which could be the same thing.
    */
    int FCGX_InitRequest(FCGX_Request* request, int sock = 0, int flags = 0);

    /++
        Accept a new request (multi-thread safe). Be sure to call FCGX_Init() first.

        Returns: 0 for successful call, -1 for error.

        Side effects:
            Finishes the request accepted by (and frees any storage allocated
            by) the previous call to FCGX_Accept.
            Creates input output and error streams and assigns them to *in,
            *out and *err respectively.
            Creates a parameters data structure to be accessed via getenv(3)
            (if assigned to environ) or by FCGX_GetParam and assignes it to
            *envp.

            DO NOT retain pointers to the envp array or any strings contained
            in it (e.e. to the result of calling FCGX_GetParam), since these
            will be freed by the next call to FCGX_Finish or FCGX_Accept.
    ++/
    int FCGX_Accept_r(FCGX_Request*);

    /++
        Finish the request (multi-thread safe).

        Side effects:
            Finishes the request accepted by (and frees any storage allocated
            by) the previous call to FCGX_Accept.
    ++/
    void FCGX_Finish_r(FCGX_Request*);

    /++
        Free the memory and, if close is TRUE, IPC FD associated with the
        request (multi-thread safe).
    ++/
    void FCGX_Free(FCGX_Request* request, int close);

    /++
        Accept a new request (NOT multi-thread safe).
        Returns: 0 for a successful call, -1 for error.

        Same side effects as FCGX_Accept_r
    ++/
    int FCGX_Accept(FCGX_Stream** in_, FCGX_Stream** out_, FCGX_Stream** err_, FCGX_ParamArray* envp);

    /++
        Finish the current request (NOT multi-thread safe).

        Same side effects as FCGX_Finish_r
    ++/
    void FCGX_Finish();

    /++
        stream is an input stream for a FCGI_FILTER request.
        stream is positioned as EOF on FCGI_STDIN.
        Repositions stream to the start of FCGI_DATA.
        If the preconditions are not met (e.g. FCGI_STDIN has not been read
        to EOF) sets the stream error code to FastCGIError.CallSeqError.

        Returns: 0 form normal, < 0 for error
    ++/
    int FCGX_StartFilterData(FCGX_Stream*);

    /++
        Sets the exit status for stream's request. The exit status is the
        status code the request would have exited with, had the request been
        run as a CGI program. You can call SetExitStatus several times during
        a request; the last call before the request ends determines the value.
    ++/
    void FCGX_SetExitStatus(int status, FCGX_Stream*);

    /*
       ==========
       Parameters
       ==========
    */

    /++
        Obtain value of FCGI parameter in environment
    ++/
    char* FCGX_GetParam(const char *, FCGX_ParamArray);

    /*
       =======
       Readers
       =======
    */

    /++
        Reads a byte from the input stream and returns it.

        Returns: the byte, or EOF (-1) if the end of the input has been
            reached.
    ++/
    int FCGX_GetChar(FCGX_Stream*);
    /++
        Pushes back the character c onto the input stream. One character
        of pushback is guaranteed once a character has been read. No pushback
        is possible for EOF.

        Returns: c if the pushback succeeded, EOF if not.
    ++/
    int FCGX_UnGetChar(int c, FCGX_Stream* stream);

    /++
        Reads up to n consecutive bytes from the input stream into the
        character array str. Performs no interpretation of the input bytes.

        Returns: The number of bytes read if < n then the end of input has
            been reached.
    ++/
    int FCGX_GetStr(char* str, int n, FCGX_Stream* stream);
    /++
        Reads up to n-1 consecutive bytes for the input stream into the
        character array str. Stops vefore n-1 bytes have been read if
        '\n' or EOF is read. The terminating '\n' is copied to str. After
        copying the last byte into str, stores a '\0' terminator.

        Returns: NULL if EOF is the first thing read from the input stream,
            str otherwise.
    ++/
    char* FCGX_GetLine(char*, int, FCGX_Stream);

    /++
        Returns EOF (-1) is end-of-file has been detected while reading from
        stream; otherwise returns 0.

        Note that FCGX_HasSeenEOF(s) may return 0, yet an immediately
        following FCGX_GetChar(s) may return EOF. This function, like the
        standard C stdio function feof, does not provide the ability to peek
        ahead.

        Returns: EOF if end-of-file has been detected, 0 if not
    ++/
    int FCGX_HasSeenEOF(FCGX_Stream *stream);

    /*
       =======
       Writers
       =======
    */

    /++
        Writes a byte to the output stream.

        Returns: the byte or EOF (-1) if an error occured.
    ++/
    int FCGX_PutChar(int, FCGX_Stream*);
    /++
        Writes n consecutive bytes from the character array str into the
        output stream. Performs no interpretation of the output bytes.

        Returns: Number of bytes written (n), EOF (-1) if an error occured.
    ++/
    int FCGX_PutStr(const char* str, int n, FCGX_Stream* stream);

    /++
        Writes a null-terminated character string to the output stream.

        Returns: number of bytes written for a normal return, EOF (-1) if
        and error occured.
    ++/
    int FCGX_PutS(const char*, FCGX_Stream*);

    /++
        Performs printf-style output formatting and writes the results to the
        output stream.

        Returns: number of bytes written for a normal return, EOF (-1) if an
            error occured
    ++/
    int FCGX_FPrintF(FCGX_Stream* stream, const char *format, ...);
    int FCGX_VFPrintF(FCGX_Stream* stream, const char *format, va_list arg);/// ditto

    /++
        Flushes any buffered output.

        Server-push is a legitimate application of FCGX_FFlush.
        Otherwise, FCGX_FFlush is not very useful, since FCGX_Accept does it
        implicitly. Calling FCGX_FFlush in no-push applications results in
        extra writes and therefore reduces performance.

        Returns: EOF (-1) if an error occurred.
    ++/
    int FCGX_FFlush(FCGX_Stream*);

    /*
       =================
       Readers & Writers
       =================
    */

    /++
        Closes the stream. For writers, flushes any buffered output.

        Close is not a very useful operation since FCGX_Accept does it
        implicitly. Closing the out stream before the err stream results in an
        extra write if there's nothing in the err stream, and therefore reduces
        performance.

        Returns: EOF (-1) if an error occurred.
    ++/
    int FCGX_FClose(FCGX_Stream*);

    /++
        Returns: The stream error code. 0 means no error, > 0 is an errno(2)
        error, < 0 is a FastCGI error.
    ++/
    int FCGX_GetError(FCGX_Stream*);

    /++
        Clear the stream error code an end-of-file indication.
    ++/
    void FCGX_ClearError(FCGX_Stream*);

    /++
        Create a FCGX_Stream (used by cgi-fcgi). Shouldn't be needed by a
        FastCGI application.
    ++/
    FCGX_Stream* FCGX_CreateWriter(int,int,int,int);

    /++
        Free a FCGX_Stream (used by cgi-fcgi). This should be needed by a FastCGI
        application.
    ++/
    void FCGX_FreeStream(FCGX_Stream**);

    /++
        Prevent the lib from accepting any new requests. Signal handler safe.
    ++/
    void FCGX_ShutdownPending();
}
