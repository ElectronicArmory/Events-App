'use strict';

import * as functions from 'firebase-functions';

import admin = require('firebase-admin');
// import firebase = require('firebase');

import express = require('express');
// const cookieParser = require('cookie-parser')();
const cors = require('cors')({origin: true});
// import geoFirestore = require('geofirestore');
admin.initializeApp();
const app = express();
import {/*Router, */Request, Response, NextFunction} from 'express';


// Express middleware that validates Firebase ID Tokens passed in the Authorization HTTP header.
// The Firebase ID token needs to be passed as a Bearer token in the Authorization HTTP header like this:
// `Authorization: Bearer <Firebase ID Token>`.
// when decoded successfully, the ID Token content will be added as `req.user`.
const validateFirebaseIdToken = (req:Request, res:Response, next:NextFunction) => {
    if ((!req.headers.authorization || !req.headers.authorization.startsWith('Bearer ')) &&
        !req.cookies.__session) {
        console.error('No Firebase ID token was passed as a Bearer token in the Authorization header.',
            'Make sure you authorize your request by providing the following HTTP header:',
            'Authorization: Bearer <Firebase ID Token>',
            'or by passing a "__session" cookie.');
        res.status(403).send('Unauthorized request');
        return;
    }
};

app.use(cors);
app.use(validateFirebaseIdToken);


app.get('/location/', (req:Request, res:Response) => {

    const latitude = req.headers.latitude;
    const longitude = req.headers.longitude;

    if( typeof latitude === "undefined" || typeof longitude === "undefined" ){
        return res.status(500).send({"code": 500, "message": "No location sent."});
    }


    var db = admin.firestore();

    // Create a Firebase reference where GeoFirestore will store its information
    const collectionRef = db.collection('locations').doc('boise');

    collectionRef.get().then((snapshot)=> {
        var boiseData = snapshot.data();
        if( boiseData == null ){ return; }

        let boiseLatitude = boiseData["latitude"];
        let boiseLongitude = boiseData["longitude"];

        const distance = 1.0

        if( (latitude > boiseLatitude ) && (latitude < boiseLatitude + distance) &&
            (longitude > boiseLongitude ) && (longitude < boiseLatitude + distance) ){
                return res.status(200).type('application/json').send({"market": "Boise"});
            }
            else{
                return res.status(200).type('application/json').send({"market": "Other"});
            }

    }).catch(err => {
        return res.status(500).send({"message": err});
    });
    return;
});


exports.app = functions.https.onRequest(app);

