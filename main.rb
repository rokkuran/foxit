require_relative 'kitsu'
require_relative 'db'

# require 'ruby-prof'



def get_batch_user_library id_start, id_end
  
  kitsu = KitsuAPI.new()

  docs = []
  for i in id_start..id_end
    puts i

    # TODO: add some console output to following function
    doc = kitsu.get_user_library_document(i)
    unless doc.nil?  # can't insert nil results into mongodb
      docs << doc
    end
  end
  return docs
end


def get_batch_anime id_start, id_end
  
  kitsu = KitsuAPI.new()

  docs = []
  for i in id_start..id_end
    # TODO: add some console output to following function
    doc = kitsu.get_anime_document(i)

    unless doc.nil?  # can't insert nil results into mongodb
      docs << doc
    end
  end

  return docs
end


def insert_many_docs collection, docs
  begin
    puts "inserting..."
    result = collection.insert_many(docs)
    puts "records inserted: #{result.inserted_count}"
  rescue StandardError => e
    puts "error: #{e}"
  end
  puts "complete.\n"
end


def batch_insert_docs docs, chunk_size

end


def batch_indices id_start, id_end, step_size
  a = (id_start..id_end).step(step_size).to_a
  b = a[1..a.length].map {|v| v - 1}
  b << id_end
  return a.zip(b)
end


def main_users

  db = Database.new(name: 'test')
  c = db.collection('users')

  # indices = batch_indices(1001, 2000, 50)
  indices = batch_indices(4, 20, 1)

  indices.each do |i, j|
    puts "#{i} -> #{j}"
    docs = get_batch_user_library(i, j)
    insert_many_docs(c, docs)
  end

end


def main_anime
  db = Database.new(name: 'kitsu')
  c = db.collection('anime')

  indices = batch_indices(5001, 6000, 50)
  indices.each do |i, j|
    puts "#{i} -> #{j}"
    docs = get_batch_anime(i, j)
    unless docs.empty?
      insert_many_docs(c, docs)
    end
  end
end



def main_all_library

  db = Database.new(name: 'test')
  c = db.collection('library')

  kitsu = Kitsu.new()
  docs = kitsu.get_batch_libraries_docs(501..1000)

  insert_many_docs(c, docs)

end



main_all_library()


# RubyProf.start

# main_users()
# main_anime()

# result = RubyProf.stop

# # print a flat profile to text
# printer = RubyProf::FlatPrinter.new(result)
# printer.print(STDOUT)
