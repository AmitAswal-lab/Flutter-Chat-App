// Import the necessary V2 modules. Notice the "/v2/firestore".
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { setGlobalOptions } = require("firebase-functions/v2/options");
const admin = require("firebase-admin");
const logger = require("firebase-functions/logger");

// Initialize the Firebase Admin SDK.
admin.initializeApp();

setGlobalOptions({ region: "asia-southeast1" });

/**
 * Cloud Function to send a push notification when a new message is created in a chat.
 * This function uses the V2 syntax.
 */
exports.sendChatNotification = onDocumentCreated(
    // This is the V2 trigger. The path with wildcards is the first argument.
    "chats/{chatId}/messages/{messageId}",
    async (event) => {
        // In V2, the snapshot and context are combined into a single "event" object.
        const snapshot = event.data;
        if (!snapshot) {
            logger.log("No data associated with the event");
            return;
        }

        // 1. Get the new message data from the snapshot.
        const newMessage = snapshot.data();
        const senderId = newMessage.userId;
        const senderUsername = newMessage.username;
        const messageText = newMessage.text;

        // 2. Get the chatId wildcard from event.params.
        const chatId = event.params.chatId;
        const chatDoc = await admin.firestore().collection("chats").doc(chatId).get();
        const participants = chatDoc.data().participants;

        // 3. Find the recipient's ID.
        const recipientId = participants.find((uid) => uid !== senderId);

        if (!recipientId) {
            logger.log("Could not find a recipient. Exiting function.");
            return;
        }

        // 4. Get the recipient's FCM token.
        const recipientDoc = await admin.firestore().collection("users").doc(recipientId).get();

        if (!recipientDoc.exists || !recipientDoc.data().fcmToken) {
            logger.log("Recipient user document does not exist or has no FCM token.");
            return;
        }

        const recipientToken = recipientDoc.data().fcmToken;

        // 5. Construct the full message payload with the CORRECT structure.
        //    (This is the updated section)
        const message = {
            // The simple, cross-platform notification object
            notification: {
                title: `New message from ${senderUsername}`,
                body: messageText,
            },

            // Platform-specific APNS (iOS) configuration for sound and badge
            apns: {
                payload: {
                    aps: {
                        badge: 1, // Badge count must be a number
                        sound: "default",
                    },
                },
            },

            // The recipient's device token
            token: recipientToken,
        };

        // 6. Send the notification.
        //    (This section is now simpler because 'message' is already fully constructed)
        logger.log(`Sending notification to token: ${recipientToken}`);
        try {
            const response = await admin.messaging().send(message);
            logger.log("Successfully sent message:", response);
            return response;
        } catch (error) {
            logger.error("Error sending message:", error);
            return null;
        }
    }
);