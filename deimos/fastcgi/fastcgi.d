module deimos.fastcgi.fastcgi;

import core.stdc.string : memset;

extern (System) {
/*
 * Listening socket file number
 */
const(ubyte) FCGI_LISTENSOCK_FILENO =   0;

struct FCGI_Header{
    ubyte FCGI_version = FCGI_VERSION_1;
    ubyte type;
    ubyte requestIdB1;
    ubyte requestIdB0;
    ubyte contentLengthB1;
    ubyte contentLengthB0;
    ubyte paddingLength;
    ubyte reserved;
}

const(size_t) FCGI_MAX_LENGTH =   0xffff ;

/*
 * Number of bytes in a FCGI_Header.  Future versions of the protocol
 * will not reduce this number.
 */
const(ubyte) FCGI_HEADER_LEN        =    8;

/*
 * Value for version component of FCGI_Header
 */
const(ubyte) FCGI_VERSION_1         =     1;

/*
 * Values for type component of FCGI_Header
 */
const(ubyte) FCGI_BEGIN_REQUEST     =     1;
const(ubyte) FCGI_ABORT_REQUEST     =     2;
const(ubyte) FCGI_END_REQUEST       =     3;
const(ubyte) FCGI_PARAMS            =     4;
const(ubyte) FCGI_STDIN             =     5;
const(ubyte) FCGI_STDOUT            =     6;
const(ubyte) FCGI_STDERR            =     7;
const(ubyte) FCGI_DATA              =     8;
const(ubyte) FCGI_GET_VALUES        =     9;
const(ubyte) FCGI_GET_VALUES_RESULT =    10;
const(ubyte) FCGI_UNKNOWN_TYPE      =    11;
const(ubyte) FCGI_MAXTYPE           =    FCGI_UNKNOWN_TYPE;

/*
 * Value for requestId component of FCGI_Header
 */
const(ubyte) FCGI_NULL_REQUEST_ID =       0;


struct FCGI_BeginRequestBody {
    ubyte roleB1;
    ubyte roleB0;
    ubyte flags;
    ubyte reserved[5];
}

struct FCGI_BeginRequestRecord {
    FCGI_Header             fcgiHeader;
    FCGI_BeginRequestBody   fcgiBody;
}

/*
 * Mask for flags component of FCGI_BeginRequestBody
 */
const(ubyte) FCGI_KEEP_CONN =    1;

/*
 * Values for role component of FCGI_BeginRequestBody
 */
const(ubyte) FCGI_RESPONDER  =   1;
const(ubyte) FCGI_AUTHORIZER =   2;
const(ubyte) FCGI_FILTER     =   3;


struct FCGI_EndRequestBody {
    ubyte appStatusB3;
    ubyte appStatusB2;
    ubyte appStatusB1;
    ubyte appStatusB0;
    ubyte protocolStatus;
    ubyte reserved[3];
}

struct FCGI_EndRequestRecord {
    FCGI_Header         fcgiHeader;
    FCGI_EndRequestBody fcgiBody;
}

/*
 * Values for protocolStatus component of FCGI_EndRequestBody
 */
const(ubyte) FCGI_REQUEST_COMPLETE =   0;
const(ubyte) FCGI_CANT_MPX_CONN    =   1;
const(ubyte) FCGI_OVERLOADED       =   2;
const(ubyte) FCGI_UNKNOWN_ROLE     =   3;


/*
 * Variable names for FCGI_GET_VALUES / FCGI_GET_VALUES_RESULT records
 */
const(string) FCGI_MAX_CONNS  = "FCGI_MAX_CONNS";
const(string) FCGI_MAX_REQS   = "FCGI_MAX_REQS";
const(string) FCGI_MPXS_CONNS = "FCGI_MPXS_CONNS";


struct FCGI_UnknownTypeBody {
    ubyte type;
    ubyte reserved[7];
}

struct FCGI_UnknownTypeRecord {
    FCGI_Header             fcgiHeader;
    FCGI_UnknownTypeBody    fcgiBody;
}

}
/**
 * MakeHeader --
 * Constructs an FCGI_Header struct.
 */
static FCGI_Header MakeHeader( ubyte type, int requestId, int contentLength, int paddingLength){
    FCGI_Header header;
    assert(contentLength >= 0 && contentLength <= FCGI_MAX_LENGTH);
    assert(paddingLength >= 0 && paddingLength <= 0xff);
    header.FCGI_version     = FCGI_VERSION_1;
    header.type             = type;
    header.requestIdB1      = cast(ubyte) ((requestId     >> 8) & 0xff);
    header.requestIdB0      = cast(ubyte) ((requestId         ) & 0xff);
    header.contentLengthB1  = cast(ubyte) ((contentLength >> 8) & 0xff);
    header.contentLengthB0  = cast(ubyte) ((contentLength     ) & 0xff);
    header.paddingLength    = cast(ubyte) paddingLength;
    header.reserved         =  0;
    return header;
}


static int exitStatus = 0;
