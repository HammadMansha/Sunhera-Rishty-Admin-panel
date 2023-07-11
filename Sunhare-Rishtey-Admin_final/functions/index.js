const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp(functions.config().firebase);

exports.functions = functions.database.ref("User Information/{customer_id}").onDelete(
    (_, context) => {
      const customerID = context.params.customer_id;
      return admin.auth().deleteUser(customerID);
    });