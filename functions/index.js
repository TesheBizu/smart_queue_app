const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

exports.callNextTicket = functions.https.onCall(async (data, context) => {
  const { serviceId } = data;

  const ticketsRef = db.collection("tickets");

  const snapshot = await ticketsRef
    .where("serviceId", "==", serviceId)
    .where("status", "==", "waiting")
    .orderBy("number")
    .limit(1)
    .get();

  if (snapshot.empty) {
    throw new functions.https.HttpsError("not-found", "No tickets");
  }

  const doc = snapshot.docs[0];

  await doc.ref.update({
    status: "called",
    calledAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { success: true };
});

exports.claimTicket = functions.https.onCall(async (data, context) => {
  const { ticketId, providerId } = data;

  const ticketRef = db.collection("tickets").doc(ticketId);

  return db.runTransaction(async (transaction) => {
    const doc = await transaction.get(ticketRef);

    if (!doc.exists) throw "Ticket not found";

    const ticket = doc.data();

    if (ticket.status !== "called" || ticket.assignedProviderId) {
      throw "Already claimed";
    }

    transaction.update(ticketRef, {
      status: "in_service",
      assignedProviderId: providerId,
      startedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { success: true };
  });
});

exports.finishTicket = functions.https.onCall(async (data, context) => {
  const { ticketId } = data;

  const ticketRef = db.collection("tickets").doc(ticketId);

  await ticketRef.update({
    status: "done",
    finishedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { success: true };
});
