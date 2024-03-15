# frozen_string_literal: true

# Service to perform mathematical calculations.
class CalculatorService < BaseService
  INVALID_EXPRESSION = %r{[^0-9+\-*/]}
  INVALID_CHARACTERS = 'Invalid characters in the expression, only numbers, +, -, * and / supported'
  INVALID_FORMAT = 'Invalid mathematical expression format'
  ZERO_DIVISION = 'Division by zero found in the expression'

  attr_reader :tree
  private :tree

  def initialize(data:)
    super(data: data.to_s.squish)

    assert_valid_expression

    @tree = build_tree unless @error
  end

  def payload
    return error_message unless valid?

    begin
      evaluate_tree(tree)
    rescue TypeError
      error!(INVALID_FORMAT)
    rescue ZeroDivisionError
      error!(ZERO_DIVISION)
    end
  end

  private

  def assert_valid_expression
    error!(INVALID_CHARACTERS) if data.match?(INVALID_EXPRESSION)
    error!(INVALID_FORMAT) if data.blank?
  end

  def build_tree
    tokens = data.scan(%r{\d+|[+\-*/]})

    # Split numbers and operators
    numbers = tokens.select { |token| token.match(/\d+/) }.map(&:to_i)
    operators = tokens.select { |token| token.match(%r{[+\-*/]}) }

    # Build the tree
    build_tree_from_tokens(numbers, operators)
  rescue NoMethodError
    error!(INVALID_FORMAT)
  end

  # rubocop:disable Metrics/AbcSize
  def build_tree_from_tokens(numbers, operators)
    # If there are no operators, this node is the last leaf
    return TreeNode.new(numbers.last) if operators.empty?

    idx = operators.length - 1
    idx.downto(0) do |i|
      if operators[i] == '+' || operators[i] == '-'
        idx = i
        break
      end
    end

    node = TreeNode.new(operators[idx])

    # Recursively build the tree
    node.left = build_tree_from_tokens(numbers[0..idx], operators[0...idx])
    node.right = build_tree_from_tokens(numbers[idx + 1..],
                                        operators[idx + 1..])

    node
  end
  # rubocop:enable Metrics/AbcSize

  def evaluate_tree(node)
    # Base case: Node is a leaf
    return node.value if node.left.nil? && node.right.nil?

    # Recursively evaluates the left and right subtrees
    left_val = evaluate_tree(node.left)
    right_val = evaluate_tree(node.right)

    # Apply node operation
    evaluate_op(node.value, left_val, right_val)
  end

  def evaluate_op(node_value, left_val, right_val)
    case node_value
    when '+'
      left_val + right_val
    when '-'
      left_val - right_val
    when '*'
      left_val * right_val
    when '/'
      raise ZeroDivisionError if right_val&.zero?

      left_val.to_f / right_val
    end
  end
end
