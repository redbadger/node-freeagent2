#
#Module dependencies.
#

#
#`Strategy` constructor.
#
#The FreeAgent authentication strategy authenticates requests by delegating to
#FreeAgent using the OAuth 2.0 protocol.
#
#Applications must supply a `verify` callback which accepts an `accessToken`,
#`refreshToken` and service-specific `profile`, and then calls the `done`
#callback supplying a `user`, which should be set to `false` if the
#credentials are not valid.  If an exception occured, `err` should be set.
#
#Options:
#- `clientID`      your FreeAgent application's Client ID
#- `clientSecret`  your FreeAgent application's Client Secret
#- `callbackURL`   URL to which FreeAgent will redirect the user after granting authorization
#- `scope`         array of permission scopes to request.  valid scopes include:
#'user', 'public_repo', 'repo', 'gist', or none.
#(see http://developer.FreeAgent.com/v3/oauth/#scopes for more info)
#
#Examples:
#
#passport.use(new FreeAgentStrategy({
#clientID: '123-456-789',
#clientSecret: 'shhh-its-a-secret'
#callbackURL: 'https://www.example.net/auth/FreeAgent/callback'
#},
#function(accessToken, refreshToken, profile, done) {
#User.findOrCreate(..., function (err, user) {
#done(err, user);
#});
#}
#));
#
#@param {Object} options
#@param {Function} verify
#@api public
#
InternalOAuthError = undefined
OAuth2Strategy = undefined
Strategy = undefined
util = undefined
Strategy = (options, verify) ->
  options = options or {}
  options.authorizationURL = options.authorizationURL or "https://api.freeagent.com/v2/approve_app"
  options.tokenURL = options.tokenURL or "https://api.freeagent.com/v2/token_endpoint"
  options.scopeSeparator = options.scopeSeparator or ","
  OAuth2Strategy.call this, options, verify
  @name = "freeagent"

util = require("util")
OAuth2Strategy = require("passport-oauth").OAuth2Strategy
InternalOAuthError = require("passport-oauth").InternalOAuthError

#
#Inherit from `OAuth2Strategy`.
#
util.inherits Strategy, OAuth2Strategy

#
#Retrieve user profile from FreeAgent.
#
#This function constructs a normalized profile, with the following properties:
#
#- `provider`         always set to `FreeAgent`
#- `id`               the user's FreeAgent ID
#- `username`         the user's FreeAgent username
#- `displayName`      the user's full name
#- `profileUrl`       the URL of the profile for the user on FreeAgent
#- `emails`           the user's email addresses
#
#@param {String} accessToken
#@param {Function} done
#@api protected
#
Strategy::userProfile = (accessToken, done) ->
  @_oauth2._request "GET", "https://api.freeagent.com/v2/users/me",
    "User-Agent": "passport-freeagent2"
    "Authorization": "Bearer #{accessToken}"
  , null, accessToken, (err, body, res) ->
    json = undefined
    return done(new InternalOAuthError("failed to fetch user profile", err))  if err
    try
      json = JSON.parse(body)
      json.provider = "freeagent"
      return done(null, json.user)
    catch e
      return done(e)

#
#Expose `Strategy`.
#
module.exports = Strategy