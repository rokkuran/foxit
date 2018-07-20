require_relative 'kitsu'
require_relative 'db'



def get_batch_user_library id_start, id_end
  
  kitsu = KitsuAPI.new()

  docs = []
  for i in id_start..id_end
    puts i

    # TODO: add some console output to following function
    doc = kitsu.get_user_library_document(i)
    unless doc.nil?  # can't insert nil results into mongodb
      docs << kitsu.get_user_library_document(i)
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
      docs << kitsu.get_anime_document(i)
    end
  end
  return docs
end


def insert_many_docs collection, docs
  begin
    puts "\ninserting..."
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

  indices = batch_indices(1, 100, 25)

  indices.each do |i, j|
    puts "#{i} -> #{j}"
    docs = get_batch_user_library(i, j)
    insert_many_docs(c, docs)
  end

end


def main_anime
  db = Database.new(name: 'test')
  c = db.collection('anime')

  indices = batch_indices(1, 100, 25)
  indices.each do |i, j|
    puts "#{i} -> #{j}"
    docs = get_batch_anime(i, j)
    insert_many_docs(c, docs)
  end
end



# main_users()
main_anime()