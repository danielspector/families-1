module PeopleHelper

  def members_array(emails, relations)
    emails.zip(relations)
  end

  def rearrange_members(nested_array)
    aunts_and_uncles = []
    first = []
    grandparents = []
    remainder = []
    nested_array.each do |pair|
      if ["father", "mother", "wife", "husband"].include?(pair[1])
        first.push(pair)
      elsif pair[1].include?("grand")
       grandparents.push(pair)
      elsif pair[1].include?("aunt") || pair[1].include?("uncle")
        aunts_and_uncles.push(pair)
      else
        remainder.push(pair)
      end
    end
    array = [first, remainder, grandparents, aunts_and_uncles].flatten(1)
  end

  def set_relations(ordered_nested_array, admin)
    ordered_nested_array.each do |pair|
      member = pair[0]
      relation = pair[1]

      extra_relations = ["maternal_grandmother", "maternal_grandfather", "paternal_grandmother", "paternal_grandfather", "maternal_aunt", "paternal_aunt", "maternal_uncle", "paternal_uncle"]
      possible_relations = [Person::RELATIONSHIPS, extra_relations].flatten

      possible_relations.each do |possible_relation|
        relation_param = relation.gsub(/[ |-]/, '_')
        if relation_param == possible_relation
          admin.send("#{relation_param}=", member)
        end
        member.save!
        admin.save!
      end
    end
  end
end
