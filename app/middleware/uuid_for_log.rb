# -*- encoding : utf-8 -*-
require 'uuid'

class UuidForLog
  def initialize(app, session_key = '_session_id')
    @app = app
  end

  def call(env)
    $UUID = UUID.new.generate
    ret = @app.call(env)
    ret
  end

end
