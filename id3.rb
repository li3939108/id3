
$training_set = [
	{'Age'=> 2, 'Sex'=> 'Male'   ,'Breed'=> 'Pomeranian' , 'Decision'=> 'N'         },
	{'Age'=> 1, 'Sex'=> 'Male'   ,'Breed'=> 'Chihuahua' , 'Decision'=> 'Y'          },
	{'Age'=> 4, 'Sex'=> 'Female' ,'Breed'=> 'Australian Shepherd' , 'Decision'=> 'Y'},
	{'Age'=> 2, 'Sex'=> 'Male'   ,'Breed'=> 'Pit Bull' , 'Decision'=> 'N'           },
	{'Age'=> 1, 'Sex'=> 'Male'   ,'Breed'=> 'Australian Shepherd' , 'Decision'=> 'Y'},
	{'Age'=> 1, 'Sex'=> 'Male'   ,'Breed'=> 'Pit Bull' , 'Decision'=> 'N'           },
	{'Age'=> 1, 'Sex'=> 'Female' ,'Breed'=> 'Australian Shepherd' , 'Decision'=> 'N'},
	{'Age'=> 1, 'Sex'=> 'Female' ,'Breed'=> 'Chihuahua' , 'Decision'=> 'Y'          },
	{'Age'=> 4, 'Sex'=> 'Female' ,'Breed'=> 'Pomeranian' , 'Decision'=> 'N'         } ,
	{'Age'=> 2, 'Sex'=> 'Male'   ,'Breed'=> 'Chihuahua' , 'Decision'=> 'Y'          },
	{'Age'=> 2, 'Sex'=> 'Female' ,'Breed'=> 'Pomeranian' , 'Decision'=> 'Y'         },
	{'Age'=> 2, 'Sex'=> 'Female' ,'Breed'=> 'Australian Shepherd' , 'Decision'=> 'N'},
]                                                                                   



class Treenode
	def initialize(type, attr_or_label, children = [])
		#types can be ":label" or ":attr"
		@type = type
		@value = attr_or_label
		@children = children
	end
	def type
		@type
	end
	def value
		@value
	end
	def children
		@children
	end
	def add_child(value, node)
		@children.push([value, node])
	end
end

def initialize_attr_values(whole_dataset)
	$attr_possible_values = {}
	whole_dataset[0].keys.each do |attr|
		$attr_possible_values[attr] = 
		whole_dataset.map{|point| point[attr] }.uniq
	end
end

def id3(dataset, target_attr, attrs)
	attrs = attrs - [target_attr]
	target_arr = dataset.map do |point|
		point[target_attr]
	end
	target_values = $attr_possible_values[ target_attr]
	occurance_counts_arr = target_values.map do |target_value|
		target_arr.count(target_value)
	end
	majority_target = target_values[occurance_counts_arr.index(occurance_counts_arr.max)]
	init_entropy = entropy(occurance_counts_arr)
	if(target_arr.uniq.length == 1)
		Treenode.new(:label, target_arr[0])
	elsif(attrs.empty?)
		Treenode.new(:label, majority_target)
	else
		gain_arr = attrs.map do |attr|
			attr_values = $attr_possible_values[attr]
			
			attr_entropy = attr_values.map{|attr_value|
				attr_target_arr = dataset.select{|point|
					point[attr] == attr_value
				}.map{|point|
					point[target_attr]
				}
				counts = attr_target_arr.length
				attr_occurance_counts_arr = target_values.map do |target_value|
					attr_target_arr.count(target_value)
				end
				print attr_occurance_counts_arr, "\n"
				(counts + 0.0) / dataset.length * entropy(attr_occurance_counts_arr)
			}.reduce(0, :+)
			init_entropy - attr_entropy
		end
		print gain_arr
		selected_attr = attrs[gain_arr.index(gain_arr.max)]
		treenode = Treenode.new(:attr, selected_attr)
		empty_attr_value_arr = $attr_possible_values[selected_attr].select{|attr_value|
			dataset.select{|point| point[selected_attr] == attr_value }.empty?
		}
		empty_attr_value_arr.each do |attr_value|
			treenode.add_child(attr_value , Treenode.new(:label, majority_target) )
		end
		#create attribute nodes
		($attr_possible_values[selected_attr] - empty_attr_value_arr).each do |attr_value|
			selected_dataset = 
			dataset.select{|point| point[selected_attr] == attr_value }
			node = id3(selected_dataset, target_attr, attrs - [selected_attr, target_attr])
			treenode.add_child(attr_value, node)
		end
		treenode
	end
end
def entropy(counts)
	sum = counts.reduce(0, :+)
	return 0 if sum == 0
	possibility = counts.map{|count| (0.0 + count) / sum }
	possibility.map{|p|
		if p == 0 then 0 
		else
			-p*Math.log2(p)
		end
	}.reduce(0, :+)
end
initialize_attr_values($training_set)
id3($training_set, 'Decision', $training_set[0].keys)
