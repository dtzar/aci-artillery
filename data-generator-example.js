'use strict';

module.exports = {
  generateRandomData
};

const rand = require('random-seed');

/* 
Set the Seed for replaying same datasets
Empty string is equivalent to no seed ('fully' random).
*/
const seed = '';

// Set the proper RNG
let rng;
if (seed === '') {
  rng = rand.create();
} else {
  rng = rand.create(seed);
}

/**
 * Generates sets of data that can be controlled and replayed.
 */
function generateRandomData(userContext, events, done) {
  
  // parameter01 has let's say 5 possible fixed values
  let parameter01_possible_values = [
    "p1",
    "p2",
    "p3",
    "p4",
    "p5"
  ];
  let parameter01 = parameter01_possible_values[rng(parameter01_possible_values.length)];

  // parameter02 starts with a fixed prefix and can have let's say 5000 possible values
  let parameter02 = `parameter02_${rng(5000)}`;
   
  // parameter03_subparam02 has 20000 possible values between 1 and 20000
  let parameter03_subparam02 = rng(20000) + 1   
  
  // Add variables to virtual user's context to be accessible in artillery.io context:
  userContext.vars.parameter01 = parameter01;
  userContext.vars.parameter02 = parameter02;
  userContext.vars.parameter03_subparam02 = parameter03_subparam02;
  
  return done();
}