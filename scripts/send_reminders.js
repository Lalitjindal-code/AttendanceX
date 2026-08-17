const admin = require("firebase-admin");

// TODO: Replace with the actual path to your service account key JSON file
// Get this from Firebase Console -> Project Settings -> Service Accounts -> Generate new private key
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const auth = admin.auth();
const db = admin.firestore();
const messaging = admin.messaging();

// Read custom message from command line arguments, or use default
const customMessage = process.argv.slice(2).join(" ");
const notificationBody = customMessage.length > 0 
  ? customMessage 
  : "Please open Attendify and complete your onboarding to start tracking attendance.";

async function sendReminders() {
  try {
    console.log("Fetching all users from Firebase Auth...");
    const listUsersResult = await auth.listUsers(1000); 
    const allAuthUsers = listUsersResult.users;
    console.log(`Found ${allAuthUsers.length} users in Auth.`);

    console.log("Fetching users from Firestore 'users' collection...");
    const usersSnapshot = await db.collection("users").get();
    const completedUsers = new Set();
    usersSnapshot.forEach(doc => completedUsers.add(doc.id));

    const incompleteUsers = allAuthUsers.filter(user => !completedUsers.has(user.uid));
    console.log(`Found ${incompleteUsers.length} users with incomplete profiles.`);

    let successCount = 0;
    let failCount = 0;

    for (const user of incompleteUsers) {
      const tokenDoc = await db.collection("fcm_tokens").doc(user.uid).get();
      if (tokenDoc.exists) {
        const token = tokenDoc.data().fcmToken;
        if (token) {
          const message = {
            notification: {
              title: "Profile Incomplete!",
              body: notificationBody,
            },
            token: token,
          };
          try {
            await messaging.send(message);
            console.log(`Sent reminder to ${user.email}`);
            successCount++;
          } catch (e) {
            console.error(`Failed to send to ${user.email}:`, e.message);
            failCount++;
          }
        }
      } else {
        console.log(`Skipping ${user.email} - No FCM token found. (They haven't opened the app since this update)`);
      }
    }
    console.log(`\nDone! Sent: ${successCount}, Failed: ${failCount}`);
  } catch (error) {
    console.error("Error:", error);
  }
}

sendReminders();
