Model = require './Model'


module.exports = class User extends Model

  table_name: 'user'

  find_by_email: (email, callback) ->
    q = @table.where 'email', email
    console.log q.toString()

    q.exec callback
