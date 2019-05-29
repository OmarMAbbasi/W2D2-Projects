require 'sqlite3'
require 'singleton'
require 'byebug'

class QDB < SQLite3::Database
  include Singleton
  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class User
  attr_accessor :fname, :lname
  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def self.find_by_id(id)
    user = QDB.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    return nil unless user.length > 0
    User.new(user.first)
  end

  def self.find_by_name(fname,lname)
    user = QDB.instance.execute(<<-SQL, fname, lname)
      SELECT DISTINCT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    return nil unless user.length > 0
    User.new(user.first)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end
end

class Question
  attr_accessor :title, :body, :author_id
  
  def self.find_by_author_id(author_id)
    question = QDB.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
    SQL
    return nil if question.length == 0
    questions = []
    question.map {|question| questions << Question.new(question) }
    return questions
  end

  def self.find_by_id(id)
    question = QDB.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    
    SQL
    return nil if question.length == 0
    Question.new(question.first)
  end


  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  def author
    User.find_by_id(@author_id)
  end

  def replies
    Reply.find_by_question_id(@id)
  end
end



class Reply
  attr_accessor :body, :user_id, :question_id, :reply_id

  def self.find_by_user_id(user_id)
    reply = QDB.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    return nil if reply.length == 0
    replies = []
    reply.map {|reply| replies << Reply.new(reply) }
    return replies
  end

  def self.find_by_question_id(question_id)
    reply = QDB.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    return nil if reply.length == 0
    replies = []
    reply.map {|r| replies << Reply.new(r) }
    return replies
  end

  def self.find_by_id(id)
    reply = QDB.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    return nil if reply.length == 0
    return Reply.new(reply.first)
  end

  def self.find_by_reply_id(reply_id)
    reply = QDB.instance.execute(<<-SQL, reply_id)
      SELECT
        *
      FROM
        replies
      WHERE
        reply_id = ?
    SQL
    return nil if reply.length == 0
    replies = []
    reply.map {|r| replies << Reply.new(r) }
    return replies
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @body = options['body']
    @reply_id = options['reply_id']
    @user_id = options['user_id']
  end

  def author
    User.find_by_id(@user_id)
  end

  def question
    Question.find_by_id(@question_id)
  end

  def parent_reply
    Reply.find_by_id(@reply_id)
  end

  def child_replies
    Reply.find_by_reply_id(@id)
  end


end

class QuestionLikes
  attr_accessor :user_id, :question_id

  def initialize(options)
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
  

end

class QuestionFollows
  attr_accessor :user_id, :question_id

  def initialize(options)
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def self.followers_for_question_id(question_id)
    followers = QDB.instance.execute(<<-SQL, question_id)
      SELECT DISTINCT
        user_id
      FROM
        questions
      JOIN
        question_follows ON questions.id = question_follows.questions_id
      WHERE
        question_id = ?
    SQL
    followers.map { |id| User.find_by_id(id)}
  end 

  def followed_questions_for_user_id(user_id)
    followed = QDB.instance.execute(<<-SQL, user_id)

    SQL
    Question.find_by_author_id(user_id)
  end
  
end

u = User.new({'id' =>  2 , 'fname' => 'Omar', 'lname' => 'Abbasi'})
u = User.new({'id' =>  1 , 'fname' => 'Alex', 'lname' => 'Yang'})
q = Question.new({'id' => 1, 'title' => 'Is boolean?', 'body' => 'Is like supposed to be a boolean?', 'author_id' => 1})
r = Reply.new({'id' => 3, 'body' => 'Freaky Fast', 'question_id' => 3, 'user_id' => 3})