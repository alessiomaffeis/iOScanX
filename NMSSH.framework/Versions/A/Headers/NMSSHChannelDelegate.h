/**
 * Protocol for registering to receive messages from an active NMSSHChannel.
 */
@protocol NMSSHChannelDelegate <NSObject>

/**
 * Called when a channel read new data on the socket.
 *
 * @param channel The channel that read the message
 * @param message The message that the channel has read
 */
- (void)channel:(NMSSHChannel *)channel didReadData:(NSString *)message;

/**
 * Called when a channel read new error on the socket.
 *
 * @param channel The channel that read the message
 * @param message The error that the channel has read
 */
- (void)channel:(NMSSHChannel *)channel didReadError:(NSString *)error;


@end