const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { setGlobalOptions } = require("firebase-functions/v2/options");
const admin = require("firebase-admin");
const logger = require("firebase-functions/logger");

admin.initializeApp();
setGlobalOptions({ region: "asia-southeast1" });

exports.sendChatNotification = onDocumentCreated(
    "chats/{chatId}/messages/{messageId}",
    async (event) => {
        const snapshot = event.data;
        if (!snapshot) {
            logger.log("No data associated with the event");
            return;
        }

        const newMessage = snapshot.data();
        const senderId = newMessage.userId;
        const senderUsername = newMessage.username;
        const messageText = newMessage.text;
        const chatId = event.params.chatId;

        if (chatId === 'global_chat') {
            // --- Handle Global Chat Notification ---
            const usersSnapshot = await admin.firestore().collection('users').get();
            const allTokens = [];

            usersSnapshot.forEach(doc => {
                const user = doc.data();
                if (doc.id !== senderId && user.fcmToken) {
                    allTokens.push(user.fcmToken);
                }
            });

            if (allTokens.length === 0) {
                logger.log("No other users found to notify in global chat.");
                return;
            }

            // Construct the multicast message with explicit Android config
            const message = {
                notification: {
                    title: `Global Chat: ${senderUsername}`,
                    body: messageText,
                },
                data: {
                    chatId: 'global_chat',
                },
                tokens: allTokens,
                android: {
                    collapse_key: 'global_chat',
                    notification: {
                        icon: 'ic_stat_app_icon',
                        color: '#00BFFF',
                    },
                },
                apns: {
                    headers: {
                        'apns-collapse-id': 'global_chat',
                    },
                },
            };

            logger.log(`Sending global notification to ${allTokens.length} devices.`);
            try {
                await admin.messaging().sendEachForMulticast(message);
            } catch (error) {
                logger.error("Error sending global message:", error);
            }

        } else {
            // --- Handle Private Chat Notification ---
            const chatDoc = await admin.firestore().collection("chats").doc(chatId).get();
            const participants = chatDoc.data().participants;
            const recipientId = participants.find((uid) => uid !== senderId);

            if (!recipientId) { return; }

            const recipientDoc = await admin.firestore().collection("users").doc(recipientId).get();
            if (!recipientDoc.exists || !recipientDoc.data().fcmToken) {
                logger.log("Recipient user document does not exist or has no FCM token.");
                return;
            }

            const recipientToken = recipientDoc.data().fcmToken;

            const message = {
                notification: {
                    title: `New message from ${senderUsername}`,
                    body: messageText,
                },
                data: {
                    chatId: chatId,
                    otherUsername: senderUsername,
                },
                token: recipientToken,
                android: {
                    collapse_key: chatId,
                    notification: {
                        icon: 'ic_stat_app_icon',
                        color: '#00BFFF',
                    },
                },
                apns: {
                    headers: {
                        'apns-collapse-id': chatId,
                    },
                },
            };

            logger.log(`Sending private notification to token: ${recipientToken}`);
            try {
                await admin.messaging().send(message);
            } catch (error) {
                logger.error("Error sending private message:", error);
            }
        }
    }
);