// The Cloud Functions for Firebase SDK to create Cloud Functions and triggers.
const {logger} = require("firebase-functions");
const {onRequest} = require("firebase-functions/v2/https");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");

// The Firebase Admin SDK to access Firestore.
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const mailgun = require('mailgun-js')({
  apiKey: 'dd6abfe4fca5ae7326b67e2faa31954f-b02bcf9f-0871cbcb',
  domain: 'sandbox1fbddbc12fa749aa8b0d5feb81a87759.mailgun.org',
});

admin.initializeApp();

exports.sendLoginCodeEmail = functions.https.onCall(async (data, context) => {
  const email = data.email;
  const loginCode = data.loginCode;

  const msg = {
    from: 'PVPteam@senjorai.com',
    to: email,
    subject: 'Your Login Code',
    text: `Hello! Your login code is: ${loginCode}. Hope you have wonderful day <3 \nBest regards,\n PVPteam`,
  };

  try {
    await mailgun.messages().send(msg);
    return { success: true };
  } catch (error) {
    console.error('Error sending email:', error);
    return { success: false, error: error.message };
  }
});
