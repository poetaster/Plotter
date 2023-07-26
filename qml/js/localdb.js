.pragma library

.import QtQuick.LocalStorage 2.0 as LocalStorage

var _db;
var debug = false;

function db(){
    if (!_db){
        _db = LocalStorage.LocalStorage.openDatabaseSync(
                    "Plotter", "0.4", "Settings", 100000,
                     function(db) { db.changeVersion("", "0.4"); }
                     );
        initDb();
    }

    return _db;
}

function initDb() {
    if (debug) console.log("init Database");
    //creating tables
    _db.transaction( function (tx) {
        tx.executeSql("create table if not exists settings (key TEXT primary key, value TEXT)");
    }
    );
    console.log("init Database finished");
}


function getProp(propertyName){

    if (debug) console.log("getProp: " + propertyName);
    var retValue;
    db().readTransaction(
                function (tx) {
                    var queryResults = tx.executeSql("select value from settings where key = ?", [propertyName]);

                    if (queryResults.rows.length !== 1) {//propery not found
                        return "";
                    }

                    retValue = queryResults.rows.item(0).value;
                    if (debug) console.log("getProperty value: " + retValue);
                }
           );

    if (retValue){
        return retValue;
    } else {
        return "";
    }

}

function setProp(propertyName, propertyValue){
    if (debug) console.log("setProp: " + propertyName + " = " + propertyValue);
    db().transaction(
         function (tx){
                    tx.executeSql("REPLACE INTO settings (key, value) VALUES (?, ?)", [propertyName, propertyValue]);
                }
          );
}
