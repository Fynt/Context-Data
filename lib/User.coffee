Model = require './Model'


module.exports = class User extends Model

  table_name: 'user'

  find_by_email: (email, callback) ->
    q = @table().where 'email', email
    .limit 1

    q.exec (error, results) =>
      #TODO Finish implementing this
      callback error, @create()
