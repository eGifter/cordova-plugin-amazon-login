#!/usr/bin/env node
'use strict';
var fs = require('fs-extra');

var env = "Development";
if (process.env.NODE_ENV) {
  env = process.env.NODE_ENV;
}

var configobj = JSON.parse(fs.readFileSync('config/project.json', 'utf8'));

var filename = "platforms/android/app/src/main/assets/api_key.txt";
fs.writeFileSync(filename, configobj[env].AMAZON_API_KEY, 'utf8');
