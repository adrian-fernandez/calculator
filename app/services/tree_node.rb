# frozen_string_literal: true

# Auxiliar class used to store nodes for a tree structure
class TreeNode
  attr_accessor :value, :left, :right

  def initialize(value)
    @value = value
    @left = nil
    @right = nil
  end
end
