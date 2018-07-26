class Helpers
  def to_hash
    hash = {}
    instance_variables.each {|x| hash[x.to_s.delete("@")] = instance_variable_get(x)}
    hash
  end

  def objects_to_hash obj_array
    docs = []
    obj_array.map { |obj| docs << obj.to_hash }
    docs
  end
end