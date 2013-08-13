#import "NMSSHSessionDelegate.h"

/**
NMSSHSession provides the functionality required to setup a SSH connection
and authorize against it.

In it's simplest form it works like this:

    NMSSHSession *session = [NMSSHSession connectToHost:@"127.0.0.1:22"
                                             withUsername:@"user"];

    if (session.isConnected) {
        NSLog(@"Successfully created a new session");
    }

    [session authenticateByPassword:@"pass"];

    if (session.isAuthorized) {
        NSLog(@"Successfully authorized");
    }
*/
@interface NMSSHSession : NSObject

/// ----------------------------------------------------------------------------
/// @name Setting the Delegate
/// ----------------------------------------------------------------------------

/**
 * The receiver’s `delegate`.
 *
 * The `delegate` is sent messages when content is loading.
 */
@property (nonatomic, weak) id<NMSSHSessionDelegate> delegate;

/// ----------------------------------------------------------------------------
/// @name Initialize a new SSH session
/// ----------------------------------------------------------------------------

/**
 * Shorthand method for initializing a NMSSHSession object and calling connect.
 *
 * @param host The server hostname (a port number can be specified by appending
 *             `@":{portnr}"`
 * @param username A valid username the server will accept
 * @returns NMSSHSession instance
 */
+ (id)connectToHost:(NSString *)host withUsername:(NSString *)username;

/**
 * Shorthand method for initializing a NMSSHSession object and calling connect,
 * (explicitly setting a port number).
 *
 * @param host The server hostname
 * @param port The port number
 * @param username A valid username the server will accept
 * @returns NMSSHSession instance
 */
+ (id)connectToHost:(NSString *)host port:(NSInteger)port withUsername:(NSString *)username;

/**
 * Create and setup a new NMSSH instance.
 *
 * @param host The server hostname (a port number can be specified by appending
 *             `@":{portnr}"`
 * @param username A valid username the server will accept
 * @returns NMSSHSession instance
 */
- (id)initWithHost:(NSString *)host andUsername:(NSString *)username;

/**
 * Create and setup a new NMSSH instance.
 *
 * @param host The server hostname
 * @param port The port number
 * @param username A valid username the server will accept
 * @returns NMSSHSession instance
 */
- (id)initWithHost:(NSString *)host port:(NSInteger)port andUsername:(NSString *)username;

/// ----------------------------------------------------------------------------
/// @name Connection settings
/// ----------------------------------------------------------------------------

/** Full server hostname in the format `@"{hostname}:{port}"`. */
@property (nonatomic, readonly) NSString *host;

/** The server port to connect to. */
@property (nonatomic, readonly) NSNumber *port;

/** Username that will authenticate against the server. */
@property (nonatomic, readonly) NSString *username;

/** Timeout for libssh2 blocking functions. */
@property (nonatomic, strong) NSNumber *timeout;

/// ----------------------------------------------------------------------------
/// @name Raw libssh2 session and socket reference
/// ----------------------------------------------------------------------------

/** Raw libssh2 session instance. */
@property (nonatomic, readonly, getter = rawSession) LIBSSH2_SESSION *session;

/** Raw session socket. */
@property (nonatomic, readonly) int sock;

/// ----------------------------------------------------------------------------
/// @name Open/Close a connection to the server
/// ----------------------------------------------------------------------------

/**
 * A Boolean value indicating whether the session connected successfully
 * (read-only).
 */
@property (nonatomic, readonly, getter = isConnected) BOOL connected;

/**
 * Connect to the server using the default timeout (10 seconds)
 *
 * @returns Connection status
 */
- (BOOL)connect;

/**
 * Connect to the server.
 *
 * @param timeout The time, in seconds, to wait before giving up.
 * @returns Connection status
 */
- (BOOL)connectWithTimeout:(NSNumber *)timeout;

/**
 * Close the session
 */
- (void)disconnect;

/// ----------------------------------------------------------------------------
/// @name Authentication
/// ----------------------------------------------------------------------------

/**
 * A Boolean value indicating whether the session is successfully authorized
 * (read-only).
 */
@property (nonatomic, readonly, getter = isAuthorized) BOOL authorized;

/**
 * Authenticate by password
 *
 * @param password Password for connected user
 * @returns Authentication success
 */
- (BOOL)authenticateByPassword:(NSString *)password;

/**
 * Authenticate by public key
 *
 * Use password:nil when the key is unencrypted
 *
 * @param publicKey Path to public key on local computer
 * @param password Password for encrypted private key
 * @returns Authentication success
 */
- (BOOL)authenticateByPublicKey:(NSString *)publicKey
                    andPassword:(NSString *)password;

/**
 * Authenticate by keyboard-interactive using delegate.
 *
 * @returns Authentication success
 */
- (BOOL)authenticateByKeyboardInteractive;

/**
 * Authenticate by keyboard-interactive using block.
 *
 * @param authenticationBlock The block to apply to server requests.
 *     The block takes one argument:
 *
 *     _request_ - Question from server<br>
 *     The block returns a NSString object that represents a valid response
 *     to the given question.
 * @returns Authentication success
 */
- (BOOL)authenticateByKeyboardInteractiveUsingBlock:(NSString *(^)(NSString *request))authenticationBlock;

/**
 * Setup and connect to an SSH agent
 *
 * @returns Authentication success
 */
- (BOOL)connectToAgent;

/// ----------------------------------------------------------------------------
/// @name Quick channel/sftp access
/// ----------------------------------------------------------------------------

/** Get a pre-configured NMSSHChannel object for the current session (read-only). */
@property (nonatomic, readonly) NMSSHChannel *channel;

/** Get a pre-configured NMSFTP object for the current session (read-only). */
@property (nonatomic, readonly) NMSFTP *sftp;

@end
