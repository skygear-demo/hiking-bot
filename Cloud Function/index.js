let request = require('request');
let skygear = require('skygear');


let apiKey = 'e6c3834fcb64d9c4ce9ae9cbdb90497d';
let city = 'hong kong';
let url = `http://api.openweathermap.org/data/2.5/weather?q=${city}&units=metric&appid=${apiKey}`


const skygearCloud = require('skygear/cloud');



