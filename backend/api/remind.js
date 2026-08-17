const admin = require("firebase-admin");

// Initialize Firebase Admin App
// For local testing or if passing service account as string
if (!admin.apps.length) {
  try {
    if (process.env.FIREBASE_SERVICE_ACCOUNT) {
      // Decode the service account JSON string from environment variables
      const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
    } else {
      // Fallback to default application credentials (e.g. if deployed to Google Cloud)
      // Or in local testing, set GOOGLE_APPLICATION_CREDENTIALS env var
      admin.initializeApp();
    }
  } catch (error) {
    console.error("Firebase initialization error:", error);
  }
}

module.exports = async (req, res) => {
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Credentials', true);
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
  res.setHeader('Access-Control-Allow-Headers', 'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed. Use POST.' });
  }

  const { title, message, target } = req.body;

  if (!title || !message) {
    return res.status(400).json({ error: 'Missing title or message.' });
  }

  // target can be 'all' or 'incomplete' (default to all if not specified)
  const audience = target || 'all';

  try {
    const auth = admin.auth();
    const db = admin.firestore();
    const messaging = admin.messaging();

    let targetUids = [];

    if (audience === 'incomplete') {
      // Logic for incomplete users
      const listUsersResult = await auth.listUsers(1000); 
      const allAuthUsers = listUsersResult.users;

      const usersSnapshot = await db.collection("users").get();
      const completedUsers = new Set();
      usersSnapshot.forEach(doc => completedUsers.add(doc.id));

      const incompleteUsers = allAuthUsers.filter(user => !completedUsers.has(user.uid));
      targetUids = incompleteUsers.map(u => u.uid);

    } else {
      // target === 'all'
      // Fetch all users from Auth
      const listUsersResult = await auth.listUsers(1000);
      targetUids = listUsersResult.users.map(u => u.uid);
    }

    if (targetUids.length === 0) {
      return res.status(200).json({ message: 'No users found for the specified target.' });
    }

    // Fetch tokens for the targeted UIDs
    let tokens = [];
    const BATCH_SIZE = 10; // Firestore IN query limit is 30, use 10 to be safe
    for (let i = 0; i < targetUids.length; i += BATCH_SIZE) {
      const batchUids = targetUids.slice(i, i + BATCH_SIZE);
      const tokenDocs = await db.collection("fcm_tokens").where(admin.firestore.FieldPath.documentId(), "in", batchUids).get();
      tokenDocs.forEach(doc => {
        const t = doc.data().fcmToken;
        if (t) tokens.push(t);
      });
    }

    if (tokens.length === 0) {
      return res.status(200).json({ message: `No FCM tokens found for target: ${audience}` });
    }

    // Send multicast message
    const payload = {
      notification: {
        title: title,
        body: message,
      },
      tokens: tokens,
    };

    const response = await messaging.sendEachForMulticast(payload);
    
    res.status(200).json({
      success: true,
      message: `Successfully sent ${response.successCount} messages. Failed: ${response.failureCount}. Target: ${audience}`,
      details: {
        successCount: response.successCount,
        failureCount: response.failureCount,
        target: audience
      }
    });

  } catch (error) {
    console.error("Error sending message:", error);
    res.status(500).json({ error: 'Internal server error', details: error.message });
  }
};
