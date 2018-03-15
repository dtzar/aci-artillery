# aci-artillery
ACI-backed loadtesting solution using https://artillery.io/

Uses artillery.io and controlled data set generation.

## Requirements
- [NodeJs](https://nodejs.org/en/)
- [artillery.io](https://artillery.io)

## Install
After installing NodeJS and having access to `npm`:

`npm install -g artillery`

`npm install` to restore the packages specified in `package.json` needed by the load testing suite (here for example we added a more configurable random number generator).

## Run
`artillery run ./load-example.yml`

## Configuration
You can edit the `seed` constant in `data-generator-example.js` to control the data generation. Empty string is *full random* and specifying a seed will allow the replay of data generation.