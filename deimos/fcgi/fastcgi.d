/**
  Bindings for libfcgi/fastcgi.h

  This is mostly here for completeness. In libfcgi, fastcgi.h is a common
  include for other files.

  It mostly contains definitions for the fastcgi protocol itself and therefore
  could be useful for someone wanting to implement FastCGI natively in D.
**/
module deimos.fcgi.fastcgi;

/*
   Constants
*/

enum {
    FcgiListenSockFileNo = 0,
    FcgiMaxLength = 0xffff,
    FcgiVersion = 1,
    FcgiNullRequestID = 0
}

enum FcgiType : ubyte {
    BeginRequest  = 1,
    AbortRequest,
    EndRequest,
    Params,
    Stdin,
    Stdout,
    Stderr,
    Data,
    GetValues,
    GetValuesResult,
    UnknownType
}

enum FcgiRequestFlags : ubyte {
    KeepConn = 1
}

enum FcgiRequestRole : ubyte {
    Responder = 1,
    Authorizer,
    Filter
}

enum FcgiRequestStatus : ubyte {
    RequestComplete = 0,
    CantMpxConn, //What?
    Overloaded,
    UnknownRole
}

enum FcgiValueName : char* {
    MaxConns    = cast(char*)"FCGI_MAX_CONNS".ptr,
    MaxReqs     = cast(char*)"FCGI_MAX_REQS".ptr,
    MpxsConns   = cast(char*)"FCGI_MPXS_CONNS".ptr
}

extern (C) {

    struct FCGI_Header {
        ubyte versn; //Version
        FcgiType type;
        ubyte requestIdB1;
        ubyte requestIdB0;
        ubyte contentLengthB1;
        ubyte contentLengthB0;
        ubyte paddingLength;
        ubyte reserved;
    }

    struct FCGI_BeginRequestBody {
        ubyte roleB1;
        ubyte roleB0;
        ubyte flags;
        ubyte[5] reserved;
    }

    struct FCGI_BeginRequestRecord {
        FCGI_Header header;
        FCGI_BeginRequestBody body_;
    }

    struct FCGI_EndRequestBody {
        ubyte appStatusB3;
        ubyte appStatusB2;
        ubyte appStatusB1;
        ubyte appStatusB0;
        ubyte protocolStatus;
        ubyte[3] reserved;
    }

    struct FCGI_EndRequestRecord {
        FCGI_Header header;
        FCGI_EndRequestBody body_;
    }

    struct FCGI_UnknownTypeBody {
        ubyte type;
        ubyte[7] reserved;
    }

    struct FCGI_UnknownTypeRecord {
        FCGI_Header header;
        FCGI_UnknownTypeBody body_;
    }
}

enum FcgiHeaderLen = FCGI_Header.sizeof;
