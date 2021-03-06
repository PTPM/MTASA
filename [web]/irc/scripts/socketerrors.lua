---------------------------------------------------------------------
-- Project: irc
-- Author: MCvarial
-- Contact: mcvarial@gmail.com
-- Version: 1.0.3
-- Date: 31.10.2010
---------------------------------------------------------------------

-- linux error codes	
socketErrors = {}	
socketErrors[001] = "Operation not permitted"
socketErrors[002] = "No such file or directory"
socketErrors[003] = "No such process"
socketErrors[004] = "Interrupted system call"
socketErrors[005] = "I/O error"
socketErrors[006] = "No such device or address"
socketErrors[007] = "Argument list too long"
socketErrors[008] = "Exec format error"
socketErrors[009] = "Bad file number"
socketErrors[010] = "No child processes"
socketErrors[011] = "Try again"
socketErrors[012] = "Out of memory"
socketErrors[013] = "Permission denied"
socketErrors[014] = "Bad address"
socketErrors[015] = "Block device required"
socketErrors[016] = "Device or resource busy"
socketErrors[017] = "File exists"
socketErrors[018] = "Cross-device link"
socketErrors[019] = "No such device"
socketErrors[020] = "Not a directory"
socketErrors[021] = "Is a directory"
socketErrors[022] = "Invalid argument"
socketErrors[023] = "File table overflow"
socketErrors[024] = "Too many open files"
socketErrors[025] = "Not a typewriter"
socketErrors[026] = "Text file busy"
socketErrors[027] = "File too large"
socketErrors[028] = "No space left on device"
socketErrors[029] = "Illegal seek"
socketErrors[030] = "Read-only file system"
socketErrors[031] = "Too many links"
socketErrors[032] = "Broken pipe"
socketErrors[033] = "Math argument out of domain of func"
socketErrors[034] = "Math result not representable"
socketErrors[035] = "Resource deadlock would occur"
socketErrors[036] = "File name too long"
socketErrors[037] = "No record locks available"
socketErrors[038] = "Function not implemented"
socketErrors[039] = "Directory not empty"
socketErrors[040] = "Too many symbolic links encountered"
socketErrors[042] = "No message of desired type"
socketErrors[043] = "Identifier removed"
socketErrors[044] = "Channel number out of range"
socketErrors[045] = "Level 2 not synchronized"
socketErrors[046] = "Level 3 halted"
socketErrors[047] = "Level 3 reset"
socketErrors[048] = "Link number out of range"
socketErrors[049] = "Protocol driver not attached"
socketErrors[050] = "No CSI structure available"
socketErrors[051] = "Level 2 halted"
socketErrors[052] = "Invalid exchange"
socketErrors[053] = "Invalid request descriptor"
socketErrors[054] = "Exchange full"
socketErrors[055] = "No anode"
socketErrors[056] = "Invalid request code"
socketErrors[057] = "Invalid slot"
socketErrors[059] = "Bad font file format"
socketErrors[060] = "Device not a stream"
socketErrors[061] = "No data available"
socketErrors[062] = "Timer expired"
socketErrors[063] = "Out of streams resources"
socketErrors[064] = "Machine is not on the network"
socketErrors[065] = "Package not installed"
socketErrors[066] = "Object is remote"
socketErrors[067] = "Link has been severed"
socketErrors[068] = "Advertise error"
socketErrors[069] = "Srmount error"
socketErrors[070] = "Communication error on send"
socketErrors[071] = "Protocol error"
socketErrors[072] = "Multihop attempted"
socketErrors[073] = "RFS specific error"
socketErrors[074] = "Not a data message"
socketErrors[075] = "Value too large for defined data type"
socketErrors[076] = "Name not unique on network"
socketErrors[077] = "File descriptor in bad state"
socketErrors[078] = "Remote address changed"
socketErrors[079] = "Can not access a needed shared library"
socketErrors[080] = "Accessing a corrupted shared library"
socketErrors[081] = ".lib section in a.out corrupted"
socketErrors[082] = "Attempting to link in too many shared libraries"
socketErrors[083] = "Cannot exec a shared library directly"
socketErrors[084] = "Illegal byte sequence"
socketErrors[085] = "Interrupted system call should be restarted"
socketErrors[086] = "Streams pipe error"
socketErrors[087] = "Too many users"
socketErrors[088] = "Socket operation on non-socket"
socketErrors[089] = "Destination address required"
socketErrors[090] = "Message too long"
socketErrors[091] = "Protocol wrong type for socket"
socketErrors[092] = "Protocol not available"
socketErrors[093] = "Protocol not supported"
socketErrors[094] = "Socket type not supported"
socketErrors[095] = "Operation not supported on transport endpoint"
socketErrors[096] = "Protocol family not supported"
socketErrors[097] = "Address family not supported by protocol"
socketErrors[098] = "Address already in use"
socketErrors[099] = "Cannot assign requested address"
socketErrors[100] = "Network is down"
socketErrors[101] = "Network is unreachable"
socketErrors[102] = "Network dropped connection because of reset"
socketErrors[103] = "Software caused connection abort"
socketErrors[104] = "Connection reset by peer"
socketErrors[105] = "No buffer space available"
socketErrors[106] = "Transport endpoint is already connected"
socketErrors[107] = "Transport endpoint is not connected"
socketErrors[108] = "Cannot send after transport endpoint shutdown"
socketErrors[109] = "Too many references: cannot splice"
socketErrors[110] = "Connection timed out"
socketErrors[111] = "Connection refused"
socketErrors[112] = "Host is down"
socketErrors[113] = "No route to host"
socketErrors[114] = "Operation already in progress"
socketErrors[115] = "Operation now in progress"
socketErrors[116] = "Stale NFS file handle"
socketErrors[117] = "Structure needs cleaning"
socketErrors[118] = "Not a XENIX named type file"
socketErrors[119] = "No XENIX semaphores available"
socketErrors[120] = "Is a named type file"
socketErrors[121] = "Remote I/O error"
socketErrors[122] = "Quota exceeded"
socketErrors[123] = "No medium found"
socketErrors[124] = "Wrong medium type"

-- windows socket errors
socketErrors[10004] = "Interrupted function call. This error is returned when a socket is closed or a process is terminated, on a pending Winsock operation for that socket."
socketErrors[10013] = "Permission denied. An attempt was made to access a socket in a way forbidden by its access permissions."
socketErrors[10014] = "Bad address. The system detected an invalid pointer address in attempting to use a pointer argument of a call. This error occurs if an application passes an invalid pointer value, or if the length of the buffer is too small. For instance, if the length of an argument, which is a sockaddr structure, is smaller than the sizeof(SOCKADDR)."
socketErrors[10022] = "Invalid argument. Some invalid argument was supplied (for example, specifying an invalid level to the setsockopt (Windows Sockets) function). In some instances, it also refers to the current state of the socket � for instance, calling accept (Windows Sockets) on a socket that is not listening."
socketErrors[10024] = "Too many open files. Too many open sockets. Each implementation may have a maximum number of socket handles available, either globally, per process, or per thread."
socketErrors[10035] = "Resource temporarily unavailable. This error is returned from operations on nonblocking sockets that cannot be completed immediately, for example recv when no data is queued to be read from the socket. It is a nonfatal error, and the operation should be retried later. It is normal for WSAEWOULDBLOCK to be reported as the result from calling connect (Windows Sockets) on a nonblocking SOCK_STREAM socket, since some time must elapse for the connection to be established."
socketErrors[10036] = "Operation now in progress. A blocking operation is currently executing. Windows Sockets only allows a single blocking operation � per task or thread � to be outstanding, and if any other function call is made (whether or not it references that or any other socket) the function fails with the WSAEINPROGRESS error."
socketErrors[10037] = "Operation already in progress. An operation was attempted on a nonblocking socket with an operation already in progress � that is, calling connect a second time on a nonblocking socket that is already connecting, or canceling an asynchronous request (WSAAsyncGetXbyY) that has already been canceled or completed."
socketErrors[10038] = "Socket operation on nonsocket. An operation was attempted on something that is not a socket. Either the socket handle parameter did not reference a valid socket, or for the select function, a member of an fd_set structure was not valid."
socketErrors[10039] = "Destination address required. A required address was omitted from an operation on a socket. For example, this error is returned if sendto is called with the remote address of ADDR_ANY."
socketErrors[10040] = "Message too long. A message sent on a datagram socket was larger than the internal message buffer or some other network limit, or the buffer used to receive a datagram was smaller than the datagram itself."
socketErrors[10041] = "Protocol wrong type for socket. A protocol was specified in the socket function call that does not support the semantics of the socket type requested. For example, the ARPA Internet UDP protocol cannot be specified with a socket type of SOCK_STREAM."
socketErrors[10042] = "Bad protocol option. An unknown, invalid or unsupported option or level was specified in a getsockopt (Windows Sockets) or setsockopt (Windows Sockets) call."
socketErrors[10043] = "Protocol not supported. The requested protocol has not been configured into the system, or no implementation for it exists. For example, a socket call requests a SOCK_DGRAM socket, but specifies a stream protocol."
socketErrors[10044] = "Socket type not supported. The support for the specified socket type does not exist in this address family. For example, the optional type SOCK_RAW might be selected in a socket call, and the implementation does not support SOCK_RAW sockets at all. Also, this error code maybe returned for SOCK_RAW if the caller application is not privileged."
socketErrors[10045] = "Operation not supported. The attempted operation is not supported for the type of object referenced. Usually this occurs when a socket descriptor to a socket that cannot support this operation is trying to accept a connection on a datagram socket."
socketErrors[10046] = "Protocol family not supported. The protocol family has not been configured into the system or no implementation for it exists. This message has a slightly different meaning from WSAEAFNOSUPPORT. However, it is interchangeable in most cases, and all Windows Sockets functions that return one of these messages also specify WSAEAFNOSUPPORT."
socketErrors[10047] = "Address family not supported by protocol family. An address incompatible with the requested protocol was used. All sockets are created with an associated address family (that is, AF_INET for Internet protocols) and a generic protocol type (that is, SOCK_STREAM). This error is returned if an incorrect protocol is explicitly requested in the socket call, or if an address of the wrong family is used for a socket, for example, in sendto."
socketErrors[10048] = "Address already in use. Typically, only one usage of each socket address (protocol/IP address/port) is permitted. This error occurs if an application attempts to bind a socket to an IP address/port that has already been used for an existing socket, or a socket that was not closed properly, or one that is still in the process of closing. For server applications that need to bind multiple sockets to the same port number, consider using setsockopt (Windows Sockets)(SO_REUSEADDR). Client applications usually need not call bind at all � connect chooses an unused port automatically. When bind is called with a wildcard address (involving ADDR_ANY), a WSAEADDRINUSE error could be delayed until the specific address is committed. This could happen with a call to another function later, including connect, listen, WSAConnect, or WSAJoinLeaf."
socketErrors[10049] = "Cannot assign requested address. The requested address is not valid in its context. This normally results from an attempt to bind to an address that is not valid for the local machine. This can also result from connect (Windows Sockets), sendto, WSAConnect, WSAJoinLeaf, or WSASendTo when the remote address or port is not valid for a remote machine (for example, address or port 0)."
socketErrors[10050] = "Network is down. A socket operation encountered a dead network. This could indicate a serious failure of the network system (that is, the protocol stack that the Windows Sockets DLL runs over), the network interface, or the local network itself."
socketErrors[10051] = "Network is unreachable. A socket operation was attempted to an unreachable network. This usually means the local software knows no route to reach the remote host."
socketErrors[10052] = "Network dropped connection on reset. The connection has been broken due to keep-alive activity detecting a failure while the operation was in progress. It can also be returned by setsockopt (Windows Sockets) if an attempt is made to set SO_KEEPALIVE on a connection that has already failed."
socketErrors[10053] = "Software caused connection abort. An established connection was aborted by the software in your host machine, possibly due to a data transmission time-out or protocol error."
socketErrors[10054] = "Connection reset by peer. An existing connection was forcibly closed by the remote host. This normally results if the peer application on the remote host is suddenly stopped, the host is rebooted, or the remote host uses a hard close (see setsockopt (Windows Sockets) for more information on the SO_LINGER option on the remote socket.) This error may also result if a connection was broken due to keep-alive activity detecting a failure while one or more operations are in progress. Operations that were in progress fail with WSAENETRESET. Subsequent operations fail with WSAECONNRESET."
socketErrors[10055] = "No buffer space available. An operation on a socket could not be performed because the system lacked sufficient buffer space or because a queue was full."
socketErrors[10056] = "Socket is already connected. A connect request was made on an already-connected socket. Some implementations also return this error if sendto is called on a connected SOCK_DGRAM socket (for SOCK_STREAM sockets, the to parameter in sendto is ignored) although other implementations treat this as a legal occurrence."
socketErrors[10056] = "Socket is already connected. A connect request was made on an already-connected socket. Some implementations also return this error if sendto is called on a connected SOCK_DGRAM socket (for SOCK_STREAM sockets, the to parameter in sendto is ignored) although other implementations treat this as a legal occurrence."
socketErrors[10057] = "Socket is not connected. A request to send or receive data was disallowed because the socket is not connected and (when sending on a datagram socket using sendto) no address was supplied. Any other type of operation might also return this error � for example, setsockopt (Windows Sockets) setting SO_KEEPALIVE if the connection has been reset."
socketErrors[10058] = "Cannot send after socket shutdown. A request to send or receive data was disallowed because the socket had already been shut down in that direction with a previous shutdown call. By calling shutdown a partial close of a socket is requested, which is a signal that sending or receiving, or both have been discontinued."
socketErrors[10060] = "Connection timed out. A connection attempt failed because the connected party did not properly respond after a period of time, or the established connection failed because the connected host has failed to respond."
socketErrors[10060] = "Connection timed out. A connection attempt failed because the connected party did not properly respond after a period of time, or the established connection failed because the connected host has failed to respond."
socketErrors[10061] = "Connection refused. No connection could be made because the target machine actively refused it. This usually results from trying to connect to a service that is inactive on the foreign host � that is, one with no server application running."
socketErrors[10064] = "Host is down. A socket operation failed because the destination host is down. A socket operation encountered a dead host. Networking activity on the local host has not been initiated. These conditions are more likely to be indicated by the error WSAETIMEDOUT."
socketErrors[10065] = "No route to host. A socket operation was attempted to an unreachable host. See WSAENETUNREACH."
socketErrors[10067] = "Too many processes. A Windows Sockets implementation may have a limit on the number of applications that can use it simultaneously. WSAStartup may fail with this error if the limit has been reached."
socketErrors[10091] = "Network subsystem is unavailable. This error is returned by WSAStartup if the Windows Sockets implementation cannot function at because the underlying system it uses to provide network services is currently unavailable. Users should check: That the appropriate Windows Sockets DLL file is in the current path. That they are not trying to use more than one Windows Sockets implementation simultaneously. If there is more than one Winsock DLL on your system, be sure the first one in the path is appropriate for the network subsystem currently loaded. The Windows Sockets implementation documentation to be sure all necessary components are currently installed and configured correctly."
socketErrors[10092] = "Winsock.dll version out of range. The current Windows Sockets implementation does not support the Windows Sockets specification version requested by the application. Check that no old Windows Sockets DLL files are being accessed."
socketErrors[10093] = "Successful WSAStartup not yet performed. Either the application has not called WSAStartup or WSAStartup failed. The application may be accessing a socket that the current active task does not own (that is, trying to share a socket between tasks), or WSACleanup has been called too many times."
socketErrors[10101] = "Graceful shutdown in progress. Returned by WSARecv and WSARecvFrom to indicate that the remote party has initiated a graceful shutdown sequence."
socketErrors[10109] = "Class type not found. The specified class was not found."
socketErrors[11001] = "Host not found. No such host is known. The name is not an official host name or alias, or it cannot be found in the database(s) being queried. This error may also be returned for protocol and service queries, and means that the specified name could not be found in the relevant database."
socketErrors[11002] = "Nonauthoritative host not found. This is usually a temporary error during host name resolution and means that the local server did not receive a response from an authoritative server. A retry at some time later may be successful."
socketErrors[11003] = "This is a nonrecoverable error. This indicates some sort of nonrecoverable error occurred during a database lookup. This may be because the database files (for example, BSD-compatible HOSTS, SERVICES, or PROTOCOLS files) could not be found, or a DNS request was returned by the server with a severe error."
socketErrors[11004] = "Valid name, no data record of requested type. The requested name is valid and was found in the database, but it does not have the correct associated data being resolved for."