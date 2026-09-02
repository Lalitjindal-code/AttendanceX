const admin = require("firebase-admin");

// Initialize Firebase Admin App
if (!admin.apps.length) {
  try {
    if (process.env.FIREBASE_SERVICE_ACCOUNT) {
      // Decode the service account JSON string from environment variables
      const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
    } else {
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
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed. Use GET.' });
  }

  try {
    const db = admin.firestore();
    const usersSnapshot = await db.collection("users").get();
    
    let usersList = [];
    usersSnapshot.forEach(doc => {
      const data = doc.data();
      // Ensure we don't send back sensitive data like auth tokens if any existed
      usersList.push({
        id: doc.id,
        name: data.name || 'Unknown',
        email: data.email || 'No email',
        branch: data.branch || '-',
        semester: data.semester || '-',
        updatedAt: data.updatedAt ? data.updatedAt.toDate().toISOString() : null,
      });
    });

    res.status(200).json({ users: usersList });
  } catch (error) {
    console.error("Error fetching users:", error);
    res.status(500).json({ error: 'Internal server error', details: error.message });
  }
};
